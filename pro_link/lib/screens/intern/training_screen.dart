import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    Future<void> openModule(String url) async {
      final launched = await launchUrl(Uri.parse(url));
      if (!launched && context.mounted) {
        AppFeedback.info(context, 'Could not open the training module.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Training Modules')),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView.builder(
            padding: EdgeInsets.zero,
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
              ),
            },
          ),
        ),
      ),
    );
  }
}
