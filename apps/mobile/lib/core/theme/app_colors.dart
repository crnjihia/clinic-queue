// path: apps/mobile/lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Kenyan healthcare teal theme
  static const Color primaryTeal = Color(0xFF006A60);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFF73F8E6);
  static const Color onPrimaryContainer = Color(0xFF00201C);

  // Secondary mint
  static const Color secondaryMint = Color(0xFF4A635F);
  static const Color secondaryContainer = Color(0xFFCCE8E2);
  static const Color onSecondaryContainer = Color(0xFF05201C);

  // Status Colors (Queue States)
  static const Color statusWaiting = Color(0xFFE65100);    // Warm amber
  static const Color statusCalled = Color(0xFF0277BD);     // Alert blue
  static const Color statusInService = Color(0xFF2E7D32);  // Healthy green
  static const Color statusDone = Color(0xFF558B2F);       // Olive success
  static const Color statusNoShow = Color(0xFFC62828);     // Crimson red
  static const Color statusCancelled = Color(0xFF616161);  // Neutral slate

  // Surface & Backgrounds
  static const Color backgroundLight = Color(0xFFFAFDFB);
  static const Color surfaceLight = Color(0xFFFAFDFB);
  static const Color surfaceVariantLight = Color(0xFFDAE5E1);

  static const Color backgroundDark = Color(0xFF191C1B);
  static const Color surfaceDark = Color(0xFF191C1B);
  static const Color surfaceVariantDark = Color(0xFF3F4946);

  // M-Pesa brand green for payments
  static const Color mpesaGreen = Color(0xFF00A859);
}

