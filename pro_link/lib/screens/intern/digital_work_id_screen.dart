import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/intern_provider.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/work_id_card.dart';

class DigitalWorkIdScreen extends ConsumerWidget {
  const DigitalWorkIdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;
    final intern = ref.watch(internProvider).intern;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/intern');
              }
            },
            tooltip: 'Go Back',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        title: const Text('Digital Work ID', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ResponsivePage(
        maxWidth: 560,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.badge_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Corporate ID',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Present this card when requested for verification.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),
            Hero(
              tag: 'work-id-card',
              child: Material(
                color: Colors.transparent,
                child: WorkIdCard(
                  fullName: user?.fullName ?? 'Intern User',
                  matricule: intern?.matricule ?? 'N/A',
                  department: intern?.department ?? 'Unassigned',
                  email: user?.email ?? 'intern@prolink.test',
                  photoUrl: user?.photoUrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
