import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';
import 'dart:async';

import 'offline_first_service.dart';
import 'database_service.dart';
import 'outbox_codec.dart';
import '../data/local/entities/sync_queue_entity.dart';
import '../core/firebase/firebase_config.dart';
import '../modules/accounting/posting_service.dart';
import 'mixins/safe_voucher_posting_mixin.dart';

// Entities
import '../data/local/entities/vehicle_entity.dart';
import '../data/local/entities/diesel_log_entity.dart';
import '../data/local/base_entity.dart';

const dieselLogsCollection = 'diesel_logs';
const vehiclesCollection = 'vehicles';
const fuelStockDoc = 'public_settings/fuel_stock';
const fuelSettingsDoc = 'public_settings/fuel_settings';
const fuelPurchasesCollection = 'fuel_purchases';

// Models
class DieselLog {
  final String id;
  final String vehicleId;
  final String vehicleNumber;
  final String driverName;
  final String fillDate;
  final double liters;
  final double rate;
  final double totalCost;
  final double odometerReading;
  final bool tankFull;
  final String? journeyFrom;
  final String? journeyTo;

  final double? cycleDistance;
  final double? cycleFuelUsed;
  final double? cycleEfficiency; // mileage
  final double? penaltyAmount;
  final String status;

  final double? startOdometer;
  final double? endOdometer;

  final String createdBy;
  final String createdAt;

  final bool penaltyOverridden;
  final String? overrideReason;
  final String? overriddenBy;
  final double? originalPenaltyAmount;

  DieselLog({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.driverName,
    required this.fillDate,
    required this.liters,
    required this.rate,
    required this.totalCost,
    required this.odometerReading,
    required this.tankFull,
    this.journeyFrom,
    this.journeyTo,
    this.cycleDistance,
    this.cycleFuelUsed,
    this.cycleEfficiency,
    this.penaltyAmount,
    this.status = 'PENDING',
    this.startOdometer,
    this.endOdometer,
    required this.createdBy,
    required this.createdAt,
    this.penaltyOverridden = false,
    this.overrideReason,
    this.overriddenBy,
    this.originalPenaltyAmount,
  });

  // Convenience getters for backward compatibility
  double? get mileage => cycleEfficiency;
  double get odometer => odometerReading;
  String get date => fillDate;

  factory DieselLog.fromEntity(DieselLogEntity e) {
    return DieselLog(
      id: e.id,
      vehicleId: e.vehicleId,
      vehicleNumber: e.vehicleNumber,
      driverName: e.driverName ?? '',
      fillDate: e.fillDate.toIso8601String(),
      liters: e.liters,
      rate: e.rate,
      totalCost: e.totalCost,
      odometerReading: e.odometerReading,
      tankFull: e.tankFull,
      journeyFrom: e.journeyFrom,
      journeyTo: e.journeyTo,
      cycleDistance: e.cycleDistance,
      cycleFuelUsed: e.cycleFuelUsed,
      cycleEfficiency: e.cycleEfficiency,
      penaltyAmount: e.penaltyAmount,
      status: e.status ?? 'PENDING',
      createdBy: e.createdBy ?? '',
      createdAt: e.createdAt,
      penaltyOverridden: e.penaltyOverridden,
      overrideReason: e.overrideReason,
      overriddenBy: e.overriddenBy,
      originalPenaltyAmount: e.originalPenaltyAmount,
    );
  }
}

class FuelPurchase {
  final String id;
  final double quantity;
  final double rate;
  final double totalAmount;
  final String supplierName;
  final String purchaseDate;
  final String addedBy;
  final String createdAt;

  FuelPurchase({
    required this.id,
    required this.quantity,
    required this.rate,
    required this.totalAmount,
    required this.supplierName,
    required this.purchaseDate,
    required this.addedBy,
    required this.createdAt,
  });

  factory FuelPurchase.fromJson(Map<String, dynamic> json) {
    return FuelPurchase(
      id: json['id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      supplierName: json['supplierName'] as String,
      purchaseDate: json['purchaseDate'] as String,
      addedBy: json['addedBy'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

class DieselService extends OfflineFirstService with SafeVoucherPostingMixin {
  final DatabaseService _dbService;
  late final PostingService _postingService;

  @override
  PostingService? get postingService => _postingService;

  DieselService(super.firebase) : _dbService = DatabaseService() {
    _postingService = PostingService(firebaseServices);
  }

  @override
  String get localStorageKey => 'local_diesel';

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  double _parseDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime _resolveLogEventTime(DieselLogEntity log) {
    final createdAt = DateTime.tryParse(log.createdAt);
    return createdAt ?? log.updatedAt;
  }

  Future<double> _sumLocalConsumedLiters({DateTime? after}) async {
    final allLogs = await _dbService.dieselLogs.where().findAll();
    return allLogs
        .where((log) {
          if (log.isDeleted) return false;
          if (after == null) return true;
          return _resolveLogEventTime(log).isAfter(after);
        })
        .fold<double>(0, (total, log) => total + log.liters);
  }

  Future<double> _sumPendingPurchasedLiters({Set<String>? excludeIds}) async {
    final queueItems = await _dbService.syncQueue
        .filter()
        .collectionEqualTo(fuelPurchasesCollection)
        .findAll();

    double queuedLiters = 0;
    for (final item in queueItems) {
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      if (OutboxCodec.isPermanentFailure(decoded.meta)) {
        continue;
      }
      if (item.action == 'delete') continue;

      final payload = decoded.payload;
      final id = payload['id']?.toString();
      if (excludeIds != null && id != null && excludeIds.contains(id)) {
        continue;
      }
      queuedLiters += _parseDouble(payload['quantity']);
    }
    return queuedLiters;
  }

  Future<double?> _tryReconstructStockFromPurchases({
    required double consumedLiters,
  }) async {
    final firestore = db;
    if (firestore == null) {
      final pendingPurchased = await _sumPendingPurchasedLiters();
      if (pendingPurchased <= 0) return null;
      final reconstructed = pendingPurchased - consumedLiters;
      return reconstructed < 0 ? 0.0 : reconstructed;
    }

    try {
      final snapshot = await firestore
          .collection(fuelPurchasesCollection)
          .get();
      final remoteIds = <String>{};
      final purchasedLiters = snapshot.docs.fold<double>(0, (total, doc) {
        remoteIds.add(doc.id);
        return total + _parseDouble(doc.data()['quantity']);
      });
      final pendingPurchased = await _sumPendingPurchasedLiters(
        excludeIds: remoteIds,
      );
      final totalPurchased = purchasedLiters + pendingPurchased;
      if (totalPurchased <= 0) return null;

      final reconstructed = totalPurchased - consumedLiters;
      return reconstructed < 0 ? 0.0 : reconstructed;
    } catch (_) {
      final pendingPurchased = await _sumPendingPurchasedLiters();
      if (pendingPurchased <= 0) return null;
      final reconstructed = pendingPurchased - consumedLiters;
      return reconstructed < 0 ? 0.0 : reconstructed;
    }
  }

  Future<void> _hydrateDieselLogsFromFirebaseIfNeeded() async {
    final localCount = await _dbService.dieselLogs.count();
    if (localCount > 0) return;

    final items = await bootstrapFromFirebase(
      collectionName: dieselLogsCollection,
    );
    if (items.isEmpty) return;

    await _dbService.db.writeTxn(() async {
      for (final item in items) {
        final id = (item['id'] ?? '').toString().trim();
        final vehicleId = (item['vehicleId'] ?? '').toString().trim();
        final vehicleNumber = (item['vehicleNumber'] ?? '').toString().trim();
        if (id.isEmpty || vehicleId.isEmpty || vehicleNumber.isEmpty) continue;

        final liters = _parseDouble(item['liters']);
        final rate = _parseDouble(item['rate']);
        var totalCost = _parseDouble(item['totalCost']);
        if (totalCost <= 0 && liters > 0 && rate > 0) {
          totalCost = liters * rate;
        }

        final entity = DieselLogEntity()
          ..id = id
          ..vehicleId = vehicleId
          ..vehicleNumber = vehicleNumber
          ..driverName = item['driverName']?.toString()
          ..fillDate = _parseDateTime(item['fillDate'])
          ..liters = liters
          ..rate = rate
          ..totalCost = totalCost
          ..odometerReading = _parseDouble(item['odometerReading'])
          ..tankFull = item['tankFull'] == true
          ..journeyFrom = item['journeyFrom']?.toString()
          ..journeyTo = item['journeyTo']?.toString()
          ..cycleDistance = _parseNullableDouble(item['cycleDistance'])
          ..cycleFuelUsed = _parseNullableDouble(item['cycleFuelUsed'])
          ..cycleEfficiency = _parseNullableDouble(item['cycleEfficiency'])
          ..penaltyAmount = _parseNullableDouble(item['penaltyAmount'])
          ..status = item['status']?.toString()
          ..createdBy = item['createdBy']?.toString()
          ..createdAt =
              (item['createdAt']?.toString().trim().isNotEmpty ?? false)
              ? item['createdAt'].toString()
              : DateTime.now().toIso8601String()
          ..updatedAt = _parseDateTime(item['updatedAt'] ?? item['createdAt'])
          ..syncStatus = SyncStatus.synced
          ..isDeleted = false;

        await _dbService.dieselLogs.put(entity);
      }
    });
  }

  Future<List<DieselLog>> getDieselLogs({
    int? limitCount,
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _hydrateDieselLogsFromFirebaseIfNeeded();

    // Fetch all and filter - Isar QueryBuilder has limited chaining support
    final allLogs = await _dbService.dieselLogs.where().findAll();
    
    var filtered = allLogs.where((l) {
      if (vehicleId != null && vehicleId != 'all' && l.vehicleId != vehicleId) {
        return false;
      }
      if (startDate != null && l.fillDate.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && l.fillDate.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
    
    filtered.sort((a, b) => b.fillDate.compareTo(a.fillDate));
    
    if (limitCount != null && filtered.length > limitCount) {
      filtered = filtered.sublist(0, limitCount);
    }

    return filtered.map((e) => DieselLog.fromEntity(e)).toList();
  }

  Future<List<DieselLog>> getDieselLogsByDriver(String driverName) async {
    final logs = await getDieselLogs();
    return logs
        .where(
          (l) =>
              l.driverName.trim().toLowerCase() ==
              driverName.trim().toLowerCase(),
        )
        .take(20)
        .toList();
  }

  Future<DieselLog?> getLastFullTankLog(String vehicleId) async {
    // Find last FULL tank log for this vehicle
    final log = await _dbService.dieselLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .tankFullEqualTo(true)
        .sortByFillDateDesc()
        .findFirst();

    if (log != null) {
      return DieselLog.fromEntity(log);
    }
    return null;
  }

  /// Add a diesel log entry for a vehicle.
  ///
  /// Records fuel fill, calculates mileage if tank is full, and updates vehicle stats.
  ///
  /// Parameters:
  /// - [logData]: Map containing vehicleId, tankFull, odometerReading, liters, rate, fillDate, etc.
  ///
  /// Throws:
  /// - [Exception] if odometer reading is less than current reading
  /// - [Exception] if fill date is in the future
  Future<void> addDieselLog(Map<String, dynamic> logData) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'offline_user';

    final vehicleId = logData['vehicleId'] as String;
    final tankFull = logData['tankFull'] as bool;
    final odometerReading = (logData['odometerReading'] as num).toDouble();
    final liters = (logData['liters'] as num).toDouble();
    final rate = (logData['rate'] as num).toDouble();
    final fillDate = DateTime.parse(logData['fillDate'] as String);
    final totalCost = liters * rate;

    // Validate odometer increment
    final vehicle = await _dbService.vehicles
        .filter()
        .idEqualTo(vehicleId)
        .findFirst();
    if (vehicle != null && odometerReading < vehicle.currentOdometer) {
      throw Exception(
        'Odometer reading (${odometerReading.toStringAsFixed(0)} km) cannot be less than current reading (${vehicle.currentOdometer.toStringAsFixed(0)} km)',
      );
    }

    // Validate future date
    if (fillDate.isAfter(DateTime.now())) {
      throw Exception('Fill date cannot be in the future');
    }

    // 1. Calculate Cycle Data
    double cycleDistance = 0;
    double cycleFuelUsed = 0;
    double cycleEfficiency = 0;
    String status = 'PENDING';
    double penaltyAmount = 0;

    DieselLog? lastFullLog;
    if (tankFull) {
      lastFullLog = await getLastFullTankLog(vehicleId);
      if (lastFullLog != null) {
        cycleDistance = odometerReading - lastFullLog.odometerReading;

        // Find intermediate logs
        final intermediateLogs = await _dbService.dieselLogs
            .filter()
            .vehicleIdEqualTo(vehicleId)
            .and()
            .tankFullEqualTo(false)
            .and()
            .fillDateGreaterThan(DateTime.parse(lastFullLog.fillDate))
            .findAll();

        final intermediateLiters = intermediateLogs.fold<double>(
          0,
          (total, log) => total + log.liters,
        );
        cycleFuelUsed = liters + intermediateLiters;

        if (cycleFuelUsed > 0) {
          cycleEfficiency = cycleDistance / cycleFuelUsed;
        }

        // Simple check using vehicle's configured minimum average
        final minAverage = vehicle?.minAverage ?? 10.0;
        if (cycleEfficiency < minAverage) {
          status = 'LOW_AVERAGE';
        } else {
          status = 'GOOD_AVERAGE';
        }
      }
    }

    // 2. Create Entity
    final entity = DieselLogEntity()
      ..id = generateId()
      ..vehicleId = vehicleId
      ..vehicleNumber = logData['vehicleNumber']
      ..driverName = logData['driverName']
      ..fillDate = fillDate
      ..liters = liters
      ..rate = rate
      ..totalCost = totalCost
      ..odometerReading = odometerReading
      ..tankFull = tankFull
      ..journeyFrom = logData['journeyFrom']
      ..journeyTo = logData['journeyTo']
      ..cycleDistance = cycleDistance
      ..cycleFuelUsed = cycleFuelUsed
      ..cycleEfficiency = cycleEfficiency
      ..status = status
      ..penaltyAmount = penaltyAmount
      ..createdBy = userId
      ..createdAt = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now();

    // 3. Local Transaction
    await _dbService.db.writeTxn(() async {
      // Save Log
      await _dbService.dieselLogs.put(entity);

      // Update Vehicle
      final vehicle = await _dbService.vehicles
          .filter()
          .idEqualTo(vehicleId)
          .findFirst();
      if (vehicle != null) {
        vehicle.currentOdometer = odometerReading;
        vehicle.totalDieselCost += totalCost;
        vehicle.totalFuelConsumed += liters; // Correctly using Liters for avg

        // Recalculate Distance (Total)
        // If cycle calculated, add it? Or trust odometer?
        // Trust odometer diff if reliable, or just rely on totalDistance field logic
        if (tankFull && cycleDistance > 0) {
          vehicle.totalDistance += cycleDistance;
        } else if (!tankFull) {
          // Approximate distance? Or wait for full tank?
          // Usually we only update total confirmed distance on Full Tank cycles
          // Or we update Odometer always.
          // Let's stick to updating global stats carefully.
        }

        vehicle.lastDieselFill = fillDate.toIso8601String();
        await _dbService.vehicles.put(vehicle);
      }
    });

    // 4. Sync
    final json = {
      'id': entity.id,
      'vehicleId': vehicleId,
      'vehicleNumber': entity.vehicleNumber,
      'driverName': entity.driverName,
      'fillDate': logData['fillDate'],
      'liters': liters,
      'rate': rate,
      'totalCost': totalCost,
      'odometerReading': odometerReading,
      'tankFull': tankFull,
      'journeyFrom': entity.journeyFrom,
      'journeyTo': entity.journeyTo,
      if (cycleDistance > 0) 'cycleDistance': cycleDistance,
      if (cycleFuelUsed > 0) 'cycleFuelUsed': cycleFuelUsed,
      if (cycleEfficiency > 0) 'cycleEfficiency': cycleEfficiency,
      'status': status,
      'createdBy': userId,
      'createdAt': entity.createdAt,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };

    await syncToFirebase('add', json, collectionName: dieselLogsCollection);
  }

  // Stock (Stubbed or Online)
  Future<double> getFuelStock() async {
    await _hydrateDieselLogsFromFirebaseIfNeeded();

    try {
      final consumedLiters = await _sumLocalConsumedLiters();
      final reconstructed = await _tryReconstructStockFromPurchases(
        consumedLiters: consumedLiters,
      );
      if (reconstructed != null) return reconstructed;

      final firestore = db;
      if (firestore == null) return 0.0;
      final doc = await firestore
          .doc(fuelStockDoc)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 3));
      if (!doc.exists) return 0.0;
      return _parseDouble(doc.data()?['totalLiters']);
    } catch (_) {
      try {
        final firestore = db;
        if (firestore != null) {
          final doc = await firestore
              .doc(fuelStockDoc)
              .get(const GetOptions(source: Source.cache));
          if (doc.exists) return _parseDouble(doc.data()?['totalLiters']);
        }
      } catch (_) {}

      final consumedLiters = await _sumLocalConsumedLiters();
      final reconstructed = await _tryReconstructStockFromPurchases(
        consumedLiters: consumedLiters,
      );
      return reconstructed ?? 0.0;
    }
  }

  Future<void> addFuelStock({
    required double quantity,
    required double rate,
    required String supplierName,
    required String purchaseDate,
  }) async {
    if (quantity <= 0 || rate <= 0) {
      throw Exception('Quantity and rate must be greater than zero.');
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('Authentication Error');

    try {
      final totalCost = quantity * rate;
      final nowIso = DateTime.now().toIso8601String();
      final purchaseId = generateId();

      await syncToFirebase('set', {
        'id': purchaseId,
        'quantity': quantity,
        'rate': rate,
        'totalAmount': totalCost,
        'supplierName': supplierName,
        'purchaseDate': purchaseDate,
        'addedBy': userId,
        'createdAt': nowIso,
        'updatedAt': nowIso,
      }, collectionName: fuelPurchasesCollection).timeout(
        const Duration(seconds: 15),
      );

      // Auto-post fuel purchase voucher
      await _postFuelPurchaseVoucher(
        purchaseId: purchaseId,
        quantity: quantity,
        rate: rate,
        totalCost: totalCost,
        supplierName: supplierName,
        purchaseDate: purchaseDate,
        userId: userId,
      );
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check internet and try again.',
      );
    } catch (e) {
      throw handleError(e, 'addFuelStock');
    }
  }

  Future<void> _postFuelPurchaseVoucher({
    required String purchaseId,
    required double quantity,
    required double rate,
    required double totalCost,
    required String supplierName,
    required String purchaseDate,
    required String userId,
  }) async {
    await safePostVoucher((service) async {
      await service.createManualVoucher(
        voucherType: 'payment',
        transactionRefId: purchaseId,
        date: DateTime.parse(purchaseDate),
        entries: [
          {
            'accountCode': 'FUEL_EXPENSE',
            'accountName': 'Fuel Expense',
            'debit': totalCost,
            'credit': 0,
            'narration': 'Fuel purchase - $quantity liters @ ₹$rate/liter from $supplierName',
          },
          {
            'accountCode': 'CASH_IN_HAND',
            'accountName': 'Cash in Hand',
            'debit': 0,
            'credit': totalCost,
            'narration': 'Payment to $supplierName for fuel purchase',
          },
        ],
        postedByUserId: userId,
        narration: 'Fuel Purchase - $supplierName ($quantity liters)',
        partyName: supplierName,
      );
    });
  }

  Future<List<FuelPurchase>> getFuelPurchases() async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(fuelPurchasesCollection)
          .orderBy('purchaseDate', descending: true)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 3));

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return FuelPurchase.fromJson(data);
      }).toList();
    } catch (_) {
      try {
        final firestore = db;
        if (firestore != null) {
          final snapshot = await firestore
              .collection(fuelPurchasesCollection)
              .orderBy('purchaseDate', descending: true)
              .get(const GetOptions(source: Source.cache));
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return FuelPurchase.fromJson(data);
          }).toList();
        }
      } catch (_) {}
      return [];
    }
  }

  Future<double> getLatestDieselRate() async {
    try {
      // Prefer last purchase rate
      final purchases = await getFuelPurchases();
      if (purchases.isNotEmpty) return purchases.first.rate;

      // Fallback to settings or reasonable default
      final firestore = db;
      if (firestore != null) {
        try {
          final doc = await firestore.doc(fuelSettingsDoc).get();
          if (doc.exists) {
            final rate = _parseDouble(doc.data()?['defaultRate']);
            if (rate > 0) return rate;
          }
        } catch (_) {}
      }
      
      return 100.0; // Final fallback
    } catch (e) {
      return 100.0;
    }
  }

  Future<void> resetFuelStock(double newStockValue) async {
    if (newStockValue < 0) {
      throw Exception('Stock value cannot be negative');
    }

    final firestore = db;
    if (firestore == null) {
      throw Exception('Cannot reset stock while offline');
    }

    try {
      await firestore.doc(fuelStockDoc).set({
        'totalLiters': newStockValue,
        'lastUpdated': DateTime.now().toIso8601String(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
      }, SetOptions(merge: true));
    } catch (e) {
      throw handleError(e, 'resetFuelStock');
    }
  }
}
