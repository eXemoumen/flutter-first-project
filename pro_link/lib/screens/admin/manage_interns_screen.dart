import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        title: const Text('Manage Interns'),
      ),
      body: LoadingOverlay(
        isLoading: admin.isLoading,
        child: ResponsivePage(
          maxWidth: 1000,
          child: admin.interns.isEmpty && !admin.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off_rounded,
                          size: 64, color: theme.disabledColor),
                      const SizedBox(height: 16),
                      Text(
                        'No interns found',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: admin.interns.length,
                  itemBuilder: (context, index) {
                    final intern = admin.interns[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InternListTile(
                              name: intern.fullName,
                              matricule: intern.matricule,
                              department: intern.department ?? 'Unassigned',
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 500;
                                final children = [
                                  Expanded(
                                    flex: isWide ? 1 : 0,
                                    child: DropdownButtonFormField<String>(
                                      value: intern.departmentId,
                                      decoration: InputDecoration(
                                        labelText: 'Assign Department',
                                        prefixIcon: const Icon(Icons.business_rounded),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
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
                                  ),
                                  if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                                  Expanded(
                                    flex: isWide ? 1 : 0,
                                    child: DropdownButtonFormField<String>(
                                      value: intern.mentorId,
                                      decoration: InputDecoration(
                                        labelText: 'Assign Mentor',
                                        prefixIcon: const Icon(Icons.person_outline_rounded),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
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
                                  ),
                                ];

                                if (isWide) {
                                  return Row(children: children);
                                } else {
                                  return Column(children: children);
                                }
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
