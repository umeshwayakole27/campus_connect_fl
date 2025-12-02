import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../../core/models/event_model.dart';
import '../../../core/utils.dart';

/// Service to handle event notifications and reminders
/// 
/// Features:
/// - Immediate notification when event is created
/// - Morning reminder at 8:00 AM on event day
/// - One hour before event reminder
/// - Cancel/reschedule on event update/delete
/// - Persist scheduled notifications across app restarts
class EventNotificationService {
  static final EventNotificationService _instance = EventNotificationService._internal();
  factory EventNotificationService() => _instance;
  EventNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  static const String _scheduledNotificationsKey = 'scheduled_event_notifications';
  
  // Notification channels
  static const String _eventChannelId = 'event_notifications';
  static const String _eventChannelName = 'Event Notifications';
  static const String _reminderChannelId = 'event_reminders';
  static const String _reminderChannelName = 'Event Reminders';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      
      // Get local timezone
      final locationName = await _getLocalTimeZone();
      tz.setLocalLocation(tz.getLocation(locationName));

      await _initializeLocalNotifications();
      _initialized = true;
      AppLogger.logInfo('Event Notification Service initialized');
    } catch (e) {
      AppLogger.logError('Failed to initialize Event Notification Service', error: e);
    }
  }

  /// Get the device's local timezone
  Future<String> _getLocalTimeZone() async {
    try {
      // Try to detect timezone from native platform
      final String timeZoneName = DateTime.now().timeZoneName;
      
      // Map common timezone abbreviations to IANA timezone names
      const timezoneMap = {
        'IST': 'Asia/Kolkata',
        'UTC': 'UTC',
        'GMT': 'Europe/London',
        'EST': 'America/New_York',
        'PST': 'America/Los_Angeles',
        'CST': 'America/Chicago',
        'MST': 'America/Denver',
      };
      
      // If it's a known abbreviation, use the mapped name
      if (timezoneMap.containsKey(timeZoneName)) {
        return timezoneMap[timeZoneName]!;
      }
      
      // Try to use it directly
      try {
        tz.getLocation(timeZoneName);
        return timeZoneName;
      } catch (e) {
        // If it fails, default to Asia/Kolkata for India
        AppLogger.logWarning('Could not find timezone $timeZoneName, defaulting to Asia/Kolkata');
        return 'Asia/Kolkata';
      }
    } catch (e) {
      // Fallback to Asia/Kolkata (IST) for India
      AppLogger.logWarning('Failed to detect timezone, defaulting to Asia/Kolkata');
      return 'Asia/Kolkata';
    }
  }

  /// Initialize local notifications with Android and iOS settings
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Event notifications channel
    const eventChannel = AndroidNotificationChannel(
      _eventChannelId,
      _eventChannelName,
      description: 'Notifications for new campus events',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Reminder notifications channel
    const reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: 'Reminders for upcoming campus events',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await androidPlugin.createNotificationChannel(eventChannel);
    await androidPlugin.createNotificationChannel(reminderChannel);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    try {
      // Add a delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      final iosPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      // Request Android 13+ permission
      if (androidPlugin != null) {
        // Check if we already have permission (Android 12 and below)
        bool? alreadyGranted;
        try {
          alreadyGranted = await androidPlugin.areNotificationsEnabled();
        } catch (e) {
          // Method might not be available on all Android versions
          alreadyGranted = null;
        }
        
        // Only request if not already granted or if we couldn't check
        if (alreadyGranted != true) {
          final granted = await androidPlugin.requestNotificationsPermission();
          if (granted != true) {
            AppLogger.logWarning('Android notification permission denied');
            return false;
          }
        }
      }

      // Request iOS permissions
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted != true) {
          AppLogger.logWarning('iOS notification permission denied');
          return false;
        }
      }

      AppLogger.logInfo('Notification permissions granted');
      return true;
    } catch (e) {
      AppLogger.logError('Error requesting notification permissions', error: e);
      return false;
    }
  }

  /// Show immediate notification when a new event is created
  Future<void> showImmediateNotification(
    String eventId,
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!_initialized) {
        AppLogger.logWarning('EventNotificationService not initialized, initializing now...');
        await initialize();
      }

      final notificationId = _generateNotificationId(eventId, 'immediate');

      AppLogger.logInfo('Showing immediate notification - ID: $notificationId, Title: $title');

      const androidDetails = AndroidNotificationDetails(
        _eventChannelId,
        _eventChannelName,
        channelDescription: 'Notifications for new campus events',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notificationId,
        '📅 New Event: $title',
        body,
        details,
        payload: jsonEncode({
          'type': 'new_event',
          'event_id': eventId,
          ...?data,
        }),
      );

      AppLogger.logInfo('✅ Immediate notification shown successfully for event: $eventId');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to show immediate notification', error: e, stackTrace: stackTrace);
      // Don't rethrow - notification failure shouldn't break event creation
    }
  }

  /// Schedule morning reminder at 8:00 AM on event day
  Future<void> scheduleMorningReminder(Event event) async {
    if (!_initialized) {
      AppLogger.logWarning('Notification service not initialized, initializing now...');
      await initialize();
    }

    try {
      final eventDateTime = event.time;
      final morningTime = DateTime(
        eventDateTime.year,
        eventDateTime.month,
        eventDateTime.day,
        8, // 8:00 AM
        0,
        0,
      );

      final now = DateTime.now();
      AppLogger.logInfo('📅 Scheduling morning reminder:');
      AppLogger.logInfo('   Event: ${event.title} (${event.id})');
      AppLogger.logInfo('   Event time: $eventDateTime');
      AppLogger.logInfo('   Morning reminder: $morningTime');
      AppLogger.logInfo('   Current time: $now');

      // Don't schedule if morning time has already passed
      if (morningTime.isBefore(now)) {
        AppLogger.logWarning('⏭️ Morning reminder time has passed, skipping');
        return;
      }

      final notificationId = _generateNotificationId(event.id, 'morning');
      
      // Convert to timezone-aware datetime
      final location = tz.local;
      final tzDateTime = tz.TZDateTime(
        location,
        morningTime.year,
        morningTime.month,
        morningTime.day,
        morningTime.hour,
        morningTime.minute,
        morningTime.second,
      );

      AppLogger.logInfo('   Notification ID: $notificationId');
      AppLogger.logInfo('   TZ DateTime: $tzDateTime');
      AppLogger.logInfo('   Timezone: ${location.name}');

      const androidDetails = AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: 'Reminders for upcoming campus events',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final formattedTime = _formatEventTime(eventDateTime);
      final body = '🕐 ${event.title}\nTime: $formattedTime${event.location != null ? '\n📍 ${event.location}' : ''}';

      await _localNotifications.zonedSchedule(
        notificationId,
        '☀️ Event Today!',
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'type': 'morning_reminder',
          'event_id': event.id,
          'event_title': event.title,
        }),
      );

      // Check if already scheduled before saving
      final existing = await _getScheduledNotifications(event.id);
      if (existing['morning'] == null) {
        await _saveScheduledNotification(event.id, 'morning', morningTime);
        AppLogger.logInfo('✅ Morning reminder scheduled successfully!');
      } else {
        AppLogger.logInfo('ℹ️  Morning reminder already exists, re-scheduled');
      }
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to schedule morning reminder', error: e, stackTrace: stackTrace);
    }
  }

  /// Schedule reminder 1 hour before event
  Future<void> scheduleOneHourReminder(Event event) async {
    if (!_initialized) {
      AppLogger.logWarning('Notification service not initialized, initializing now...');
      await initialize();
    }

    try {
      final eventDateTime = event.time;
      final oneHourBefore = eventDateTime.subtract(const Duration(hours: 1));

      final now = DateTime.now();
      AppLogger.logInfo('⏰ Scheduling 1-hour reminder:');
      AppLogger.logInfo('   Event: ${event.title} (${event.id})');
      AppLogger.logInfo('   Event time: $eventDateTime');
      AppLogger.logInfo('   Reminder time: $oneHourBefore');
      AppLogger.logInfo('   Current time: $now');

      // Don't schedule if reminder time has already passed
      if (oneHourBefore.isBefore(now)) {
        AppLogger.logWarning('⏭️ One hour reminder time has passed, skipping');
        return;
      }

      final notificationId = _generateNotificationId(event.id, 'one_hour');
      
      // Convert to timezone-aware datetime
      final location = tz.local;
      final tzDateTime = tz.TZDateTime(
        location,
        oneHourBefore.year,
        oneHourBefore.month,
        oneHourBefore.day,
        oneHourBefore.hour,
        oneHourBefore.minute,
        oneHourBefore.second,
      );

      AppLogger.logInfo('   Notification ID: $notificationId');
      AppLogger.logInfo('   TZ DateTime: $tzDateTime');
      AppLogger.logInfo('   Timezone: ${location.name}');

      const androidDetails = AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: 'Reminders for upcoming campus events',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final formattedTime = _formatEventTime(eventDateTime);
      final body = '🕐 ${event.title}\nTime: $formattedTime${event.location != null ? '\n📍 ${event.location}' : ''}';

      await _localNotifications.zonedSchedule(
        notificationId,
        '⏰ Event Starting in 1 Hour!',
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'type': 'one_hour_reminder',
          'event_id': event.id,
          'event_title': event.title,
        }),
      );

      // Check if already scheduled before saving
      final existing = await _getScheduledNotifications(event.id);
      if (existing['one_hour'] == null) {
        await _saveScheduledNotification(event.id, 'one_hour', oneHourBefore);
        AppLogger.logInfo('✅ One hour reminder scheduled successfully!');
      } else {
        AppLogger.logInfo('ℹ️  One hour reminder already exists, re-scheduled');
      }
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to schedule 1-hour reminder', error: e, stackTrace: stackTrace);
    }
  }

  /// Cancel all notifications for a specific event
  Future<void> cancelEventNotifications(String eventId) async {
    if (!_initialized) await initialize();

    try {
      final immediateId = _generateNotificationId(eventId, 'immediate');
      final morningId = _generateNotificationId(eventId, 'morning');
      final oneHourId = _generateNotificationId(eventId, 'one_hour');

      await _localNotifications.cancel(immediateId);
      await _localNotifications.cancel(morningId);
      await _localNotifications.cancel(oneHourId);

      // Remove from scheduled notifications
      await _removeScheduledNotification(eventId);

      AppLogger.logInfo('Cancelled all notifications for event: $eventId');
    } catch (e) {
      AppLogger.logError('Failed to cancel event notifications', error: e);
    }
  }

  /// Reschedule notifications when event is updated
  Future<void> rescheduleOnUpdate(Event event) async {
    if (!_initialized) await initialize();

    try {
      // Cancel existing notifications
      await cancelEventNotifications(event.id);

      // Check if scheduled notifications exist and if they're duplicates
      final existingSchedules = await _getScheduledNotifications(event.id);
      
      if (existingSchedules.isEmpty) {
        // Schedule new reminders
        await scheduleMorningReminder(event);
        await scheduleOneHourReminder(event);
        
        AppLogger.logInfo('Rescheduled notifications for updated event: ${event.id}');
      } else {
        // Verify times haven't changed significantly
        final morningSchedule = existingSchedules['morning'];
        final oneHourSchedule = existingSchedules['one_hour'];
        
        final expectedMorning = DateTime(
          event.time.year,
          event.time.month,
          event.time.day,
          8, 0, 0,
        );
        final expectedOneHour = event.time.subtract(const Duration(hours: 1));

        // Reschedule only if times have changed
        if (morningSchedule == null || 
            (morningSchedule as DateTime).difference(expectedMorning).abs().inMinutes > 5) {
          await scheduleMorningReminder(event);
        }

        if (oneHourSchedule == null || 
            (oneHourSchedule as DateTime).difference(expectedOneHour).abs().inMinutes > 5) {
          await scheduleOneHourReminder(event);
        }
      }
    } catch (e) {
      AppLogger.logError('Failed to reschedule notifications', error: e);
    }
  }

  /// Schedule all reminders for an event (called when event is created or synced)
  Future<void> scheduleEventReminders(Event event) async {
    if (!_initialized) await initialize();

    try {
      debugPrint('🔔 Scheduling event reminders for: ${event.title} (${event.id})');
      
      // Always schedule reminders - the individual functions will check for duplicates
      await scheduleMorningReminder(event);
      await scheduleOneHourReminder(event);
      
      AppLogger.logInfo('✅ Scheduled all reminders for event: ${event.id}');
    } catch (e) {
      AppLogger.logError('Failed to schedule event reminders', error: e);
    }
  }

  /// Re-initialize and rehydrate pending schedules on app launch
  Future<void> rehydratePendingSchedules(List<Event> events) async {
    if (!_initialized) await initialize();

    try {
      AppLogger.logInfo('Rehydrating pending notification schedules...');

      for (final event in events) {
        // Only schedule for future events
        if (event.time.isAfter(DateTime.now())) {
          await scheduleEventReminders(event);
        } else {
          // Clean up notifications for past events
          await cancelEventNotifications(event.id);
        }
      }

      AppLogger.logInfo('Rehydration complete for ${events.length} events');
    } catch (e) {
      AppLogger.logError('Failed to rehydrate schedules', error: e);
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        AppLogger.logInfo('Notification tapped: ${data['type']}');
        
        // TODO: Navigate to event detail screen
        // You can use a NavigatorKey or stream to handle navigation
      }
    } catch (e) {
      AppLogger.logError('Error handling notification tap', error: e);
    }
  }

  /// Generate unique notification ID based on event ID and type
  int _generateNotificationId(String eventId, String type) {
    final combined = '$eventId-$type';
    return combined.hashCode.abs() % 2147483647; // Keep within int32 range
  }

  /// Format event time for notification
  String _formatEventTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Save scheduled notification to persistent storage
  Future<void> _saveScheduledNotification(
    String eventId,
    String type,
    DateTime scheduledTime,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_scheduledNotificationsKey-$eventId';
      
      final existing = prefs.getString(key);
      Map<String, dynamic> schedules = {};
      
      if (existing != null) {
        schedules = jsonDecode(existing);
      }
      
      schedules[type] = scheduledTime.toIso8601String();
      
      await prefs.setString(key, jsonEncode(schedules));
    } catch (e) {
      AppLogger.logError('Failed to save scheduled notification', error: e);
    }
  }

  /// Get scheduled notifications for an event
  Future<Map<String, dynamic>> _getScheduledNotifications(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_scheduledNotificationsKey-$eventId';
      final existing = prefs.getString(key);
      
      if (existing != null) {
        final schedules = jsonDecode(existing) as Map<String, dynamic>;
        // Convert ISO strings back to DateTime
        return schedules.map((k, v) => MapEntry(k, DateTime.parse(v)));
      }
    } catch (e) {
      AppLogger.logError('Failed to get scheduled notifications', error: e);
    }
    return {};
  }

  /// Remove scheduled notification from persistent storage
  Future<void> _removeScheduledNotification(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_scheduledNotificationsKey-$eventId';
      await prefs.remove(key);
    } catch (e) {
      AppLogger.logError('Failed to remove scheduled notification', error: e);
    }
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    
    await _localNotifications.cancelAll();
    
    // Clear all from storage
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_scheduledNotificationsKey));
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    AppLogger.logInfo('All notifications cancelled');
  }
}
