import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class AppUserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? university;
  final String? faculty;
  final String? department;
  final String? academicLevel;
  final UserRole role;
  final bool isVerified;
  final bool isEmailVerified;
  final DateTime createdAt;

  const AppUserModel({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.university,
    this.faculty,
    this.department,
    this.academicLevel,
    this.role = UserRole.member,
    this.isVerified = false,
    this.isEmailVerified = false,
    required this.createdAt,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      university: json['university'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      academicLevel: json['academic_level'] as String?,
      role: UserRoleX.fromString(json['role'] as String? ?? 'member'),
      isVerified: json['is_verified'] as bool? ?? false,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'bio': bio,
        'university': university,
        'faculty': faculty,
        'department': department,
        'academic_level': academicLevel,
        'role': role.value,
        'is_verified': isVerified,
        'is_email_verified': isEmailVerified,
        'created_at': createdAt.toIso8601String(),
      };

  AppUserModel copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? university,
    String? faculty,
    String? department,
    String? academicLevel,
  }) {
    return AppUserModel(
      id: id,
      email: email,
      username: username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      academicLevel: academicLevel ?? this.academicLevel,
      role: role,
      isVerified: isVerified,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, username, role];
}
