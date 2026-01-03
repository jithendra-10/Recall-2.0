import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart';
import 'package:recall_flutter/src/features/auth/controllers/auth_controller.dart';
import 'package:recall_flutter/main.dart';
import 'package:recall_client/src/protocol/dashboard_data.dart';
import 'package:recall_client/src/protocol/interaction_summary.dart';
import 'package:recall_client/src/protocol/contact.dart';

import '../providers/dashboard_provider.dart';
import 'coming_soon_screen.dart';
import 'ask_recall_screen.dart';
import '../../profile/views/profile_screen.dart';
import 'calendar_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  // Get user info
  String get _userFullName {
    if (currentGoogleUser != null && currentGoogleUser!.displayName != null) {
      return currentGoogleUser!.displayName!;
    }
    if (storedUserInfo?.name != null && storedUserInfo!.name!.isNotEmpty) {
      return storedUserInfo!.name!;
    }
    final user = sessionManager.signedInUser;
    if (user != null && user.fullName != null && user.fullName!.isNotEmpty) {
      return user.fullName!;
    }
    return 'User';
  }

  String get _userFirstName => _userFullName.split(' ').first;

  String? get _userImageUrl {
    if (currentGoogleUser != null && currentGoogleUser!.photoUrl != null) {
      return currentGoogleUser!.photoUrl;
    }
    if (storedUserInfo?.photo != null && storedUserInfo!.photo!.isNotEmpty) {
      return storedUserInfo!.photo;
    }
    final user = sessionManager.signedInUser;
    return user?.imageUrl;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            greeting: _greeting,
            userFullName: _userFullName,
            userFirstName: _userFirstName,
            userImageUrl: _userImageUrl,
          ),
          const AskRecallScreen(),
          // Placeholder for Mic/Voice Screen - reusing AskRecall for now with different mode? 
          // Or just a placeholder. Let's use AskRecallScreen for now or a dummy.
          // User asked for "Mike symbol", implies voice. Let's make it open Ask Screen for now
          // but logically it should be a voice interface.
          const Center(child: Icon(Icons.mic, size: 80, color: Colors.cyan)), 
          const ComingSoonScreen(featureName: 'Network'), // Was People
          const CalendarScreen(),
        ],
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => setState(() => _currentIndex = 2),
          backgroundColor: const Color(0xFF1A1F24), // Match nav bar or dark
          elevation: 0,
          shape: const CircleBorder(side: BorderSide(color: Colors.cyan, width: 2)),
          child: Icon(Icons.mic, color: _currentIndex == 2 ? Colors.cyan : Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ============================================================================
// BOTTOM NAVIGATION
// ============================================================================
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF1A1F24),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 10,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Group
            Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                const SizedBox(width: 20),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ],
            ),
            
            // Spacer for FAB
            const SizedBox(width: 48),

            // Right Group
            Row(
              children: [
                _NavItem(
                  icon: Icons.hub_outlined, // Network icon
                  label: 'Network',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                const SizedBox(width: 20),
                _NavItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Calendar',
                  isSelected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.cyan : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.cyan : Colors.grey[600],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HOME TAB - CONSUMES REAL DATA
// ============================================================================
class _HomeTab extends ConsumerWidget {
  final String greeting;
  final String userFullName;
  final String userFirstName;
  final String? userImageUrl;

  const _HomeTab({
    required this.greeting,
    required this.userFullName,
    required this.userFirstName,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final isLoading = dashboardState.isLoading;
    final isSyncing = dashboardState.data?.isSyncing ?? false;
    final showLoadingOverlay = isLoading || isSyncing;

    return SafeArea(
      child: Stack(
        children: [
          // Main Content
          RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            color: AppColors.primary,
            backgroundColor: const Color(0xFF1A1F24),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _Header(
                    greeting: greeting,
                    userFullName: userFullName,
                    userFirstName: userFirstName,
                    userImageUrl: userImageUrl,
                  ),
                  const SizedBox(height: 20),
                  
                  // Butler Status Card
                  _ButlerStatusCard(
                    lastSyncTime: dashboardState.data?.lastSyncTime,
                    isSyncing: isSyncing,
                  ),
                  const SizedBox(height: 20),
                  
                  // Content
                  if (dashboardState.error != null)
                     _ErrorState(error: dashboardState.error!)
                  else if (dashboardState.data != null)
                    _DashboardContent(data: dashboardState.data!)
                  // Show content skeleton or learning state if no data yet (and not loading initial)
                  else if (!isLoading) 
                    const _LearningState(),
                ],
              ),
            ),
          ),

          // Blur Overlay & Loading Bar
          if (showLoadingOverlay)
            Positioned.fill(
              child: Stack(
                children: [
                   // Blur Effect
                   BackdropFilter(
                    filter: dart_ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  // Loading Bar
                  if (isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Colors.transparent,
                        color: AppColors.primary,
                      ),
                    ),
                   // Sync Status Text Center
                   if (isSyncing && !isLoading)
                     Center(
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                         decoration: BoxDecoration(
                           color: const Color(0xFF1A1F24),
                           borderRadius: BorderRadius.circular(30),
                           border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                           boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                           ],
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             const SizedBox(
                               width: 16,
                               height: 16,
                               child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                             ),
                             const SizedBox(width: 12),
                             const Text(
                               'Syncing emails...',
                               style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                             ),
                           ],
                         ),
                       ),
                     ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOADING STATE
// ============================================================================


// ============================================================================
// ERROR STATE
// ============================================================================
class _ErrorState extends StatelessWidget {
  final String error;
  
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red, fontSize: 13),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LEARNING STATE - When no data yet
// ============================================================================
class _LearningState extends StatelessWidget {
  const _LearningState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2328),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ).createShader(bounds),
            child: const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'RECALL is learning',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Syncing your Gmail and building relationship memory. This may take a few minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DASHBOARD CONTENT - Real data
// ============================================================================
class _DashboardContent extends StatelessWidget {
  final DashboardData data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    // Only show email feed if we have interactions, otherwise generic empty state or learning
    // But user asked to remove other sections, so we focus on the list.
    
    if (data.recentInteractions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'No emails found yet',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'All Mails'),
        const SizedBox(height: 16),
        _EmailFeed(interactions: data.recentInteractions),
      ],
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================
class _Header extends StatelessWidget {
  final String greeting;
  final String userFullName;
  final String userFirstName;
  final String? userImageUrl;

  const _Header({
    required this.greeting,
    required this.userFullName,
    required this.userFirstName,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              LayoutBuilder(
                builder: (context, constraints) {
                  final fullNamePainter = TextPainter(
                    text: TextSpan(
                      text: userFullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                    textScaler: MediaQuery.of(context).textScaler, // Fix for text scale
                  )..layout();
                  
                  final displayName = fullNamePainter.width <= constraints.maxWidth
                      ? userFullName
                      : userFirstName;
                  
                  return Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2B313A),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: userImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        userImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 22),
                      ),
                    )
                  : const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 22),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// BUTLER STATUS CARD
// ============================================================================
class _ButlerStatusCard extends StatelessWidget {
  final DateTime? lastSyncTime;
  final bool isSyncing;

  const _ButlerStatusCard({
    required this.lastSyncTime,
    required this.isSyncing,
  });

  String get _syncText {
    if (isSyncing) return 'Syncing Gmail...';
    if (lastSyncTime == null) return 'Gmail sync pending';
    
    final diff = DateTime.now().toUtc().difference(lastSyncTime!);
    if (diff.inMinutes < 1) return 'Last Gmail sync: just now';
    if (diff.inMinutes < 60) return 'Last Gmail sync: ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last Gmail sync: ${diff.inHours}h ago';
    return 'Last Gmail sync: ${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isSyncing ? AppColors.primary : const Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isSyncing ? AppColors.primary : const Color(0xFF22C55E)).withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECALL is running in the background',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _syncText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isSyncing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            Icon(
              Icons.check_circle,
              color: const Color(0xFF22C55E).withOpacity(0.6),
              size: 20,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMAIL FEED
// ============================================================================
class _EmailFeed extends StatelessWidget {
  final List<InteractionSummary> interactions;

  const _EmailFeed({required this.interactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: interactions.map((i) => _EmailCard(interaction: i)).toList(),
    );
  }
}

class _EmailCard extends StatelessWidget {
  final InteractionSummary interaction;

  const _EmailCard({required this.interaction});

  @override
  Widget build(BuildContext context) {
    final initials = interaction.contactName.isNotEmpty 
        ? interaction.contactName.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.4),
          builder: (context) => _EmailDetailDialog(interaction: interaction),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2328),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2B313A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: interaction.contactAvatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        interaction.contactAvatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          interaction.contactName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(interaction.timestamp),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Subject (Small light text)
                  if (interaction.subject != null && interaction.subject!.isNotEmpty)
                    Text(
                      interaction.subject!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Snippet
                  Text(
                    interaction.summary, // Using snippet which is mapped to summary
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().toUtc().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ============================================================================
// EMAIL DETAIL DIALOG
// ============================================================================
class _EmailDetailDialog extends ConsumerStatefulWidget {
  final InteractionSummary interaction;

  const _EmailDetailDialog({required this.interaction});

  @override
  ConsumerState<_EmailDetailDialog> createState() => _EmailDetailDialogState();
}

class _EmailDetailDialogState extends ConsumerState<_EmailDetailDialog> {
  bool _isComposing = false;
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill composer for reply
    _subjectController.text = 'Re: ${widget.interaction.subject ?? "Conversation"}';
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: const Color(0xFF1E2328).withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isComposing ? _buildComposeView() : _buildDetailView(),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.interaction.subject ?? 'No Subject',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'From: ${widget.interaction.contactName} <${widget.interaction.contactEmail}>',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        const Divider(color: Colors.white10, height: 32),
        
        // Body
        Flexible(
          child: SingleChildScrollView(
            child: Text(
              widget.interaction.body ?? widget.interaction.summary,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement AI summary logic properly
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('AI Summary: ${widget.interaction.summary}'),
                      backgroundColor: const Color(0xFF1A1F24),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View Context'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _isComposing = true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Send Draft'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComposeView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Compose Draft',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () => setState(() => _isComposing = false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Subject Field
        TextField(
          controller: _subjectController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Subject',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 12),
        
        // Body Field
        Expanded(
          child: TextField(
            controller: _bodyController,
            style: const TextStyle(color: Colors.white),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Write your message here...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Send Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSending 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Send Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _sendEmail() async {
    if (_bodyController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    final success = await ref.read(dashboardProvider.notifier).sendEmail(
      widget.interaction.contactEmail,
      _subjectController.text,
      _bodyController.text,
    );

    if (!mounted) return;

    setState(() => _isSending = false);

    if (success) {
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sent successfully!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send email. Need permission?'), backgroundColor: Colors.red),
      );
    }
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
