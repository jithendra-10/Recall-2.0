import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';

class RecallEndpoint extends Endpoint {
  // Don't require login - we'll handle gracefully
  @override
  bool get requireLogin => false;

  /// Ask RECALL - RAG-powered question answering with Gemini
  Future<ChatMessage> askRecall(Session session, String query) async {
    try {
      // Try to get authenticated user, fall back to test user
      final userIdentifier = session.authenticated?.userIdentifier;
      if (userIdentifier == null) {
        return ChatMessage(
          role: 'assistant',
          content: "Please sign in to ask questions.",
          timestamp: DateTime.now().toUtc(),
          sources: [],
        );
      }
      final userId = int.parse(userIdentifier);

      session.log('Ask RECALL query: $query', level: LogLevel.info);

      // Get all interactions for this user
      final interactions = await Interaction.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
        include: Interaction.include(contact: Contact.include()),
        orderBy: (t) => t.date,
        orderDescending: true,
        limit: 100,
      );

      if (interactions.isEmpty) {
        return ChatMessage(
          role: 'assistant',
          content:
              "I don't have any communication history to search through yet. Once your Gmail syncs, I'll be able to answer questions about your contacts.",
          timestamp: DateTime.now().toUtc(),
          sources: [],
        );
      }

      // Keyword search for relevant interactions
      final queryLower = query.toLowerCase();

      final matches = interactions
          .where((i) {
            final snippet = i.snippet.toLowerCase();
            final contactName = (i.contact?.name ?? '').toLowerCase();
            final contactEmail = (i.contact?.email ?? '').toLowerCase();

            return snippet.contains(queryLower) ||
                contactName.contains(queryLower) ||
                contactEmail.contains(queryLower) ||
                queryLower
                    .split(' ')
                    .any(
                      (word) =>
                          word.length > 3 &&
                          (snippet.contains(word) ||
                              contactName.contains(word)),
                    );
          })
          .take(10)
          .toList();

      if (matches.isEmpty) {
        return ChatMessage(
          role: 'assistant',
          content:
              "I couldn't find any relevant information about that in your communication history. Try asking about specific contacts or topics from your emails.",
          timestamp: DateTime.now().toUtc(),
          sources: [],
        );
      }

      // Build context for RAG
      final contexts = matches.map((m) {
        final contactName = m.contact?.name ?? m.contact?.email ?? 'Unknown';
        final dateStr = _formatDate(m.date);
        return '[$dateStr] $contactName: ${m.snippet}';
      }).toList();

      // Generate response using Gemini
      final response = await GeminiService.generateRagResponse(
        query: query,
        retrievedContexts: contexts,
      );

      // Build sources list
      final sources = matches
          .map((m) {
            final contactName =
                m.contact?.name ?? m.contact?.email ?? 'Unknown';
            return '$contactName (${_formatDate(m.date)})';
          })
          .toSet()
          .take(5)
          .toList();

      return ChatMessage(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now().toUtc(),
        sources: sources,
      );
    } catch (e, stack) {
      session.log(
        'Ask RECALL error: $e',
        level: LogLevel.error,
        stackTrace: stack,
      );
      return ChatMessage(
        role: 'assistant',
        content:
            "I encountered an error processing your request. Please try again.",
        timestamp: DateTime.now().toUtc(),
        sources: [],
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${diff.inDays ~/ 30} months ago';
  }

  /// Generate AI draft email for a contact using Gemini
  Future<String> generateDraftEmail(Session session, int contactId) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return 'Please sign in to generate drafts.';
    final userId = int.parse(userIdentifier);

    final contact = await Contact.db.findById(session, contactId);
    if (contact == null || contact.ownerId != userId) {
      return 'Contact not found.';
    }

    final interactions = await Interaction.db.find(
      session,
      where: (t) => t.ownerId.equals(userId) & t.contactId.equals(contactId),
      orderBy: (t) => t.date,
      orderDescending: true,
      limit: 5,
    );

    final contactName = contact.name ?? 'there';
    final daysSilent = contact.lastContacted != null
        ? DateTime.now().toUtc().difference(contact.lastContacted!).inDays
        : 30;
    final lastTopic = interactions.isNotEmpty
        ? interactions.first.snippet
        : 'our last conversation';
    final recentSnippets = interactions.map((i) => i.snippet).toList();

    final draft = await GeminiService.generateDraftEmail(
      contactName: contactName,
      lastTopic: lastTopic,
      daysSilent: daysSilent,
      recentInteractions: recentSnippets,
    );

    return draft;
  }
}
