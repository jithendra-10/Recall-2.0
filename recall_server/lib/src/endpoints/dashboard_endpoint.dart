import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';

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

  /// Trigger manual sync
  Future<void> triggerSync(Session session) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return; // Silently skip if not authenticated
    final userId = int.parse(userIdentifier);

    session.log('Manual sync triggered for user $userId', level: LogLevel.info);
    
    final userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (userConfig == null || userConfig.googleRefreshToken == null) {
      session.log('No Gmail connection configured for user $userId', level: LogLevel.warning);
      return;
    }

    userConfig.lastSyncTime = DateTime.now().toUtc();
    await UserConfig.db.updateRow(session, userConfig);
  }

  /// Exchange auth code for refresh token and store it
  Future<bool> exchangeAndStoreGmailToken(Session session, String authCode) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return false;
    final userId = int.parse(userIdentifier);

    try {
      // 1. Load Client Secret
      final secretFile = File('config/google_client_secret.json');
      if (!await secretFile.exists()) {
        session.log('Secret file not found', level: LogLevel.error);
        return false;
      }
      
      final secretJson = jsonDecode(await secretFile.readAsString());
      final webConfig = secretJson['web'];
      final clientId = webConfig['client_id'];
      final clientSecret = webConfig['client_secret'];
      
      // Use the first redirect URI from config (usually the correct one)
      // For mobile apps using serverAuthCode, the redirect URI often needs to exactly match 
      // what was registered or sometimes be null/'postmessage'. 
      // We try the registered one first.
      /*
      final redirectUri = (webConfig['redirect_uris'] as List).isNotEmpty 
          ? (webConfig['redirect_uris'] as List).first 
          : null;
      */
      // For Native Android/iOS Google Sign In, the serverAuthCode is generated without a redirect URI.
      // Passing one during exchange causes a mismatch error. We must pass null.
      const String? redirectUri = null;

      session.log('Exchanging code for user $userId with redirect: $redirectUri', level: LogLevel.info);

      // 2. Exchange Code
      final client = http.Client();
      try {
        final credentials = await obtainAccessCredentialsViaCodeExchange(
          client,
          ClientId(clientId, clientSecret),
          authCode,
        );

        final refreshToken = credentials.refreshToken;
        if (refreshToken == null) {
          session.log('No refresh token returned. User might need to revoke access.', level: LogLevel.warning);
          // Only sync if we have a token or valid credentials, but we need refresh token for offline
          // If null, it means we were already approved but not "offline" or already granted?
          // We can't proceed without it for background sync.
          return false;
        }

        // 3. Store Token
        await _storeRefreshTokenInternal(session, userId, refreshToken);
        session.log('Refresh token stored successfully', level: LogLevel.info);
        
        // Trigger immediate sync
        await triggerSync(session);
        return true;
        
      } finally {
        client.close();
      }
    } catch (e, stack) {
      session.log('Token exchange error: $e', level: LogLevel.error, stackTrace: stack);
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
