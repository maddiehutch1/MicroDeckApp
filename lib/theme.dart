import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0F0E0D);
  static const surface = Color(0xFF1C1A18);
  static const surfaceHigh = Color(0xFF252321);
  static const textPrimary = Color(0xFFEFEDE8);
  static const textMuted = Color(0xFF8A8580);
  static const textFaint = Color(0xFF4A4744);
  static const border = Color(0xFF2A2825);
}

abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double page = 24;
}

abstract final class AppTextStyles {
  static const appName = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );
  static const headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const screenTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const sheetTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static const bodyMuted = TextStyle(
    fontSize: 16,
    color: AppColors.textMuted,
    height: 1.4,
  );
  static const cardAction = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const cardGoal = TextStyle(
    fontSize: 13,
    color: AppColors.textMuted,
  );
  static const contextLabel = TextStyle(
    fontSize: 14,
    color: AppColors.textFaint,
    letterSpacing: 0.5,
  );
  static const timerDisplay = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.w200,
    color: AppColors.textPrimary,
    letterSpacing: -2,
  );
  static const timerLabel = TextStyle(
    fontSize: 16,
    color: AppColors.textFaint,
    height: 1.4,
  );
  static const completion = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  static const button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );
  static const buttonMuted = TextStyle(fontSize: 17);
  static const label = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );
  static const badge = TextStyle(fontSize: 12, color: AppColors.textMuted);
}

abstract final class AppTheme {
  static ThemeData get themeData {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.textPrimary,
        onPrimary: AppColors.background,
        secondary: AppColors.textMuted,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textFaint),
        labelStyle: TextStyle(color: AppColors.textFaint),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.surfaceHigh,
          disabledForegroundColor: AppColors.textFaint,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: AppTextStyles.buttonMuted,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
      ),
    );
  }
}
