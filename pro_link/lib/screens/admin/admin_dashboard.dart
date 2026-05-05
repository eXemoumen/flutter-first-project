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
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 1060,
          child: RefreshIndicator(
            onRefresh: () => ref.read(adminProvider).loadDashboard(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Text(
                    'Control center for assignments, approvals, and resources.'),
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
                          title: 'Manage Interns',
                          subtitle: 'Assign departments & mentors',
                          icon: Icons.manage_accounts_rounded,
                          color: const Color(0xFF2563EB), // Blue
                          onTap: () => context.push('/admin/manage-interns'),
                        ),
                        _ActionCard(
                          title: 'Validate Users',
                          subtitle: 'Approve or reject users',
                          icon: Icons.verified_user_rounded,
                          color: const Color(0xFF16A34A), // Green
                          onTap: () => context.push('/admin/validate-users'),
                        ),
                        _ActionCard(
                          title: 'Upload Timetable',
                          subtitle: 'Publish shift schedules',
                          icon: Icons.calendar_month_rounded,
                          color: const Color(0xFF9333EA), // Purple
                          onTap: () => context.push('/admin/upload-schedule'),
                        ),
                        _ActionCard(
                          title: 'Upload Policy Docs',
                          subtitle: 'Publish compliance documents',
                          icon: Icons.policy_rounded,
                          color: const Color(0xFFD97706), // Amber
                          onTap: () => context.push('/admin/upload-policy'),
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
