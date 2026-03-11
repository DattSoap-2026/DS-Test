import 'package:flutter/material.dart';

import '../../utils/responsive.dart';

/// CORE ARCHITECTURE FILE
/// DO NOT BYPASS.
/// All responsive behavior must route through this layer.
class ResponsiveAlertDialog extends StatelessWidget {
  final Widget? icon;
  final EdgeInsetsGeometry? iconPadding;
  final Color? iconColor;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final TextStyle? titleTextStyle;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? actionsPadding;
  final MainAxisAlignment? actionsAlignment;
  final OverflowBarAlignment? actionsOverflowAlignment;
  final VerticalDirection? actionsOverflowDirection;
  final double? actionsOverflowButtonSpacing;
  final EdgeInsetsGeometry? buttonPadding;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final String? semanticLabel;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;
  final bool scrollable;
  final EdgeInsets? insetPadding;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? contentTextStyle;
  final BoxConstraints? constraints;
  final double maxWidth;
  final double maxHeightFactor;

  const ResponsiveAlertDialog({
    super.key,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.title,
    this.titlePadding,
    this.titleTextStyle,
    this.content,
    this.actions,
    this.actionsPadding,
    this.actionsAlignment,
    this.actionsOverflowAlignment,
    this.actionsOverflowDirection,
    this.actionsOverflowButtonSpacing,
    this.buttonPadding,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.semanticLabel,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.scrollable = false,
    this.insetPadding,
    this.contentPadding,
    this.contentTextStyle,
    this.constraints,
    this.maxWidth = 600,
    this.maxHeightFactor = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveConstraints = Responsive.dialogConstraints(
      context,
      maxWidth: maxWidth,
      maxHeightFactor: maxHeightFactor,
    );
    final effectiveConstraints =
        constraints == null
            ? responsiveConstraints
            : BoxConstraints(
                minWidth: constraints!.minWidth,
                maxWidth: constraints!.maxWidth < responsiveConstraints.maxWidth
                    ? constraints!.maxWidth
                    : responsiveConstraints.maxWidth,
                minHeight: constraints!.minHeight,
                maxHeight: constraints!.maxHeight < responsiveConstraints.maxHeight
                    ? constraints!.maxHeight
                    : responsiveConstraints.maxHeight,
              );

    final resolvedContent =
        content == null
            ? null
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: effectiveConstraints.maxWidth),
                child:
                    scrollable ? content! : SingleChildScrollView(child: content!),
              );

    return Align(
      alignment: alignment ?? Alignment.center,
      child: ConstrainedBox(
        constraints: effectiveConstraints,
        child: AlertDialog(
          icon: icon,
          iconPadding: iconPadding,
          iconColor: iconColor,
          title: title,
          titlePadding: titlePadding,
          titleTextStyle: titleTextStyle,
          content: resolvedContent,
          contentPadding: contentPadding,
          contentTextStyle: contentTextStyle,
          actions: actions,
          actionsPadding: actionsPadding,
          actionsAlignment: actionsAlignment,
          actionsOverflowAlignment: actionsOverflowAlignment,
          actionsOverflowDirection: actionsOverflowDirection,
          actionsOverflowButtonSpacing: actionsOverflowButtonSpacing,
          buttonPadding: buttonPadding,
          backgroundColor: backgroundColor,
          elevation: elevation,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          semanticLabel: semanticLabel,
          insetPadding: insetPadding ?? Responsive.dialogInsetPadding(context),
          clipBehavior: clipBehavior ?? Clip.none,
          shape: shape,
          scrollable: scrollable,
        ),
      ),
    );
  }
}


