import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/intern_list_tile.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class ManageInternsScreen extends ConsumerStatefulWidget {
  const ManageInternsScreen({super.key});

  @override
  ConsumerState<ManageInternsScreen> createState() => _ManageInternsScreenState();
}

class _ManageInternsScreenState extends ConsumerState<ManageInternsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider).loadManageInternData();
    });
  }

  Future<void> _assignIntern({
    required String internId,
    String? departmentId,
    String? mentorId,
  }) async {
    try {
      await ref.read(adminProvider).assignIntern(
            internId: internId,
            departmentId: departmentId,
            mentorId: mentorId,
          );
      if (!mounted) return;
      AppFeedback.success(context, 'Intern assignment updated.');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Update failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Interns')),
      body: LoadingOverlay(
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 1000,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: admin.interns.length,
            itemBuilder: (context, index) {
              final intern = admin.interns[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      InternListTile(
                        name: intern.fullName,
                        matricule: intern.matricule,
                        department: intern.department ?? 'Unassigned',
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: intern.departmentId,
                        decoration: const InputDecoration(labelText: 'Department'),
                        items: admin.departments
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          _assignIntern(
                            internId: intern.id,
                            departmentId: value,
                            mentorId: intern.mentorId,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: intern.mentorId,
                        decoration: const InputDecoration(labelText: 'Mentor'),
                        items: admin.mentors
                            .map(
                              (m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          _assignIntern(
                            internId: intern.id,
                            departmentId: intern.departmentId,
                            mentorId: value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
