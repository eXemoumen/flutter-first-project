import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/stat_card.dart';

class MentorDashboard extends ConsumerStatefulWidget {
  const MentorDashboard({super.key});

  @override
  ConsumerState<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends ConsumerState<MentorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mentorId = ref.read(authProvider).currentUser?.id;
      if (mentorId != null) {
        ref.read(mentorProvider).loadDashboard(mentorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mentor = ref.watch(mentorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authProvider).logout();
              if (!context.mounted) return;
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: mentor.isLoading,
        child: ResponsivePage(
          maxWidth: 1060,
          child: RefreshIndicator(
            onRefresh: () async {
              final mentorId = ref.read(authProvider).currentUser?.id;
              if (mentorId != null) {
                await ref.read(mentorProvider).loadDashboard(mentorId);
              }
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Text(
                    'Manage your intern group, track attendance, and evaluate performance.'),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 860;
                    if (compact) {
                      return Column(
                        children: [
                          StatCard(
                            title: 'Intern Group Size',
                            value: '${mentor.groupSize}',
                            icon: Icons.groups_2_rounded,
                          ),
                          const SizedBox(height: 12),
                          StatCard(
                            title: 'Recent Evaluations',
                            value: '${mentor.recentMarks.length}',
                            icon: Icons.fact_check_rounded,
                            color: const Color(0xFF1F7A1F),
                          ),
                          const SizedBox(height: 12),
                          StatCard(
                            title: 'Today Attendance',
                            value: '${mentor.attendanceByDate.length}',
                            icon: Icons.today_rounded,
                            color: const Color(0xFFB35300),
                          ),
                        ],
                      );
                    }

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 260,
                          child: StatCard(
                            title: 'Intern Group Size',
                            value: '${mentor.groupSize}',
                            icon: Icons.groups_2_rounded,
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: StatCard(
                            title: 'Recent Evaluations',
                            value: '${mentor.recentMarks.length}',
                            icon: Icons.fact_check_rounded,
                            color: const Color(0xFF1F7A1F),
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: StatCard(
                            title: 'Today Attendance',
                            value: '${mentor.attendanceByDate.length}',
                            icon: Icons.today_rounded,
                            color: const Color(0xFFB35300),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;
                    final crossAxisCount = isSmall ? 1 : 2;
                    final childAspectRatio = isSmall ? 3.5 : 2.5;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ActionCard(
                          title: 'Intern Group',
                          subtitle: 'View and manage assigned interns',
                          icon: Icons.people_outline_rounded,
                          color: const Color(0xFF2563EB), // Blue
                          onTap: () => context.push('/mentor/intern-group'),
                        ),
                        _ActionCard(
                          title: 'Mark Performance',
                          subtitle: 'Evaluate intern skills and comments',
                          icon: Icons.grading_rounded,
                          color: const Color(0xFF16A34A), // Green
                          onTap: () => context.push('/mentor/mark-performance'),
                        ),
                        _ActionCard(
                          title: 'Attendance Tracking',
                          subtitle: 'Mark weekly attendance by date',
                          icon: Icons.event_available_rounded,
                          color: const Color(0xFFD97706), // Amber
                          onTap: () => context.push('/mentor/attendance'),
                        ),
                        _ActionCard(
                          title: 'Upload Training',
                          subtitle: 'Share modules and learning materials',
                          icon: Icons.upload_file_rounded,
                          color: const Color(0xFF9333EA), // Purple
                          onTap: () => context.push('/mentor/upload-training'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.color : (isDark ? Colors.white10 : Colors.black12),
              width: 1.5,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: _isHovered ? widget.color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
