// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      eventId: json['eventId'] as String?,
      type: json['type'] as String,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      read: json['read'] as bool? ?? false,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'eventId': instance.eventId,
      'type': instance.type,
      'message': instance.message,
      'sentAt': instance.sentAt.toIso8601String(),
      'read': instance.read,
    };
