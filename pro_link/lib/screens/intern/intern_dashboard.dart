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
        isLoading: intern.isLoading,
        child: ResponsivePage(
          maxWidth: 1060,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(context, auth.currentUser?.fullName ?? 'Intern'),
              const SizedBox(height: 24),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.push('/intern/work-id'),
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
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              Text(
                'Workspace',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 600;
                  return GridView.count(
                    crossAxisCount: isCompact ? 2 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isCompact ? 1.0 : 1.1,
                    children: [
                      _GridActionCard(
                        title: 'Digital ID',
                        icon: Icons.badge_rounded,
                        color: Colors.blueAccent,
                        onTap: () => context.push('/intern/work-id'),
                      ),
                      _GridActionCard(
                        title: 'Schedule',
                        icon: Icons.schedule_rounded,
                        color: Colors.orangeAccent,
                        onTap: () => context.push('/intern/schedule'),
                      ),
                      _GridActionCard(
                        title: 'Training',
                        icon: Icons.menu_book_rounded,
                        color: Colors.green,
                        onTap: () => context.push('/intern/training'),
                      ),
                      _GridActionCard(
                        title: 'Marks',
                        icon: Icons.analytics_rounded,
                        color: Colors.purpleAccent,
                        onTap: () => context.push('/intern/marks'),
                      ),
                      _GridActionCard(
                        title: 'Calendar',
                        icon: Icons.event_note_rounded,
                        color: Colors.redAccent,
                        onTap: () => context.push('/intern/calendar'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your schedule, marks, and modules in one place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridActionCard extends StatelessWidget {
  const _GridActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.1 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
