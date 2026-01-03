import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/core/ip_config.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
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
      // WAIT for session to initialize if starting up
      int attempts = 0;
      while (sessionManager.signedInUser == null && attempts < 5) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }

      // Use explicit userId and unauthenticated client to bypass JWT validation issues with legacy keys
      // Get current user ID from session
      final userId = sessionManager.signedInUser?.id;
      
      // Create temp client without auth key manager
      // This ensures we don't send the "Invalid" JWT token that causes the server to reject the request
      final tempClient = Client(
        'http://$serverIpAddress:8080/',
        authenticationKeyManager: null, // Explicitly null
      )..connectivityMonitor = FlutterConnectivityMonitor();

      final data = await tempClient.dashboard.getDashboardData(userId: userId);
      state = DashboardState(
        isLoading: false,
        data: data,
      );

      // POLL: If syncing, fetch again after delay to update status
      if (data.isSyncing) {
        Future.delayed(const Duration(seconds: 3), () {
          fetchDashboardData();
        });
      }
    } catch (e) {
      print('Dashboard fetch error: $e');
      state = DashboardState(
        isLoading: false,
        error: 'Failed to load dashboard data',
      );
    }
  }

  Future<bool> sendEmail(String to, String subject, String body) async {
    try {
      // Use authenticated client
      final success = await client.email.sendEmail(to, subject, body);
      return success;
    } catch (e) {
      print('Send email error: $e');
      return false;
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
final dashboardProvider = StateNotifierProvider.autoDispose<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

/// Contacts list provider
final contactsProvider = FutureProvider.autoDispose<List<Contact>>((ref) async {
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
final chatProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

/// Draft email provider
final draftEmailProvider = FutureProvider.family<String, int>((ref, contactId) async {
  return await client.recall.generateDraftEmail(contactId);
});
