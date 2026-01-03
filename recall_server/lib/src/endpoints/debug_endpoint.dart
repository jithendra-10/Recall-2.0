import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Debug endpoint for testing - to be removed in production
class DebugEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Seed test data for dashboard verification
  Future<String> seedTestData(Session session) async {
    session.log('Seeding test data...', level: LogLevel.info);

    try {
      // Create a test user config (user ID 1)
      const testUserId = 1;

      // Check if already has data
      final existingContacts = await Contact.db.find(
        session,
        where: (t) => t.ownerId.equals(testUserId),
      );

      if (existingContacts.isNotEmpty) {
        return 'Test data already exists (${existingContacts.length} contacts)';
      }

      // Create UserConfig
      var userConfig = await UserConfig.db.findFirstRow(
        session,
        where: (t) => t.userInfoId.equals(testUserId),
      );

      if (userConfig == null) {
        userConfig = UserConfig(
          userInfoId: testUserId,
          lastSyncTime: DateTime.now().toUtc(),
        );
        await UserConfig.db.insertRow(session, userConfig);
      }

      // Create realistic contacts
      final contacts = [
        Contact(
          ownerId: testUserId,
          email: 'rahul.sharma@gmail.com',
          name: 'Rahul Sharma',
          healthScore: 42.0,
          tier: 1,
          lastContacted: DateTime.now().subtract(const Duration(days: 28)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'priya.patel@gmail.com',
          name: 'Priya Patel',
          healthScore: 85.0,
          tier: 1,
          lastContacted: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'arjun.mehta@gmail.com',
          name: 'Arjun Mehta',
          healthScore: 72.0,
          tier: 2,
          lastContacted: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'sneha.gupta@gmail.com',
          name: 'Sneha Gupta',
          healthScore: 58.0,
          tier: 2,
          lastContacted: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'vikram.singh@gmail.com',
          name: 'Vikram Singh',
          healthScore: 35.0,
          tier: 1,
          lastContacted: DateTime.now().subtract(const Duration(days: 21)),
        ),
      ];

      final insertedContacts = <Contact>[];
      for (var contact in contacts) {
        final inserted = await Contact.db.insertRow(session, contact);
        insertedContacts.add(inserted);
      }

      // Create realistic interactions
      final interactions = [
        Interaction(
          ownerId: testUserId,
          contactId: insertedContacts[1].id!, // Priya
          date: DateTime.now().subtract(const Duration(hours: 2)),
          snippet:
              'Shared notes from the product sync meeting - discussed Q1 roadmap priorities',
          type: 'email_in',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          contactId: insertedContacts[2].id!, // Arjun
          date: DateTime.now().subtract(const Duration(hours: 5)),
          snippet: 'You followed up on the Mumbai trip plans for next month',
          type: 'email_out',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          contactId: insertedContacts[3].id!, // Sneha
          date: DateTime.now().subtract(const Duration(days: 1)),
          snippet:
              'Quarterly review discussion - performance metrics and team goals',
          type: 'meeting',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          contactId: insertedContacts[0].id!, // Rahul
          date: DateTime.now().subtract(const Duration(days: 28)),
          snippet:
              'Internship referral at Google - his team is hiring for ML roles, promised to forward your resume',
          type: 'email_in',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          contactId: insertedContacts[4].id!, // Vikram
          date: DateTime.now().subtract(const Duration(days: 21)),
          snippet:
              'Discussed startup investment opportunity - follow up needed on term sheet',
          type: 'email_in',
          embedding: Vector(List.filled(768, 0.0)),
        ),
      ];

      for (var interaction in interactions) {
        await Interaction.db.insertRow(session, interaction);
      }

      session.log('Test data seeded successfully', level: LogLevel.info);
      return 'Seeded ${contacts.length} contacts and ${interactions.length} interactions';
    } catch (e, stack) {
      session.log(
        'Error seeding data: $e',
        level: LogLevel.error,
        stackTrace: stack,
      );
      return 'Error: $e';
    }
  }

  /// Clear all test data
  Future<String> clearTestData(Session session) async {
    const testUserId = 1;

    try {
      // Delete interactions first (foreign key)
      await Interaction.db.deleteWhere(
        session,
        where: (t) => t.ownerId.equals(testUserId),
      );

      // Delete contacts
      await Contact.db.deleteWhere(
        session,
        where: (t) => t.ownerId.equals(testUserId),
      );

      // Delete user config
      await UserConfig.db.deleteWhere(
        session,
        where: (t) => t.userInfoId.equals(testUserId),
      );

      return 'Test data cleared';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
