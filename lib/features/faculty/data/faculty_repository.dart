import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/faculty_model.dart';
import '../../../core/utils.dart';

class FacultyRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Cache for faculty list
  List<Faculty>? _cachedFaculty;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// Fetch all faculty members with their user information
  Future<List<Faculty>> getAllFaculty() async {
    try {
      // Return cached data if available and fresh
      if (_cachedFaculty != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _cachedFaculty!;
      }

      final response = await _client
          .from('faculty')
          .select('''
            *,
            user:users!user_id(id, name, email, profile_pic)
          ''')
          .order('created_at', ascending: false);

      AppLogger.logInfo('Faculty response received, parsing...');
      AppLogger.logInfo('Raw response: $response');
      AppLogger.logInfo('Raw response type: ${response.runtimeType}');
      
      final faculty = (response as List).map((json) {
        AppLogger.logInfo('Raw JSON keys: ${json.keys}');
        AppLogger.logInfo('user field: ${json['user']}');
        
        final facultyObj = Faculty.fromJson(json);
        AppLogger.logInfo('Faculty userName: ${facultyObj.userName}');
        return facultyObj;
      }).toList();

      // Update cache
      _cachedFaculty = faculty;
      _lastFetchTime = DateTime.now();

      AppLogger.logInfo('Fetched ${faculty.length} faculty members');
      if (faculty.isNotEmpty) {
        AppLogger.logInfo('First faculty name: ${faculty.first.userName}');
      }
      return faculty;
    } catch (e) {
      AppLogger.logError('Failed to fetch faculty', error: e);
      throw Exception('Failed to fetch faculty: ${e.toString()}');
    }
  }

  /// Fetch faculty by ID
  Future<Faculty?> getFacultyById(String id) async {
    try {
      final response = await _client
          .from('faculty')
          .select('''
            *,
            user:users!user_id(id, name, email, profile_pic)
          ''')
          .eq('id', id)
          .single();

      return Faculty.fromJson(response);
    } catch (e) {
      AppLogger.logError('Failed to fetch faculty by ID', error: e);
      return null;
    }
  }

  /// Fetch faculty by user ID
  Future<Faculty?> getFacultyByUserId(String userId) async {
    try {
      final response = await _client
          .from('faculty')
          .select('''
            *,
            user:users!user_id(id, name, email, profile_pic)
          ''')
          .eq('user_id', userId)
          .single();

      return Faculty.fromJson(response);
    } catch (e) {
      AppLogger.logError('Failed to fetch faculty by user ID', error: e);
      return null;
    }
  }

  /// Fetch faculty by department
  Future<List<Faculty>> getFacultyByDepartment(String department) async {
    try {
      final response = await _client
          .from('faculty')
          .select('''
            *,
            user:users!user_id(id, name, email, profile_pic)
          ''')
          .eq('department', department)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Faculty.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch faculty by department', error: e);
      throw Exception('Failed to fetch faculty: ${e.toString()}');
    }
  }

  /// Search faculty by name
  Future<List<Faculty>> searchFaculty(String query) async {
    try {
      final response = await _client
          .from('faculty')
          .select('''
            *,
            user:users!user_id(id, name, email, profile_pic)
          ''')
          .order('created_at', ascending: false);

      // Filter by name in memory since Supabase doesn't support filtering on joined tables easily
      final allFaculty = (response as List)
          .map((json) => Faculty.fromJson(json))
          .toList();
      
      return allFaculty.where((faculty) {
        final name = faculty.userName?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      AppLogger.logError('Failed to search faculty', error: e);
      throw Exception('Failed to search faculty: ${e.toString()}');
    }
  }

  /// Get unique departments
  Future<List<String>> getDepartments() async {
    try {
      final response = await _client
          .from('faculty')
          .select('department')
          .order('department', ascending: true);

      final departments = <String>{};
      for (var item in response as List) {
        if (item['department'] != null) {
          departments.add(item['department'] as String);
        }
      }

      return departments.toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch departments', error: e);
      return [];
    }
  }

  /// Update faculty profile
  Future<Faculty?> updateFaculty(String id, Faculty faculty) async {
    try {
      // Convert to JSON and remove fields that shouldn't be updated
      final facultyData = faculty.toJson();
      facultyData.remove('id');
      facultyData.remove('user_id');
      facultyData.remove('created_at');
      facultyData.remove('user'); // Remove nested user data
      
      final response = await _client
          .from('faculty')
          .update(facultyData)
          .eq('id', id)
          .select('''
            *,
            user:users!user_id(id, name, email, profile_pic)
          ''')
          .single();

      // Clear cache
      _cachedFaculty = null;
      _lastFetchTime = null;

      AppLogger.logInfo('Updated faculty profile: $id');
      return Faculty.fromJson(response);
    } catch (e) {
      AppLogger.logError('Failed to update faculty', error: e);
      throw Exception('Failed to update faculty: ${e.toString()}');
    }
  }

  /// Clear cache manually
  void clearCache() {
    _cachedFaculty = null;
    _lastFetchTime = null;
  }
}
