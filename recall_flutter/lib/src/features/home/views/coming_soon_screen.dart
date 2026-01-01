import 'package:flutter/material.dart';
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart';

class ComingSoonScreen extends StatelessWidget {
  final String featureName;

  const ComingSoonScreen({super.key, required this.featureName});

  IconData get _featureIcon {
    switch (featureName.toLowerCase()) {
      case 'ask recall':
        return Icons.auto_awesome_rounded;
      case 'people':
        return Icons.people_outline_rounded;
      case 'contacts':
        return Icons.contacts_outlined;
      case 'search':
        return Icons.search_rounded;
      case 'settings':
        return Icons.settings_outlined;
      default:
        return Icons.rocket_launch_outlined;
    }
  }

  String get _featureDescription {
    switch (featureName.toLowerCase()) {
      case 'ask recall':
        return 'Ask questions about your relationships and get AI-powered insights from your communication history.';
      case 'people':
        return 'View all your contacts with relationship health scores and communication timelines.';
      case 'contacts':
        return 'Manage your network and track relationship health across all your connections.';
      case 'search':
        return 'Search through your conversation history and find any context instantly.';
      case 'settings':
        return 'Customize your RECALL experience and manage your account preferences.';
      default:
        return 'This feature is being built with care and will be available soon.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Icon with glow effect
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ).createShader(bounds),
                  child: Icon(
                    _featureIcon,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Feature name
              Text(
                featureName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Coming soon badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'COMING SOON',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                _featureDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 3),
              // Bottom hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 16,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "We'll notify you when it's ready",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
