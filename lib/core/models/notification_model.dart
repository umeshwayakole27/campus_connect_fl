import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class AppNotification extends Equatable {
  @JsonKey(name: 'notification_id', fromJson: _idFromJson)
  final String id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'data')
  final Map<String, dynamic>? eventData;
  @JsonKey(name: 'notification_type')
  final String? type;
  final String? title;
  final String? message;
  // Support both created_at and sent_at for backward compatibility
  @JsonKey(name: 'created_at', defaultValue: null)
  final DateTime? createdAt;
  @JsonKey(name: 'sent_at', defaultValue: null)
  final DateTime? sentAtOld;
  @JsonKey(name: 'is_read', defaultValue: false)
  final bool read;
  
  // Convert int or String to String for id
  static String _idFromJson(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
  
  // Helper getter for event_id from data JSON
  String? get eventId => eventData?['event_id'] as String?;
  
  // Use created_at if available, otherwise fall back to sent_at
  DateTime get sentAt => createdAt ?? sentAtOld ?? DateTime.now();

  const AppNotification({
    required this.id,
    this.userId,
    this.eventData,
    this.type,
    this.title,
    this.message,
    this.createdAt,
    this.sentAtOld,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    try {
      return _$AppNotificationFromJson(json);
    } catch (e) {
      // If parsing fails, create a minimal valid object
      return AppNotification(
        id: json['notification_id']?.toString() ?? json['id']?.toString() ?? '',
        userId: json['user_id']?.toString(),
        type: json['notification_type']?.toString() ?? json['type']?.toString() ?? 'system',
        message: json['message']?.toString() ?? 'Notification',
        title: json['title']?.toString(),
        read: json['is_read'] == true || json['read'] == true,
      );
    }
  }
  
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({
    String? id,
    String? userId,
    Map<String, dynamic>? eventData,
    String? type,
    String? title,
    String? message,
    DateTime? createdAt,
    DateTime? sentAtOld,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventData: eventData ?? this.eventData,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      sentAtOld: sentAtOld ?? this.sentAtOld,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    eventData,
    type,
    title,
    message,
    createdAt,
    sentAtOld,
    read,
  ];
}
