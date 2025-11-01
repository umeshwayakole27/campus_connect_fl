import 'package:flutter/foundation.dart';
import '../../../core/models/event_model.dart';
import '../data/event_repository.dart';

class EventProvider with ChangeNotifier {
  final EventRepository _repository = EventRepository();

  List<Event> _events = [];
  List<Event> get events => _events;

  Event? _selectedEvent;
  Event? get selectedEvent => _selectedEvent;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Event filters
  EventFilter _filter = EventFilter.all;
  EventFilter get filter => _filter;

  /// Load all events
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _repository.getAllEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load upcoming events only
  Future<void> loadUpcomingEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _repository.getUpcomingEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load event by ID
  Future<void> loadEventById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEvent = await _repository.getEventById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new event
  Future<bool> createEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdEvent = await _repository.createEvent(event);
      if (createdEvent != null) {
        _events.insert(0, createdEvent);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an event
  Future<bool> updateEvent(String id, Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEvent = await _repository.updateEvent(id, event);
      if (updatedEvent != null) {
        final index = _events.indexWhere((e) => e.id == id);
        if (index != -1) {
          _events[index] = updatedEvent;
        }
        _selectedEvent = updatedEvent;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteEvent(id);
      if (success) {
        _events.removeWhere((e) => e.id == id);
        if (_selectedEvent?.id == id) {
          _selectedEvent = null;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set selected event
  void selectEvent(Event? event) {
    _selectedEvent = event;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set filter
  void setFilter(EventFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  /// Get filtered events based on current filter
  List<Event> get filteredEvents {
    final now = DateTime.now();
    
    switch (_filter) {
      case EventFilter.upcoming:
        return _events.where((e) => e.time.isAfter(now)).toList();
      case EventFilter.past:
        return _events.where((e) => e.time.isBefore(now)).toList();
      case EventFilter.today:
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        return _events.where((e) => 
          e.time.isAfter(today) && e.time.isBefore(tomorrow)
        ).toList();
      case EventFilter.all:
        return _events;
    }
  }

  /// Refresh events
  Future<void> refresh() async {
    _repository.clearCache();
    await loadUpcomingEvents();
  }
}

enum EventFilter {
  all,
  upcoming,
  today,
  past,
}
