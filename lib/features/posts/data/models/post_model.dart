import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class PostModel extends Equatable {
  final String id;
  final String authorId;
  final String? communityId;
  final String title;
  final String body;
  final PostType type;
  final List<String> tags;
  final bool isAnonymous;
  final String? anonymousAlias;
  final bool isPinned;
  final bool isLocked;
  final bool isHidden;
  final int commentCount;
  final Map<String, int> reactionCounts;
  final ReactionType? myReaction;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields (populated from the `posts_with_meta` view / select join)
  final String? authorUsername;
  final String? authorDisplayName;
  final String? authorAvatarUrl;
  final UserRole? authorRole;
  final String? communityName;

  const PostModel({
    required this.id,
    required this.authorId,
    this.communityId,
    required this.title,
    required this.body,
    this.type = PostType.discussion,
    this.tags = const [],
    this.isAnonymous = false,
    this.anonymousAlias,
    this.isPinned = false,
    this.isLocked = false,
    this.isHidden = false,
    this.commentCount = 0,
    this.reactionCounts = const {},
    this.myReaction,
    this.mediaUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
    this.authorRole,
    this.communityName,
  });

  int get totalReactions => reactionCounts.values.fold(0, (a, b) => a + b);

  String get displayAuthorName =>
      isAnonymous ? (anonymousAlias ?? 'Anonymous') : (authorDisplayName ?? authorUsername ?? 'User');

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      communityId: json['community_id'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: PostTypeX.fromString(json['type'] as String? ?? 'discussion'),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      anonymousAlias: json['anonymous_alias'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      isHidden: json['is_hidden'] as bool? ?? false,
      commentCount: json['comment_count'] as int? ?? 0,
      reactionCounts: Map<String, int>.from(json['reaction_counts'] as Map? ?? {}),
      myReaction: json['my_reaction'] != null
          ? ReactionTypeX.fromString(json['my_reaction'] as String)
          : null,
      mediaUrls: (json['media_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? json['created_at'] as String),
      authorUsername: json['author_username'] as String?,
      authorDisplayName: json['author_display_name'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      authorRole: json['author_role'] != null
          ? UserRoleX.fromString(json['author_role'] as String)
          : null,
      communityName: json['community_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'author_id': authorId,
        'community_id': communityId,
        'title': title,
        'body': body,
        'type': type.value,
        'tags': tags,
        'is_anonymous': isAnonymous,
        'anonymous_alias': anonymousAlias,
        'media_urls': mediaUrls,
      };

  PostModel copyWith({
    int? commentCount,
    Map<String, int>? reactionCounts,
    ReactionType? myReaction,
    bool clearMyReaction = false,
    bool? isPinned,
    bool? isLocked,
    bool? isHidden,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      communityId: communityId,
      title: title,
      body: body,
      type: type,
      tags: tags,
      isAnonymous: isAnonymous,
      anonymousAlias: anonymousAlias,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      commentCount: commentCount ?? this.commentCount,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      myReaction: clearMyReaction ? null : (myReaction ?? this.myReaction),
      mediaUrls: mediaUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarUrl: authorAvatarUrl,
      authorRole: authorRole,
      communityName: communityName,
    );
  }

  @override
  List<Object?> get props => [id, commentCount, reactionCounts, myReaction, isPinned, isLocked, isHidden];
}
