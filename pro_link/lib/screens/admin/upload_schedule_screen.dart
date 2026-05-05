import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/date_formatter.dart';
import '../../utils/file_helper.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class UploadScheduleScreen extends ConsumerStatefulWidget {
  const UploadScheduleScreen({super.key});

  @override
  ConsumerState<UploadScheduleScreen> createState() =>
      _UploadScheduleScreenState();
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
      await ref.read(adminProvider).loadSchedules();
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

  Future<void> _openFile(String url) async {
    final launched = await launchUrl(Uri.parse(url));
    if (!launched && mounted) {
      AppFeedback.info(context, 'Could not open the schedule file.');
    }
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
        title: const Text('Upload Timetable'),
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
                        'Upload New Timetable',
                        style: theme.textTheme.titleLarge?.copyWith(
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
                      DropdownButtonFormField<String>(
                        value: _departmentId,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          prefixIcon: const Icon(Icons.business_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: admin.departments
                            .map((d) => DropdownMenuItem(
                                value: d.id, child: Text(d.name)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _departmentId = value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDateRange,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.date_range_rounded),
                              label: Text(
                                _range == null
                                    ? 'Select validity range'
                                    : '${_range!.start.toIso8601String().split('T').first} - '
                                        '${_range!.end.toIso8601String().split('T').first}',
                              ),
                            ),
                          ),
                        ],
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
                                    ? 'Pick schedule file'
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
                          label: const Text('Upload Timetable'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Schedules',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (admin.schedules.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No schedules uploaded yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ),
                )
              else
                ...admin.schedules.map(
                  (schedule) => Card(
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
                          Icons.calendar_month_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        schedule.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${schedule.department ?? 'General'} • '
                          '${DateFormatter.short(schedule.validFrom)} to '
                          '${DateFormatter.short(schedule.validTo)}',
                        ),
                      ),
                      trailing: schedule.fileUrl == null
                          ? null
                          : IconButton.filledTonal(
                              tooltip: 'View document',
                              onPressed: () => _openFile(schedule.fileUrl!),
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
