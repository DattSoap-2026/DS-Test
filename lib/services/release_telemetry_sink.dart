import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Release-only telemetry sink for structured error/warning persistence.
///
/// Stores newline-delimited JSON records under app documents:
/// `telemetry/release_error_log.jsonl`
class ReleaseTelemetrySink {
  ReleaseTelemetrySink._();

  static final ReleaseTelemetrySink instance = ReleaseTelemetrySink._();

  static const String _fileName = 'release_error_log.jsonl';
  static const String _directoryName = 'telemetry';
  static const int _maxErrorTextLength = 4000;

  File? _file;
  Future<void> _writeChain = Future<void>.value();

  Future<void> record({
    required String level,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!(kReleaseMode || kProfileMode)) {
      return Future<void>.value();
    }

    _writeChain = _writeChain.then((_) async {
      final file = await _resolveFile();
      if (file == null) return;

      final payload = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'level': level,
        'tag': tag ?? '',
        'message': message,
        if (error != null) 'error': _truncate(error.toString()),
        if (stackTrace != null) 'stack': _truncate(stackTrace.toString()),
        'releaseMode': kReleaseMode,
        'profileMode': kProfileMode,
      };

      try {
        await file.writeAsString(
          '${jsonEncode(payload)}\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (_) {
        // Fail-safe: telemetry persistence must never crash production flow.
      }
    }).catchError((_) {
      // Keep the write chain alive after unexpected failures.
    });

    return _writeChain;
  }

  Future<File?> _resolveFile() async {
    if (_file != null) return _file;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/$_directoryName');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}/$_fileName');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      _file = file;
      return _file;
    } catch (_) {
      return null;
    }
  }

  String _truncate(String value) {
    if (value.length <= _maxErrorTextLength) {
      return value;
    }
    return '${value.substring(0, _maxErrorTextLength)}...';
  }
}
