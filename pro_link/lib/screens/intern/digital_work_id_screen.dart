import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Work ID')),
      body: ResponsivePage(
        maxWidth: 560,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Hero(
              tag: 'work-id-card',
              child: WorkIdCard(
                fullName: user?.fullName ?? 'Intern User',
                matricule: intern?.matricule ?? 'N/A',
                department: intern?.department ?? 'Unassigned',
                email: user?.email ?? 'intern@prolink.test',
                photoUrl: user?.photoUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
