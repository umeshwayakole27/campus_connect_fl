import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_fl/core/models/notification_model.dart';

void main() {
  group('Notification Model Tests', () {
    test('Notification model fromJson creates correct object', () {
      // Arrange
      final json = {
        'id': '1',
        'user_id': 'user-1',
        'event_id': 'event-1',
        'type': 'event',
        'title': 'New Event',
        'message': 'Check out this new event!',
        'read': false,
        'sent_at': '2025-10-17T09:00:00.000Z',
      };

      // Act
      final notification = AppNotification.fromJson(json);

      // Assert
      expect(notification.id, '1');
      expect(notification.userId, 'user-1');
      expect(notification.eventId, 'event-1');
      expect(notification.type, 'event');
      expect(notification.title, 'New Event');
      expect(notification.message, 'Check out this new event!');
      expect(notification.read, false);
    });

    test('Notification model toJson creates correct map', () {
      // Arrange
      final notification = AppNotification(
        id: '1',
        userId: 'user-1',
        eventId: 'event-1',
        type: 'event',
        title: 'New Event',
        message: 'Check out this new event!',
        read: false,
        sentAt: DateTime(2025, 10, 17, 9, 0),
      );

      // Act
      final json = notification.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['user_id'], 'user-1');
      expect(json['event_id'], 'event-1');
      expect(json['type'], 'event');
      expect(json['title'], 'New Event');
      expect(json['read'], false);
    });

    test('Notification model handles null eventId', () {
      // Arrange
      final json = {
        'id': '1',
        'user_id': 'user-1',
        'event_id': null,
        'type': 'announcement',
        'title': 'Announcement',
        'message': 'Important announcement',
        'read': false,
        'sent_at': '2025-10-17T09:00:00.000Z',
      };

      // Act
      final notification = AppNotification.fromJson(json);

      // Assert
      expect(notification.eventId, isNull);
      expect(notification.type, 'announcement');
    });
  });
}
