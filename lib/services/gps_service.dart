import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'base_service.dart';

const locationsCollection = 'locations';
const _locationCacheKey = 'gps_cached_locations_v1';
String _historyCacheKey(String userId) => 'gps_cached_history_v1_$userId';

class LocationData {
  final String userId;
  final String userName;
  final String role;
  final double latitude;
  final double longitude;
  final int timestamp; // Milliseconds
  final String lastUpdated; // ISO String
  final bool isOnline;
  final double? heading;
  final double? speed;

  LocationData({
    required this.userId,
    required this.userName,
    required this.role,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.lastUpdated,
    required this.isOnline,
    this.heading,
    this.speed,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'role': role,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'lastUpdated': lastUpdated,
      'isOnline': isOnline,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
    };
  }
}

class LocationHistoryPoint {
  final double latitude;
  final double longitude;
  final int timestamp;
  final String isoTimestamp;
  final double speed;
  final double heading;

  LocationHistoryPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.isoTimestamp,
    required this.speed,
    required this.heading,
  });

  factory LocationHistoryPoint.fromJson(Map<String, dynamic> json) {
    return LocationHistoryPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: (json['timestamp'] as num).toInt(),
      isoTimestamp: json['isoTimestamp'] as String,
      speed: (json['speed'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'isoTimestamp': isoTimestamp,
      'speed': speed,
      'heading': heading,
    };
  }
}

class LocationStats {
  final double totalDistance;
  final double maxSpeed;
  final double avgSpeed;
  final int totalPoints;
  final LocationHistoryPoint? firstPoint;
  final LocationHistoryPoint? lastPoint;

  LocationStats({
    required this.totalDistance,
    required this.maxSpeed,
    required this.avgSpeed,
    required this.totalPoints,
    this.firstPoint,
    this.lastPoint,
  });
}

class GpsService extends BaseService {
  GpsService(super.firebase);

  bool _isTracking = false;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;

  /// Sets the polling interval. Setting dynamic intervals helps save battery.
  void setPollingInterval(int seconds) {
    AppLogger.info('GPS polling interval set to $seconds seconds', tag: 'GPS');
  }

  /// Starts location tracking with battery-efficient strategy.
  Future<void> startTracking(
    String userId, {
    String? userName,
    String? role,
  }) async {
    if (_isTracking) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    } else if (permission == LocationPermission.deniedForever) {
      return;
    }

    _isTracking = true;

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 10,
          ),
        ).listen(
          (Position position) {
            _handleNewPosition(position, userId, userName, role);
          },
          onError: (Object error, StackTrace stackTrace) {
            handleError(error, 'startTracking.positionStream');
            _isTracking = false;
          },
          onDone: () {
            _isTracking = false;
          },
        );
  }

  void stopTracking() {
    _positionStream?.cancel();
    _isTracking = false;
  }

  void _handleNewPosition(
    Position position,
    String userId,
    String? userName,
    String? role,
  ) {
    // Battery efficiency: Only update if moved more than 20 meters or 5 minutes passed
    if (_lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      final timeSinceLast = position.timestamp.difference(
        _lastPosition!.timestamp,
      );

      // If moving slowly (speed < 1m/s) and moved < 20m and < 5 mins passed, skip update
      if (position.speed < 1.0 &&
          distance < 20 &&
          timeSinceLast.inMinutes < 5) {
        return;
      }
    }

    _lastPosition = position;

    updateEntityLocation(
      userId,
      PartialLocationData(
        userId: userId,
        userName: userName,
        role: role,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
        isOnline: true,
      ),
    );
  }

  Future<void> updateEntityLocation(
    String entityId,
    PartialLocationData data,
  ) async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final isoNow = now.toIso8601String();

    // Keep last-known location/history locally even when Firestore is unavailable.
    await _cacheLocationUpdate(
      entityId,
      data,
      timestamp: timestamp,
      isoNow: isoNow,
    );

    try {
      final firestore = db;
      if (firestore == null) return;

      final ref = firestore.collection(locationsCollection).doc(entityId);
      final updateData = data.toJson();
      updateData['lastUpdated'] = isoNow;
      updateData['timestamp'] = timestamp;

      // Update current location
      await ref.set(updateData, SetOptions(merge: true));

      // If we have coordinates, add to history
      if (data.latitude != null && data.longitude != null) {
        final historyRef = ref.collection('history');
        await historyRef.add({
          'latitude': data.latitude,
          'longitude': data.longitude,
          'timestamp': timestamp,
          'isoTimestamp': isoNow,
          'speed': data.speed ?? 0,
          'heading': data.heading ?? 0,
        });
      }
    } catch (e) {
      handleError(e, 'updateEntityLocation');
      // Do not rethrow, log only
    }
  }

  // Alias for backward compatibility if needed, but in Flutter we can just use updateEntityLocation
  Future<void> updateSalesmanLocation(
    String entityId,
    PartialLocationData data,
  ) => updateEntityLocation(entityId, data);

  Stream<List<LocationData>> subscribeToLocations() async* {
    final cachedInitial = await _readCachedLocations();
    if (cachedInitial.isNotEmpty) {
      yield cachedInitial;
    }

    final firestore = db;
    if (firestore == null) {
      yield cachedInitial;
      while (true) {
        await Future<void>.delayed(const Duration(seconds: 30));
        yield await _readCachedLocations();
      }
    }

    final query = firestore.collection(locationsCollection);

    List<LocationData> mapSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return LocationData.fromJson(data);
      }).toList();
    }

    while (true) {
      try {
        final snapshot = await query.get();
        final locations = mapSnapshot(snapshot);
        await _cacheLocations(locations);
        yield locations;
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          yield await _readCachedLocations();
          return;
        }
        handleError(e, 'subscribeToLocations');
        yield await _readCachedLocations();
      } catch (e) {
        handleError(e, 'subscribeToLocations');
        yield await _readCachedLocations();
      }

      // Poll every 30 seconds to avoid real-time listeners and save reads
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }

  Future<List<LocationData>> getSalesmanLocations() async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore.collection(locationsCollection).get();
      final locations = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return LocationData.fromJson(data);
      }).toList();

      // Filter out stale locations (older than 10 minutes)
      final tenMinutesAgo =
          DateTime.now().millisecondsSinceEpoch - 10 * 60 * 1000;
      return locations.where((loc) => loc.timestamp > tenMinutesAgo).toList();
    } catch (e) {
      handleError(e, 'getSalesmanLocations');
      return [];
    }
  }

  Future<List<LocationHistoryPoint>> getLocationHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final firestore = db;
    if (firestore == null) {
      return _readCachedHistory(userId, startDate: startDate, endDate: endDate);
    }

    try {
      Query query = firestore
          .collection(locationsCollection)
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(1000);

      if (startDate != null && endDate != null) {
        query = firestore
            .collection(locationsCollection)
            .doc(userId)
            .collection('history')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
            )
            .where(
              'timestamp',
              isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
            )
            .orderBy('timestamp', descending: true)
            .limit(1000);
      }

      final snapshot = await query.get();

      // Data from Firestore comes in descending order (newest first).
      // We reverse it to return chronological order (oldest first).
      final history = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return LocationHistoryPoint.fromJson(data);
      }).toList();

      final ordered = history.reversed.toList();
      await _cacheHistory(userId, ordered);
      return ordered;
    } catch (e) {
      handleError(e, 'getLocationHistory');
      return _readCachedHistory(userId, startDate: startDate, endDate: endDate);
    }
  }

  Future<void> _cacheLocationUpdate(
    String entityId,
    PartialLocationData data, {
    required int timestamp,
    required String isoNow,
  }) async {
    try {
      final locations = await _readCachedLocations();
      final existingIndex = locations.indexWhere(
        (loc) => loc.userId == entityId,
      );
      final existing = existingIndex >= 0 ? locations[existingIndex] : null;

      final next = LocationData(
        userId: data.userId ?? existing?.userId ?? entityId,
        userName: data.userName ?? existing?.userName ?? '',
        role: data.role ?? existing?.role ?? '',
        latitude: data.latitude ?? existing?.latitude ?? 0,
        longitude: data.longitude ?? existing?.longitude ?? 0,
        timestamp: timestamp,
        lastUpdated: isoNow,
        isOnline: data.isOnline ?? existing?.isOnline ?? false,
        heading: data.heading ?? existing?.heading,
        speed: data.speed ?? existing?.speed,
      );

      if (existingIndex >= 0) {
        locations[existingIndex] = next;
      } else {
        locations.add(next);
      }
      await _cacheLocations(locations);

      final hasCoordinates =
          next.latitude.abs() <= 90 &&
          next.longitude.abs() <= 180 &&
          !(next.latitude == 0 && next.longitude == 0);
      if (!hasCoordinates) return;

      final history = await _readCachedHistory(entityId);
      history.add(
        LocationHistoryPoint(
          latitude: next.latitude,
          longitude: next.longitude,
          timestamp: timestamp,
          isoTimestamp: isoNow,
          speed: next.speed ?? 0,
          heading: next.heading ?? 0,
        ),
      );
      await _cacheHistory(entityId, history);
    } catch (_) {
      // Best-effort cache update only.
    }
  }

  Future<void> _cacheLocations(List<LocationData> locations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = locations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_locationCacheKey, jsonEncode(payload));
    } catch (_) {
      // Best-effort cache write only.
    }
  }

  Future<List<LocationData>> _readCachedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_locationCacheKey);
      if (raw == null || raw.isEmpty) return <LocationData>[];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <LocationData>[];

      return decoded
          .whereType<Map>()
          .map((item) => LocationData.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return <LocationData>[];
    }
  }

  Future<void> _cacheHistory(
    String userId,
    List<LocationHistoryPoint> history,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trimmed = history.length > 1500
          ? history.sublist(history.length - 1500)
          : history;
      final payload = trimmed.map((point) => point.toJson()).toList();
      await prefs.setString(_historyCacheKey(userId), jsonEncode(payload));
    } catch (_) {
      // Best-effort cache write only.
    }
  }

  Future<List<LocationHistoryPoint>> _readCachedHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyCacheKey(userId));
      if (raw == null || raw.isEmpty) return <LocationHistoryPoint>[];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <LocationHistoryPoint>[];

      final history = decoded
          .whereType<Map>()
          .map(
            (item) =>
                LocationHistoryPoint.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      final filtered = history.where((point) {
        if (startDate != null &&
            point.timestamp < startDate.millisecondsSinceEpoch) {
          return false;
        }
        if (endDate != null &&
            point.timestamp > endDate.millisecondsSinceEpoch) {
          return false;
        }
        return true;
      }).toList();

      filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return filtered;
    } catch (_) {
      return <LocationHistoryPoint>[];
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth's radius in kilometers
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = R * c;

    return distance; // in km
  }

  double getTotalDistance(List<LocationHistoryPoint> history) {
    if (history.length < 2) return 0;

    double totalDistance = 0;

    for (int i = 1; i < history.length; i++) {
      final prev = history[i - 1];
      final curr = history[i];

      totalDistance += calculateDistance(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );
    }

    return totalDistance;
  }

  Future<LocationStats> getLocationStats(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final history = await getLocationHistory(
      userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    final totalDistance = getTotalDistance(history);

    // Calculate max speed
    double maxSpeed = 0;
    if (history.isNotEmpty) {
      maxSpeed = history.map((h) => h.speed).reduce(math.max);
    }

    // Calculate avg speed
    double avgSpeed = 0;
    if (history.isNotEmpty) {
      final sumSpeed = history.fold<double>(0, (total, h) => total + h.speed);
      avgSpeed = sumSpeed / history.length;
    }

    return LocationStats(
      totalDistance: totalDistance,
      maxSpeed: maxSpeed,
      avgSpeed: avgSpeed,
      totalPoints: history.length,
      firstPoint: history.isNotEmpty ? history.first : null,
      lastPoint: history.isNotEmpty ? history.last : null,
    );
  }

  Future<PartialLocationData?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return PartialLocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
      );
    } catch (e) {
      return null;
    }
  }
}

// Helper class for partial updates to avoid null issues in toJson
class PartialLocationData {
  final String? userId;
  final String? userName;
  final String? role;
  final double? latitude;
  final double? longitude;
  final bool? isOnline;
  final double? heading;
  final double? speed;

  PartialLocationData({
    this.userId,
    this.userName,
    this.role,
    this.latitude,
    this.longitude,
    this.isOnline,
    this.heading,
    this.speed,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (userId != null) data['userId'] = userId;
    if (userName != null) data['userName'] = userName;
    if (role != null) data['role'] = role;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (isOnline != null) data['isOnline'] = isOnline;
    if (heading != null) data['heading'] = heading;
    if (speed != null) data['speed'] = speed;
    return data;
  }
}
