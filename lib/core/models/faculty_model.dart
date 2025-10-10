import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'faculty_model.g.dart';

@JsonSerializable()
class Faculty extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String department;
  final String? office;
  final String? officeHours;
  final String? contactEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Faculty({
    required this.id,
    required this.userId,
    required this.name,
    required this.department,
    this.office,
    this.officeHours,
    this.contactEmail,
    this.createdAt,
    this.updatedAt,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) => _$FacultyFromJson(json);
  Map<String, dynamic> toJson() => _$FacultyToJson(this);

  Faculty copyWith({
    String? id,
    String? userId,
    String? name,
    String? department,
    String? office,
    String? officeHours,
    String? contactEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Faculty(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      department: department ?? this.department,
      office: office ?? this.office,
      officeHours: officeHours ?? this.officeHours,
      contactEmail: contactEmail ?? this.contactEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    department,
    office,
    officeHours,
    contactEmail,
    createdAt,
    updatedAt,
  ];
}
