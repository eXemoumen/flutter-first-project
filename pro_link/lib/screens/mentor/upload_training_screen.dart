import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/department_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_feedback.dart';
import '../../utils/file_helper.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class UploadTrainingScreen extends ConsumerStatefulWidget {
  const UploadTrainingScreen({super.key});

  @override
  ConsumerState<UploadTrainingScreen> createState() =>
      _UploadTrainingScreenState();
}

class _UploadTrainingScreenState extends ConsumerState<UploadTrainingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<DepartmentModel> _departments = const [];
  String? _departmentId;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final departments =
          await ref.read(databaseServiceProvider).fetchDepartments();
      if (!mounted) return;
      setState(() {
        _departments = departments;
        _departmentId = departments.isNotEmpty ? departments.first.id : null;
      });

      if (_departmentId != null) {
        ref.read(mentorProvider).loadTrainingModules(_departmentId);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
      AppFeedback.info(context, 'Could not open the training module.');
    }
  }

  Future<void> _upload() async {
    final user = ref.read(authProvider).currentUser;

    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _departmentId == null ||
        _filePath == null ||
        user == null) {
      AppFeedback.info(context, 'Please complete all fields.');
      return;
    }

    try {
      await ref.read(mentorProvider).uploadTrainingModule(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            departmentId: _departmentId!,
            uploaderId: user.id,
            localPath: _filePath!,
          );

      if (!mounted) return;
      AppFeedback.success(context, 'Training module uploaded.');

      _titleController.clear();
      _descriptionController.clear();
      setState(() => _filePath = null);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentor = ref.watch(mentorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Upload Training Module'),
      ),
      body: LoadingOverlay(
        isLoading: mentor.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Module Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _departmentId,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          prefixIcon: const Icon(Icons.business_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _departments
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _departmentId = value);
                          ref.read(mentorProvider).loadTrainingModules(value);
                        },
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
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
                              ? 'Pick training file'
                              : _filePath!.split(RegExp(r'[\\/]')).last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _upload,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Upload Module',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Modules',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (mentor.trainingModules.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No modules uploaded yet.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...mentor.trainingModules.map(
                  (module) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        module.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        module.description ?? 'No description provided.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: module.fileUrl.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Open module',
                              onPressed: () => _openFile(module.fileUrl),
                              icon: const Icon(Icons.open_in_new_rounded),
                              color: Theme.of(context).colorScheme.primary,
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
