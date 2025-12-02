// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: AppNotification._idFromJson(json['notification_id']),
      userId: json['user_id'] as String?,
      eventData: json['data'] as Map<String, dynamic>?,
      type: json['notification_type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      sentAtOld: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      read: json['is_read'] as bool? ?? false,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'notification_id': instance.id,
      'user_id': instance.userId,
      'data': instance.eventData,
      'notification_type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'created_at': instance.createdAt?.toIso8601String(),
      'sent_at': instance.sentAtOld?.toIso8601String(),
      'is_read': instance.read,
    };
