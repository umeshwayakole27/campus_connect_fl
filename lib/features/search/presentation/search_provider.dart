import 'package:flutter/material.dart';
import '../data/search_repository.dart';
import '../../../core/models/event_model.dart';
import '../../../core/models/faculty_model.dart';
import '../../../core/models/campus_location_model.dart';

enum SearchCategory { all, events, faculty, locations }

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  // State
  String _query = '';
  SearchCategory _category = SearchCategory.all;
  bool _isLoading = false;
  String? _error;

  // Results
  List<Event> _events = [];
  List<Faculty> _faculty = [];
  List<CampusLocation> _locations = [];

  // Search history
  List<String> _searchHistory = [];
  List<String> _popularSearches = [];

  // Getters
  String get query => _query;
  SearchCategory get category => _category;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Event> get events => _events;
  List<Faculty> get faculty => _faculty;
  List<CampusLocation> get locations => _locations;
  List<String> get searchHistory => _searchHistory;
  List<String> get popularSearches => _popularSearches;

  bool get hasResults =>
      _events.isNotEmpty || _faculty.isNotEmpty || _locations.isNotEmpty;

  int get totalResults => _events.length + _faculty.length + _locations.length;

  // Set category
  void setCategory(SearchCategory category) {
    _category = category;
    notifyListeners();
    
    // Re-run search if query exists
    if (_query.isNotEmpty) {
      search(_query);
    }
  }

  // Search with debouncing handled by UI
  Future<void> search(String query) async {
    _query = query.trim();
    
    if (_query.isEmpty) {
      _clearResults();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (_category) {
        case SearchCategory.all:
          final results = await _repository.searchAll(_query);
          _events = results['events'] as List<Event>;
          _faculty = results['faculty'] as List<Faculty>;
          _locations = results['locations'] as List<CampusLocation>;
          break;

        case SearchCategory.events:
          _events = await _repository.searchEvents(_query);
          _faculty = [];
          _locations = [];
          break;

        case SearchCategory.faculty:
          _faculty = await _repository.searchFaculty(_query);
          _events = [];
          _locations = [];
          break;

        case SearchCategory.locations:
          _locations = await _repository.searchLocations(_query);
          _events = [];
          _faculty = [];
          break;
      }

      _error = null;
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      _clearResults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save search to history
  Future<void> saveToHistory(String userId, String query) async {
    if (query.trim().isEmpty) return;

    await _repository.saveSearchHistory(
      userId,
      query,
      category: _category != SearchCategory.all ? _category.name : null,
    );

    // Refresh history
    await loadSearchHistory(userId);
  }

  // Load search history
  Future<void> loadSearchHistory(String userId) async {
    try {
      final history = await _repository.getSearchHistory(userId);
      _searchHistory = history
          .map((item) => item['query'] as String)
          .toSet() // Remove duplicates
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  // Load popular searches
  Future<void> loadPopularSearches() async {
    try {
      _popularSearches = await _repository.getPopularSearches();
      notifyListeners();
    } catch (e) {
      print('Error loading popular searches: $e');
    }
  }

  // Clear search history
  Future<void> clearHistory(String userId) async {
    try {
      await _repository.clearSearchHistory(userId);
      _searchHistory = [];
      notifyListeners();
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  // Clear current search
  void clearSearch() {
    _query = '';
    _clearResults();
    notifyListeners();
  }

  void _clearResults() {
    _events = [];
    _faculty = [];
    _locations = [];
  }
}
