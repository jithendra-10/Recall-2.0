import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/main.dart';

/// Dashboard data state
class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardData? data;

  DashboardState({
    this.isLoading = true,
    this.error,
    this.data,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardData? data,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

/// Dashboard notifier that fetches and manages dashboard data
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final data = await client.dashboard.getDashboardData();
      state = DashboardState(
        isLoading: false,
        data: data,
      );
    } catch (e) {
      print('Dashboard fetch error: $e');
      state = DashboardState(
        isLoading: false,
        error: 'Failed to load dashboard data',
      );
    }
  }

  Future<void> refresh() async {
    await fetchDashboardData();
  }

  Future<void> triggerSync() async {
    try {
      await client.dashboard.triggerSync();
      await fetchDashboardData();
    } catch (e) {
      print('Sync error: $e');
    }
  }
}

/// Main dashboard provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

/// Contacts list provider
final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  try {
    return await client.dashboard.getContacts();
  } catch (e) {
    print('Contacts fetch error: $e');
    return [];
  }
});

/// Chat state for Ask RECALL
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Chat notifier for Ask RECALL
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  Future<void> sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      role: 'user',
      content: query,
      timestamp: DateTime.now().toUtc(),
    );
    
    state = ChatState(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final response = await client.recall.askRecall(query);
      state = ChatState(
        messages: [...state.messages, response],
        isLoading: false,
      );
    } catch (e) {
      print('Chat error: $e');
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
        timestamp: DateTime.now().toUtc(),
      );
      state = ChatState(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = ChatState();
  }
}

/// Chat provider for Ask RECALL
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

/// Draft email provider
final draftEmailProvider = FutureProvider.family<String, int>((ref, contactId) async {
  return await client.recall.generateDraftEmail(contactId);
});
