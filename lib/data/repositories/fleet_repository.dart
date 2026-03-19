import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/diesel_log_entity.dart';
import '../local/entities/fuel_purchase_entity.dart';
import '../local/entities/maintenance_log_entity.dart';
import '../local/entities/tyre_log_entity.dart';
import '../local/entities/tyre_stock_entity.dart';
import '../local/entities/vehicle_entity.dart';
import '../local/entities/vehicle_issue_entity.dart';

/// Isar-first repository for fleet, tyre, diesel, issue, and fuel purchase data.
class FleetRepository {
  FleetRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  /// Saves a vehicle locally first, then enqueues it for sync.
  Future<void> saveVehicle(VehicleEntity vehicle) async {
    final now = DateTime.now();
    final id = _ensureId(vehicle);
    final existing = await _dbService.vehicles.getById(id);

    vehicle
      ..id = id
      ..createdAt = _safeString(
        () => vehicle.createdAt,
        fallback: existing?.createdAt ?? now.toIso8601String(),
      )
      ..status = _safeString(() => vehicle.status, fallback: 'active');

    await _stampForSync(vehicle, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.vehicles.put(vehicle);
    });

    await _enqueue(
      CollectionRegistry.vehicles,
      vehicle.id,
      existing == null ? 'create' : 'update',
      vehicle.toJson(),
    );
    await _syncIfOnline();
  }

  /// Returns all non-deleted vehicles except decommissioned ones.
  Future<List<VehicleEntity>> getAllVehicles() async {
    final vehicles = await _dbService.vehicles
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
    return vehicles
        .where((vehicle) => vehicle.status.trim().toLowerCase() != 'decommissioned')
        .toList(growable: false);
  }

  /// Returns a vehicle by id when it is not soft-deleted.
  Future<VehicleEntity?> getVehicleById(String id) {
    return _dbService.vehicles
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns a vehicle by registration number when it is not soft-deleted.
  Future<VehicleEntity?> getVehicleByNumber(String number) {
    return _dbService.vehicles
        .filter()
        .numberEqualTo(number)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns active vehicles from Isar only.
  Future<List<VehicleEntity>> getActiveVehicles() {
    return _dbService.vehicles
        .filter()
        .statusEqualTo('active')
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Streams all non-deleted vehicles from Isar only.
  Stream<List<VehicleEntity>> watchAllVehicles() {
    return _dbService.vehicles
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true)
        .map((vehicles) {
          return vehicles
              .where(
                (vehicle) =>
                    vehicle.status.trim().toLowerCase() != 'decommissioned',
              )
              .toList(growable: false);
        });
  }

  /// Streams active vehicles from Isar only.
  Stream<List<VehicleEntity>> watchActiveVehicles() {
    return watchAllVehicles().map((vehicles) {
      return vehicles
          .where((vehicle) => vehicle.status.trim().toLowerCase() == 'active')
          .toList(growable: false);
    });
  }

  /// Updates the current odometer reading and enqueues the change.
  Future<void> updateOdometer(String vehicleId, double reading) async {
    final vehicle = await _dbService.vehicles.getById(vehicleId);
    if (vehicle == null || vehicle.isDeleted) {
      return;
    }

    vehicle.currentOdometer = reading;
    await _stampForSync(vehicle, vehicle);
    await _dbService.db.writeTxn(() async {
      await _dbService.vehicles.put(vehicle);
    });

    await _enqueue(
      CollectionRegistry.vehicles,
      vehicle.id,
      'update',
      vehicle.toJson(),
    );
    await _syncIfOnline();
  }

  /// Soft-deletes a vehicle and enqueues the delete operation.
  Future<void> deleteVehicle(String id) async {
    final vehicle = await _dbService.vehicles.getById(id);
    if (vehicle == null || vehicle.isDeleted) {
      return;
    }

    vehicle
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await _stampDeleted(vehicle);

    await _dbService.db.writeTxn(() async {
      await _dbService.vehicles.put(vehicle);
    });

    await _enqueue(
      CollectionRegistry.vehicles,
      vehicle.id,
      'delete',
      vehicle.toJson(),
    );
    await _syncIfOnline();
  }

  /// Saves a diesel log locally first, then enqueues it for sync.
  Future<void> saveDieselLog(DieselLogEntity log) async {
    final now = DateTime.now();
    final id = _ensureId(log);
    final existing = await _dbService.dieselLogs.getById(id);
    final previousVehicleId = existing?.vehicleId;

    log
      ..id = id
      ..createdAt = _safeString(
        () => log.createdAt,
        fallback: existing?.createdAt ?? now.toIso8601String(),
      );

    await _stampForSync(log, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.dieselLogs.put(log);
    });

    await _enqueue(
      CollectionRegistry.dieselLogs,
      log.id,
      existing == null ? 'create' : 'update',
      log.toJson(),
    );

    await _recomputeVehicleAggregates(log.vehicleId);
    if (previousVehicleId != null && previousVehicleId != log.vehicleId) {
      await _recomputeVehicleAggregates(previousVehicleId);
    }
    await _syncIfOnline();
  }

  /// Returns diesel logs for a vehicle from Isar only.
  Future<List<DieselLogEntity>> getDieselLogsByVehicle(String vehicleId) {
    return _dbService.dieselLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByFillDateDesc()
        .findAll();
  }

  /// Returns diesel logs for a driver from Isar only.
  Future<List<DieselLogEntity>> getDieselLogsByDriver(String driverName) {
    return _dbService.dieselLogs
        .filter()
        .driverNameEqualTo(driverName)
        .and()
        .isDeletedEqualTo(false)
        .sortByFillDateDesc()
        .findAll();
  }

  /// Returns diesel logs in a date range from Isar only.
  Future<List<DieselLogEntity>> getDieselLogsByDateRange(
    DateTime from,
    DateTime to,
  ) {
    return _dbService.dieselLogs
        .filter()
        .fillDateBetween(from, to, includeUpper: true)
        .and()
        .isDeletedEqualTo(false)
        .sortByFillDateDesc()
        .findAll();
  }

  /// Returns all diesel logs from Isar only.
  Future<List<DieselLogEntity>> getAllDieselLogs() {
    return _dbService.dieselLogs
        .filter()
        .isDeletedEqualTo(false)
        .sortByFillDateDesc()
        .findAll();
  }

  /// Streams diesel logs for a vehicle from Isar only.
  Stream<List<DieselLogEntity>> watchDieselLogsByVehicle(String vehicleId) {
    return _dbService.dieselLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByFillDateDesc()
        .watch(fireImmediately: true);
  }

  /// Returns pending-penalty diesel logs from Isar only.
  Future<List<DieselLogEntity>> getPendingPenaltyLogs() async {
    final logs = await getAllDieselLogs();
    return logs
        .where(
          (log) => log.status?.trim().toLowerCase() == 'pending_penalty',
        )
        .toList(growable: false);
  }

  /// Marks a diesel penalty override locally first, then enqueues it.
  Future<void> overridePenalty(
    String logId,
    String reason,
    String overriddenBy,
  ) async {
    final log = await _dbService.dieselLogs.getById(logId);
    if (log == null || log.isDeleted) {
      return;
    }

    log
      ..penaltyOverridden = true
      ..overrideReason = reason
      ..overriddenBy = overriddenBy
      ..originalPenaltyAmount = log.originalPenaltyAmount ?? log.penaltyAmount
      ..status = 'penalty_overridden';

    await _stampForSync(log, log);
    await _dbService.db.writeTxn(() async {
      await _dbService.dieselLogs.put(log);
    });

    await _enqueue(
      CollectionRegistry.dieselLogs,
      log.id,
      'update',
      log.toJson(),
    );
    await _syncIfOnline();
  }

  /// Soft-deletes a diesel log and enqueues the delete operation.
  Future<void> deleteDieselLog(String id) async {
    final log = await _dbService.dieselLogs.getById(id);
    if (log == null || log.isDeleted) {
      return;
    }

    log
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await _stampDeleted(log);

    await _dbService.db.writeTxn(() async {
      await _dbService.dieselLogs.put(log);
    });

    await _enqueue(
      CollectionRegistry.dieselLogs,
      log.id,
      'delete',
      log.toJson(),
    );
    await _recomputeVehicleAggregates(log.vehicleId);
    await _syncIfOnline();
  }

  /// Saves a maintenance log locally first, then enqueues it for sync.
  Future<void> saveMaintenanceLog(MaintenanceLogEntity log) async {
    final now = DateTime.now();
    final id = _ensureId(log);
    final existing = await _dbService.maintenanceLogs.getById(id);
    final previousVehicleId = existing?.vehicleId;

    log
      ..id = id
      ..createdAt = _safeString(
        () => log.createdAt,
        fallback: existing?.createdAt ?? now.toIso8601String(),
      )
      ..items = List<MaintenanceItemEntity>.from(log.items ?? const []);

    await _stampForSync(log, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.maintenanceLogs.put(log);
    });

    await _enqueue(
      CollectionRegistry.vehicleMaintenanceLogs,
      log.id,
      existing == null ? 'create' : 'update',
      log.toJson(),
    );

    await _recomputeVehicleAggregates(log.vehicleId);
    if (previousVehicleId != null && previousVehicleId != log.vehicleId) {
      await _recomputeVehicleAggregates(previousVehicleId);
    }
    await _syncIfOnline();
  }

  /// Returns maintenance logs for a vehicle from Isar only.
  Future<List<MaintenanceLogEntity>> getMaintenanceByVehicle(String vehicleId) {
    return _dbService.maintenanceLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByServiceDateDesc()
        .findAll();
  }

  /// Returns maintenance logs for a type from Isar only.
  Future<List<MaintenanceLogEntity>> getMaintenanceByType(String type) {
    return _dbService.maintenanceLogs
        .filter()
        .typeEqualTo(type)
        .and()
        .isDeletedEqualTo(false)
        .sortByServiceDateDesc()
        .findAll();
  }

  /// Returns all maintenance logs from Isar only.
  Future<List<MaintenanceLogEntity>> getAllMaintenanceLogs() {
    return _dbService.maintenanceLogs
        .filter()
        .isDeletedEqualTo(false)
        .sortByServiceDateDesc()
        .findAll();
  }

  /// Streams maintenance logs for a vehicle from Isar only.
  Stream<List<MaintenanceLogEntity>> watchMaintenanceByVehicle(String vehicleId) {
    return _dbService.maintenanceLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByServiceDateDesc()
        .watch(fireImmediately: true);
  }

  /// Soft-deletes a maintenance log and enqueues the delete operation.
  Future<void> deleteMaintenanceLog(String id) async {
    final log = await _dbService.maintenanceLogs.getById(id);
    if (log == null || log.isDeleted) {
      return;
    }

    log
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await _stampDeleted(log);

    await _dbService.db.writeTxn(() async {
      await _dbService.maintenanceLogs.put(log);
    });

    await _enqueue(
      CollectionRegistry.vehicleMaintenanceLogs,
      log.id,
      'delete',
      log.toJson(),
    );
    await _recomputeVehicleAggregates(log.vehicleId);
    await _syncIfOnline();
  }

  /// Saves a tyre log locally first, then enqueues it for sync.
  Future<void> saveTyreLog(TyreLogEntity log) async {
    final now = DateTime.now();
    final id = _ensureId(log);
    final existing = await _dbService.tyreLogs.getById(id);
    final previousVehicleId = existing?.vehicleId;

    log
      ..id = id
      ..createdAt = _safeString(
        () => log.createdAt,
        fallback: existing?.createdAt ?? now.toIso8601String(),
      )
      ..items = List<TyreLogItemEntity>.from(log.items ?? const []);

    await _stampForSync(log, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.tyreLogs.put(log);
    });

    await _enqueue(
      CollectionRegistry.tyreLogs,
      log.id,
      existing == null ? 'create' : 'update',
      log.toJson(),
    );

    await _recomputeVehicleAggregates(log.vehicleId);
    if (previousVehicleId != null && previousVehicleId != log.vehicleId) {
      await _recomputeVehicleAggregates(previousVehicleId);
    }
    await _syncIfOnline();
  }

  /// Saves a tyre stock record locally first, then enqueues it for sync.
  Future<void> saveTyreStock(TyreStockEntity tyre) async {
    final now = DateTime.now();
    final id = _ensureId(tyre);
    final existing = await _dbService.tyreStocks.getById(id);

    tyre
      ..id = id
      ..createdAt = _safeString(
        () => tyre.createdAt,
        fallback: existing?.createdAt ?? now.toIso8601String(),
      );

    await _stampForSync(tyre, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.tyreStocks.put(tyre);
    });

    await _enqueue(
      CollectionRegistry.tyreItems,
      tyre.id,
      existing == null ? 'create' : 'update',
      tyre.toJson(),
    );
    await _syncIfOnline();
  }

  /// Returns tyre logs for a vehicle from Isar only.
  Future<List<TyreLogEntity>> getTyreLogsByVehicle(String vehicleId) {
    return _dbService.tyreLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByInstallationDateDesc()
        .findAll();
  }

  /// Returns all tyre logs from Isar only.
  Future<List<TyreLogEntity>> getAllTyreLogs() {
    return _dbService.tyreLogs
        .filter()
        .isDeletedEqualTo(false)
        .sortByInstallationDateDesc()
        .findAll();
  }

  /// Returns all tyre stock from Isar only.
  Future<List<TyreStockEntity>> getAllTyreStock() {
    return _dbService.tyreStocks
        .filter()
        .isDeletedEqualTo(false)
        .sortByBrand()
        .findAll();
  }

  /// Returns tyres currently available for installation.
  Future<List<TyreStockEntity>> getAvailableTyres() async {
    final tyres = await getAllTyreStock();
    return tyres
        .where((tyre) {
          final status = tyre.status.trim().toLowerCase();
          return status == 'available' ||
              status == 'in stock' ||
              status == 'in_stock';
        })
        .toList(growable: false);
  }

  /// Returns a tyre stock record by serial number.
  Future<TyreStockEntity?> getTyreBySerial(String serialNumber) {
    return _dbService.tyreStocks
        .filter()
        .serialNumberEqualTo(serialNumber)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns a tyre stock record by id.
  Future<TyreStockEntity?> getTyreById(String tyreId) {
    return _dbService.tyreStocks
        .filter()
        .idEqualTo(tyreId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Streams all tyre stock from Isar only.
  Stream<List<TyreStockEntity>> watchAllTyreStock() {
    return _dbService.tyreStocks
        .filter()
        .isDeletedEqualTo(false)
        .sortByBrand()
        .watch(fireImmediately: true);
  }

  /// Marks a tyre as installed and enqueues the update.
  Future<void> installTyre(String tyreId, String vehicleId, String position) async {
    final tyre = await _dbService.tyreStocks.getById(tyreId);
    if (tyre == null || tyre.isDeleted) {
      return;
    }
    final vehicle = await _dbService.vehicles.getById(vehicleId);
    tyre
      ..status = 'installed'
      ..vehicleNumber = vehicle?.number ?? vehicleId
      ..position = position;
    await saveTyreStock(tyre);
  }

  /// Marks a tyre as removed and enqueues the update.
  Future<void> removeTyre(String tyreId) async {
    final tyre = await _dbService.tyreStocks.getById(tyreId);
    if (tyre == null || tyre.isDeleted) {
      return;
    }
    tyre
      ..status = 'removed'
      ..vehicleNumber = null
      ..position = null;
    await saveTyreStock(tyre);
  }

  /// Soft-deletes a tyre log and enqueues the delete operation.
  Future<void> deleteTyreLog(String id) async {
    final log = await _dbService.tyreLogs.getById(id);
    if (log == null || log.isDeleted) {
      return;
    }

    log
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await _stampDeleted(log);

    await _dbService.db.writeTxn(() async {
      await _dbService.tyreLogs.put(log);
    });

    await _enqueue(
      CollectionRegistry.tyreLogs,
      log.id,
      'delete',
      log.toJson(),
    );
    await _recomputeVehicleAggregates(log.vehicleId);
    await _syncIfOnline();
  }

  /// Saves a vehicle issue locally first, then enqueues it for sync.
  Future<void> saveVehicleIssue(VehicleIssueEntity issue) async {
    final now = DateTime.now();
    final id = _ensureId(issue);
    final existing = await _dbService.vehicleIssues.getById(id);

    issue
      ..id = id
      ..createdAt = _safeString(
        () => issue.createdAt,
        fallback: existing?.createdAt ?? now.toIso8601String(),
      );

    await _stampForSync(issue, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.vehicleIssues.put(issue);
    });

    await _enqueue(
      CollectionRegistry.vehicleIssues,
      issue.id,
      existing == null ? 'create' : 'update',
      issue.toJson(),
    );
    await _syncIfOnline();
  }

  /// Returns vehicle issues for a vehicle from Isar only.
  Future<List<VehicleIssueEntity>> getIssuesByVehicle(String vehicleId) {
    return _dbService.vehicleIssues
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByReportedDateDesc()
        .findAll();
  }

  /// Returns non-resolved vehicle issues from Isar only.
  Future<List<VehicleIssueEntity>> getOpenIssues() async {
    final issues = await getAllVehicleIssues();
    return issues
        .where((issue) => issue.status.trim().toLowerCase() != 'resolved')
        .toList(growable: false);
  }

  /// Returns all vehicle issues from Isar only.
  Future<List<VehicleIssueEntity>> getAllVehicleIssues() {
    return _dbService.vehicleIssues
        .filter()
        .isDeletedEqualTo(false)
        .sortByReportedDateDesc()
        .findAll();
  }

  /// Streams open vehicle issues from Isar only.
  Stream<List<VehicleIssueEntity>> watchOpenIssues() {
    return _dbService.vehicleIssues
        .filter()
        .isDeletedEqualTo(false)
        .sortByReportedDateDesc()
        .watch(fireImmediately: true)
        .map((issues) {
          return issues
              .where((issue) => issue.status.trim().toLowerCase() != 'resolved')
              .toList(growable: false);
        });
  }

  /// Resolves a vehicle issue locally first, then enqueues it.
  Future<void> resolveIssue(
    String id,
    String notes,
    DateTime resolvedDate,
  ) async {
    final issue = await _dbService.vehicleIssues.getById(id);
    if (issue == null || issue.isDeleted) {
      return;
    }

    issue
      ..status = 'resolved'
      ..resolutionNotes = notes
      ..resolvedDate = resolvedDate;
    await _stampForSync(issue, issue);

    await _dbService.db.writeTxn(() async {
      await _dbService.vehicleIssues.put(issue);
    });

    await _enqueue(
      CollectionRegistry.vehicleIssues,
      issue.id,
      'update',
      issue.toJson(),
    );
    await _syncIfOnline();
  }

  /// Soft-deletes a vehicle issue and enqueues the delete operation.
  Future<void> deleteVehicleIssue(String id) async {
    final issue = await _dbService.vehicleIssues.getById(id);
    if (issue == null || issue.isDeleted) {
      return;
    }

    issue
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await _stampDeleted(issue);

    await _dbService.db.writeTxn(() async {
      await _dbService.vehicleIssues.put(issue);
    });

    await _enqueue(
      CollectionRegistry.vehicleIssues,
      issue.id,
      'delete',
      issue.toJson(),
    );
    await _syncIfOnline();
  }

  /// Saves a fuel purchase locally first, then enqueues it for sync.
  Future<void> saveFuelPurchase(FuelPurchaseEntity purchase) async {
    final now = DateTime.now();
    final id = _ensureId(purchase);
    final existing = await _dbService.fuelPurchases
        .filter()
        .idEqualTo(id)
        .findFirst();

    purchase
      ..id = id
      ..createdAt = purchase.createdAt ?? existing?.createdAt ?? now;

    await _stampForSync(purchase, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.fuelPurchases.put(purchase);
    });

    await _enqueue(
      CollectionRegistry.fuelPurchases,
      purchase.id,
      existing == null ? 'create' : 'update',
      purchase.toJson(),
    );
    await _syncIfOnline();
  }

  /// Returns fuel purchases for a vehicle from Isar only.
  Future<List<FuelPurchaseEntity>> getFuelPurchasesByVehicle(String vehicleId) {
    return _dbService.fuelPurchases
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .sortByPurchaseDateDesc()
        .findAll();
  }

  /// Returns all fuel purchases from Isar only.
  Future<List<FuelPurchaseEntity>> getAllFuelPurchases() {
    return _dbService.fuelPurchases
        .filter()
        .isDeletedEqualTo(false)
        .sortByPurchaseDateDesc()
        .findAll();
  }

  /// Streams all fuel purchases from Isar only.
  Stream<List<FuelPurchaseEntity>> watchFuelPurchases() {
    return _dbService.fuelPurchases
        .filter()
        .isDeletedEqualTo(false)
        .sortByPurchaseDateDesc()
        .watch(fireImmediately: true);
  }

  Future<void> _recomputeVehicleAggregates(String vehicleId) async {
    if (vehicleId.trim().isEmpty) {
      return;
    }
    final vehicle = await _dbService.vehicles.getById(vehicleId);
    if (vehicle == null || vehicle.isDeleted) {
      return;
    }

    final dieselLogs = await _dbService.dieselLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    final maintenanceLogs = await _dbService.maintenanceLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    final tyreLogs = await _dbService.tyreLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    final totalDieselCost = dieselLogs.fold<double>(
      0,
      (sum, entry) => sum + entry.totalCost,
    );
    final totalFuelConsumed = dieselLogs.fold<double>(
      0,
      (sum, entry) => sum + entry.liters,
    );
    final totalDistance = dieselLogs.fold<double>(
      0,
      (sum, entry) => sum + (entry.cycleDistance ?? 0),
    );
    final totalMaintenanceCost = maintenanceLogs.fold<double>(
      0,
      (sum, entry) => sum + entry.totalCost,
    );
    final totalTyreCost = tyreLogs.fold<double>(
      0,
      (sum, entry) => sum + entry.totalCost,
    );
    final latestLog = dieselLogs.isEmpty
        ? null
        : (dieselLogs.toList()..sort((a, b) => b.fillDate.compareTo(a.fillDate)))
            .first;
    final combinedCost = totalDieselCost + totalMaintenanceCost + totalTyreCost;

    vehicle
      ..currentOdometer = latestLog?.odometerReading ?? vehicle.currentOdometer
      ..lastDieselFill = latestLog?.fillDate.toIso8601String() ?? vehicle.lastDieselFill
      ..totalDieselCost = totalDieselCost
      ..totalFuelConsumed = totalFuelConsumed
      ..totalMaintenanceCost = totalMaintenanceCost
      ..totalTyreCost = totalTyreCost
      ..totalDistance = totalDistance
      ..costPerKm = totalDistance > 0 ? combinedCost / totalDistance : 0.0;

    await _stampForSync(vehicle, vehicle);
    await _dbService.db.writeTxn(() async {
      await _dbService.vehicles.put(vehicle);
    });

    await _enqueue(
      CollectionRegistry.vehicles,
      vehicle.id,
      'update',
      vehicle.toJson(),
    );
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _stampDeleted(BaseEntity entity) async {
    entity
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _enqueue(
    String collectionName,
    String documentId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return _syncQueueService.addToQueue(
      collectionName: collectionName,
      documentId: documentId,
      operation: operation,
      payload: payload,
    );
  }

  String _ensureId(BaseEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _safeString(String Function() reader, {String fallback = ''}) {
    try {
      final value = reader().trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
