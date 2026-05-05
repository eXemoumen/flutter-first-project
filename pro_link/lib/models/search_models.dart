enum SearchCategory { interns, modules, policies }

class SearchItem {
  const SearchItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.fileUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String? fileUrl;
}

class SearchResultBundle {
  const SearchResultBundle({
    this.interns = const [],
    this.modules = const [],
    this.policies = const [],
  });

  final List<SearchItem> interns;
  final List<SearchItem> modules;
  final List<SearchItem> policies;
}
