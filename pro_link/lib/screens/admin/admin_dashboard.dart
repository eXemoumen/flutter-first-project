import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/stat_card.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
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
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 1060,
          child: RefreshIndicator(
            onRefresh: () => ref.read(adminProvider).loadDashboard(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Text('Control center for assignments, approvals, and resources.'),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 860;
                    if (compact) {
                      return Column(
                        children: [
                          StatCard(
                            title: 'Total Interns',
                            value: '${admin.totalInterns}',
                            icon: Icons.groups_rounded,
                          ),
                          const SizedBox(height: 12),
                          StatCard(
                            title: 'Pending Approvals',
                            value: '${admin.pendingApprovals}',
                            icon: Icons.pending_actions_rounded,
                            color: const Color(0xFFB35300),
                          ),
                          const SizedBox(height: 12),
                          StatCard(
                            title: 'Active Mentors',
                            value: '${admin.activeMentors}',
                            icon: Icons.support_agent_rounded,
                            color: const Color(0xFF1F7A1F),
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
                            title: 'Total Interns',
                            value: '${admin.totalInterns}',
                            icon: Icons.groups_rounded,
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: StatCard(
                            title: 'Pending Approvals',
                            value: '${admin.pendingApprovals}',
                            icon: Icons.pending_actions_rounded,
                            color: const Color(0xFFB35300),
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: StatCard(
                            title: 'Active Mentors',
                            value: '${admin.activeMentors}',
                            icon: Icons.support_agent_rounded,
                            color: const Color(0xFF1F7A1F),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  title: 'Manage Interns',
                  subtitle: 'Assign departments and mentors',
                  icon: Icons.manage_accounts_rounded,
                  onTap: () => context.go('/admin/manage-interns'),
                ),
                _ActionButton(
                  title: 'Validate Users',
                  subtitle: 'Approve or reject pending registrations',
                  icon: Icons.verified_user_rounded,
                  onTap: () => context.go('/admin/validate-users'),
                ),
                _ActionButton(
                  title: 'Upload Timetable',
                  subtitle: 'Publish shift schedules by department',
                  icon: Icons.calendar_month_rounded,
                  onTap: () => context.go('/admin/upload-schedule'),
                ),
                _ActionButton(
                  title: 'Upload Policy Docs',
                  subtitle: 'Publish compliance and handbook documents',
                  icon: Icons.policy_rounded,
                  onTap: () => context.go('/admin/upload-policy'),
                ),
              ],
            ),
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
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
