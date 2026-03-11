import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class CustomDialogs {
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResponsiveAlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          CustomButton(
            label: buttonText,
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Close',
  }) {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          CustomButton(
            label: buttonText,
            onPressed: () => Navigator.pop(context),
            width: double.infinity,
            color: theme.colorScheme.surfaceContainerHighest,
            textColor: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: cancelText,
                  variant: ButtonVariant.text,
                  onPressed: () => Navigator.pop(context, false),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: confirmText,
                  onPressed: () => Navigator.pop(context, true),
                  color: confirmColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

