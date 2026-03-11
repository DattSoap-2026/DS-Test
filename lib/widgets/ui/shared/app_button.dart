import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Premium dimensions
    const double height = 44.0;
    const double radius = 12.0;
    const double iconSize = 18.0;

    final bool effectivelyDisabled =
        isDisabled || isLoading || onPressed == null;

    Color backgroundColor;
    Color effectiveForegroundColor; // Renamed local variable
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        effectiveForegroundColor = colorScheme.onPrimary;
        break;
      case ButtonVariant.secondary:
        backgroundColor = colorScheme.primary.withValues(alpha: 0.08);
        effectiveForegroundColor = colorScheme.primary;
        borderSide = BorderSide(color: colorScheme.primary.withValues(alpha: 0.3));
        break;
      case ButtonVariant.danger:
        backgroundColor = colorScheme.error;
        effectiveForegroundColor = colorScheme.onError;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        effectiveForegroundColor = colorScheme.onSurface.withValues(alpha: 0.7);
        break;
    }

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: effectivelyDisabled ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor ?? effectiveForegroundColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
                side: borderSide,
              ),
              shadowColor: colorScheme.primary.withValues(alpha: 0.25),
              disabledBackgroundColor:
                  variant == ButtonVariant.ghost ||
                      variant == ButtonVariant.secondary
                  ? Colors.transparent
                  : colorScheme.onSurface.withValues(alpha: 0.12),
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return (foregroundColor ?? effectiveForegroundColor)
                      .withValues(alpha: 0.08);
                }
                if (states.contains(WidgetState.pressed)) {
                  return (foregroundColor ?? effectiveForegroundColor)
                      .withValues(alpha: 0.12);
                }
                return null;
              }),
            ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor ?? effectiveForegroundColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: effectivelyDisabled
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : (foregroundColor ?? effectiveForegroundColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
