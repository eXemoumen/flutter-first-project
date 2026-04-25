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
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
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
              const SizedBox(height: 20),
              _ActionButton(
                title: 'Intern Group',
                subtitle: 'View and manage assigned interns',
                icon: Icons.people_outline_rounded,
                onTap: () => context.go('/mentor/intern-group'),
              ),
              _ActionButton(
                title: 'Mark Performance',
                subtitle: 'Evaluate intern skills and comments',
                icon: Icons.grading_rounded,
                onTap: () => context.go('/mentor/mark-performance'),
              ),
              _ActionButton(
                title: 'Attendance Tracking',
                subtitle: 'Mark weekly attendance by date',
                icon: Icons.event_available_rounded,
                onTap: () => context.go('/mentor/attendance'),
              ),
              _ActionButton(
                title: 'Upload Training',
                subtitle: 'Share modules and learning materials',
                icon: Icons.upload_file_rounded,
                onTap: () => context.go('/mentor/upload-training'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
