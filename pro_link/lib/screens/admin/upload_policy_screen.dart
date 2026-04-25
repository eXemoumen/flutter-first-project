import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> _upload() async {
    final user = ref.read(authProvider).currentUser;

    if (_titleController.text.trim().isEmpty || _filePath == null || user == null) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Policy Document')),
      body: LoadingOverlay(
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 900,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Policy Title'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(
                  _filePath == null
                      ? 'Pick policy file'
                      : _filePath!.split(RegExp(r'[\\/]')).last,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _upload,
                child: const Text('Upload'),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent policies',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...admin.policies.map(
                (p) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.policy_outlined),
                    title: Text(p.title),
                    subtitle: Text(p.fileUrl),
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
