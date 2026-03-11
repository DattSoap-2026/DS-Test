import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'app_toast.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class UINotifier {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  // Key for accessing MainScaffoldState for tabs/sidebar control
  static final GlobalKey<State> mainScaffoldKey = GlobalKey<State>();

  /// Shows a modern Toast for info/success/error.
  /// Falls back to standard Snackbar if an [action] is provided.
  static void showSnackbar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    // If we have an action (e.g. Undo), we MUST use a standard SnackBar
    if (action != null) {
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger == null) return;
      final theme = Theme.of(messenger.context);
      final backgroundColor = isError
          ? theme.colorScheme.error
          : (isSuccess ? AppColors.success : theme.colorScheme.primary);
      final foregroundColor = isError
          ? theme.colorScheme.onError
          : theme.colorScheme.onPrimary;

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline
                    : (isSuccess
                          ? Icons.check_circle_outline
                          : Icons.info_outline),
                color: foregroundColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: foregroundColor),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          action: action,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
      return;
    }

    // Otherwise, use the modern AppToast
    final context = navigatorKey.currentContext;
    if (context != null) {
      ToastType type = ToastType.info;
      if (isError) type = ToastType.error;
      if (isSuccess) type = ToastType.success;

      AppToast.show(context, message: message, type: type, duration: duration);
    }
  }

  /// Convenience method for error snackbars
  static void showError(String message) => showSnackbar(message, isError: true);

  /// Convenience method for success snackbars
  static void showSuccess(String message) =>
      showSnackbar(message, isSuccess: true);

  /// Shows a loading dialog
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResponsiveAlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}

