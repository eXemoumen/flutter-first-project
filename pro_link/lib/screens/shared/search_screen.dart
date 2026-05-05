import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/search_models.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/search_bar_widget.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  Future<void> _openResult(
    BuildContext context,
    WidgetRef ref,
    SearchItem item,
  ) async {
    switch (item.category) {
      case SearchCategory.interns:
        _openInternResult(context, ref);
        return;
      case SearchCategory.modules:
      case SearchCategory.policies:
        await _openDocumentResult(context, item);
    }
  }

  void _openInternResult(BuildContext context, WidgetRef ref) {
    final role = ref.read(authProvider).role;
    switch (role) {
      case AppRole.admin:
        context.push('/admin/manage-interns');
        return;
      case AppRole.mentor:
        context.push('/mentor/intern-group');
        return;
      case AppRole.intern:
      case null:
        AppFeedback.info(
            context, 'Intern details are available from your dashboard.');
    }
  }

  Future<void> _openDocumentResult(
      BuildContext context, SearchItem item) async {
    final fileUrl = item.fileUrl;
    if (fileUrl == null || fileUrl.isEmpty) {
      AppFeedback.info(
          context, 'No document link is available for this result.');
      return;
    }

    final launched = await launchUrl(Uri.parse(fileUrl));
    if (!launched && context.mounted) {
      AppFeedback.info(context, 'Could not open the document.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ResponsivePage(
        maxWidth: 1060,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resultHeight = constraints.maxWidth < 760 ? 420.0 : 520.0;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                SearchBarWidget(
                  onChanged: (query) => ref.read(searchProvider).search(query),
                ),
                const SizedBox(height: 16),
                if (search.isLoading) const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Card(
                  child: SizedBox(
                    height: resultHeight,
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: 'Interns'),
                              Tab(text: 'Modules'),
                              Tab(text: 'Policies'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _ResultList(
                                  items: search.result.interns,
                                  onOpen: (item) =>
                                      _openResult(context, ref, item),
                                ),
                                _ResultList(
                                  items: search.result.modules,
                                  onOpen: (item) =>
                                      _openResult(context, ref, item),
                                ),
                                _ResultList(
                                  items: search.result.policies,
                                  onOpen: (item) =>
                                      _openResult(context, ref, item),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.items,
    required this.onOpen,
  });

  final List<SearchItem> items;
  final ValueChanged<SearchItem> onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No results'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(_iconForCategory(item.category)),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          trailing: IconButton(
            tooltip: _actionLabelForCategory(item.category),
            onPressed: () => onOpen(item),
            icon: Icon(_actionIconForCategory(item.category)),
          ),
          onTap: () => onOpen(item),
        );
      },
    );
  }

  IconData _iconForCategory(SearchCategory category) {
    switch (category) {
      case SearchCategory.interns:
        return Icons.person_search_rounded;
      case SearchCategory.modules:
        return Icons.menu_book_rounded;
      case SearchCategory.policies:
        return Icons.policy_rounded;
    }
  }

  IconData _actionIconForCategory(SearchCategory category) {
    switch (category) {
      case SearchCategory.interns:
        return Icons.chevron_right_rounded;
      case SearchCategory.modules:
      case SearchCategory.policies:
        return Icons.open_in_new_rounded;
    }
  }

  String _actionLabelForCategory(SearchCategory category) {
    switch (category) {
      case SearchCategory.interns:
        return 'Open related workspace';
      case SearchCategory.modules:
        return 'Open module';
      case SearchCategory.policies:
        return 'Open policy';
    }
  }
}
