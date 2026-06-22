import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String otherUserId;
  final String? otherUsername;
  final String? otherAvatarUrl;
  final bool hasUnread;

  const ConversationModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
    required this.otherUserId,
    this.otherUsername,
    this.otherAvatarUrl,
    this.hasUnread = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final participants = List<String>.from(json['participant_ids'] as List? ?? []);
    final otherUser = json['other_user'] as Map<String, dynamic>?;
    return ConversationModel(
      id: json['id'] as String,
      participantIds: participants,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null ? DateTime.parse(json['last_message_at'] as String) : null,
      otherUserId: otherUser?['id'] as String? ?? '',
      otherUsername: otherUser?['username'] as String?,
      otherAvatarUrl: otherUser?['avatar_url'] as String?,
      hasUnread: json['has_unread'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, lastMessage, hasUnread];
}

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, isRead];
}
