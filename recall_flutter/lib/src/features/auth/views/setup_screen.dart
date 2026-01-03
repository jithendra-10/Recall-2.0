import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart';
import 'package:recall_flutter/src/features/home/views/dashboard_screen.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/main.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Connecting to your Google account',
    'Scanning recent conversations',
    'Building relationship memory',
    'Activating background agent',
  ];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Immediate initial check
    _checkStatus();
    
    // Poll every 1.5 seconds
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final userId = sessionManager.signedInUser?.id;
      final status = await client.dashboard.getSetupStatus(userId: userId);
      if (!mounted) return;

      int nextStep = _currentStep;

      // Step 1: Connecting (Token exists)
      if (status.hasToken) {
        if (nextStep < 1) nextStep = 1;
      }

      // Step 2: Scanning (Token exists and we are likely syncing)
      if (status.hasToken && (status.isSyncing || status.interactionCount > 0)) {
         if (nextStep < 2) nextStep = 2;
      }

      // Step 3: Building Memory (We have some interactions)
      if (status.interactionCount > 0) {
         if (nextStep < 3) nextStep = 3;
      }

      // Step 4: Activating Agent (Sync finished)
      // Check if sync is done (not syncing) and we have token
      if (!status.isSyncing && status.hasToken) {
         if (nextStep < 4) nextStep = 4;
      }

      if (nextStep != _currentStep) {
        setState(() => _currentStep = nextStep);
      }

      // Completion
      if (_currentStep == 4) {
        _pollingTimer?.cancel();
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      print('Setup polling error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Title
              const Text(
                'Setting up your Butler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This happens once.',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
              // Robot GIF
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/Robot Automation Gif.gif',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              // Progress steps
              ...List.generate(_steps.length, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primary
                              : (isCurrent
                                  ? AppColors.primary.withOpacity(0.2)
                                  : const Color(0xFF374151)),
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 18,
                              )
                            : (isCurrent
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _steps[index],
                          style: TextStyle(
                            color: isCompleted || isCurrent
                                ? Colors.white
                                : const Color(0xFF6B7280),
                            fontSize: 15,
                            fontWeight: isCompleted || isCurrent
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Spacer(flex: 1),
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == 1
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Bottom text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252B33),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You can close the app—RECALL works in the background.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
