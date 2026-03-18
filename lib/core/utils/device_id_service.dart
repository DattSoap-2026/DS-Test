import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'sync_logger.dart';

/// Provides a stable per-installation device id.
class DeviceIdService {
  DeviceIdService._internal();

  static final DeviceIdService instance = DeviceIdService._internal();

  static const String _deviceIdKey = 'inventory_sync_device_id_v1';
  static const Uuid _uuid = Uuid();

  String? _cachedDeviceId;

  /// Initializes and caches the device id.
  Future<String> initialize() async {
    try {
      return await getDeviceId();
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to initialize device id',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Returns the stable device id for this installation.
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final existing = preferences.getString(_deviceIdKey);
      if (existing != null && existing.isNotEmpty) {
        _cachedDeviceId = existing;
        return existing;
      }

      final generated = _uuid.v4();
      await preferences.setString(_deviceIdKey, generated);
      _cachedDeviceId = generated;
      return generated;
    } catch (error, stackTrace) {
      SyncLogger.instance.e(
        'Failed to get device id',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }
}
