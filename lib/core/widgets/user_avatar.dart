import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final double radius;
  final bool isAnonymous;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.displayName,
    this.radius = 20,
    this.isAnonymous = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnonymous) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.anonymous.withValues(alpha: 0.15),
        child: Icon(Icons.theater_comedy_rounded,
            size: radius, color: AppColors.anonymous),
      );
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
      );
    }
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(RegExp(r'\s+')).take(2).map((e) => e[0]).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(initials,
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: radius * 0.7)),
    );
  }
}
