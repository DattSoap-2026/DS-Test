import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../sync/sync_service.dart';
import '../utils/sync_logger.dart';

/// Tracks connectivity and triggers automatic background sync.
class ConnectivityService {
  ConnectivityService._internal();

  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isOnline = false;

  /// Current connectivity state.
  bool get isOnline => _isOnline;

  /// Broadcast stream of connectivity state.
  Stream<bool> get stream => _controller.stream.distinct();

  /// Starts the connectivity listener.
  Future<void> startListening() async {
    try {
      final current = await _connectivity.checkConnectivity();
      _updateStatus(_mapResults(current));

      await _subscription?.cancel();
      _subscription = _connectivity.onConnectivityChanged.listen((
        ConnectivityResult result,
      ) {
        final online = _mapResults(result);
        final wasOffline = !_isOnline && online;
        _updateStatus(online);
        if (wasOffline) {
          SyncLogger.instance.i(
            'Connectivity restored. Triggering automatic sync.',
            time: DateTime.now(),
          );
          unawaited(
            Future<void>.delayed(const Duration(seconds: 2), () async {
              await SyncService.instance.syncAllPending();
            }),
          );
        }
      });
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to initialize connectivity service',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Compatibility alias retained for existing startup code.
  Future<void> initialize() => startListening();

  /// Disposes the connectivity listener.
  Future<void> dispose() async {
    try {
      await _subscription?.cancel();
      await _controller.close();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to dispose connectivity service',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  bool _mapResults(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  void _updateStatus(bool online) {
    _isOnline = online;
    if (!_controller.isClosed) {
      _controller.add(online);
    }
  }
}
