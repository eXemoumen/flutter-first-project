import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class InternGroupScreen extends ConsumerStatefulWidget {
  const InternGroupScreen({super.key});

  @override
  ConsumerState<InternGroupScreen> createState() => _InternGroupScreenState();
}

class _InternGroupScreenState extends ConsumerState<InternGroupScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mentorId = ref.read(authProvider).currentUser?.id;
      if (mentorId != null) {
        ref.read(mentorProvider).loadInternGroup(mentorId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentor = ref.watch(mentorProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final query = _searchController.text.trim().toLowerCase();
    final filtered = mentor.internGroup.where((intern) {
      return intern.fullName.toLowerCase().contains(query) ||
          intern.matricule.toLowerCase().contains(query) ||
          (intern.department ?? '').toLowerCase().contains(query);
    }).toList();

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
        title: const Text('My Intern Group'),
      ),
      body: LoadingOverlay(
        isLoading: mentor.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by name, matricule, or department...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (filtered.isEmpty && !mentor.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
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
                  ),
                )
              else
                for (final intern in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push(
                          '/mentor/mark-performance?internId=${Uri.encodeComponent(intern.id)}',
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              intern.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${intern.matricule} • ${intern.department ?? 'Unassigned'}',
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: 'Attendance',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFD97706).withOpacity(0.1),
                                    foregroundColor: const Color(0xFFD97706),
                                  ),
                                  onPressed: () => context.push('/mentor/attendance'),
                                  icon: const Icon(Icons.event_available_rounded),
                                ),
                                IconButton(
                                  tooltip: 'Mark performance',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF16A34A).withOpacity(0.1),
                                    foregroundColor: const Color(0xFF16A34A),
                                  ),
                                  onPressed: () => context.push(
                                    '/mentor/mark-performance?internId=${Uri.encodeComponent(intern.id)}',
                                  ),
                                  icon: const Icon(Icons.grading_rounded),
                                ),
                              ],
                            ),
                          ),
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
