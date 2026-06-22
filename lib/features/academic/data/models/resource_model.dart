import 'package:equatable/equatable.dart';

enum ResourceType { pastPaper, studyNote, courseResource, questionBank }

extension ResourceTypeX on ResourceType {
  String get value => name;
  String get label => switch (this) {
        ResourceType.pastPaper => 'Past Paper',
        ResourceType.studyNote => 'Study Notes',
        ResourceType.courseResource => 'Course Resource',
        ResourceType.questionBank => 'Question Bank',
      };
  static ResourceType fromString(String v) =>
      ResourceType.values.firstWhere((e) => e.value == v, orElse: () => ResourceType.studyNote);
}

class ResourceModel extends Equatable {
  final String id;
  final String uploaderId;
  final String title;
  final String courseCode;
  final ResourceType type;
  final String? description;
  final String fileUrl;
  final int downloadCount;
  final DateTime createdAt;
  final String? uploaderUsername;

  const ResourceModel({
    required this.id,
    required this.uploaderId,
    required this.title,
    required this.courseCode,
    required this.type,
    this.description,
    required this.fileUrl,
    this.downloadCount = 0,
    required this.createdAt,
    this.uploaderUsername,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    final uploader = json['uploader'] as Map<String, dynamic>?;
    return ResourceModel(
      id: json['id'] as String,
      uploaderId: json['uploader_id'] as String,
      title: json['title'] as String? ?? '',
      courseCode: json['course_code'] as String? ?? '',
      type: ResourceTypeX.fromString(json['type'] as String? ?? 'study_note'),
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String? ?? '',
      downloadCount: json['download_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      uploaderUsername: uploader?['username'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'uploader_id': uploaderId,
        'title': title,
        'course_code': courseCode,
        'type': type.value,
        'description': description,
        'file_url': fileUrl,
      };

  @override
  List<Object?> get props => [id, downloadCount];
}
