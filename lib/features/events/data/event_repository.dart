import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/event_model.dart';
import '../../../core/utils.dart';

class EventRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Cache for events
  List<Event>? _cachedEvents;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 2);

  /// Fetch all events
  Future<List<Event>> getAllEvents() async {
    try {
      // Return cached data if available and fresh
      if (_cachedEvents != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _cachedEvents!;
      }

      final response = await _client
          .from('events')
          .select('''
            *,
            created_by_user:users!events_created_by_fkey(id, name, email),
            event_location:campus_locations(id, name, building_code, lat, lng)
          ''')
          .order('time', ascending: true);

      final events = (response as List)
          .map((json) => Event.fromJson(json))
          .toList();

      // Update cache
      _cachedEvents = events;
      _lastFetchTime = DateTime.now();

      return events;
    } catch (e) {
      AppLogger.logError('Failed to fetch events', error: e);
      throw Exception('Failed to fetch events: ${e.toString()}');
    }
  }

  /// Fetch events by date range
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            created_by_user:users!events_created_by_fkey(id, name, email),
            event_location:campus_locations(id, name, building_code, lat, lng)
          ''')
          .gte('time', start.toIso8601String())
          .lte('time', end.toIso8601String())
          .order('time', ascending: true);

      return (response as List)
          .map((json) => Event.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch events by date', error: e);
      throw Exception('Failed to fetch events: ${e.toString()}');
    }
  }

  /// Fetch upcoming events (from now onwards)
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final response = await _client
          .from('events')
          .select('''
            *,
            created_by_user:users!events_created_by_fkey(id, name, email),
            event_location:campus_locations(id, name, building_code, lat, lng)
          ''')
          .gte('time', now.toIso8601String())
          .order('time', ascending: true);

      return (response as List)
          .map((json) => Event.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch upcoming events', error: e);
      throw Exception('Failed to fetch upcoming events: ${e.toString()}');
    }
  }

  /// Fetch a single event by ID
  Future<Event?> getEventById(String id) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            created_by_user:users!events_created_by_fkey(id, name, email),
            event_location:campus_locations(id, name, building_code, lat, lng)
          ''')
          .eq('id', id)
          .single();

      return Event.fromJson(response);
    } catch (e) {
      AppLogger.logError('Failed to fetch event by ID', error: e);
      return null;
    }
  }

  /// Create a new event (Faculty only - RLS enforced)
  Future<Event?> createEvent(Event event) async {
    try {
      // Convert to JSON and remove fields that should be auto-generated
      final eventData = event.toJson();
      eventData.remove('id'); // Let database generate UUID
      eventData.remove('created_at'); // Use database default
      eventData.remove('updated_at'); // Use database default
      
      final response = await _client
          .from('events')
          .insert(eventData)
          .select('''
            *,
            created_by_user:users!events_created_by_fkey(id, name, email),
            event_location:campus_locations(id, name, building_code, lat, lng)
          ''')
          .single();

      // Clear cache
      _cachedEvents = null;
      _lastFetchTime = null;

      return Event.fromJson(response);
    } catch (e) {
      AppLogger.logError('Failed to create event', error: e);
      throw Exception('Failed to create event: ${e.toString()}');
    }
  }

  /// Update an event (Faculty only, own events - RLS enforced)
  Future<Event?> updateEvent(String id, Event event) async {
    try {
      // Convert to JSON and remove fields that shouldn't be updated
      final eventData = event.toJson();
      eventData.remove('id'); // Don't update ID
      eventData.remove('created_by'); // Don't change creator
      eventData.remove('created_at'); // Don't change creation date
      // Keep updated_at as it should be updated
      
      final response = await _client
          .from('events')
          .update(eventData)
          .eq('id', id)
          .select('''
            *,
            created_by_user:users!events_created_by_fkey(id, name, email),
            event_location:campus_locations(id, name, building_code, lat, lng)
          ''')
          .single();

      // Clear cache
      _cachedEvents = null;
      _lastFetchTime = null;

      return Event.fromJson(response);
    } catch (e) {
      AppLogger.logError('Failed to update event', error: e);
      throw Exception('Failed to update event: ${e.toString()}');
    }
  }

  /// Delete an event (Faculty only, own events - RLS enforced)
  Future<bool> deleteEvent(String id) async {
    try {
      await _client.from('events').delete().eq('id', id);

      // Clear cache
      _cachedEvents = null;
      _lastFetchTime = null;

      return true;
    } catch (e) {
      AppLogger.logError('Failed to delete event', error: e);
      throw Exception('Failed to delete event: ${e.toString()}');
    }
  }

  /// Clear cache manually
  void clearCache() {
    _cachedEvents = null;
    _lastFetchTime = null;
  }
}
