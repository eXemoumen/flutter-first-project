import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/intern_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/training_module_card.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(internProvider);
    final theme = Theme.of(context);

    Future<void> openModule(String url) async {
      final launched = await launchUrl(Uri.parse(url));
      if (!launched && context.mounted) {
        AppFeedback.info(context, 'Could not open the training module.');
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
        title: const Text('Training Modules', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  'Available Modules',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: state.modules.isEmpty
                    ? Center(
                        child: Text(
                          'No modules assigned yet.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: state.modules.length,
                        itemBuilder: (context, index) {
                          final item = state.modules[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TrainingModuleCard(
                              title: item.title,
                              description: item.description ?? 'No description available',
                              fileType: item.fileType ?? 'file',
                              onOpen: () => openModule(item.fileUrl),
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
