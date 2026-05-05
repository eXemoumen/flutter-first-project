import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/admin_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class ValidateUsersScreen extends ConsumerStatefulWidget {
  const ValidateUsersScreen({super.key});

  @override
  ConsumerState<ValidateUsersScreen> createState() => _ValidateUsersScreenState();
}

class _ValidateUsersScreenState extends ConsumerState<ValidateUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider).loadPendingUsers();
    });
  }

  Future<void> _approveUser(String userId) async {
    try {
      await ref.read(adminProvider).approveUser(userId);
      if (!mounted) return;
      AppFeedback.success(context, 'User approved.');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Approval failed: $e');
    }
  }

  Future<void> _rejectUser(String userId) async {
    try {
      await ref.read(adminProvider).rejectUser(userId);
      if (!mounted) return;
      AppFeedback.info(context, 'User rejected.');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Rejection failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Go Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin');
            }
          },
        ),
        title: const Text('Validate Users'),
      ),
      body: LoadingOverlay(
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 1000,
          child: admin.pendingUsers.isEmpty && !admin.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined,
                          size: 64, color: theme.disabledColor),
                      const SizedBox(height: 16),
                      Text(
                        'No pending users',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All registrations have been processed.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: admin.pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = admin.pendingUsers[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('${user.email}\nMatricule: ${user.matricule}'),
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton.filledTonal(
                                onPressed: () => _rejectUser(user.id),
                                icon: const Icon(Icons.close_rounded),
                                style: IconButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                ),
                                tooltip: 'Reject User',
                              ),
                              IconButton.filled(
                                onPressed: () => _approveUser(user.id),
                                icon: const Icon(Icons.check_rounded),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                tooltip: 'Approve User',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
