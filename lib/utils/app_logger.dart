import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/release_telemetry_sink.dart';

enum LogLevel { info, success, warning, error, debug }

class AppLogger {
  // Singleton pattern if we want to add more complex features later
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static void info(String message, {String? tag}) {
    _printLog('INFO', message, tag);
  }

  static void success(String message, {String? tag}) {
    _printLog('SUCCESS', message, tag);
  }

  static void warning(String message, {String? tag}) {
    _printLog('WARNING', message, tag);
    _emitTelemetry(level: 'warning', message: message, tag: tag);
  }

  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final combinedMessage = error != null ? '$message: $error' : message;
    _printLog('ERROR', combinedMessage, tag);
    _emitTelemetry(
      level: 'error',
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
    if (kDebugMode && stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _printLog('DEBUG', message, tag);
    }
  }

  static void _printLog(String prefix, String message, String? tag) {
    if (kDebugMode) {
      final tagStr = tag != null ? ' [$tag]' : '';
      debugPrint('$prefix$tagStr: $message');
    }
  }

  static void _emitTelemetry({
    required String level,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!(kReleaseMode || kProfileMode)) {
      return;
    }
    unawaited(
      ReleaseTelemetrySink.instance.record(
        level: level,
        message: message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
