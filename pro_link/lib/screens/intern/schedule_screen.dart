import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final theme = Theme.of(context);

    Future<void> openFile(String url) async {
      final launched = await launchUrl(Uri.parse(url));
      if (!launched && context.mounted) {
        AppFeedback.info(context, 'Could not open the schedule file.');
      }
    }

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
        title: const Text('My Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Upcoming Schedules',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: state.schedules.isEmpty
                    ? Center(
                        child: Text(
                          'No schedules available.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: state.schedules.length,
                        itemBuilder: (context, index) {
                          final item = state.schedules[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  ScheduleCard(
                                    title: item.title,
                                    department: item.department ?? 'General',
                                    validFrom: item.validFrom,
                                    validTo: item.validTo,
                                  ),
                                  if (item.fileUrl != null) ...[
                                    const Divider(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          FilledButton.tonalIcon(
                                            onPressed: () => openFile(item.fileUrl!),
                                            icon: const Icon(Icons.picture_as_pdf_rounded),
                                            label: const Text('View Document'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
