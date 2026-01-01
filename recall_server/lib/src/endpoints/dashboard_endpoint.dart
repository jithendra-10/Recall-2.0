import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';
import '../future_calls/gmail_sync_future_call.dart';

class DashboardEndpoint extends Endpoint {
  // Don't require login - we'll check manually or use demo data
  @override
  bool get requireLogin => false;

  /// Get complete dashboard data
  Future<DashboardData> getDashboardData(Session session) async {
    try {
      // Try to get authenticated user, fall back to test user
      final userIdentifier = session.authenticated?.userIdentifier;
      final userId = userIdentifier != null ? int.parse(userIdentifier) : 1; // Use test user if not authenticated

      // Get user config for sync status
      final userConfig = await UserConfig.db.findFirstRow(
        session,
        where: (t) => t.userInfoId.equals(userId),
      );

      // Get top nudge contact (lowest health score)
      final nudgeContact = await Contact.db.findFirstRow(
        session,
        where: (t) => t.ownerId.equals(userId),
        orderBy: (t) => t.healthScore,
        orderDescending: false,
      );

      // Calculate days silent for nudge contact
      int? nudgeDaysSilent;
      String? nudgeLastTopic;
      if (nudgeContact != null && nudgeContact.lastContacted != null) {
        nudgeDaysSilent = DateTime.now().toUtc().difference(nudgeContact.lastContacted!).inDays;
        
        // Get last interaction topic
        final lastInteraction = await Interaction.db.findFirstRow(
          session,
          where: (t) => t.ownerId.equals(userId) & t.contactId.equals(nudgeContact.id!),
          orderBy: (t) => t.date,
          orderDescending: true,
        );
        nudgeLastTopic = lastInteraction?.snippet;
      }

      // Get recent interactions for memory feed
      final recentInteractionsRaw = await Interaction.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
        orderBy: (t) => t.date,
        orderDescending: true,
        limit: 10,
        include: Interaction.include(contact: Contact.include()),
      );

      final recentInteractions = recentInteractionsRaw.map((i) => InteractionSummary(
        contactName: i.contact?.name ?? i.contact?.email ?? 'Unknown',
        contactEmail: i.contact?.email ?? '',
        summary: i.snippet,
        timestamp: i.date,
        type: i.type,
      )).toList();

      // Get top contacts by health score
      final topContacts = await Contact.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
        orderBy: (t) => t.healthScore,
        orderDescending: true,
        limit: 5,
      );

      // Count total contacts and drifting
      final allContacts = await Contact.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
      );
      final totalContacts = allContacts.length;
      final driftingCount = allContacts.where((c) => c.healthScore < 50).length;

      return DashboardData(
        lastSyncTime: userConfig?.lastSyncTime,
        isSyncing: false,
        nudgeContact: nudgeContact,
        nudgeDaysSilent: nudgeDaysSilent,
        nudgeLastTopic: nudgeLastTopic,
        recentInteractions: recentInteractions,
        topContacts: topContacts,
        totalContacts: totalContacts,
        driftingCount: driftingCount,
      );
    } catch (e, stack) {
      session.log('Dashboard error: $e', level: LogLevel.error, stackTrace: stack);
      // Return empty state on error
      return DashboardData(
        lastSyncTime: null,
        isSyncing: false,
        nudgeContact: null,
        nudgeDaysSilent: null,
        nudgeLastTopic: null,
        recentInteractions: [],
        topContacts: [],
        totalContacts: 0,
        driftingCount: 0,
      );
    }
  }

  /// Get all contacts for the user
  Future<List<Contact>> getContacts(Session session) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return [];
    final userId = int.parse(userIdentifier);

    return Contact.db.find(
      session,
      where: (t) => t.ownerId.equals(userId),
      orderBy: (t) => t.healthScore,
      orderDescending: true,
    );
  }

  /// Get interactions for a specific contact
  Future<List<InteractionSummary>> getContactInteractions(
    Session session,
    int contactId,
  ) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return [];
    final userId = int.parse(userIdentifier);

    final interactions = await Interaction.db.find(
      session,
      where: (t) => t.ownerId.equals(userId) & t.contactId.equals(contactId),
      orderBy: (t) => t.date,
      orderDescending: true,
      limit: 20,
      include: Interaction.include(contact: Contact.include()),
    );

    return interactions.map((i) => InteractionSummary(
      contactName: i.contact?.name ?? i.contact?.email ?? 'Unknown',
      contactEmail: i.contact?.email ?? '',
      summary: i.snippet,
      timestamp: i.date,
      type: i.type,
    )).toList();
  }

  /// Trigger manual sync for a user
  /// If userId is provided, use it directly (for unauthenticated contexts)
  /// Otherwise try to get from session
  Future<void> triggerSync(Session session, {int? userId}) async {
    // Get userId from parameter or session
    int? targetUserId = userId;
    if (targetUserId == null) {
      final userIdentifier = session.authenticated?.userIdentifier;
      if (userIdentifier == null) {
        session.log('triggerSync: No userId and no authenticated session', level: LogLevel.warning);
        return;
      }
      targetUserId = int.parse(userIdentifier);
    }

    session.log('triggerSync: Starting for userId=$targetUserId', level: LogLevel.info);
    
    final userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(targetUserId!),
    );

    if (userConfig == null || userConfig.googleRefreshToken == null) {
      session.log('triggerSync: No Gmail connection for userId=$targetUserId', level: LogLevel.warning);
      return;
    }

    // Actually invoke the Gmail sync future call
    try {
      final gmailSync = GmailSyncFutureCall();
      await gmailSync.invoke(session, null);
      session.log('triggerSync: Gmail sync completed for userId=$targetUserId', level: LogLevel.info);
    } catch (e, stack) {
      session.log('triggerSync: Gmail sync failed: $e', level: LogLevel.error, stackTrace: stack);
    }
  }

  /// Exchange auth code for refresh token and store it
  /// Returns detailed error info on failure for debugging
  Future<bool> exchangeAndStoreGmailToken(Session session, String authCode, int userId) async {
    if (userId <= 0) {
      session.log('exchangeAndStoreGmailToken: Invalid userId=$userId', level: LogLevel.error);
      return false;
    }

    session.log('exchangeAndStoreGmailToken: Starting for userId=$userId, authCode length=${authCode.length}', level: LogLevel.info);

    try {
      // 1. Load Client Secret
      final secretFile = File('config/google_client_secret.json');
      if (!await secretFile.exists()) {
        session.log('exchangeAndStoreGmailToken: Secret file not found', level: LogLevel.error);
        return false;
      }
      
      final secretJson = jsonDecode(await secretFile.readAsString());
      final webConfig = secretJson['web'];
      final clientId = webConfig['client_id'] as String;
      final clientSecret = webConfig['client_secret'] as String;
      
      session.log('exchangeAndStoreGmailToken: Using clientId=${clientId.substring(0, 20)}...', level: LogLevel.info);

      // 2. Manual OAuth token exchange with detailed error logging
      final httpClient = http.Client();
      try {
        final response = await httpClient.post(
          Uri.parse('https://oauth2.googleapis.com/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'code': authCode,
            'client_id': clientId,
            'client_secret': clientSecret,
            'grant_type': 'authorization_code',
            // No redirect_uri for native Android serverAuthCode flows
          },
        );

        session.log('exchangeAndStoreGmailToken: Google response status=${response.statusCode}', level: LogLevel.info);
        
        if (response.statusCode != 200) {
          // Log the full error for debugging
          session.log('exchangeAndStoreGmailToken: FAILED - ${response.body}', level: LogLevel.error);
          
          // Parse Google's error response
          try {
            final errorJson = jsonDecode(response.body);
            final error = errorJson['error'] ?? 'unknown';
            final errorDesc = errorJson['error_description'] ?? 'no description';
            session.log('exchangeAndStoreGmailToken: Error=$error, Description=$errorDesc', level: LogLevel.error);
            
            // Common errors:
            // - "invalid_grant" = code already used or expired
            // - "redirect_uri_mismatch" = wrong redirect URI
            // - "invalid_client" = wrong client credentials
          } catch (_) {}
          
          return false;
        }

        final tokenData = jsonDecode(response.body);
        final refreshToken = tokenData['refresh_token'] as String?;
        final accessToken = tokenData['access_token'] as String?;
        final expiresIn = tokenData['expires_in'];

        session.log('exchangeAndStoreGmailToken: accessToken=${accessToken != null}, refreshToken=${refreshToken != null}, expiresIn=$expiresIn', level: LogLevel.info);

        if (refreshToken == null) {
          session.log(
            'exchangeAndStoreGmailToken: No refresh_token returned! '
            'This happens when the user has previously authorized the app. '
            'User should revoke access at https://myaccount.google.com/permissions and try again.',
            level: LogLevel.warning
          );
          return false;
        }

        // 3. Store Token
        await _storeRefreshTokenInternal(session, userId, refreshToken);
        session.log('exchangeAndStoreGmailToken: SUCCESS - Token stored for userId=$userId', level: LogLevel.info);
        
        // 4. Trigger immediate sync
        try {
          await triggerSync(session, userId: userId);
        } catch (e) {
          session.log('exchangeAndStoreGmailToken: Sync trigger failed but token stored: $e', level: LogLevel.warning);
        }
        
        return true;
        
      } finally {
        httpClient.close();
      }
    } catch (e, stack) {
      session.log('exchangeAndStoreGmailToken: Exception - $e', level: LogLevel.error, stackTrace: stack);
      return false;
    }
  }


  /// Internal helper to store token
  Future<void> _storeRefreshTokenInternal(Session session, int userId, String refreshToken) async {
    var userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (userConfig == null) {
      userConfig = UserConfig(
        userInfoId: userId,
        googleRefreshToken: refreshToken,
        lastSyncTime: null, // Reset sync time to trigger fresh sync
      );
      await UserConfig.db.insertRow(session, userConfig);
    } else {
      userConfig.googleRefreshToken = refreshToken;
      // Don't update lastSyncTime here, let triggerSync or the sync job handle it
      await UserConfig.db.updateRow(session, userConfig);
    }
  }

  /// Store refresh token manually (legacy/debug)
  Future<void> storeRefreshToken(Session session, String refreshToken) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return;
    await _storeRefreshTokenInternal(session, int.parse(userIdentifier), refreshToken);
  }

  Future<SetupStatus> getSetupStatus(Session session) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    final userId = userIdentifier != null ? int.parse(userIdentifier) : 1;

    final userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    final interactionCount = await Interaction.db.count(
      session,
      where: (t) => t.ownerId.equals(userId),
    );

    return SetupStatus(
      hasToken: userConfig?.googleRefreshToken != null,
      emailCount: 0, 
      interactionCount: interactionCount,
      isSyncing: userConfig?.lastSyncTime == null && userConfig?.googleRefreshToken != null,
    );
  }
}
