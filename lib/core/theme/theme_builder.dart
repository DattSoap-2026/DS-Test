import 'package:flutter/material.dart';
import '../../models/theme/theme_settings.dart';

class ThemeBuilder {
  static ThemeData build(
    ThemeData base,
    ThemeSettings settings,
    Brightness brightness,
  ) {
    if (!settings.customThemeEnabled) {
      return base;
    }

    final scheme = base.colorScheme.copyWith(
      primary: settings.primaryColor,
      secondary: settings.accentColor,
      surface: settings.surfaceColor,
      surfaceContainerLowest: settings.surfaceColor,
      surfaceContainerLow: _surfaceVariant(
        settings.surfaceColor,
        base.colorScheme.onSurface,
        brightness,
        0.03,
      ),
      surfaceContainer: _surfaceVariant(
        settings.surfaceColor,
        base.colorScheme.onSurface,
        brightness,
        0.05,
      ),
      surfaceContainerHigh: _surfaceVariant(
        settings.surfaceColor,
        base.colorScheme.onSurface,
        brightness,
        0.08,
      ),
      surfaceContainerHighest: _surfaceVariant(
        settings.surfaceColor,
        base.colorScheme.onSurface,
        brightness,
        0.12,
      ),
      surfaceTint: settings.primaryColor,
    );

    final cardColor = _surfaceVariant(
      settings.surfaceColor,
      scheme.onSurface,
      brightness,
      0.06,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: settings.surfaceColor,
      cardTheme: base.cardTheme.copyWith(color: cardColor),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: settings.surfaceColor,
      ),
      dividerTheme: base.dividerTheme.copyWith(color: scheme.outline),
      hintColor: scheme.onSurfaceVariant,
      disabledColor: scheme.onSurfaceVariant.withValues(alpha: 0.6),
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
  }

  static Color _surfaceVariant(
    Color base,
    Color overlay,
    Brightness brightness,
    double strength,
  ) {
    final adjusted = brightness == Brightness.dark
        ? (strength * 1.4).clamp(0.0, 1.0)
        : strength;
    return Color.alphaBlend(
      overlay.withValues(alpha: adjusted),
      base,
    );
  }
}
