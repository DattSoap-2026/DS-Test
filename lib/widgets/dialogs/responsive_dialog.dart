import 'package:flutter/material.dart';

import '../../utils/responsive.dart';

/// CORE ARCHITECTURE FILE
/// DO NOT BYPASS.
/// All responsive behavior must route through this layer.
class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxHeightFactor;
  final BorderRadius? borderRadius;
  final bool scrollable;

  const ResponsiveDialog({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.maxHeightFactor = 0.85,
    this.borderRadius,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: Responsive.dialogInsetPadding(context),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: Responsive.dialogConstraints(
          context,
          maxWidth: maxWidth,
          maxHeightFactor: maxHeightFactor,
        ),
        child: scrollable ? SingleChildScrollView(child: child) : child,
      ),
    );
  }
}
