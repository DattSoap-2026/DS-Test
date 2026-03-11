import 'package:flutter/material.dart';
import '../core/error/failures.dart';
import '../widgets/ui/custom_dialogs.dart';

class ServiceHandler {
  static Future<T?> execute<T>(
    BuildContext context, {
    required Future<T> Function() action,
    String? loadingMessage,
    bool showSuccessDialog = false,
    String? successMessage,
    bool showErrorDialog = true,
  }) async {
    try {
      // Show loading indicator if requested
      // For now, we rely on individual screens to handle local loading states
      // but we can add a global overlay here if needed.
      
      final result = await action();

      if (showSuccessDialog && context.mounted) {
        await CustomDialogs.showSuccess(
          context: context,
          title: 'Success',
          message: successMessage ?? 'Operation completed successfully.',
        );
      }

      return result;
    } catch (e) {
      if (showErrorDialog && context.mounted) {
        String message = 'An unexpected error occurred.';
        if (e is Failure) {
          message = e.message;
        }

        await CustomDialogs.showError(
          context: context,
          title: 'Operation Failed',
          message: message,
        );
      }
      return null;
    }
  }
}
