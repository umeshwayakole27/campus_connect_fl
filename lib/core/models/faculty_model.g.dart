// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Faculty _$FacultyFromJson(Map<String, dynamic> json) => Faculty(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  department: json['department'] as String,
  designation: json['designation'] as String?,
  officeLocation: json['office_location'] as String?,
  officeHours: json['office_hours'] as String?,
  phone: json['phone'] as String?,
  researchInterests: (json['research_interests'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  user: json['user'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$FacultyToJson(Faculty instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'department': instance.department,
  'designation': instance.designation,
  'office_location': instance.officeLocation,
  'office_hours': instance.officeHours,
  'phone': instance.phone,
  'research_interests': instance.researchInterests,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'user': instance.user,
};
