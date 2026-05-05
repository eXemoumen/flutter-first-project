import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/file_helper.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class UploadPolicyScreen extends ConsumerStatefulWidget {
  const UploadPolicyScreen({super.key});

  @override
  ConsumerState<UploadPolicyScreen> createState() => _UploadPolicyScreenState();
}

class _UploadPolicyScreenState extends ConsumerState<UploadPolicyScreen> {
  final _titleController = TextEditingController();
  String? _filePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider).loadPolicies();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final path = await FileHelper.pickDocumentPath();
    if (path == null) return;
    setState(() => _filePath = path);
  }

  Future<void> _openFile(String url) async {
    final launched = await launchUrl(Uri.parse(url));
    if (!launched && mounted) {
      AppFeedback.info(context, 'Could not open the policy document.');
    }
  }

  Future<void> _upload() async {
    final user = ref.read(authProvider).currentUser;

    if (_titleController.text.trim().isEmpty ||
        _filePath == null ||
        user == null) {
      AppFeedback.info(context, 'Please complete all fields.');
      return;
    }

    try {
      await ref.read(adminProvider).uploadPolicy(
            title: _titleController.text.trim(),
            uploaderId: user.id,
            localFilePath: _filePath!,
          );

      if (!mounted) return;
      AppFeedback.success(context, 'Policy uploaded successfully.');
      _titleController.clear();
      setState(() => _filePath = null);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Upload failed: $e');
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
        title: const Text('Upload Policy Document'),
      ),
      body: LoadingOverlay(
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 900,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload New Policy',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Policy Title',
                          prefixIcon: const Icon(Icons.policy_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFile,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.upload_file_rounded),
                              label: Text(
                                _filePath == null
                                    ? 'Pick policy file'
                                    : _filePath!.split(RegExp(r'[\\/]')).last,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _upload,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: const Text('Upload Policy'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Policies',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (admin.policies.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No policies uploaded yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ),
                )
              else
                ...admin.policies.map(
                  (policy) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.policy_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        policy.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          policy.fileUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: IconButton.filledTonal(
                        tooltip: 'View document',
                        onPressed: () => _openFile(policy.fileUrl),
                        icon: const Icon(Icons.open_in_new_rounded),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
