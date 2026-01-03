import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:dotenv/dotenv.dart';

/// Gemini AI Service for summarization and embeddings
class GeminiService {
  static final _env = DotEnv(includePlatformEnvironment: true)..load();
  static String get _apiKey => _env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  /// Analyze email content using strict logic and return structured data
  static Future<Map<String, dynamic>?> analyzeEmail(String content, String sender, String recipient, bool isSent) async {
    final prompt = '''You are the intelligence layer of an application that reads a user's Gmail in real time.
Your task is to process raw Gmail messages and convert them into meaningful, structured memory for the app.

Rules:
1. You must read only real email content obtained dynamically via Gmail API.
2. Never invent, assume, or generate static or demo data.
3. Every output must be directly derived from actual email content.
4. If an email has no meaningful human intent, you must ignore it completely (set ignore=true).

Email Filtering Logic:
- Identify whether the email is human-written or automated.
- Ignore newsletters, promotions, system notifications, receipts, job feeds, alerts, marketing emails, and bulk mail.
- Process only emails that contain personal, conversational, professional, or intentional human communication.

Content Understanding:
- Read the full email body and subject.
- Detect intent such as: discussion, follow-up, request, commitment, decision, reminder, emotional context, or planning.
- Identify who the interaction is with and the direction of communication (sent or received).
- Detect any promises, deadlines, or implied future actions.

Summarization Rules:
- Summaries must be short, factual, and neutral.
- Do not rewrite the email.
- Do not add interpretation beyond what is explicitly or clearly implied.
- Capture only what is important for remembering later.
- Remove greetings, signatures, links, formatting, and repeated content.
- Never include promotional or decorative text.

Input Metadata:
From: $sender
To: $recipient
Direction: ${isSent ? 'Sent' : 'Received'}

Input Content:
$content

Output Structure (JSON):
Return a valid JSON object. Do not include markdown code blocks.
{
  "ignore": boolean,
  "summary": "One concise memory summary (if not ignored)",
  "intent_tags": ["string", "string"],
  "needs_follow_up": boolean
}
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1, // Lower temperature for stricter adherence
            'maxOutputTokens': 300,
            'responseMimeType': 'application/json',
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null) {
          try {
            // Clean markdown if present (though responseMimeType should prevent it)
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
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
        Uri.parse('$_baseUrl/models/text-embedding-004:embedContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'models/text-embedding-004',
          'content': {
            'parts': [
              {'text': text}
            ]
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embeddings = data['embedding']?['values'] as List<dynamic>?;
        if (embeddings != null) {
          return embeddings.map((e) => (e as num).toDouble()).toList();
        }
      } else {
        print('Gemini embedding error: ${response.statusCode} - ${response.body}');
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
    
    final prompt = '''Generate a friendly, professional catch-up email to reconnect with someone. Keep it natural and personal.

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
        Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300,
          }
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
    
    final prompt = '''You are a personal relationship assistant with access to the user's email history. Answer the question based ONLY on the provided context. If the context doesn't contain enough information, say so honestly.

Context from email history:
$context

User question: $query

Answer concisely and helpfully:''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 500,
          }
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
