import 'package:flutter/material.dart';

const double mobileHeaderBreakpoint = 600;
const double mobileHeaderTitleFontSize = 15;
const double mobileHeaderSubtitleFontSize = 10;

bool useMobileHeaderTypographyForWidth(double width) {
  return width < mobileHeaderBreakpoint;
}

TextStyle buildProfessionalMobileHeaderTitleStyle(TextStyle baseStyle) {
  return baseStyle.copyWith(
    fontSize: mobileHeaderTitleFontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.15,
  );
}

ThemeData applyMobileHeaderTheme(ThemeData theme, double width) {
  if (!useMobileHeaderTypographyForWidth(width)) {
    return theme;
  }

  final baseTitleStyle =
      theme.appBarTheme.titleTextStyle ??
      theme.textTheme.titleLarge ??
      const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  final mobileTitleStyle = buildProfessionalMobileHeaderTitleStyle(
    baseTitleStyle,
  );

  return theme.copyWith(
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: mobileTitleStyle,
      toolbarTextStyle: mobileTitleStyle,
    ),
  );
}
