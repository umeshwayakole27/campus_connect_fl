import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_fl/core/models/event_model.dart';

void main() {
  group('Event Model Tests', () {
    test('Event model fromJson creates correct object', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Event',
        'description': 'Test Description',
        'category': 'academic',
        'date': '2025-10-20T10:00:00.000Z',
        'location_id': 'loc-1',
        'location_name': 'Test Location',
        'created_by': 'user-1',
        'created_at': '2025-10-17T09:00:00.000Z',
      };

      // Act
      final event = Event.fromJson(json);

      // Assert
      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.category, 'academic');
      expect(event.locationName, 'Test Location');
    });

    test('Event model toJson creates correct map', () {
      // Arrange
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        category: 'academic',
        date: DateTime(2025, 10, 20, 10, 0),
        locationId: 'loc-1',
        locationName: 'Test Location',
        createdBy: 'user-1',
        createdAt: DateTime(2025, 10, 17, 9, 0),
      );

      // Act
      final json = event.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['title'], 'Test Event');
      expect(json['category'], 'academic');
      expect(json['location_name'], 'Test Location');
    });

    test('Event model handles null imageUrl', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Event',
        'description': 'Test Description',
        'category': 'academic',
        'date': '2025-10-20T10:00:00.000Z',
        'location_id': 'loc-1',
        'location_name': 'Test Location',
        'created_by': 'user-1',
        'created_at': '2025-10-17T09:00:00.000Z',
        'image_url': null,
      };

      // Act
      final event = Event.fromJson(json);

      // Assert
      expect(event.imageUrl, isNull);
    });
  });
}
