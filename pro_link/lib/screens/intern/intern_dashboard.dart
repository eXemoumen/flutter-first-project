import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/intern_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/work_id_card.dart';

class InternDashboard extends ConsumerStatefulWidget {
  const InternDashboard({super.key});

  @override
  ConsumerState<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends ConsumerState<InternDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).currentUser?.id;
      if (userId != null) {
        ref.read(internProvider).loadAll(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final intern = ref.watch(internProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline_rounded),
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
        isLoading: intern.isLoading,
        child: ResponsivePage(
          maxWidth: 1060,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Text(
                'Welcome ${auth.currentUser?.fullName ?? 'Intern'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              const Text('Track schedules, marks, and learning modules from one workspace.'),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.go('/intern/work-id'),
                child: Hero(
                  tag: 'work-id-card',
                  child: Material(
                    color: Colors.transparent,
                    child: WorkIdCard(
                      fullName: auth.currentUser?.fullName ?? 'Intern User',
                      matricule: intern.intern?.matricule ?? 'N/A',
                      department: intern.intern?.department ?? 'Unassigned',
                      email: auth.currentUser?.email ?? 'intern@prolink.test',
                      photoUrl: auth.currentUser?.photoUrl,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 860;
                  if (compact) {
                    return Column(
                      children: [
                        StatCard(
                          title: 'Schedules',
                          value: '${intern.schedules.length}',
                          icon: Icons.calendar_month_rounded,
                        ),
                        const SizedBox(height: 12),
                        StatCard(
                          title: 'Training Modules',
                          value: '${intern.modules.length}',
                          icon: Icons.menu_book_rounded,
                        ),
                        const SizedBox(height: 12),
                        StatCard(
                          title: 'Average Mark',
                          value: intern.averageMark.toStringAsFixed(2),
                          icon: Icons.auto_graph_rounded,
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
                          title: 'Schedules',
                          value: '${intern.schedules.length}',
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: StatCard(
                          title: 'Training Modules',
                          value: '${intern.modules.length}',
                          icon: Icons.menu_book_rounded,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: StatCard(
                          title: 'Average Mark',
                          value: intern.averageMark.toStringAsFixed(2),
                          icon: Icons.auto_graph_rounded,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _ActionButton(
                title: 'Digital Work ID',
                subtitle: 'Open your corporate intern card',
                icon: Icons.badge_rounded,
                onTap: () => context.go('/intern/work-id'),
              ),
              _ActionButton(
                title: 'Schedule',
                subtitle: 'View your assigned timetable',
                icon: Icons.schedule_rounded,
                onTap: () => context.go('/intern/schedule'),
              ),
              _ActionButton(
                title: 'Training',
                subtitle: 'Open your training modules',
                icon: Icons.menu_book_rounded,
                onTap: () => context.go('/intern/training'),
              ),
              _ActionButton(
                title: 'Marks',
                subtitle: 'Track your skill evaluations',
                icon: Icons.analytics_rounded,
                onTap: () => context.go('/intern/marks'),
              ),
              _ActionButton(
                title: 'Calendar',
                subtitle: 'View schedules and evaluation events',
                icon: Icons.event_note_rounded,
                onTap: () => context.go('/intern/calendar'),
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
