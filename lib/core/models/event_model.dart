import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? location;
  @JsonKey(name: 'location_id')
  final String? locationId;
  final DateTime time;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  // Nested creator data
  @JsonKey(name: 'creator')
  final Map<String, dynamic>? creator;
  
  // Getter for creator name
  String? get creatorName => creator?['name'] as String?;

  const Event({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.locationId,
    required this.time,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.creator,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? locationId,
    DateTime? time,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? creator,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      locationId: locationId ?? this.locationId,
      time: time ?? this.time,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creator: creator ?? this.creator,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    location,
    locationId,
    time,
    createdBy,
    createdAt,
    updatedAt,
    creator,
  ];
}
