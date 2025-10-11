import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'faculty_model.g.dart';

@JsonSerializable()
class Faculty extends Equatable {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String department;
  final String? designation;
  @JsonKey(name: 'office_location')
  final String? officeLocation;
  @JsonKey(name: 'office_hours')
  final String? officeHours;
  final String? phone;
  @JsonKey(name: 'research_interests')
  final List<String>? researchInterests;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  // Nested user data
  @JsonKey(name: 'user')
  final Map<String, dynamic>? user;
  
  // Getters for user data
  String? get userName => user?['name'] as String?;
  String? get userEmail => user?['email'] as String?;
  String? get userAvatarUrl => user?['avatar_url'] as String?;

  const Faculty({
    required this.id,
    required this.userId,
    required this.department,
    this.designation,
    this.officeLocation,
    this.officeHours,
    this.phone,
    this.researchInterests,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) => _$FacultyFromJson(json);
  Map<String, dynamic> toJson() => _$FacultyToJson(this);

  Faculty copyWith({
    String? id,
    String? userId,
    String? department,
    String? designation,
    String? officeLocation,
    String? officeHours,
    String? phone,
    List<String>? researchInterests,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? user,
  }) {
    return Faculty(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      officeLocation: officeLocation ?? this.officeLocation,
      officeHours: officeHours ?? this.officeHours,
      phone: phone ?? this.phone,
      researchInterests: researchInterests ?? this.researchInterests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    department,
    designation,
    officeLocation,
    officeHours,
    phone,
    researchInterests,
    createdAt,
    updatedAt,
    user,
  ];
}
