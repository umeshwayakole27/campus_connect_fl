import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'student' or 'faculty'
  final String? profilePic;
  final String? department;
  final String? office;
  final String? officeHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profilePic,
    this.department,
    this.office,
    this.officeHours,
    this.createdAt,
    this.updatedAt,
  });

  bool get isStudent => role == 'student';
  bool get isFaculty => role == 'faculty';

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? profilePic,
    String? department,
    String? office,
    String? officeHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
      department: department ?? this.department,
      office: office ?? this.office,
      officeHours: officeHours ?? this.officeHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    profilePic,
    department,
    office,
    officeHours,
    createdAt,
    updatedAt,
  ];
}
