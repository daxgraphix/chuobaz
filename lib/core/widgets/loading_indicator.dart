import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  const LoadingIndicator({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class InlineLoadingMore extends StatelessWidget {
  const InlineLoadingMore({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: LoadingIndicator(size: 22),
      );
}
