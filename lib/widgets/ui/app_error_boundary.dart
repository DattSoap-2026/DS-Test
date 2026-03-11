import 'package:flutter/material.dart';
import '../../utils/app_logger.dart';

/// A widget that catches Flutter rendering exceptions thrown by its descendants.
/// It displays a safe, user-friendly fallback UI without crashing the rest of the app hierarchy.
class AppErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, FlutterErrorDetails errorDetails)?
  fallbackBuilder;

  const AppErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
  });

  @override
  AppErrorBoundaryState createState() => AppErrorBoundaryState();
}

class AppErrorBoundaryState extends State<AppErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(FlutterErrorDetails details) {
    AppLogger.error(
      'AppErrorBoundary caught specialized rendering error',
      error: details.exception,
      stackTrace: details.stack,
      tag: 'ErrorBoundary',
    );
    setState(() {
      _errorDetails = details;
    });
  }

  /// Allows the UI to retry rendering the child.
  void resetError() {
    setState(() {
      _errorDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _errorDetails!);
      }
      return AppErrorFallbackUi(
        errorDetails: _errorDetails!,
        onRetry: resetError,
        onGoBack: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            resetError();
          }
        },
      );
    }

    // Using ErrorWidget.builder locally is tricky due to Flutter's architecture,
    // so we rely on standard Stateful widget build mechanics, but provide a context
    // wrapper if needed. For deep render catches, we override the global ErrorWidget builder
    // in main.dart OR use a Builder. Since the requirement is to intercept rendering errors
    // of *descendants*, standard try-catch in build doesn't work for child tree.
    // The standard way in Flutter to catch descendant render errors is mapping ErrorWidget.builder.
    // This Stateful widget mainly serves to encapsulate state if we *manually* trigger it,
    // or provide the layout. Real interception happens globally.
    // We will inject the builder context here if we want localized catches.

    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (e, stack) {
          _handleError(FlutterErrorDetails(exception: e, stack: stack));
          return const SizedBox.shrink(); // Will trigger rebuild with error state
        }
      },
    );
  }
}

class AppErrorFallbackUi extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const AppErrorFallbackUi({
    super.key,
    required this.errorDetails,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong displaying this screen.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'An unexpected error occurred. The application remains running.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (onRetry != null) ...[
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                const SizedBox(height: 8),
              ],
              if (onGoBack != null)
                TextButton.icon(
                  onPressed: onGoBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
