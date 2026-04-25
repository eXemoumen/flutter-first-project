import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_models.dart';
import 'database_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(databaseService: ref.watch(databaseServiceProvider));
});

class SearchService {
  SearchService({required DatabaseService databaseService})
      : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<SearchResultBundle> search(String query) async {
    return _databaseService.globalSearch(query);
  }
}
