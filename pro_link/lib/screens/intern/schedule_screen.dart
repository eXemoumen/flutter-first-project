import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/intern_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/schedule_card.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(internProvider);

    Future<void> openFile(String url) async {
      final launched = await launchUrl(Uri.parse(url));
      if (!launched && context.mounted) {
        AppFeedback.info(context, 'Could not open the schedule file.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: state.schedules.length,
            itemBuilder: (context, index) {
              final item = state.schedules[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ScheduleCard(
                      title: item.title,
                      department: item.department ?? 'General',
                      validFrom: item.validFrom,
                      validTo: item.validTo,
                    ),
                    if (item.fileUrl != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => openFile(item.fileUrl!),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('Open File'),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
