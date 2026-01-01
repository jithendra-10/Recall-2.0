import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart';
import 'package:recall_flutter/src/features/auth/controllers/auth_controller.dart';
import 'package:recall_flutter/main.dart';
import 'package:recall_client/src/protocol/dashboard_data.dart';
import 'package:recall_client/src/protocol/interaction_summary.dart';
import 'package:recall_client/src/protocol/contact.dart';
import 'package:recall_client/src/protocol/chat_message.dart';
import '../providers/dashboard_provider.dart';
import 'coming_soon_screen.dart';
import 'ask_recall_screen.dart';

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
          const ComingSoonScreen(featureName: 'People'),
        ],
      ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F24),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Ask',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'People',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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

    return SafeArea(
      child: RefreshIndicator(
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
                isSyncing: dashboardState.data?.isSyncing ?? false,
              ),
              const SizedBox(height: 20),
              
              // Loading or Content
              if (dashboardState.isLoading)
                const _LoadingState()
              else if (dashboardState.error != null)
                _ErrorState(error: dashboardState.error!)
              else if (dashboardState.data != null)
                _DashboardContent(data: dashboardState.data!)
              else
                const _LearningState(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING STATE
// ============================================================================
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your relationship data...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

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
              error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
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
    final hasNudge = data.nudgeContact != null;
    final hasInteractions = data.recentInteractions.isNotEmpty;
    final hasContacts = data.topContacts.isNotEmpty;

    if (!hasNudge && !hasInteractions && !hasContacts) {
      return const _LearningState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Nudge Card
        if (hasNudge) ...[
          _PrimaryNudgeCard(
            contact: data.nudgeContact!,
            daysSilent: data.nudgeDaysSilent ?? 0,
            lastTopic: data.nudgeLastTopic,
          ),
          const SizedBox(height: 24),
        ],
        
        // Live Memory Feed
        if (hasInteractions) ...[
          const _SectionHeader(title: 'Recent Memory'),
          const SizedBox(height: 12),
          _LiveMemoryFeed(interactions: data.recentInteractions),
          const SizedBox(height: 24),
        ],
        
        // Relationship Health
        if (hasContacts) ...[
          _SectionHeader(
            title: 'Relationship Health',
            subtitle: '${data.driftingCount} drifting',
          ),
          const SizedBox(height: 12),
          _RelationshipHealthSnapshot(contacts: data.topContacts),
          const SizedBox(height: 24),
        ],
        
        // Ask RECALL
        const _AskRecallCard(),
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
        Container(
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
// PRIMARY NUDGE CARD
// ============================================================================
class _PrimaryNudgeCard extends StatelessWidget {
  final Contact contact;
  final int daysSilent;
  final String? lastTopic;

  const _PrimaryNudgeCard({
    required this.contact,
    required this.daysSilent,
    this.lastTopic,
  });

  Color get _healthColor {
    final score = contact.healthScore;
    if (score > 70) return const Color(0xFF22C55E);
    if (score > 40) return const Color(0xFFFBBF24);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final name = contact.name ?? contact.email;
    final initials = name.isNotEmpty 
        ? name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2328), Color(0xFF1A1F24)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_healthColor, _healthColor.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: contact.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          contact.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _healthColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$daysSilent days since last contact',
                          style: TextStyle(
                            color: _healthColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _HealthRing(score: contact.healthScore.round()),
            ],
          ),
          if (lastTopic != null && lastTopic!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Last discussed',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastTopic!,
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.visibility_outlined,
                  label: 'View Context',
                  isPrimary: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Send Draft',
                  isPrimary: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  final int score;
  
  const _HealthRing({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score > 70 ? const Color(0xFF22C55E)
        : score > 40 ? const Color(0xFFFBBF24)
        : const Color(0xFFEF4444);
    
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 4,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Center(
            child: Text(
              '$score%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// LIVE MEMORY FEED
// ============================================================================
class _LiveMemoryFeed extends StatelessWidget {
  final List<InteractionSummary> interactions;

  const _LiveMemoryFeed({required this.interactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: interactions.map((i) => _MemoryCard(interaction: i)).toList(),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final InteractionSummary interaction;

  const _MemoryCard({required this.interaction});

  IconData get _icon {
    switch (interaction.type) {
      case 'email_in': return Icons.mail_outline;
      case 'email_out': return Icons.send_outlined;
      case 'meeting': return Icons.event_outlined;
      default: return Icons.chat_outlined;
    }
  }

  Color get _iconBg {
    switch (interaction.type) {
      case 'email_in': return const Color(0xFF3B82F6);
      case 'email_out': return const Color(0xFF22C55E);
      case 'meeting': return const Color(0xFFA855F7);
      default: return const Color(0xFF6B7280);
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().toUtc().difference(interaction.timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2328),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _iconBg.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _iconBg, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      interaction.contactName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  interaction.summary,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
// RELATIONSHIP HEALTH SNAPSHOT
// ============================================================================
class _RelationshipHealthSnapshot extends StatelessWidget {
  final List<Contact> contacts;

  const _RelationshipHealthSnapshot({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: contacts.map((c) => _ContactHealthCard(contact: c)).toList(),
    );
  }
}

class _ContactHealthCard extends StatelessWidget {
  final Contact contact;

  const _ContactHealthCard({required this.contact});

  Color get _color {
    final score = contact.healthScore;
    if (score > 70) return const Color(0xFF22C55E);
    if (score > 40) return const Color(0xFFFBBF24);
    return const Color(0xFFEF4444);
  }

  String get _lastContactText {
    if (contact.lastContacted == null) return 'Never';
    final diff = DateTime.now().toUtc().difference(contact.lastContacted!);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final name = contact.name ?? contact.email;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2328),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: _color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _lastContactText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${contact.healthScore.round()}%',
                  style: TextStyle(
                    color: _color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: contact.healthScore / 100,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(_color),
                    minHeight: 4,
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
// ASK RECALL CARD
// ============================================================================
class _AskRecallCard extends StatelessWidget {
  const _AskRecallCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Ask tab
        final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
        dashboardState?.setState(() {
          dashboardState._currentIndex = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.3),
              AppColors.secondary.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F24),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ).createShader(bounds),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ask RECALL: "What did I discuss with John?"',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
