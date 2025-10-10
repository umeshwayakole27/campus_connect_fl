// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CampusLocation _$CampusLocationFromJson(Map<String, dynamic> json) =>
    CampusLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      buildingCode: json['buildingCode'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CampusLocationToJson(CampusLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'buildingCode': instance.buildingCode,
      'lat': instance.lat,
      'lng': instance.lng,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
