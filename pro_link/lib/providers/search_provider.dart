import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_models.dart';
import '../services/search_service.dart';

final searchProvider = ChangeNotifierProvider<SearchController>((ref) {
  return SearchController(searchService: ref.watch(searchServiceProvider));
});

class SearchController extends ChangeNotifier {
  SearchController({required SearchService searchService}) : _searchService = searchService;

  final SearchService _searchService;

  bool _isLoading = false;
  String? _error;
  SearchResultBundle _result = const SearchResultBundle();

  bool get isLoading => _isLoading;
  String? get error => _error;
  SearchResultBundle get result => _result;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _result = const SearchResultBundle();
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _searchService.search(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
