import 'package:equatable/equatable.dart';

enum AppNotificationType { comment, mention, reaction, moderatorAction, marketplace, message }

extension AppNotificationTypeX on AppNotificationType {
  String get value => name;
  static AppNotificationType fromString(String v) =>
      AppNotificationType.values.firstWhere((e) => e.value == v, orElse: () => AppNotificationType.comment);
}

class AppNotificationModel extends Equatable {
  final String id;
  final String userId;
  final AppNotificationType type;
  final String title;
  final String body;
  final String? targetId;
  final String? targetType;
  final bool isRead;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.targetId,
    this.targetType,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: AppNotificationTypeX.fromString(json['type'] as String? ?? 'comment'),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      targetId: json['target_id'] as String?,
      targetType: json['target_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, isRead];
}
