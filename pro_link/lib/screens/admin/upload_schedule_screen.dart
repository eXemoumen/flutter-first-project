import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/file_helper.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class UploadScheduleScreen extends ConsumerStatefulWidget {
  const UploadScheduleScreen({super.key});

  @override
  ConsumerState<UploadScheduleScreen> createState() => _UploadScheduleScreenState();
}

class _UploadScheduleScreenState extends ConsumerState<UploadScheduleScreen> {
  final _titleController = TextEditingController();
  DateTimeRange? _range;
  String? _filePath;
  String? _departmentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(adminProvider).loadManageInternData();
      final departments = ref.read(adminProvider).departments;
      if (departments.isNotEmpty && mounted) {
        setState(() => _departmentId = departments.first.id);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (selected == null) return;
    setState(() => _range = selected);
  }

  Future<void> _pickFile() async {
    final path = await FileHelper.pickDocumentPath();
    if (path == null) return;
    setState(() => _filePath = path);
  }

  Future<void> _upload() async {
    final user = ref.read(authProvider).currentUser;

    if (_titleController.text.trim().isEmpty ||
        _departmentId == null ||
        _range == null ||
        _filePath == null ||
        user == null) {
      AppFeedback.info(context, 'Please complete all fields.');
      return;
    }

    try {
      await ref.read(adminProvider).uploadSchedule(
            title: _titleController.text.trim(),
            departmentId: _departmentId!,
            uploaderId: user.id,
            from: _range!.start,
            to: _range!.end,
            localFilePath: _filePath!,
          );

      if (!mounted) return;
      AppFeedback.success(context, 'Schedule uploaded successfully.');
      _titleController.clear();
      setState(() {
        _range = null;
        _filePath = null;
      });
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Timetable')),
      body: LoadingOverlay(
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 900,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _departmentId,
                decoration: const InputDecoration(labelText: 'Department'),
                items: admin.departments
                    .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                    .toList(),
                onChanged: (value) => setState(() => _departmentId = value),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range_rounded),
                label: Text(_range == null
                    ? 'Select validity range'
                    : '${_range!.start.toIso8601String().split('T').first} - ${_range!.end.toIso8601String().split('T').first}'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(
                  _filePath == null
                      ? 'Pick schedule file'
                      : _filePath!.split(RegExp(r'[\\/]')).last,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _upload,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
