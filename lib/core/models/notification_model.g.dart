// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      eventId: json['event_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String?,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      read: json['read'] as bool? ?? false,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'event_id': instance.eventId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'sent_at': instance.sentAt.toIso8601String(),
      'read': instance.read,
    };
