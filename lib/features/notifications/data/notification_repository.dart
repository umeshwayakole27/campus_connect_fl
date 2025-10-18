import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase = SupabaseService.instance.client;

  // Get notifications for user
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('sent_at', ascending: false);

      final notifications = (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
      
      return notifications;
    } catch (e) {
      throw Exception('Failed to load notifications: ${e.toString()}');
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      throw Exception('Failed to update notification');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      throw Exception('Failed to update notifications');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      throw Exception('Failed to delete notification');
    }
  }

  // Create notification (for faculty)
  Future<AppNotification> createNotification({
    required String userId,
    String? eventId,
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .insert({
            'user_id': userId,
            'event_id': eventId,
            'type': type,
            'title': title,
            'message': message,
          })
          .select()
          .single();

      return AppNotification.fromJson(response);
    } catch (e) {
      debugPrint('Error creating notification: $e');
      throw Exception('Failed to create notification');
    }
  }

  // Broadcast notification to all users (faculty only)
  Future<void> broadcastNotification({
    required String type,
    required String title,
    required String message,
    String? eventId,
  }) async {
    try {
      // Get all user IDs
      final usersResponse = await _supabase
          .from('users')
          .select('id');

      final userIds = (usersResponse as List)
          .map((user) => user['id'] as String)
          .toList();

      // Create notification for each user
      final notifications = userIds.map((userId) => {
            'user_id': userId,
            'event_id': eventId,
            'type': type,
            'title': title,
            'message': message,
          }).toList();

      await _supabase
          .from('notifications')
          .insert(notifications);
    } catch (e) {
      debugPrint('Error broadcasting notification: $e');
      throw Exception('Failed to broadcast notification');
    }
  }

  // Listen to real-time notifications
  RealtimeChannel subscribeToNotifications(String userId, Function(AppNotification) onNotification) {
    final channel = _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = AppNotification.fromJson(payload.newRecord);
            onNotification(notification);
          },
        )
        .subscribe();

    return channel;
  }

  // Unsubscribe from notifications
  Future<void> unsubscribeFromNotifications(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
