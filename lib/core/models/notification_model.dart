import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class AppNotification extends Equatable {
  final String id;
  final String? userId;
  final String? eventId;
  final String type;
  final String? title;
  final String message;
  final DateTime sentAt;
  final bool read;

  const AppNotification({
    required this.id,
    this.userId,
    this.eventId,
    required this.type,
    this.title,
    required this.message,
    required this.sentAt,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => 
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? type,
    String? title,
    String? message,
    DateTime? sentAt,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    eventId,
    type,
    title,
    message,
    sentAt,
    read,
  ];
}
