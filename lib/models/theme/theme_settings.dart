import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

enum ThemePattern {
  defaultErpBlue,
  modernDark,
  softPastel,
  highContrast,
}

extension ThemePatternLabel on ThemePattern {
  String get label {
    switch (this) {
      case ThemePattern.defaultErpBlue:
        return 'Default ERP Blue';
      case ThemePattern.modernDark:
        return 'Modern Dark';
      case ThemePattern.softPastel:
        return 'Soft Pastel';
      case ThemePattern.highContrast:
        return 'High Contrast';
    }
  }
}

class ThemePatternPalette {
  final Color primary;
  final Color surface;
  final Color accent;

  const ThemePatternPalette({
    required this.primary,
    required this.surface,
    required this.accent,
  });

  static ThemePatternPalette forPattern(ThemePattern pattern) {
    switch (pattern) {
      case ThemePattern.defaultErpBlue:
        return ThemePatternPalette(
          primary: AppColors.info,
          surface: AppColors.lightSurface,
          accent: AppColors.lightAccent,
        );
      case ThemePattern.modernDark:
        return ThemePatternPalette(
          primary: AppColors.darkPrimary,
          surface: AppColors.darkSurface,
          accent: AppColors.darkAccent,
        );
      case ThemePattern.softPastel:
        return ThemePatternPalette(
          primary: _mix(AppColors.lightPrimary, AppColors.lightSurface, 0.35),
          surface: _mix(AppColors.lightBackground, AppColors.lightSurface, 0.5),
          accent: _mix(AppColors.lightAccent, AppColors.lightSurface, 0.25),
        );
      case ThemePattern.highContrast:
        return ThemePatternPalette(
          primary: AppColors.lightTextPrimary,
          surface: AppColors.lightSurface,
          accent: AppColors.error,
        );
    }
  }

  static Color _mix(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }
}

class ThemeSettings {
  final ThemeMode themeMode;
  final bool customThemeEnabled;
  final Color primaryColor;
  final Color surfaceColor;
  final Color accentColor;
  final ThemePattern pattern;

  const ThemeSettings({
    required this.themeMode,
    required this.customThemeEnabled,
    required this.primaryColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.pattern,
  });

  factory ThemeSettings.defaults() {
    return ThemeSettings(
      themeMode: ThemeMode.system,
      customThemeEnabled: false,
      primaryColor: AppColors.lightPrimary,
      surfaceColor: AppColors.lightBackground,
      accentColor: AppColors.lightAccent,
      pattern: ThemePattern.defaultErpBlue,
    );
  }

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    bool? customThemeEnabled,
    Color? primaryColor,
    Color? surfaceColor,
    Color? accentColor,
    ThemePattern? pattern,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      customThemeEnabled: customThemeEnabled ?? this.customThemeEnabled,
      primaryColor: primaryColor ?? this.primaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      accentColor: accentColor ?? this.accentColor,
      pattern: pattern ?? this.pattern,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeSettings &&
        other.themeMode == themeMode &&
        other.customThemeEnabled == customThemeEnabled &&
        other.primaryColor.toARGB32() == primaryColor.toARGB32() &&
        other.surfaceColor.toARGB32() == surfaceColor.toARGB32() &&
        other.accentColor.toARGB32() == accentColor.toARGB32() &&
        other.pattern == pattern;
  }

  @override
  int get hashCode => Object.hash(
        themeMode,
        customThemeEnabled,
        primaryColor.toARGB32(),
        surfaceColor.toARGB32(),
        accentColor.toARGB32(),
        pattern,
      );
}
