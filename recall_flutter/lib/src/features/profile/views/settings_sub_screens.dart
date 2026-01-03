import 'package:flutter/material.dart';

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Details'), backgroundColor: Colors.transparent),
      backgroundColor: const Color(0xFF1A1D23),
      body: const Center(child: Text('Account Details Placeholder', style: TextStyle(color: Colors.white))),
    );
  }
}

class DailyBriefingScreen extends StatelessWidget {
  const DailyBriefingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Briefing Time'), backgroundColor: Colors.transparent),
      backgroundColor: const Color(0xFF1A1D23),
      body: const Center(child: Text('Briefing Time Picker Placeholder', style: TextStyle(color: Colors.white))),
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription'), backgroundColor: Colors.transparent),
      backgroundColor: const Color(0xFF1A1D23),
      body: const Center(child: Text('Subscription Management Placeholder', style: TextStyle(color: Colors.white))),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.transparent),
      backgroundColor: const Color(0xFF1A1D23),
      body: const Center(child: Text('Notification Settings Placeholder', style: TextStyle(color: Colors.white))),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security'), backgroundColor: Colors.transparent),
      backgroundColor: const Color(0xFF1A1D23),
      body: const Center(child: Text('Privacy Settings Placeholder', style: TextStyle(color: Colors.white))),
    );
  }
}

class GmailSyncScreen extends StatelessWidget {
  const GmailSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gmail Sync'), backgroundColor: Colors.transparent),
      backgroundColor: const Color(0xFF1A1D23),
      body: const Center(child: Text('Gmail Sync Status & Re-auth Placeholder', style: TextStyle(color: Colors.white))),
    );
  }
}
