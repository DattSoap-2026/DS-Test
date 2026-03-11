import '../utils/app_logger.dart';
import '../utils/ui_notifier.dart';

/// A lightweight service for managing global notifications without requiring BuildContext at init.
/// Standardizes how we show Info, Success, Error, and Warning messages across the app.
class GlobalNotificationService {
  // Singleton instance
  static final GlobalNotificationService _instance =
      GlobalNotificationService._internal();

  factory GlobalNotificationService() {
    return _instance;
  }

  GlobalNotificationService._internal();

  // Expose the instance globally
  static GlobalNotificationService get instance => _instance;

  /// Shows an informational message (toast/snackbar).
  void showInfo(String message) {
    AppLogger.info('GlobalNotification: $message', tag: 'UI_INFO');
    UINotifier.showSnackbar(message);
  }

  /// Shows a success message (toast/snackbar).
  void showSuccess(String message) {
    AppLogger.info('GlobalNotification: $message', tag: 'UI_SUCCESS');
    UINotifier.showSuccess(message);
  }

  /// Shows a warning message. This is for recoverable errors or alerts
  /// that should NOT block the user interface.
  void showWarning(String message, [dynamic error, StackTrace? stackTrace]) {
    final combinedMessage = error != null ? '$message: $error' : message;
    AppLogger.warning(
      'GlobalNotification: $combinedMessage',
      tag: 'UI_WARNING',
    );
    if (stackTrace != null) {
      AppLogger.debug('StackTrace: $stackTrace', tag: 'UI_WARNING');
    }
    // Warnings are treated as standard informational snackbars with potential custom styling if needed.
    // We use showSnackbar to ensure they are non-blocking.
    UINotifier.showSnackbar(message);
  }

  /// Shows an error message. This is for operations that failed but
  /// do not require a full app restart or blocking dialog.
  /// E.g. "Failed to sync data"
  void showError(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.error(
      'GlobalNotification: $message',
      tag: 'UI_ERROR',
      error: error,
      stackTrace: stackTrace,
    );
    // Use UINotifier error styling which is also non-blocking (Toast/Snackbar)
    UINotifier.showError(message);
  }
}
