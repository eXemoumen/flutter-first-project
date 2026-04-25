import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/intern_list_tile.dart';
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
    final query = _searchController.text.trim().toLowerCase();
    final filtered = mentor.internGroup.where((intern) {
      return intern.fullName.toLowerCase().contains(query) ||
          intern.matricule.toLowerCase().contains(query) ||
          (intern.department ?? '').toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Intern Group')),
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
                decoration: const InputDecoration(
                  hintText: 'Search by name, matricule, or department',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              for (final intern in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InternListTile(
                    name: intern.fullName,
                    matricule: intern.matricule,
                    department: intern.department ?? 'Unassigned',
                    onTap: () => AppFeedback.info(context, '${intern.fullName} selected.'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
