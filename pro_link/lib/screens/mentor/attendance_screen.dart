import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Tracking')),
      body: LoadingOverlay(
        isLoading: mentor.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text('Date: ${_selectedDate.toIso8601String().split('T').first}'),
              ),
              const SizedBox(height: 12),
              for (final intern in mentor.internGroup)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(intern.fullName),
                    subtitle: Text(intern.matricule),
                    trailing: SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<AttendanceStatus>(
                        value: _statusByIntern[intern.id] ?? AttendanceStatus.present,
                        decoration: const InputDecoration(isDense: true),
                        items: AttendanceStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.name),
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
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Attendance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
