import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/attendance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, AttendanceStatus> _statusByIntern = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mentorId = ref.read(authProvider).currentUser?.id;
      if (mentorId == null) return;

      await ref.read(mentorProvider).loadInternGroup(mentorId);
      await ref.read(mentorProvider).loadAttendanceForDate(
            mentorId: mentorId,
            date: _selectedDate,
          );

      final group = ref.read(mentorProvider).internGroup;
      for (final intern in group) {
        _statusByIntern.putIfAbsent(intern.id, () => AttendanceStatus.present);
      }

      final existing = ref.read(mentorProvider).attendanceByDate;
      for (final item in existing) {
        _statusByIntern[item.internId] = item.status;
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;

    final mentorId = ref.read(authProvider).currentUser?.id;
    if (mentorId == null) return;

    setState(() => _selectedDate = picked);
    try {
      await ref.read(mentorProvider).loadAttendanceForDate(
            mentorId: mentorId,
            date: picked,
          );

      final group = ref.read(mentorProvider).internGroup;
      for (final intern in group) {
        _statusByIntern[intern.id] = AttendanceStatus.present;
      }

      final existing = ref.read(mentorProvider).attendanceByDate;
      for (final item in existing) {
        _statusByIntern[item.internId] = item.status;
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Could not load attendance: $e');
    }
  }

  Future<void> _save() async {
    final mentorId = ref.read(authProvider).currentUser?.id;
    if (mentorId == null) return;

    try {
      await ref.read(mentorProvider).submitAttendance(
            mentorId: mentorId,
            date: _selectedDate,
            byIntern: Map.of(_statusByIntern),
          );

      if (!mounted) return;
      AppFeedback.success(context, 'Attendance saved successfully.');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentor = ref.watch(mentorProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Go Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/mentor');
            }
          },
        ),
        title: const Text('Attendance Tracking'),
      ),
      body: LoadingOverlay(
        isLoading: mentor.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_available_rounded,
                            color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Date',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _selectedDate.toIso8601String().split('T').first,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.edit_calendar_rounded),
                        label: const Text('Change Date'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              for (final intern in mentor.internGroup)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.secondary.withOpacity(0.1),
                        foregroundColor: theme.colorScheme.secondary,
                        child: const Icon(Icons.person_outline),
                      ),
                      title: Text(
                        intern.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(intern.matricule),
                      trailing: SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<AttendanceStatus>(
                          value: _statusByIntern[intern.id] ??
                              AttendanceStatus.present,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                          ),
                          items: AttendanceStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status.name.toUpperCase(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _statusByIntern[intern.id] = value);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Save Attendance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
