import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class CommunityModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final CommunityLevel level;
  final String? avatarUrl;
  final String? coverUrl;
  final int memberCount;
  final bool isJoined;
  final DateTime createdAt;

  const CommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.level = CommunityLevel.interestGroup,
    this.avatarUrl,
    this.coverUrl,
    this.memberCount = 0,
    this.isJoined = false,
    required this.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      level: CommunityLevelX.fromString(json['level'] as String? ?? 'interest_group'),
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      isJoined: json['is_joined'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CommunityModel copyWith({bool? isJoined, int? memberCount}) {
    return CommunityModel(
      id: id,
      name: name,
      description: description,
      level: level,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, isJoined, memberCount];
}
