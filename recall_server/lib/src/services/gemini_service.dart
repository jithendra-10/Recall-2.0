// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

/// Gemini AI Service for summarization and embeddings
class GeminiService {
  static final _env = DotEnv(includePlatformEnvironment: true)..load();
  static String get _apiKey => _env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Analyze email content using strict logic and return structured data
  static Future<Map<String, dynamic>?> analyzeEmail(
    String content,
    String sender,
    String recipient,
    bool isSent,
  ) async {
    final prompt =
        '''You are the intelligence layer of "RECALL", a personal relationship memory assistant.
Your goal is to mirror the user's social brain, not their inbox.

*** CORE PHILOSOPHY ***
RECALL is a relationship memory, not an inbox.
We only care about emails that help answer:
1. "Who is this?" (Introductions, Context)
2. "What did we discuss?" (Conversations, Decisions, Emotions)
3. "What should I do next?" (Actionable follow-ups, Promises)

If an email does not contribute to these questions, it MUST be ignored.

*** FILTERING RULES (STRICT) ***
Set "ignore": true if the email falls into these categories:
- AUTOMATED: Receipts, OTPs, Statements, Alerts, Confirmations.
- PROMOTIONAL: Newsletters, Marketing, Offers, Cold Sales (unless highly relevant B2B).
- SOCIAL: "Someone viewed your profile", "New login", "Tagged in photo".
- ONE-WAY: No-reply updates that require no human action or mental note.
- TRIVIAL: "Thanks", "Ok", "Received" (unless it confirms a major decision).

*** KEEP RULES ***
Set "ignore": false ONLY if the email is:
- HUMAN-TO-HUMAN: Personal, conversational, or professional 1:1 interaction.
- SEMI-HUMAN: Recruiters, Founders, Clients, Professors, Teammates.
- ACTIONABLE: Requires a reply, decision, or meeting.
- RELATIONSHIP-BUILDING: Changes the state of a relationship (e.g., apologies, congratulations, life updates).

*** OUTPUT INSTRUCTIONS ***
Return a valid JSON object.
- summary: A concise, neutral memory of the interaction (e.g., "John confirmed the meeting for Tuesday at 2 PM").
- intent_tags: [List of tags e.g., "meeting", "hiring", "update", "decision", "personal"].
- needs_follow_up: true if the user needs to reply or act.

Input Metadata:
From: $sender
To: $recipient
Direction: ${isSent ? 'Sent' : 'Received'}

Input Content:
$content
''';

    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.1, // Lower temperature for stricter adherence
            'maxOutputTokens': 300,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text != null) {
          try {
            // Clean markdown if present (though responseMimeType should prevent it)
            final cleanText = text
                .replaceAll('```json', '')
                .replaceAll('```', '')
                .trim();
            final jsonResult = jsonDecode(cleanText);

            if (jsonResult['ignore'] == true) {
              return null;
            }

            return jsonResult;
          } catch (e) {
            print('Gemini JSON parsing error: $e');
            return null;
          }
        }
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Gemini analysis error: $e');
    }

    return null;
  }

  /// Generate vector embedding for text
  static Future<List<double>> generateEmbedding(String text) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/text-embedding-004:embedContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'models/text-embedding-004',
          'content': {
            'parts': [
              {'text': text},
            ],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embeddings = data['embedding']?['values'] as List<dynamic>?;
        if (embeddings != null) {
          return embeddings.map((e) => (e as num).toDouble()).toList();
        }
      } else {
        print(
          'Gemini embedding error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Gemini embedding error: $e');
    }

    // Return zero vector as fallback (768 dimensions)
    return List.filled(768, 0.0);
  }

  /// Generate a draft email based on context
  static Future<String> generateDraftEmail({
    required String contactName,
    required String lastTopic,
    required int daysSilent,
    required List<String> recentInteractions,
  }) async {
    final context = recentInteractions.take(3).join('\n');

    final prompt =
        '''Generate a friendly, professional catch-up email to reconnect with someone. Keep it natural and personal.

Contact: $contactName
Days since last contact: $daysSilent days
Last topic discussed: $lastTopic
Recent conversation snippets:
$context

Write a short email (3-4 sentences) that:
1. References something specific from your history
2. Feels genuine, not templated
3. Has a clear call-to-action (coffee, call, etc.)

Email:''';

    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text?.trim() ?? _fallbackDraft(contactName, lastTopic);
      }
    } catch (e) {
      print('Gemini draft error: $e');
    }

    return _fallbackDraft(contactName, lastTopic);
  }

  static String _fallbackDraft(String name, String topic) {
    return '''Hi $name,

I hope you're doing well! I was just thinking about $topic and it reminded me of you.

Would love to catch up soon - are you free for a quick coffee or call this week?

Best regards''';
  }

  /// Generate RAG response from retrieved context
  static Future<String> generateRagResponse({
    required String query,
    required List<String> retrievedContexts,
  }) async {
    if (retrievedContexts.isEmpty) {
      return "I don't have any relevant information about that in your communication history.";
    }

    final context = retrievedContexts.join('\n\n');

    final prompt =
        '''You are a personal relationship assistant with access to the user's email history. Answer the question based ONLY on the provided context. If the context doesn't contain enough information, say so honestly.

Context from email history:
$context

User question: $query

Answer concisely and helpfully:''';

    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 500,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text?.trim() ?? 'Sorry, I could not generate a response.';
      }
    } catch (e) {
      print('Gemini RAG error: $e');
    }

    return 'Sorry, I encountered an error processing your request.';
  }
}
