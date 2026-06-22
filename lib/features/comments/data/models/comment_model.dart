import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String authorId;
  final String? parentId;
  final String body;
  final bool isAnonymous;
  final String? anonymousAlias;
  final Map<String, int> reactionCounts;
  final ReactionType? myReaction;
  final DateTime createdAt;
  final String? authorUsername;
  final String? authorDisplayName;
  final String? authorAvatarUrl;
  final UserRole? authorRole;
  final List<CommentModel> replies;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    this.parentId,
    required this.body,
    this.isAnonymous = false,
    this.anonymousAlias,
    this.reactionCounts = const {},
    this.myReaction,
    required this.createdAt,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
    this.authorRole,
    this.replies = const [],
  });

  String get displayAuthorName =>
      isAnonymous ? (anonymousAlias ?? 'Anonymous') : (authorDisplayName ?? authorUsername ?? 'User');

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      parentId: json['parent_id'] as String?,
      body: json['body'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      anonymousAlias: json['anonymous_alias'] as String?,
      reactionCounts: Map<String, int>.from(json['reaction_counts'] as Map? ?? {}),
      myReaction: json['my_reaction'] != null
          ? ReactionTypeX.fromString(json['my_reaction'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: author?['username'] as String?,
      authorDisplayName: author?['display_name'] as String?,
      authorAvatarUrl: author?['avatar_url'] as String?,
      authorRole:
          author?['role'] != null ? UserRoleX.fromString(author!['role'] as String) : null,
    );
  }

  CommentModel copyWith({Map<String, int>? reactionCounts, ReactionType? myReaction, bool clearMyReaction = false}) {
    return CommentModel(
      id: id,
      postId: postId,
      authorId: authorId,
      parentId: parentId,
      body: body,
      isAnonymous: isAnonymous,
      anonymousAlias: anonymousAlias,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      myReaction: clearMyReaction ? null : (myReaction ?? this.myReaction),
      createdAt: createdAt,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarUrl: authorAvatarUrl,
      authorRole: authorRole,
      replies: replies,
    );
  }

  @override
  List<Object?> get props => [id, body, reactionCounts, myReaction];
}

/// Builds a nested reply tree from a flat list ordered by created_at.
List<CommentModel> buildCommentTree(List<CommentModel> flat) {
  final byId = {for (final c in flat) c.id: c};
  final roots = <CommentModel>[];
  final childrenMap = <String, List<CommentModel>>{};

  for (final c in flat) {
    if (c.parentId != null && byId.containsKey(c.parentId)) {
      childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
    } else {
      roots.add(c);
    }
  }

  CommentModel withReplies(CommentModel c) {
    final kids = (childrenMap[c.id] ?? []).map(withReplies).toList();
    return CommentModel(
      id: c.id,
      postId: c.postId,
      authorId: c.authorId,
      parentId: c.parentId,
      body: c.body,
      isAnonymous: c.isAnonymous,
      anonymousAlias: c.anonymousAlias,
      reactionCounts: c.reactionCounts,
      myReaction: c.myReaction,
      createdAt: c.createdAt,
      authorUsername: c.authorUsername,
      authorDisplayName: c.authorDisplayName,
      authorAvatarUrl: c.authorAvatarUrl,
      authorRole: c.authorRole,
      replies: kids,
    );
  }

  return roots.map(withReplies).toList();
}
