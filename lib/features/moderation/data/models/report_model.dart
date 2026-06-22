import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class ReportModel extends Equatable {
  final String id;
  final String reporterId;
  final String targetId;
  final String targetType; // post | comment | listing | user
  final String reason;
  final String? details;
  final ReportStatus status;
  final DateTime createdAt;
  final String? reporterUsername;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetId,
    required this.targetType,
    required this.reason,
    this.details,
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.reporterUsername,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;
    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      targetId: json['target_id'] as String,
      targetType: json['target_type'] as String? ?? 'post',
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String?,
      status: ReportStatus.values.firstWhere(
          (s) => s.name == (json['status'] as String? ?? 'pending'),
          orElse: () => ReportStatus.pending),
      createdAt: DateTime.parse(json['created_at'] as String),
      reporterUsername: reporter?['username'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, status];
}
