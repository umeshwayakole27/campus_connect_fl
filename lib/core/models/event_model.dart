import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final String? locationId;
  final DateTime time;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.locationId,
    required this.time,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
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
  ];
}
