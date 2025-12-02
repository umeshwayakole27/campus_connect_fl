import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/models/event_model.dart';
import '../data/event_repository.dart';
import '../../notifications/services/fcm_service.dart';
import '../../notifications/services/event_notification_service.dart';
import '../../notifications/data/notification_repository.dart';

class EventProvider with ChangeNotifier {
  final EventRepository _repository = EventRepository();
  final EventNotificationService _notificationService = EventNotificationService();
  final NotificationRepository _notificationRepository = NotificationRepository();
  final FCMService _fcmService = FCMService();

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

  /// Initialize event provider
  Future<void> initialize() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  /// Load all events
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final previousEventIds = _events.map((e) => e.id).toSet();
      _events = await _repository.getAllEvents();
      
      // Find new events that user hasn't seen before
      final newEvents = _events.where((event) => 
        !previousEventIds.contains(event.id) && 
        event.time.isAfter(DateTime.now())
      ).toList();
      
      if (newEvents.isNotEmpty) {
        debugPrint('📢 Found ${newEvents.length} new events, scheduling local reminders...');
        for (final event in newEvents) {
          // Schedule local reminders for each new event
          await _scheduleEventReminders(event);
        }
      }
      
      // Rehydrate pending notification schedules for all upcoming events
      final upcomingEvents = _events.where((e) => e.time.isAfter(DateTime.now())).toList();
      await _notificationService.rehydratePendingSchedules(upcomingEvents);
      
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
      
      debugPrint('📅 Loaded ${_events.length} upcoming events');
      
      // Schedule reminders for ALL upcoming events (force rehydration)
      for (final event in _events) {
        if (event.time.isAfter(DateTime.now())) {
          debugPrint('📅 Scheduling reminders for event: ${event.title}');
          await _scheduleEventReminders(event);
        }
      }
      
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
        
        // Send immediate notification to all users via FCM
        await _sendEventNotification(createdEvent);
        
        // Schedule local reminders for all users
        await _scheduleEventReminders(createdEvent);
        
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

  /// Send notification for new event to ALL users
  Future<void> _sendEventNotification(Event event) async {
    try {
      // Format event time
      final dateFormat = DateFormat('EEEE, MMM dd');
      final timeFormat = DateFormat('h:mm a');
      final eventDate = dateFormat.format(event.time);
      final eventTime = timeFormat.format(event.time);
      
      // Create notification title and body
      final title = '📅 New Event: ${event.title}';
      final body = '$eventDate at $eventTime${event.location != null ? '\n📍 ${event.location}' : ''}';
      
      debugPrint('📢 Sending event notification to ALL users: ${event.id}');
      debugPrint('   Title: $title');
      debugPrint('   Body: $body');
      
      // 1. Send FCM push notification to ALL users via broadcast
      try {
        await _notificationRepository.broadcastNotification(
          type: 'event',
          title: title,
          message: body,
          eventData: {
            'event_id': event.id,
            'event_title': event.title,
            'event_time': event.time.toIso8601String(),
            'event_location': event.location ?? '',
          },
        );
        debugPrint('✅ FCM broadcast notification sent to all users');
      } catch (e) {
        debugPrint('⚠️  FCM broadcast failed (users will still see event in app): $e');
      }
      
      // 2. Send local notification on THIS device (for immediate feedback)
      await _notificationService.showImmediateNotification(
        event.id,
        event.title,
        body,
        data: {
          'event_id': event.id,
          'event_title': event.title,
          'event_time': event.time.toIso8601String(),
          'event_location': event.location ?? '',
        },
      );
      
      debugPrint('✅ Immediate local notification shown on creator device');
      
    } catch (e) {
      // Don't fail event creation if notification fails
      debugPrint('❌ Failed to send event notification: $e');
    }
  }

  /// Schedule reminders for the event
  Future<void> _scheduleEventReminders(Event event) async {
    try {
      // Schedule morning reminder (8:00 AM on event day)
      await _notificationService.scheduleMorningReminder(event);
      
      // Schedule 1-hour before reminder
      await _notificationService.scheduleOneHourReminder(event);
      
      debugPrint('Scheduled reminders for event: ${event.id}');
    } catch (e) {
      debugPrint('Failed to schedule reminders: $e');
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
        
        // Reschedule notifications for updated event
        await _notificationService.rescheduleOnUpdate(updatedEvent);
        
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
        
        // Cancel all notifications for deleted event
        await _notificationService.cancelEventNotifications(id);
        
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
