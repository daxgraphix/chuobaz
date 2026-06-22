import 'package:flutter/material.dart';

extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String truncate(int max) => length <= max ? this : '${substring(0, max)}…';

  bool get isBlank => trim().isEmpty;
}

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ));
  }
}

extension NumX on num {
  /// Compact display: 1200 -> "1.2k", 1500000 -> "1.5M"
  String get compact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }
}
