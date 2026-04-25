import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Validate Users')),
      body: LoadingOverlay(
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 1000,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: admin.pendingUsers.length,
            itemBuilder: (context, index) {
              final user = admin.pendingUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(user.fullName),
                  subtitle: Text('${user.email} • ${user.matricule}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _rejectUser(user.id),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      IconButton.filled(
                        onPressed: () => _approveUser(user.id),
                        icon: const Icon(Icons.check_rounded),
                      ),
                    ],
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
