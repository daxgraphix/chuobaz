import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool compact;
  const RoleBadge({super.key, required this.role, this.compact = false});

  Color get _color => switch (role) {
        UserRole.superAdmin => AppColors.roleSuperAdmin,
        UserRole.moderator => AppColors.roleModerator,
        UserRole.lecturer => AppColors.roleLecturer,
        UserRole.student => AppColors.roleStudent,
        UserRole.alumni => AppColors.roleAlumni,
        UserRole.member => AppColors.roleMember,
      };

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.member) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        role.label,
        style: TextStyle(
            color: _color, fontSize: compact ? 9 : 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
