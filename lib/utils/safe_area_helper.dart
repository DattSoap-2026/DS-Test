import 'package:flutter/material.dart';

/// Utility class for handling safe area padding consistently across the app
/// Ensures buttons and content are not cut off by system navigation bars
class SafeAreaHelper {
  /// Returns bottom padding that includes system navigation bar height
  /// Use this for bottom action buttons, floating action buttons, etc.
  static double getBottomPadding(BuildContext context, {double additional = 0}) {
    return MediaQuery.of(context).padding.bottom + additional;
  }

  /// Returns EdgeInsets with bottom safe area padding
  /// Useful for wrapping bottom buttons or content
  static EdgeInsets bottomPadding(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(
      left,
      top,
      right,
      bottom + MediaQuery.of(context).padding.bottom,
    );
  }

  /// Returns EdgeInsets with all safe area paddings
  static EdgeInsets allPadding(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.fromLTRB(
      left + padding.left,
      top + padding.top,
      right + padding.right,
      bottom + padding.bottom,
    );
  }

  /// Wraps a widget with SafeArea
  /// Convenience method for common use cases
  static Widget wrap(
    Widget child, {
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  /// Returns minimum touch target size (44x44 logical pixels)
  /// As per Material Design and iOS Human Interface Guidelines
  static const double minTouchTarget = 44.0;

  /// Checks if a widget meets minimum touch target size
  static bool meetsMinTouchTarget(double width, double height) {
    return width >= minTouchTarget && height >= minTouchTarget;
  }
}
