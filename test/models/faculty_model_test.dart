import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_fl/core/models/faculty_model.dart';

void main() {
  group('Faculty Model Tests', () {
    test('Faculty model fromJson creates correct object', () {
      // Arrange
      final json = {
        'id': '1',
        'user_id': 'user-1',
        'full_name': 'Dr. John Doe',
        'email': 'john.doe@example.com',
        'phone': '1234567890',
        'department': 'Computer Science',
        'designation': 'Professor',
        'office_location': 'Room 101',
        'office_hours': '9 AM - 5 PM',
        'profile_image_url': null,
      };

      // Act
      final faculty = Faculty.fromJson(json);

      // Assert
      expect(faculty.id, '1');
      expect(faculty.fullName, 'Dr. John Doe');
      expect(faculty.email, 'john.doe@example.com');
      expect(faculty.department, 'Computer Science');
      expect(faculty.designation, 'Professor');
    });

    test('Faculty model toJson creates correct map', () {
      // Arrange
      final faculty = Faculty(
        id: '1',
        userId: 'user-1',
        fullName: 'Dr. John Doe',
        email: 'john.doe@example.com',
        phone: '1234567890',
        department: 'Computer Science',
        designation: 'Professor',
        officeLocation: 'Room 101',
        officeHours: '9 AM - 5 PM',
      );

      // Act
      final json = faculty.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['full_name'], 'Dr. John Doe');
      expect(json['email'], 'john.doe@example.com');
      expect(json['department'], 'Computer Science');
    });

    test('Faculty model handles null profileImageUrl', () {
      // Arrange
      final json = {
        'id': '1',
        'user_id': 'user-1',
        'full_name': 'Dr. John Doe',
        'email': 'john.doe@example.com',
        'phone': '1234567890',
        'department': 'Computer Science',
        'designation': 'Professor',
        'office_location': 'Room 101',
        'office_hours': '9 AM - 5 PM',
        'profile_image_url': null,
      };

      // Act
      final faculty = Faculty.fromJson(json);

      // Assert
      expect(faculty.profileImageUrl, isNull);
    });
  });
}
