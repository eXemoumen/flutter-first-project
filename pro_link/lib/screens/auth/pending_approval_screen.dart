import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/responsive_page.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsivePage(
        maxWidth: 560,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Awaiting Admin Approval',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your registration is pending admin validation. You will unlock intern features once approved.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider).refreshUser();
                      final approved = !ref.read(authProvider).isInternPendingApproval;
                      if (!context.mounted) return;
                      if (approved) {
                        context.go('/intern');
                      } else {
                        AppFeedback.info(context, 'Still pending admin approval.');
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Check Approval Status'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider).logout();
                      if (!context.mounted) return;
                      context.go('/login');
                    },
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
