import 'dart:math' as math;

import 'package:flutter/material.dart';

/// CORE ARCHITECTURE FILE
/// DO NOT BYPASS.
/// All responsive behavior must route through this layer.
///
/// Mandatory layout gateway:
/// - Do not call `MediaQuery.of(context)` in feature screens/widgets.
/// - Use this helper for breakpoints, clamping, dialog sizing, and insets.
class Responsive {
  // Canonical breakpoints (project-wide requirement):
  // Mobile        : < 600
  // Tablet        : 600 - 1024
  // Small Desktop : 1024 - 1440
  // Large Desktop : > 1440
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double smallDesktopBreakpoint = 1440;

  // Compatibility aliases retained for existing widgets.
  static const double smallBreakpoint = tabletBreakpoint;
  static const double mediumBreakpoint = smallDesktopBreakpoint;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double viewInsetsBottom(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  static double devicePixelRatio(BuildContext context) =>
      MediaQuery.devicePixelRatioOf(context);

  static bool isMobile(BuildContext context) =>
      width(context) < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      width(context) >= mobileBreakpoint && width(context) < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      width(context) >= tabletBreakpoint;

  static bool isSmallDesktop(BuildContext context) =>
      width(context) >= tabletBreakpoint &&
      width(context) < smallDesktopBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      width(context) >= smallDesktopBreakpoint;

  static bool isSmall(BuildContext context) => isMobile(context);

  static bool isMedium(BuildContext context) => isTablet(context);

  static bool isLarge(BuildContext context) => isDesktop(context);

  static EdgeInsets screenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    }
    if (isTablet(context)) {
      return const EdgeInsets.all(16);
    }
    if (isSmallDesktop(context)) {
      return const EdgeInsets.all(20);
    }
    return const EdgeInsets.all(24);
  }

  static EdgeInsets dialogInsetPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: isSmall(context) ? 12 : 20,
      vertical: isSmall(context) ? 16 : 24,
    );
  }

  static BoxConstraints dialogConstraints(
    BuildContext context, {
    double maxWidth = 600,
    double maxHeightFactor = 0.85,
  }) {
    final availableWidth =
        width(context) - (dialogInsetPadding(context).horizontal);
    return BoxConstraints(
      maxWidth: math.min(maxWidth, availableWidth),
      maxHeight: height(context) * maxHeightFactor,
    );
  }

  static double clamp(
    BuildContext context, {
    required double min,
    required double max,
    required double ratio,
  }) {
    final value = width(context) * ratio;
    return value.clamp(min, max);
  }

  static int adaptiveColumns(
    BuildContext context, {
    required double minTileWidth,
    int min = 1,
    int max = 6,
    double spacing = 12,
    double horizontalPadding = 0,
  }) {
    final available = width(context) - horizontalPadding;
    final raw = ((available + spacing) / (minTileWidth + spacing)).floor();
    return raw.clamp(min, max);
  }

  static int columnsForWidth(
    double width, {
    double minTileWidth = 260,
    int min = 1,
    int max = 6,
    double spacing = 12,
  }) {
    if (width <= 0) return min;
    final raw = ((width + spacing) / (minTileWidth + spacing)).floor();
    return raw.clamp(min, max);
  }

  static ResponsiveConfig configForWidth(double width) =>
      ResponsiveConfig.fromWidth(width);

  static ResponsiveConfig configOf(BuildContext context) =>
      configForWidth(Responsive.width(context));
}

enum ResponsiveSizeClass { mobile, tablet, smallDesktop, largeDesktop }

class ResponsiveConfig {
  final double width;

  const ResponsiveConfig({required this.width});

  factory ResponsiveConfig.fromWidth(double width) =>
      ResponsiveConfig(width: width);

  ResponsiveSizeClass get sizeClass {
    if (width < Responsive.mobileBreakpoint) {
      return ResponsiveSizeClass.mobile;
    }
    if (width < Responsive.tabletBreakpoint) {
      return ResponsiveSizeClass.tablet;
    }
    if (width < Responsive.smallDesktopBreakpoint) {
      return ResponsiveSizeClass.smallDesktop;
    }
    return ResponsiveSizeClass.largeDesktop;
  }

  bool get isMobile => sizeClass == ResponsiveSizeClass.mobile;
  bool get isTablet => sizeClass == ResponsiveSizeClass.tablet;
  bool get isSmallDesktop => sizeClass == ResponsiveSizeClass.smallDesktop;
  bool get isLargeDesktop => sizeClass == ResponsiveSizeClass.largeDesktop;
  bool get isDesktop => isSmallDesktop || isLargeDesktop;

  double get horizontalPadding {
    switch (sizeClass) {
      case ResponsiveSizeClass.mobile:
        return 12;
      case ResponsiveSizeClass.tablet:
        return 16;
      case ResponsiveSizeClass.smallDesktop:
        return 20;
      case ResponsiveSizeClass.largeDesktop:
        return 24;
    }
  }

  double get sectionGap {
    switch (sizeClass) {
      case ResponsiveSizeClass.mobile:
        return 10;
      case ResponsiveSizeClass.tablet:
        return 12;
      case ResponsiveSizeClass.smallDesktop:
        return 14;
      case ResponsiveSizeClass.largeDesktop:
        return 16;
    }
  }
}
