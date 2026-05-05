import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/mark_input_widget.dart';
import '../../widgets/responsive_page.dart';

class MarkPerformanceScreen extends ConsumerStatefulWidget {
  const MarkPerformanceScreen({super.key, this.initialInternId});

  final String? initialInternId;

  @override
  ConsumerState<MarkPerformanceScreen> createState() =>
      _MarkPerformanceScreenState();
}

class _MarkPerformanceScreenState extends ConsumerState<MarkPerformanceScreen> {
  String? _selectedInternId;

  late final Map<String, TextEditingController> _markControllers;
  late final Map<String, TextEditingController> _commentControllers;

  @override
  void initState() {
    super.initState();
    _selectedInternId = widget.initialInternId;
    _markControllers = {
      for (final skill in AppConstants.skills) skill: TextEditingController(),
    };
    _commentControllers = {
      for (final skill in AppConstants.skills) skill: TextEditingController(),
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mentorId = ref.read(authProvider).currentUser?.id;
      if (mentorId != null) {
        ref.read(mentorProvider).loadInternGroup(mentorId);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _markControllers.values) {
      c.dispose();
    }
    for (final c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final mentorId = ref.read(authProvider).currentUser?.id;
    final selectedInternId = _selectedInternId;
    if (mentorId == null || selectedInternId == null) return;

    final isAssignedIntern = ref
        .read(mentorProvider)
        .internGroup
        .any((intern) => intern.id == selectedInternId);
    if (!isAssignedIntern) {
      AppFeedback.info(context, 'Select an intern before saving.');
      return;
    }

    final marks = <String, double>{};
    final comments = <String, String>{};

    for (final skill in AppConstants.skills) {
      final markValue = double.tryParse(_markControllers[skill]!.text.trim());
      if (markValue == null || markValue < 0 || markValue > 20) {
        AppFeedback.info(context, 'Invalid mark for $skill. Must be 0 to 20.');
        return;
      }

      marks[skill] = markValue;
      comments[skill] = _commentControllers[skill]!.text.trim();
    }

    try {
      await ref.read(mentorProvider).submitPerformanceMarks(
            mentorId: mentorId,
            internId: selectedInternId,
            marks: marks,
            comments: comments,
          );

      if (!mounted) return;
      AppFeedback.success(context, 'Performance evaluation saved.');
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

    final selectedValue =
        mentor.internGroup.any((intern) => intern.id == _selectedInternId)
            ? _selectedInternId
            : null;

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
        title: const Text('Mark Performance'),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_search_rounded,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Select an Intern',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedValue,
                        decoration: InputDecoration(
                          labelText: 'Assigned Interns',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                        ),
                        items: mentor.internGroup
                            .map(
                              (intern) => DropdownMenuItem(
                                value: intern.id,
                                child: Text(
                                    '${intern.fullName} (${intern.matricule})'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedInternId = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              for (final skill in AppConstants.skills)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MarkInputWidget(
                    skill: skill,
                    controller: _markControllers[skill]!,
                    commentController: _commentControllers[skill]!,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Save Evaluation',
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
