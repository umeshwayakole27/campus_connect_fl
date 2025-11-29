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

  // Broadcast notification to all users via Supabase Edge Functions + FCM (faculty only)
  Future<void> broadcastNotification({
    required String type,
    required String title,
    required String message,
    String? eventId,
  }) async {
    try {
      debugPrint('📢 Starting broadcast notification...');
      debugPrint('📢 Title: $title');
      debugPrint('📢 Message: $message');
      debugPrint('📢 Type: $type');
      
      // Step 1: Send via Supabase Edge Function (which calls FCM)
      debugPrint('📢 Calling Supabase Edge Function...');
      
      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'title': title,
          'message': message,
          'type': type,
        },
      );
      
      if (response.status == 200) {
        debugPrint('📢 Supabase response: ${response.data}');
      } else {
        debugPrint('⚠️  Supabase response error: ${response.status}');
      }
      
      // Step 2: Save to database for notification history using RPC function
      debugPrint('📢 Saving notification history to database...');
      
      try {
        // Use the database function that bypasses RLS
        debugPrint('📢 Calling broadcast_notification_to_all_users RPC...');
        
        final result = await _supabase.rpc(
          'broadcast_notification_to_all_users',
          params: {
            'p_type': type,
            'p_title': title,
            'p_message': message,
            'p_event_id': eventId,
          },
        );
        
        final notifications = result as List;
        debugPrint('📢 ✅ Broadcast complete!');
        debugPrint('📢 Push sent via FCM to all devices');
        debugPrint('📢 History saved for ${notifications.length} users');
        
        if (notifications.isNotEmpty) {
          debugPrint('📢 Sample created notification: ${notifications.first}');
        }
      } catch (e) {
        debugPrint('❌ Error calling RPC function: $e');
        debugPrint('⚠️  Make sure to run the migration: supabase/migrations/20251104_broadcast_notifications.sql');
        throw Exception('Failed to broadcast notification history: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error broadcasting notification: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Failed to broadcast notification: $e');
    }
  }
  
  // Store FCM token for user
  Future<void> saveFCMToken(String userId, String fcmToken, String platform) async {
    try {
      await _supabase.from('user_fcm_tokens').upsert({
        'user_id': userId,
        'fcm_token': fcmToken,
        'platform': platform,
      });
      debugPrint('✅ FCM token saved for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  // Listen to real-time notifications
  RealtimeChannel subscribeToNotifications(String userId, Function(AppNotification) onNotification) {
    debugPrint('🔔 Setting up realtime channel for user: $userId');
    
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
            debugPrint('🔔 Realtime event received! Payload: ${payload.newRecord}');
            try {
              final notification = AppNotification.fromJson(payload.newRecord);
              debugPrint('🔔 Parsed notification: ${notification.title}');
              onNotification(notification);
            } catch (e) {
              debugPrint('🔔 Error parsing notification: $e');
            }
          },
        )
        .subscribe();

    debugPrint('🔔 Realtime channel subscribed successfully');
    return channel;
  }

  // Unsubscribe from notifications
  Future<void> unsubscribeFromNotifications(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
