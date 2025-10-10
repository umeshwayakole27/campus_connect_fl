import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'campus_location_model.g.dart';

@JsonSerializable()
class CampusLocation extends Equatable {
  final String id;
  final String name;
  final String? buildingCode;
  final double lat;
  final double lng;
  final String? description;
  final DateTime? createdAt;

  const CampusLocation({
    required this.id,
    required this.name,
    this.buildingCode,
    required this.lat,
    required this.lng,
    this.description,
    this.createdAt,
  });

  factory CampusLocation.fromJson(Map<String, dynamic> json) => 
      _$CampusLocationFromJson(json);
  Map<String, dynamic> toJson() => _$CampusLocationToJson(this);

  CampusLocation copyWith({
    String? id,
    String? name,
    String? buildingCode,
    double? lat,
    double? lng,
    String? description,
    DateTime? createdAt,
  }) {
    return CampusLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      buildingCode: buildingCode ?? this.buildingCode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    buildingCode,
    lat,
    lng,
    description,
    createdAt,
  ];
}
