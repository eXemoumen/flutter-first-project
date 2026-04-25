import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ConsumerState<UploadTrainingScreen> createState() => _UploadTrainingScreenState();
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
      final departments = await ref.read(databaseServiceProvider).fetchDepartments();
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
      appBar: AppBar(title: const Text('Upload Training Module')),
      body: LoadingOverlay(
        isLoading: mentor.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _departmentId,
                decoration: const InputDecoration(labelText: 'Department'),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(
                  _filePath == null
                      ? 'Pick training file'
                      : _filePath!.split(RegExp(r'[\\/]')).last,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _upload,
                child: const Text('Upload Module'),
              ),
              const SizedBox(height: 20),
              Text(
                'Recent modules',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...mentor.trainingModules.map(
                (m) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(m.title),
                    subtitle: Text(m.description ?? ''),
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
