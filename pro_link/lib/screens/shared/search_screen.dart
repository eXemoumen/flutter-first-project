import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/search_models.dart';
import '../../providers/search_provider.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/search_bar_widget.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

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
                                _ResultList(items: search.result.interns),
                                _ResultList(items: search.result.modules),
                                _ResultList(items: search.result.policies),
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
  const _ResultList({required this.items});

  final List<SearchItem> items;

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
}

