import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/location_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils.dart';

class LocationRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  // Cache for locations
  List<CampusLocation>? _cachedLocations;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiration = Duration(minutes: 10);
  
  SupabaseClient get _client {
    if (!_supabaseService.isInitialized) {
      throw Exception('Supabase not initialized. Call SupabaseService.instance.initialize() first.');
    }
    return _supabaseService.client;
  }

  // Get all campus locations (with caching)
  Future<List<CampusLocation>> getAllLocations({bool forceRefresh = false}) async {
    // Return cached data if available and not expired
    if (!forceRefresh && 
        _cachedLocations != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheExpiration) {
      AppLogger.logInfo('Returning ${_cachedLocations!.length} cached locations');
      return _cachedLocations!;
    }

    try {
      final response = await _client
          .from('campus_locations')
          .select()
          .order('name');

      final locations = (response as List)
          .map((json) => CampusLocation.fromJson(json))
          .toList();

      // Update cache
      _cachedLocations = locations;
      _lastFetchTime = DateTime.now();

      AppLogger.logInfo('Fetched ${locations.length} campus locations from database');
      return locations;
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to fetch locations', error: e, stackTrace: stackTrace);
      // Return cached data if available, even if expired
      if (_cachedLocations != null) {
        AppLogger.logInfo('Returning stale cache due to error');
        return _cachedLocations!;
      }
      rethrow;
    }
  }
  
  // Clear cache
  void clearCache() {
    _cachedLocations = null;
    _lastFetchTime = null;
  }

  // Get locations by category (using cache)
  Future<List<CampusLocation>> getLocationsByCategory(String category) async {
    final allLocations = await getAllLocations();
    return allLocations.where((loc) => loc.category == category).toList();
  }

  // Get single location by id
  Future<CampusLocation?> getLocationById(String id) async {
    try {
      final response = await _client
          .from('campus_locations')
          .select()
          .eq('id', id)
          .single();

      return CampusLocation.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to fetch location by id', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Search locations by name or building code (using cache)
  Future<List<CampusLocation>> searchLocations(String query) async {
    final allLocations = await getAllLocations();
    final lowerQuery = query.toLowerCase();
    return allLocations.where((loc) {
      return loc.name.toLowerCase().contains(lowerQuery) ||
             (loc.buildingCode?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Add new location (faculty only - enforced by RLS)
  Future<CampusLocation?> addLocation({
    required String name,
    String? description,
    String? buildingCode,
    required double lat,
    required double lng,
    String? category,
    String? floorInfo,
    String? imageUrl,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'building_code': buildingCode,
        'lat': lat,
        'lng': lng,
        'category': category,
        'floor_info': floorInfo,
        'image_url': imageUrl,
      };

      final response = await _client
          .from('campus_locations')
          .insert(data)
          .select()
          .single();

      // Clear cache to force refresh
      clearCache();

      return CampusLocation.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to add location', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update location (faculty only - enforced by RLS)
  Future<CampusLocation?> updateLocation({
    required String id,
    String? name,
    String? description,
    String? buildingCode,
    double? lat,
    double? lng,
    String? category,
    String? floorInfo,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (buildingCode != null) data['building_code'] = buildingCode;
      if (lat != null) data['lat'] = lat;
      if (lng != null) data['lng'] = lng;
      if (category != null) data['category'] = category;
      if (floorInfo != null) data['floor_info'] = floorInfo;
      if (imageUrl != null) data['image_url'] = imageUrl;

      final response = await _client
          .from('campus_locations')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      // Clear cache to force refresh
      clearCache();

      return CampusLocation.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to update location', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete location (faculty only - enforced by RLS)
  Future<void> deleteLocation(String id) async {
    try {
      await _client
          .from('campus_locations')
          .delete()
          .eq('id', id);

      // Clear cache to force refresh
      clearCache();

      AppLogger.logInfo('Deleted location: $id');
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to delete location', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
