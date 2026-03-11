import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
  filled,
  outline,
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? color;
  final Color? textColor;
  final bool isDense;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
    this.color,
    this.textColor,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    // Modern theming
    final theme = Theme.of(context);
    final themeColor = color ?? theme.colorScheme.primary;
    final isEnabled = onPressed != null && !isLoading;

    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.filled:
        return _buildElevatedButton(
          themeColor,
          textColor ?? theme.colorScheme.onPrimary,
          isEnabled,
        );
      case ButtonVariant.secondary:
        return _buildElevatedButton(
          themeColor.withValues(alpha: 0.1),
          textColor ?? themeColor,
          isEnabled,
        );
      case ButtonVariant.outlined:
      case ButtonVariant.outline:
        return _buildOutlinedButton(textColor ?? themeColor, isEnabled);
      case ButtonVariant.text:
        return _buildTextButton(textColor ?? themeColor, isEnabled);
      case ButtonVariant.danger:
        return _buildElevatedButton(
          theme.colorScheme.error,
          textColor ?? theme.colorScheme.onError,
          isEnabled,
        ); // onError usually white
    }
  }

  // Wrapper for haptics
  VoidCallback? _getHandler(bool isEnabled) {
    if (!isEnabled) return null;
    return () {
      HapticFeedback.lightImpact();
      onPressed?.call();
    };
  }

  Widget _buildElevatedButton(Color bg, Color fg, bool isEnabled) {
    return SizedBox(
      width: width,
      height: isDense ? 40 : height,
      child: ElevatedButton(
        onPressed: _getHandler(isEnabled),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _buildChild(fg),
      ),
    );
  }

  Widget _buildOutlinedButton(Color color, bool isEnabled) {
    return SizedBox(
      width: width,
      height: isDense ? 40 : height,
      child: OutlinedButton(
        onPressed: _getHandler(isEnabled),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: isEnabled ? color : color.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _buildChild(color),
      ),
    );
  }

  Widget _buildTextButton(Color color, bool isEnabled) {
    return SizedBox(
      width: width,
      height: isDense ? 40 : height,
      child: TextButton(
        onPressed: _getHandler(isEnabled),
        style: TextButton.styleFrom(
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _buildChild(color),
      ),
    );
  }

  Widget _buildChild(Color fgColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: isDense ? 13 : 14,
      letterSpacing: 0.2,
      color: fgColor,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 8),
          Text(label, style: textStyle),
        ],
      );
    }

    return Text(label, style: textStyle);
  }
}
