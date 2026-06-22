import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _font = 'Roboto';

  static const h1 = TextStyle(
      fontFamily: _font, fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);
  static const h2 = TextStyle(
      fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w700, height: 1.25);
  static const h3 = TextStyle(
      fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);
  static const bodyLarge = TextStyle(
      fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const bodyMedium = TextStyle(
      fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const bodySmall = TextStyle(
      fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);
  static const labelLarge = TextStyle(
      fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600);
  static const labelSmall = TextStyle(
      fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4);
  static const caption = TextStyle(
      fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.lightTextSecondary);
}
