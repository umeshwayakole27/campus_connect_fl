// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Faculty _$FacultyFromJson(Map<String, dynamic> json) => Faculty(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  department: json['department'] as String,
  office: json['office'] as String?,
  officeHours: json['officeHours'] as String?,
  contactEmail: json['contactEmail'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FacultyToJson(Faculty instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'department': instance.department,
  'office': instance.office,
  'officeHours': instance.officeHours,
  'contactEmail': instance.contactEmail,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
