import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/event_model.dart';
import '../../../core/models/faculty_model.dart';
import '../../../core/models/campus_location_model.dart';

class SearchRepository {
  final SupabaseClient _supabase = SupabaseService.instance.client;

  // Search across all categories
  Future<Map<String, List<dynamic>>> searchAll(String query) async {
    if (query.trim().isEmpty) {
      return {
        'events': [],
        'faculty': [],
        'locations': [],
      };
    }

    final results = await Future.wait([
      searchEvents(query),
      searchFaculty(query),
      searchLocations(query),
    ]);

    return {
      'events': results[0],
      'faculty': results[1],
      'locations': results[2],
    };
  }

  // Search events by title, description, or location
  Future<List<Event>> searchEvents(String query) async {
    try {
      final searchPattern = '%${query.toLowerCase()}%';
      
      final response = await _supabase
          .from('events')
          .select('''
            *,
            creator:created_by(id, name, email)
          ''')
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern,location.ilike.$searchPattern')
          .order('time', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => Event.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  // Search faculty by name, department, or designation
  Future<List<Faculty>> searchFaculty(String query) async {
    try {
      final searchPattern = '%${query.toLowerCase()}%';
      
      final response = await _supabase
          .from('faculty')
          .select('''
            *,
            user:user_id(id, name, email, profile_pic)
          ''')
          .or('department.ilike.$searchPattern,designation.ilike.$searchPattern,office_location.ilike.$searchPattern')
          .order('created_at', ascending: false)
          .limit(20);

      final List<Faculty> facultyList = [];
      
      for (var json in response as List) {
        // Also search by user name
        final userData = json['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final userName = (userData['name'] as String?)?.toLowerCase() ?? '';
          if (userName.contains(query.toLowerCase())) {
            facultyList.add(Faculty.fromJson(json));
            continue;
          }
        }
        
        // Add if matches department/designation
        facultyList.add(Faculty.fromJson(json));
      }

      return facultyList;
    } catch (e) {
      print('Error searching faculty: $e');
      return [];
    }
  }

  // Search campus locations by name, building code, or description
  Future<List<CampusLocation>> searchLocations(String query) async {
    try {
      final searchPattern = '%${query.toLowerCase()}%';
      
      final response = await _supabase
          .from('campus_locations')
          .select()
          .or('name.ilike.$searchPattern,building_code.ilike.$searchPattern,description.ilike.$searchPattern,category.ilike.$searchPattern')
          .order('name', ascending: true)
          .limit(20);

      return (response as List)
          .map((json) => CampusLocation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  // Save search history
  Future<void> saveSearchHistory(String userId, String query, {String? category}) async {
    try {
      await _supabase.from('search_history').insert({
        'user_id': userId,
        'query': query,
        'category': category,
      });
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  // Get search history for user
  Future<List<Map<String, dynamic>>> getSearchHistory(String userId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('search_history')
          .select()
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(limit);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  // Clear search history
  Future<void> clearSearchHistory(String userId) async {
    try {
      await _supabase
          .from('search_history')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  // Get popular searches (most common queries)
  Future<List<String>> getPopularSearches({int limit = 5}) async {
    try {
      // This would require a more complex query with grouping
      // For now, return recent unique queries
      final response = await _supabase
          .from('search_history')
          .select('query')
          .order('searched_at', ascending: false)
          .limit(limit * 2);

      final queries = (response as List)
          .map((item) => item['query'] as String)
          .toSet()
          .take(limit)
          .toList();

      return queries;
    } catch (e) {
      print('Error getting popular searches: $e');
      return [];
    }
  }
}
