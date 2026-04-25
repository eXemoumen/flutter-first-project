import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/mark_input_widget.dart';
import '../../widgets/responsive_page.dart';

class MarkPerformanceScreen extends ConsumerStatefulWidget {
  const MarkPerformanceScreen({super.key});

  @override
  ConsumerState<MarkPerformanceScreen> createState() => _MarkPerformanceScreenState();
}

class _MarkPerformanceScreenState extends ConsumerState<MarkPerformanceScreen> {
  String? _selectedInternId;

  late final Map<String, TextEditingController> _markControllers;
  late final Map<String, TextEditingController> _commentControllers;

  @override
  void initState() {
    super.initState();
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
    if (mentorId == null || _selectedInternId == null) return;

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
            internId: _selectedInternId!,
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

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Performance')),
      body: LoadingOverlay(
        isLoading: mentor.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedInternId,
                decoration: const InputDecoration(labelText: 'Select Intern'),
                items: mentor.internGroup
                    .map(
                      (intern) => DropdownMenuItem(
                        value: intern.id,
                        child: Text('${intern.fullName} (${intern.matricule})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedInternId = value),
              ),
              const SizedBox(height: 16),
              for (final skill in AppConstants.skills)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MarkInputWidget(
                    skill: skill,
                    controller: _markControllers[skill]!,
                    commentController: _commentControllers[skill]!,
                  ),
                ),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Evaluation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
