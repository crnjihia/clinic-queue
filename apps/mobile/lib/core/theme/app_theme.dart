// path: apps/mobile/lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primaryTeal,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondaryMint,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: AppColors.surfaceLight,
      onSurface: const Color(0xFF191C1B),
      surfaceVariant: AppColors.surfaceVariantLight,
      onSurfaceVariant: const Color(0xFF3F4946),
      error: AppColors.statusNoShow,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: Color(0xFF191C1B),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE0E3E1)),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF53DBC9),
      onPrimary: const Color(0xFF003731),
      primaryContainer: AppColors.primaryTeal,
      onPrimaryContainer: AppColors.primaryContainer,
      secondary: const Color(0xFFB0CCC6),
      onSecondary: const Color(0xFF1B3531),
      secondaryContainer: const Color(0xFF324C47),
      onSecondaryContainer: AppColors.secondaryContainer,
      surface: AppColors.surfaceDark,
      onSurface: const Color(0xFFE0E3E1),
      surfaceVariant: AppColors.surfaceVariantDark,
      onSurfaceVariant: const Color(0xFFBEC9C5),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Color(0xFFE0E3E1),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFF2E3331)),
        ),
        color: Color(0xFF222624),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF53DBC9),
          foregroundColor: const Color(0xFF003731),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}

