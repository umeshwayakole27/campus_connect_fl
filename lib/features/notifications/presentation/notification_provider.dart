import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/notification_repository.dart';
import '../services/fcm_service.dart';
import '../../../core/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  final FCMService _fcmService = FCMService();

  // State
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  
  RealtimeChannel? _realtimeSubscription;

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.read).toList();

  List<AppNotification> get readNotifications =>
      _notifications.where((n) => n.read).toList();

  // Initialize FCM
  Future<void> initializeFCM() async {
    try {
      await _fcmService.initialize();
      
      // Subscribe to general topics for all users
      await _fcmService.subscribeToTopic('all_users');
      await _fcmService.subscribeToTopic('all_events');
      
      debugPrint('✅ FCM initialized and subscribed to topics: all_users, all_events');
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  // Load notifications
  Future<void> loadNotifications(String userId) async {
    debugPrint('NotificationProvider: Loading notifications for userId: $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications(userId);
      debugPrint('NotificationProvider: Loaded ${_notifications.length} notifications');
      
      _unreadCount = await _repository.getUnreadCount(userId);
      debugPrint('NotificationProvider: Unread count: $_unreadCount');
      
      _error = null;

      // Subscribe to real-time updates
      _subscribeToRealtime(userId);
    } catch (e, stackTrace) {
      debugPrint('NotificationProvider Error: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString().replaceAll('Exception: ', '');
      _notifications = [];
      _unreadCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subscribe to real-time notifications
  void _subscribeToRealtime(String userId) {
    // Unsubscribe from previous subscription
    if (_realtimeSubscription != null) {
      _repository.unsubscribeFromNotifications(_realtimeSubscription!);
    }

    debugPrint('📱 Subscribing to realtime notifications for user: $userId');
    
    // Subscribe to new notifications
    _realtimeSubscription = _repository.subscribeToNotifications(
      userId,
      (notification) {
        debugPrint('📱 ✅ New notification received via realtime!');
        debugPrint('📱 Title: ${notification.title}');
        debugPrint('📱 Message: ${notification.message}');
        
        // Add new notification to the list
        _notifications.insert(0, notification);
        _unreadCount++;
        notifyListeners();

        // Show a snackbar or local notification
        debugPrint('📱 Notification added to list. Total: ${_notifications.length}');
      },
    );
    
    debugPrint('📱 Realtime subscription created successfully');
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].read) {
        _notifications[index] = _notifications[index].copyWith(read: true);
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _repository.markAllAsRead(userId);

      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        if (!_notifications[index].read) {
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        }
        _notifications.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      throw Exception('Failed to delete notification');
    }
  }

  // Create notification (for faculty)
  Future<void> createNotification({
    required String userId,
    String? eventId,
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      await _repository.createNotification(
        userId: userId,
        eventId: eventId,
        type: type,
        title: title,
        message: message,
      );
    } catch (e) {
      debugPrint('Error creating notification: $e');
      throw Exception('Failed to create notification');
    }
  }

  // Broadcast notification (for faculty)
  Future<void> broadcastNotification({
    required String type,
    required String title,
    required String message,
    String? eventId,
  }) async {
    debugPrint('📢 NotificationProvider: Broadcasting notification...');
    debugPrint('📢 Type: $type, Title: $title, Message: $message');
    
    try {
      await _repository.broadcastNotification(
        type: type,
        title: title,
        message: message,
        eventId: eventId,
      );
      debugPrint('📢 NotificationProvider: Broadcast successful!');
    } catch (e, stackTrace) {
      debugPrint('❌ NotificationProvider: Error broadcasting notification: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Failed to broadcast notification: $e');
    }
  }

  // Dispose
  @override
  void dispose() {
    if (_realtimeSubscription != null) {
      _repository.unsubscribeFromNotifications(_realtimeSubscription!);
    }
    super.dispose();
  }
}
