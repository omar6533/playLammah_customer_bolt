import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFD64453);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color secondaryRed = Color(0xFFE85865);
  static const Color lightBackground = Color(0xFFEDEDED);
  static const Color customGray = Color(0xFFBDBDBD);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color darkBlue = Color(0xFF556E78);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, secondaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFFFF5F5), Color(0xFFFFE5E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
