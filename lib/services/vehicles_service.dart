import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'offline_first_service.dart';
import 'database_service.dart';
import '../data/repositories/fleet_repository.dart';
import '../data/repositories/route_repository.dart';
import '../modules/accounting/posting_service.dart';
import 'mixins/safe_voucher_posting_mixin.dart';

// Entities
import '../data/local/entities/vehicle_entity.dart';
import '../data/local/entities/maintenance_log_entity.dart';
import '../data/local/entities/tyre_log_entity.dart';
import '../data/local/base_entity.dart'; // Added
import '../data/local/entities/tyre_stock_entity.dart'; // Added
import '../data/local/entities/route_entity.dart'; // Added
import '../data/local/entities/vehicle_issue_entity.dart'; // Added

const vehiclesCollection = 'vehicles';
const maintenanceLogsCollection = 'vehicle_maintenance_logs';
const tyreLogsCollection = 'tyre_logs';
const tyreStockCollection = 'tyre_items';
const routesCollection = 'routes'; // Added
const vehicleIssuesCollection = 'vehicle_issues'; // Added

class Vehicle {
  final String id;
  final String name;
  final String number;
  final String type;
  final String status;

  final double currentOdometer;
  final double totalDistance;
  final double totalMaintenanceCost;
  final double totalDieselCost;
  final double totalTyreCost;
  final double totalFuelConsumed;
  final double costPerKm;

  // Documents
  final DateTime? purchaseDate;
  final String? purchaseAmount;
  final DateTime? pucExpiryDate;
  final String? pucNumber;
  final DateTime? insuranceStartDate;
  final DateTime? insuranceExpiryDate;
  final String? insuranceProvider;
  final String? policyNumber;
  final DateTime? permitExpiryDate;
  final String? permitNumber;
  final DateTime? fitnessExpiryDate;
  final String? rcNumber;

  // Service
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDue;
  final int? serviceIntervalKm;
  final int totalServicesCompleted;

  // Tyres
  final int totalTyresUsed;
  final Map<String, dynamic>? currentTyres;

  // Other
  final String createdAt;
  final String? lastDieselFill;
  final String? ownership;
  final double? capacity;
  final double minAverage;
  final double maxAverage;
  final String? model;
  final String? serialNumber;
  final String? fuelType;
  final String? tyreSize;

  Vehicle({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.status,
    this.currentOdometer = 0,
    this.totalDistance = 0,
    this.totalMaintenanceCost = 0,
    this.totalDieselCost = 0,
    this.totalTyreCost = 0,
    this.totalFuelConsumed = 0,
    this.costPerKm = 0,
    this.purchaseDate,
    this.purchaseAmount,
    this.pucExpiryDate,
    this.pucNumber,
    this.insuranceStartDate,
    this.insuranceExpiryDate,
    this.insuranceProvider,
    this.policyNumber,
    this.permitExpiryDate,
    this.permitNumber,
    this.fitnessExpiryDate,
    this.rcNumber,
    this.lastServiceDate,
    this.nextServiceDue,
    this.serviceIntervalKm,
    this.totalServicesCompleted = 0,
    this.totalTyresUsed = 0,
    this.currentTyres,
    required this.createdAt,
    this.lastDieselFill,
    this.ownership,
    this.capacity,
    this.minAverage = 0.0,
    this.maxAverage = 0.0,
    this.model,
    this.serialNumber,
    this.fuelType,
    this.tyreSize,
  });

  String get vehicleNumber => number;
  String get displayName => name;
  double get dieselAverage =>
      totalFuelConsumed > 0 ? totalDistance / totalFuelConsumed : 0;

  Map<String, dynamic> get documentStatus {
    final now = DateTime.now();
    return {
      'pucExpired': pucExpiryDate != null && pucExpiryDate!.isBefore(now),
      'pucExpiringSoon':
          pucExpiryDate != null &&
          pucExpiryDate!.isAfter(now) &&
          pucExpiryDate!.difference(now).inDays <= 30,
      'insuranceExpired':
          insuranceExpiryDate != null && insuranceExpiryDate!.isBefore(now),
      'insuranceExpiringSoon':
          insuranceExpiryDate != null &&
          insuranceExpiryDate!.isAfter(now) &&
          insuranceExpiryDate!.difference(now).inDays <= 60,
      'permitExpired':
          permitExpiryDate != null && permitExpiryDate!.isBefore(now),
      'permitExpiringSoon':
          permitExpiryDate != null &&
          permitExpiryDate!.isAfter(now) &&
          permitExpiryDate!.difference(now).inDays <= 30,
    };
  }

  factory Vehicle.fromEntity(VehicleEntity e) {
    return Vehicle(
      id: e.id,
      name: e.name,
      number: e.number,
      type: e.type,
      status: e.status,
      currentOdometer: e.currentOdometer,
      totalDistance: e.totalDistance,
      totalMaintenanceCost: e.totalMaintenanceCost,
      totalDieselCost: e.totalDieselCost,
      totalTyreCost: e.totalTyreCost,
      totalFuelConsumed: e.totalFuelConsumed,
      costPerKm: e.costPerKm,
      purchaseDate: e.purchaseDate,
      insuranceStartDate: e.insuranceStartDate,
      insuranceProvider: e.insuranceProvider,
      policyNumber: e.policyNumber,
      pucNumber: e.pucNumber,
      pucExpiryDate: e.pucExpiryDate,
      insuranceExpiryDate: e.insuranceExpiryDate,
      permitNumber: e.permitNumber,
      permitExpiryDate: e.permitExpiryDate,
      fitnessExpiryDate: e.fitnessExpiryDate,
      rcNumber: e.rcNumber,
      createdAt: e.createdAt,
      lastDieselFill: e.lastDieselFill,
      capacity: e.capacity,
      minAverage: e.minAverage,
      maxAverage: e.maxAverage,
      model: e.model,
      serialNumber: e.serialNumber,
      fuelType: e.fuelType,
      tyreSize: e.tyreSize,
    );
  }
}

class MaintenanceItem {
  final String partName;
  final String? description;
  final double quantity;
  final double price;

  MaintenanceItem({
    required this.partName,
    this.description,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'partName': partName,
    if (description != null) 'description': description,
    'quantity': quantity,
    'price': price,
  };

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      partName: json['partName'] ?? '',
      description: json['description'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MaintenanceLog {
  final String id;
  final String vehicleId;
  final String vehicleNumber;
  final String serviceDate;
  final String vendor;
  final String description;
  final double totalCost;
  final String type;
  final double? odometerReading;
  final String? mechanicName;
  final String? nextServiceDate;
  final List<String>? partsReplaced;
  final List<MaintenanceItem> items;
  final String createdAt;

  MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.serviceDate,
    required this.vendor,
    required this.description,
    required this.totalCost,
    required this.type,
    this.odometerReading,
    this.mechanicName,
    this.nextServiceDate,
    this.partsReplaced,
    this.items = const [],
    this.createdAt = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'vehicleNumber': vehicleNumber,
    'serviceDate': serviceDate,
    'vendor': vendor,
    'description': description,
    'totalCost': totalCost,
    'type': type,
    if (odometerReading != null) 'odometerReading': odometerReading,
    if (mechanicName != null) 'mechanicName': mechanicName,
    if (nextServiceDate != null) 'nextServiceDate': nextServiceDate,
    if (partsReplaced != null) 'partsReplaced': partsReplaced,
    'items': items.map((i) => i.toJson()).toList(),
    'createdAt': createdAt,
  };

  factory MaintenanceLog.fromEntity(MaintenanceLogEntity e) {
    return MaintenanceLog(
      id: e.id,
      vehicleId: e.vehicleId,
      vehicleNumber: e.vehicleNumber,
      serviceDate: e.serviceDate.toIso8601String(),
      vendor: e.vendor,
      description: e.description,
      totalCost: e.totalCost,
      type: e.type,
      odometerReading: e.odometerReading,
      mechanicName: e.mechanicName,
      nextServiceDate: e.nextServiceDate?.toIso8601String(),
      items:
          e.items
              ?.map(
                (i) => MaintenanceItem(
                  partName: i.partName ?? '',
                  description: i.description,
                  quantity: i.quantity,
                  price: i.price,
                ),
              )
              .toList() ??
          [],
      createdAt: e.createdAt,
    );
  }
}

class TyreLog {
  final String id;
  final String vehicleId;
  final String vehicleNumber;
  final String installationDate;
  final String reason;
  final double totalCost;
  final List<TyreLogItem> items; // Restored

  TyreLog({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.installationDate,
    required this.reason,
    required this.totalCost,
    required this.items,
  });

  factory TyreLog.fromEntity(TyreLogEntity e) {
    return TyreLog(
      id: e.id,
      vehicleId: e.vehicleId,
      vehicleNumber: e.vehicleNumber,
      installationDate: e.installationDate.toIso8601String(),
      reason: e.reason,
      totalCost: e.totalCost,
      items: e.items?.map((i) => TyreLogItem.fromEntity(i)).toList() ?? [],
    );
  }
}

class TyreLogItem {
  final String tyrePosition;
  final String newTyreType;
  final String tyreItemId;
  final String tyreBrand;
  final String tyreNumber;
  final double cost;
  final String? oldTyreDisposition;
  final String? oldTyreBrand;
  final String? oldTyreNumber;
  final String? oldTyreItemId;

  TyreLogItem({
    required this.tyrePosition,
    required this.newTyreType,
    required this.tyreItemId,
    required this.tyreBrand,
    required this.tyreNumber,
    required this.cost,
    this.oldTyreDisposition,
    this.oldTyreBrand,
    this.oldTyreNumber,
    this.oldTyreItemId,
  });

  // Convenience getters for compatibility
  String get brand => tyreBrand;
  String get position => tyrePosition;

  factory TyreLogItem.fromEntity(TyreLogItemEntity e) {
    return TyreLogItem(
      tyrePosition: e.tyrePosition ?? '',
      newTyreType: e.newTyreType ?? '',
      tyreItemId: e.tyreItemId ?? '',
      tyreBrand: e.tyreBrand ?? '',
      tyreNumber: e.tyreNumber ?? '',
      cost: e.cost,
      oldTyreDisposition: e.oldTyreDisposition,
      oldTyreBrand: e.oldTyreBrand,
      oldTyreNumber: e.oldTyreNumber,
    );
  }

  TyreLogItemEntity toEntity() {
    return TyreLogItemEntity()
      ..tyrePosition = tyrePosition
      ..newTyreType = newTyreType
      ..tyreItemId = tyreItemId
      ..tyreBrand = tyreBrand
      ..tyreNumber = tyreNumber
      ..cost = cost
      ..oldTyreDisposition = oldTyreDisposition
      ..oldTyreBrand = oldTyreBrand
      ..oldTyreNumber = oldTyreNumber;
  }
}

class TyreStockItem {
  final String id;
  final String brand;
  final String size;
  final String serialNumber;
  final String type; // New, Remold
  final String status; // In Stock, Mounted, Scrapped
  final String? vehicleNumber;
  final String? position;
  final String? notes;
  final double cost;
  final String? purchaseDate;

  TyreStockItem({
    required this.id,
    required this.brand,
    required this.size,
    required this.serialNumber,
    required this.type,
    required this.status,
    this.vehicleNumber,
    this.position,
    this.notes,
    required this.cost,
    this.purchaseDate,
  });

  factory TyreStockItem.fromJson(Map<String, dynamic> json) {
    return TyreStockItem(
      id: json['id'] ?? '',
      brand: json['brand'] ?? '',
      size: json['size'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'In Stock',
      vehicleNumber: json['vehicleNumber'],
      position: json['position'],
      notes: json['notes'],
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: json['purchaseDate'],
    );
  }
}

class TyreStockInvoiceLine {
  final String brand;
  final String type;
  final String size;
  final String serialNumberInput;
  final int quantity;
  final double unitPrice;

  const TyreStockInvoiceLine({
    required this.brand,
    required this.type,
    required this.size,
    required this.serialNumberInput,
    required this.quantity,
    required this.unitPrice,
  });
}

class VehicleIssue {
  final String id;
  final String vehicleId;
  final String vehicleNumber;
  final String reportedBy;
  final String reportedDate;
  final String description;
  final String priority;
  final String status;
  final String? resolutionNotes;
  final String? resolvedDate;
  final List<String> images;
  final String createdAt;
  final String updatedAt;

  VehicleIssue({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.reportedBy,
    required this.reportedDate,
    required this.description,
    required this.priority,
    required this.status,
    this.resolutionNotes,
    this.resolvedDate,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleIssue.fromEntity(VehicleIssueEntity e) {
    return VehicleIssue(
      id: e.id,
      vehicleId: e.vehicleId,
      vehicleNumber: e.vehicleNumber,
      reportedBy: e.reportedBy,
      reportedDate: e.reportedDate.toIso8601String(),
      description: e.description,
      priority: e.priority,
      status: e.status,
      resolutionNotes: e.resolutionNotes,
      resolvedDate: e.resolvedDate?.toIso8601String(),
      images: e.images ?? [],
      createdAt: e.createdAt,
      updatedAt: e.updatedAt.toIso8601String(),
    );
  }
}

class VehiclesService extends OfflineFirstService with ChangeNotifier, SafeVoucherPostingMixin {
  final DatabaseService _dbService;
  late final PostingService _postingService;
  late final FleetRepository _fleetRepository;
  late final RouteRepository _routeRepository;

  @override
  PostingService? get postingService => _postingService;

  VehiclesService(super.firebase) : _dbService = DatabaseService() {
    _postingService = PostingService(firebaseServices);
    _fleetRepository = FleetRepository(_dbService);
    _routeRepository = RouteRepository(_dbService);
  }

  @override
  String get localStorageKey => 'local_vehicles';

  Future<List<Vehicle>> getVehicles({String? status, int? limitCount}) async {
    List<VehicleEntity> entities;

    if (status != null) {
      entities = await _dbService.vehicles
          .filter()
          .statusEqualTo(status)
          .findAll();
    } else {
      entities = await _dbService.vehicles.where().findAll();
    }

    // Sort (Memory)
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Limit
    if (limitCount != null && entities.length > limitCount) {
      entities = entities.sublist(0, limitCount);
    }

    final vehicles = entities.map((e) => Vehicle.fromEntity(e)).toList();
    // DEDUPLICATE to prevent duplicate vehicles in UI
    return deduplicate(vehicles, (v) => v.id);
  }

  Future<Vehicle?> getVehicle(String id) async {
    final entity = await _dbService.vehicles.filter().idEqualTo(id).findFirst();
    if (entity != null) {
      return Vehicle.fromEntity(entity);
    }
    return null;
  }

  Future<Map<String, dynamic>> _normalizeVehiclePayload({
    required String id,
    required Map<String, dynamic> data,
    VehicleEntity? existing,
  }) async {
    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      if (existing != null) ...existing.toFirebaseJson(),
      ...data,
      'id': id,
      'createdAt': (data['createdAt']?.toString().trim().isNotEmpty ?? false)
          ? data['createdAt']
          : existing?.createdAt ?? now,
      'updatedAt': now,
      'isDeleted': existing?.isDeleted ?? false,
    };

    const dateFields = <String>[
      'purchaseDate',
      'insuranceStartDate',
      'pucExpiryDate',
      'insuranceExpiryDate',
      'permitExpiryDate',
      'fitnessExpiryDate',
    ];
    for (final field in dateFields) {
      final value = payload[field];
      if (value is DateTime) {
        payload[field] = value.toIso8601String();
      }
    }

    return payload;
  }

  Future<void> addVehicle(Map<String, dynamic> data) async {
    // Check duplicate vehicle number
    final vehicleNumber = (data['number'] as String?)?.trim().toUpperCase();
    if (vehicleNumber != null && vehicleNumber.isNotEmpty) {
      final existing = await _dbService.vehicles
          .filter()
          .numberEqualTo(vehicleNumber)
          .isDeletedEqualTo(false)
          .findFirst();
      if (existing != null) {
        throw Exception('Vehicle number $vehicleNumber already exists');
      }
    }

    // Validate odometer reading
    final odometer = (data['currentOdometer'] as num?)?.toDouble() ?? 0;
    if (odometer < 0) {
      throw Exception('Odometer reading cannot be negative');
    }

    final providedId = (data['id'] as String?)?.trim() ?? '';
    final resolvedId = providedId.isNotEmpty ? providedId : generateId();
    final payload = await _normalizeVehiclePayload(id: resolvedId, data: data);
    final entity = VehicleEntity.fromFirebaseJson(payload)
      ..id = resolvedId
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
    await _fleetRepository.saveVehicle(entity);
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    final existing = await _dbService.vehicles
        .filter()
        .idEqualTo(id)
        .findFirst();
    final payload = await _normalizeVehiclePayload(
      id: id,
      data: data,
      existing: existing,
    );
    final entity = VehicleEntity.fromFirebaseJson(payload)
      ..id = id
      ..createdAt =
          existing?.createdAt ??
          payload['createdAt']?.toString() ??
          DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isDeleted = existing?.isDeleted ?? false;
    await _fleetRepository.saveVehicle(entity);
  }

  Future<void> recomputeMaintenanceAggregate({String? vehicleId}) async {
    final targetVehicleIds = <String>{};
    if (vehicleId != null && vehicleId.trim().isNotEmpty) {
      targetVehicleIds.add(vehicleId.trim());
    } else {
      final allVehicles = await _dbService.vehicles.where().findAll();
      targetVehicleIds.addAll(allVehicles.map((e) => e.id));
    }

    for (final targetId in targetVehicleIds) {
      await _recomputeMaintenanceAggregateForVehicle(targetId);
    }
  }

  Future<void> _recomputeMaintenanceAggregateForVehicle(
    String vehicleId,
  ) async {
    if (vehicleId.trim().isEmpty) return;
    final vehicle = await _dbService.vehicles
        .filter()
        .idEqualTo(vehicleId)
        .findFirst();
    if (vehicle == null) return;

    final maintenanceLogs = await _dbService.maintenanceLogs
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .findAll();
    final maintenanceTotal = maintenanceLogs.fold<double>(
      0,
      (sum, entry) => sum + entry.totalCost,
    );
    final totalCost =
        maintenanceTotal + vehicle.totalDieselCost + vehicle.totalTyreCost;
    final recalculatedCostPerKm = vehicle.totalDistance > 0
        ? totalCost / vehicle.totalDistance
        : 0.0;
    final now = DateTime.now();
    vehicle
      ..totalMaintenanceCost = maintenanceTotal
      ..costPerKm = recalculatedCostPerKm
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _fleetRepository.saveVehicle(vehicle);
  }

  // Maintenance
  Future<List<MaintenanceLog>> getMaintenanceLogs({
    int? limitCount,
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      try {
        final payloads = await bootstrapFromFirebase(
          collectionName: maintenanceLogsCollection,
        );
        final newEntities = <MaintenanceLogEntity>[];
        final existingIds =
            (await _dbService.maintenanceLogs.where().idProperty().findAll())
                .toSet();

        for (final payload in payloads) {
          if (!existingIds.contains(payload['id'])) {
            final embeddedItems = (payload['items'] as List<dynamic>?)?.map((
              i,
            ) {
              final map = i as Map<String, dynamic>;
              return MaintenanceItemEntity()
                ..partName = map['partName']
                ..description = map['description']
                ..quantity = _toDouble(map['quantity'])
                ..price = _toDouble(map['price']);
            }).toList();

            final odometerDynamic = payload['odometerReading'];
            final odometerResult = odometerDynamic != null
                ? _toDouble(odometerDynamic)
                : null;

            final entity = MaintenanceLogEntity()
              ..id = payload['id']
              ..vehicleId = payload['vehicleId']
              ..vehicleNumber = payload['vehicleNumber'] ?? ''
              ..serviceDate = DateTime.parse(payload['serviceDate'])
              ..nextServiceDate = payload['nextServiceDate'] != null
                  ? DateTime.tryParse(payload['nextServiceDate'].toString())
                  : null
              ..odometerReading = odometerResult == 0.0 ? null : odometerResult
              ..vendor = payload['vendor'] ?? ''
              ..mechanicName = payload['mechanicName']
              ..description = payload['description'] ?? ''
              ..totalCost = _toDouble(payload['totalCost'])
              ..type = payload['type'] ?? 'Regular'
              ..items = embeddedItems
              ..createdAt = payload['createdAt'].toString()
              ..updatedAt = payload['updatedAt'] != null
                  ? DateTime.tryParse(payload['updatedAt'].toString()) ??
                        DateTime.now()
                  : DateTime.now()
              ..syncStatus = SyncStatus.synced
              ..isDeleted = false;
            newEntities.add(entity);
          }
        }
        if (newEntities.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.maintenanceLogs.putAll(newEntities);
          });
        }
      } catch (e) {
        debugPrint('Error bootstrapping maintenance logs: $e');
        // Fallback to local
      }
    }

    var query = _dbService.maintenanceLogs.where();
    var entities = await query.sortByServiceDateDesc().findAll();

    // Apply filters in memory
    List<MaintenanceLogEntity> filtered = entities.where((e) {
      if (vehicleId != null && e.vehicleId != vehicleId) return false;
      if (startDate != null && e.serviceDate.isBefore(startDate)) return false;
      if (endDate != null && e.serviceDate.isAfter(endDate)) return false;
      return true;
    }).toList();

    if (limitCount != null && filtered.length > limitCount) {
      filtered = filtered.sublist(0, limitCount);
    }

    return filtered.map((e) => MaintenanceLog.fromEntity(e)).toList();
  }

  Future<void> addMaintenanceLog(Map<String, dynamic> data) async {
    final userId = auth?.currentUser?.uid;
    if (userId == null) {
      throw Exception('User must be authenticated to add maintenance logs');
    }
    final userName = auth?.currentUser?.displayName ?? 'User';
    // Validate service date
    final serviceDate = data['serviceDate'];
    if (serviceDate != null) {
      final date = DateTime.tryParse(serviceDate.toString());
      if (date != null && date.isAfter(DateTime.now())) {
        throw Exception('Service date cannot be in the future');
      }
    }

    final now = DateTime.now().toIso8601String();
    final providedId = (data['id'] as String?)?.trim() ?? '';
    final resolvedId = providedId.isNotEmpty ? providedId : generateId();
    final payload = <String, dynamic>{
      ...data,
      'id': resolvedId,
      'createdAt': (data['createdAt']?.toString().trim().isNotEmpty ?? false)
          ? data['createdAt']
          : now,
    };

    final embeddedItems = (payload['items'] as List<dynamic>?)?.map((i) {
      if (i is MaintenanceItem) {
        return MaintenanceItemEntity()
          ..partName = i.partName
          ..description = i.description
          ..quantity = i.quantity
          ..price = i.price;
      }
      final map = i as Map<String, dynamic>;
      return MaintenanceItemEntity()
        ..partName = map['partName']
        ..description = map['description']
        ..quantity = _toDouble(map['quantity'])
        ..price = _toDouble(map['price']);
    }).toList();

    final odometerDynamic = payload['odometerReading'];
    final odometerResult = odometerDynamic != null
        ? _toDouble(odometerDynamic)
        : null;

    final entity = MaintenanceLogEntity()
      ..id = resolvedId
      ..vehicleId = payload['vehicleId']
      ..vehicleNumber = payload['vehicleNumber'] ?? ''
      ..serviceDate = DateTime.parse(payload['serviceDate'])
      ..nextServiceDate = payload['nextServiceDate'] != null
          ? DateTime.tryParse(payload['nextServiceDate'].toString())
          : null
      ..odometerReading = odometerResult == 0.0 ? null : odometerResult
      ..vendor = payload['vendor'] ?? ''
      ..mechanicName = payload['mechanicName']
      ..description = payload['description'] ?? ''
      ..totalCost = _toDouble(payload['totalCost'])
      ..type = payload['type'] ?? 'Regular'
      ..items = embeddedItems
      ..createdAt = payload['createdAt'].toString()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
    await _fleetRepository.saveMaintenanceLog(entity);

    // Auto-post maintenance voucher to accounting
    await _postMaintenanceVoucher(
      maintenanceData: payload,
      userId: userId,
      userName: userName,
    );
  }

  Future<void> _postMaintenanceVoucher({
    required Map<String, dynamic> maintenanceData,
    required String userId,
    required String userName,
  }) async {
    await safePostVoucher((service) async {
      final totalCost = _toDouble(maintenanceData['totalCost']);
      if (totalCost <= 0) return;

      final vehicleNumber = maintenanceData['vehicleNumber']?.toString() ?? '';
      final vendor = maintenanceData['vendor']?.toString() ?? 'Vendor';
      final description = maintenanceData['description']?.toString() ?? 'Maintenance';
      
      final entries = [
        {
          'accountCode': 'VEHICLE_MAINTENANCE_EXPENSE',
          'accountName': 'Vehicle Maintenance Expense',
          'debit': totalCost,
          'credit': 0.0,
          'narration': 'Maintenance for $vehicleNumber - $description',
        },
        {
          'accountCode': 'CASH_IN_HAND',
          'accountName': 'Cash in Hand',
          'debit': 0.0,
          'credit': totalCost,
          'narration': 'Payment to $vendor for vehicle maintenance',
        },
      ];

      await _postingService.createManualVoucher(
        voucherType: 'payment',
        transactionRefId: maintenanceData['id']?.toString() ?? generateId(),
        date: DateTime.parse(maintenanceData['serviceDate']?.toString() ?? DateTime.now().toIso8601String()),
        entries: entries,
        postedByUserId: userId,
        postedByName: userName,
        narration: 'Vehicle Maintenance - $vehicleNumber ($vendor)',
        partyName: vendor,
      );
    });
  }

  Future<void> deleteMaintenanceLog(
    String id,
    String vehicleId,
    double cost,
  ) async {
    if (cost.isNaN) {
      throw ArgumentError('Invalid maintenance cost');
    }
    await _fleetRepository.deleteMaintenanceLog(id);
  }

  // Tyres
  Future<List<TyreLog>> getTyreLogs({
    int? limitCount,
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      try {
        final payloads = await bootstrapFromFirebase(
          collectionName: tyreLogsCollection,
        );
        final newEntities = <TyreLogEntity>[];
        final existingIds =
            (await _dbService.tyreLogs.where().idProperty().findAll()).toSet();

        for (final payload in payloads) {
          if (!existingIds.contains(payload['id'])) {
            final itemsList =
                (payload['items'] as List<dynamic>?)?.map((i) {
                  final map = i as Map<String, dynamic>;
                  return TyreLogItemEntity()
                    ..tyrePosition = map['tyrePosition']
                    ..newTyreType = map['newTyreType']
                    ..tyreItemId = map['tyreItemId']
                    ..tyreBrand = map['tyreBrand']
                    ..tyreNumber = map['tyreNumber']
                    ..cost = _toDouble(map['cost'])
                    ..oldTyreDisposition = map['oldTyreDisposition']
                    ..oldTyreBrand = map['oldTyreBrand']
                    ..oldTyreNumber = map['oldTyreNumber'];
                }).toList() ??
                [];

            final entity = TyreLogEntity()
              ..id = payload['id']
              ..vehicleId = payload['vehicleId']
              ..vehicleNumber = payload['vehicleNumber'] ?? ''
              ..installationDate = DateTime.parse(payload['installationDate'])
              ..reason = payload['reason'] ?? ''
              ..totalCost = _toDouble(payload['totalCost'])
              ..items = itemsList
              ..createdAt = payload['createdAt'].toString()
              ..updatedAt = payload['updatedAt'] != null
                  ? DateTime.tryParse(payload['updatedAt'].toString()) ??
                        DateTime.now()
                  : DateTime.now()
              ..syncStatus = SyncStatus.synced
              ..isDeleted = false;
            newEntities.add(entity);
          }
        }
        if (newEntities.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.tyreLogs.putAll(newEntities);
          });
        }
      } catch (e) {
        debugPrint('Error bootstrapping tyre logs: $e');
        // Fallback to local
      }
    }

    var entities = await _dbService.tyreLogs
        .where()
        .sortByInstallationDateDesc()
        .findAll();

    // Apply filters in memory
    List<TyreLogEntity> filtered = entities.where((e) {
      if (vehicleId != null && e.vehicleId != vehicleId) return false;
      if (startDate != null && e.installationDate.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && e.installationDate.isAfter(endDate)) return false;
      return true;
    }).toList();

    if (limitCount != null && filtered.length > limitCount) {
      filtered = filtered.sublist(0, limitCount);
    }

    return filtered.map((e) => TyreLog.fromEntity(e)).toList();
  }

  Future<void> addTyreLog(TyreLog log) async {
    final now = DateTime.now();

    // Convert Model -> Entity
    final entity = TyreLogEntity()
      ..id = generateId()
      ..vehicleId = log.vehicleId
      ..vehicleNumber = log.vehicleNumber
      ..installationDate = DateTime.parse(log.installationDate)
      ..reason = log.reason
      ..totalCost = log.totalCost
      ..createdAt = now.toIso8601String()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;

    final itemsEntities = log.items.map((i) => i.toEntity()).toList();
    entity.items = itemsEntities;
    final updatedTyreStockById = <String, TyreStockEntity>{};

    await _dbService.db.writeTxn(() async {
      await _dbService.tyreLogs.put(entity);

      // Update Vehicle Cost
      final vehicle = await _dbService.vehicles
          .filter()
          .idEqualTo(log.vehicleId)
          .findFirst();
      if (vehicle != null) {
        vehicle.totalTyreCost += log.totalCost;
        if (vehicle.totalDistance > 0) {
          double totalAll =
              vehicle.totalMaintenanceCost +
              vehicle.totalDieselCost +
              vehicle.totalTyreCost;
          vehicle.costPerKm = totalAll / vehicle.totalDistance;
        }
        await _dbService.vehicles.put(vehicle);
      }

      await _applyTyreStockMovementsInTxn(log, updatedTyreStockById);
    });
    await _fleetRepository.saveTyreLog(entity);

    for (final stock in updatedTyreStockById.values) {
      await _syncTyreStockEntity(stock);
    }
  }

  Future<void> _applyTyreStockMovementsInTxn(
    TyreLog log,
    Map<String, TyreStockEntity> updatedTyreStockById,
  ) async {
    final now = DateTime.now();
    for (final item in log.items) {
      final newTyreItemId = item.tyreItemId.trim();
      if (newTyreItemId.isNotEmpty) {
        final mountedTyre = await _dbService.tyreStocks.getById(newTyreItemId);
        if (mountedTyre != null) {
          mountedTyre
            ..status = 'Mounted'
            ..vehicleNumber = log.vehicleNumber
            ..position = item.tyrePosition.trim().isNotEmpty
                ? item.tyrePosition.trim()
                : null
            ..notes = _mergeTyreNotes(
              mountedTyre.notes,
              'Mounted on ${log.vehicleNumber} (${item.tyrePosition})',
            )
            ..updatedAt = now
            ..syncStatus = SyncStatus.pending;
          await _dbService.tyreStocks.put(mountedTyre);
          updatedTyreStockById[mountedTyre.id] = mountedTyre;
        }
      }

      final oldTyreItemId = (item.oldTyreItemId ?? '').trim();
      if (oldTyreItemId.isNotEmpty) {
        final removedTyre = await _dbService.tyreStocks.getById(oldTyreItemId);
        if (removedTyre != null) {
          final disposition = (item.oldTyreDisposition ?? '').toLowerCase();
          removedTyre
            ..status = _statusFromOldTyreDisposition(item.oldTyreDisposition)
            ..vehicleNumber = null
            ..position = null
            ..notes = _mergeTyreNotes(
              removedTyre.notes,
              'Dismounted from ${log.vehicleNumber}: ${item.oldTyreDisposition ?? 'Updated'}',
            )
            ..updatedAt = now
            ..syncStatus = SyncStatus.pending;
          if (disposition.contains('remold')) {
            removedTyre.type = 'Remold';
          }
          await _dbService.tyreStocks.put(removedTyre);
          updatedTyreStockById[removedTyre.id] = removedTyre;
        }
      }
    }
  }

  String _statusFromOldTyreDisposition(String? disposition) {
    final text = (disposition ?? '').toLowerCase();
    if (text.contains('scrap')) return 'Scrapped';
    return 'In Stock';
  }

  String _mergeTyreNotes(String? existing, String update) {
    final cleanUpdate = update.trim();
    if (cleanUpdate.isEmpty) {
      return existing?.trim() ?? '';
    }
    final cleanExisting = existing?.trim() ?? '';
    if (cleanExisting.isEmpty) return cleanUpdate;
    if (cleanExisting.contains(cleanUpdate)) return cleanExisting;
    return '$cleanExisting | $cleanUpdate';
  }

  Future<void> _syncTyreStockEntity(TyreStockEntity entity) async {
    await _fleetRepository.saveTyreStock(entity);
  }

  TyreStockItem _mapTyreStockEntityToModel(TyreStockEntity entity) {
    return TyreStockItem(
      id: entity.id,
      brand: entity.brand,
      size: entity.size,
      serialNumber: entity.serialNumber,
      type: entity.type,
      status: entity.status,
      vehicleNumber: entity.vehicleNumber,
      position: entity.position,
      notes: entity.notes,
      cost: entity.cost,
      purchaseDate: entity.purchaseDate?.toIso8601String(),
    );
  }

  Future<void> _cacheTyreItemsFromRemote(
    List<TyreStockItem> items, {
    bool markSynced = true,
  }) async {
    if (items.isEmpty) return;

    final now = DateTime.now();
    await _dbService.db.writeTxn(() async {
      for (final item in items) {
        if (item.id.trim().isEmpty) continue;
        final existing = await _dbService.tyreStocks.getById(item.id);
        final entity =
            existing ??
            (TyreStockEntity()
              ..id = item.id
              ..createdAt = now.toIso8601String());
        entity
          ..brand = item.brand
          ..size = item.size
          ..serialNumber = item.serialNumber
          ..type = item.type
          ..status = item.status
          ..vehicleNumber = item.vehicleNumber
          ..position = item.position
          ..notes = item.notes
          ..cost = item.cost
          ..purchaseDate = item.purchaseDate != null
              ? DateTime.tryParse(item.purchaseDate!)
              : null
          ..updatedAt = now
          ..isDeleted = false
          ..syncStatus = markSynced ? SyncStatus.synced : SyncStatus.pending;
        await _dbService.tyreStocks.put(entity);
      }
    });
  }

  Future<void> updateTyreStockStatus({
    required String tyreItemId,
    required String status,
    String? vehicleNumber,
    String? position,
    String? notes,
  }) async {
    final existing = await _dbService.tyreStocks.getById(tyreItemId);
    if (existing == null) {
      throw Exception('Tyre item not found: $tyreItemId');
    }

    final cleanStatus = status.trim();
    if (cleanStatus.isEmpty) {
      throw Exception('Invalid tyre status');
    }

    existing
      ..status = cleanStatus
      ..vehicleNumber = (vehicleNumber ?? '').trim().isEmpty
          ? null
          : vehicleNumber!.trim()
      ..position = (position ?? '').trim().isEmpty ? null : position!.trim()
      ..notes = notes == null
          ? existing.notes
          : _mergeTyreNotes(existing.notes, notes);

    await _fleetRepository.saveTyreStock(existing);
  }

  Future<int> importTyresFromPurchase({
    required String poId,
    required String poNumber,
    required List<Map<String, dynamic>> tyres,
    String? supplierName,
  }) async {
    if (tyres.isEmpty) return 0;

    final now = DateTime.now();
    final entities = <TyreStockEntity>[];

    for (final source in tyres) {
      final brand = (source['brand']?.toString().trim() ?? '');
      final size = (source['size']?.toString().trim() ?? '');
      final serialNumber = (source['serialNumber']?.toString().trim() ?? '');
      if (brand.isEmpty || serialNumber.isEmpty) {
        continue;
      }

      final duplicate = await _dbService.tyreStocks
          .filter()
          .serialNumberEqualTo(serialNumber)
          .findFirst();
      if (duplicate != null) {
        continue;
      }

      final entity = TyreStockEntity()
        ..id = generateId()
        ..brand = brand
        ..size = size.isNotEmpty ? size : 'Standard'
        ..serialNumber = serialNumber
        ..type = (source['type']?.toString().trim().isNotEmpty ?? false)
            ? source['type'].toString().trim()
            : 'New'
        ..status = 'In Stock'
        ..vehicleNumber = null
        ..position = null
        ..notes = _mergeTyreNotes(
          source['notes']?.toString(),
          'Imported from PO $poNumber [$poId]${supplierName != null && supplierName.trim().isNotEmpty ? ' ($supplierName)' : ''}',
        )
        ..cost = _toDouble(source['cost'])
        ..purchaseDate = DateTime.tryParse(
          source['purchaseDate']?.toString() ?? '',
        )
        ..createdAt = now.toIso8601String()
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;

      entities.add(entity);
    }

    if (entities.isEmpty) return 0;

    for (final entity in entities) {
      await _fleetRepository.saveTyreStock(entity);
    }

    return entities.length;
  }

  Future<int> addTyreStockEntry({
    required String vendorName,
    required String brand,
    required String tyreType,
    required int quantity,
    required List<String> tyreNumbers,
    required String invoiceNumber,
    String size = 'Standard',
    double unitCost = 0.0,
    DateTime? purchaseDate,
  }) async {
    return addTyreStockInvoice(
      vendorName: vendorName,
      invoiceNumber: invoiceNumber,
      invoiceDate: purchaseDate ?? DateTime.now(),
      lines: [
        TyreStockInvoiceLine(
          brand: brand,
          type: tyreType,
          size: size,
          serialNumberInput: tyreNumbers.join(','),
          quantity: quantity,
          unitPrice: unitCost,
        ),
      ],
    );
  }

  Future<int> addTyreStockInvoice({
    required String vendorName,
    required String invoiceNumber,
    required DateTime invoiceDate,
    required List<TyreStockInvoiceLine> lines,
  }) async {
    final cleanVendor = vendorName.trim();
    final cleanInvoice = invoiceNumber.trim();

    if (cleanVendor.isEmpty) {
      throw Exception('Vendor name is required');
    }
    if (cleanInvoice.isEmpty) {
      throw Exception('Invoice number is required');
    }
    if (lines.isEmpty) {
      throw Exception('At least one tyre line item is required');
    }

    final now = DateTime.now();
    final entities = <TyreStockEntity>[];
    final seenTyreNumbers = <String>{};

    for (final line in lines) {
      final cleanBrand = line.brand.trim();
      final cleanType = line.type.trim().isEmpty ? 'New' : line.type.trim();
      final cleanSize = line.size.trim().isEmpty
          ? 'Standard'
          : line.size.trim();

      if (cleanBrand.isEmpty) {
        throw Exception('Tyre brand is required for each line');
      }
      if (line.quantity <= 0) {
        throw Exception('Quantity must be at least 1 for each line');
      }
      if (line.unitPrice < 0) {
        throw Exception('Price cannot be negative');
      }

      final serialNumbers = _expandSerialNumbers(
        input: line.serialNumberInput,
        quantity: line.quantity,
      );
      for (final serialNumber in serialNumbers) {
        final serialKey = _normalizeInputToken(serialNumber);
        if (!seenTyreNumbers.add(serialKey)) {
          throw Exception('Duplicate tyre number in invoice: $serialNumber');
        }
        final duplicate = await _dbService.tyreStocks
            .filter()
            .serialNumberEqualTo(serialNumber)
            .findFirst();
        if (duplicate != null && !duplicate.isDeleted) {
          throw Exception('Tyre number already exists: $serialNumber');
        }

        final entity = TyreStockEntity()
          ..id = generateId()
          ..brand = cleanBrand
          ..size = cleanSize
          ..serialNumber = serialNumber
          ..type = cleanType
          ..status = 'In Stock'
          ..vehicleNumber = null
          ..position = null
          ..notes = _mergeTyreNotes(
            null,
            'Manual stock entry (Vendor: $cleanVendor, Invoice: $cleanInvoice)',
          )
          ..cost = line.unitPrice
          ..purchaseDate = invoiceDate
          ..createdAt = now.toIso8601String()
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;

        entities.add(entity);
      }
    }

    for (final entity in entities) {
      await _fleetRepository.saveTyreStock(entity);
    }

    return entities.length;
  }

  List<String> _expandSerialNumbers({
    required String input,
    required int quantity,
  }) {
    final values = input
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (values.isEmpty) {
      throw Exception('Tyre number is required');
    }

    final unique = values.map(_normalizeInputToken).toSet();
    if (unique.length != values.length) {
      throw Exception('Duplicate tyre numbers in item input');
    }

    if (quantity == 1) {
      return [values.first];
    }
    if (values.length == quantity) {
      return values;
    }
    if (values.length == 1) {
      final base = values.first;
      return List.generate(
        quantity,
        (index) => '$base-${(index + 1).toString().padLeft(2, '0')}',
      );
    }
    throw Exception(
      'Please enter either 1 serial number (will be auto-numbered) or exactly $quantity unique serial numbers',
    );
  }

  String _normalizeInputToken(String value) {
    return value.trim().toLowerCase();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  // Tyre Stock
  Future<List<TyreStockItem>> getAllTyres({bool forceRefresh = false}) async {
    if (forceRefresh) {
      try {
        final payloads = await bootstrapFromFirebase(
          collectionName: tyreStockCollection,
        );
        final items = payloads.map((d) {
          final data = Map<String, dynamic>.from(d);
          data['id'] = data['id'];
          return TyreStockItem.fromJson(data);
        }).toList();
        await _cacheTyreItemsFromRemote(items);
      } catch (e) {
        debugPrint('Error refreshing tyre stock from Firebase: $e');
        // Fallback to local data
      }
    }

    final entities = await _dbService.tyreStocks.where().findAll();
    return entities.map(_mapTyreStockEntityToModel).toList();
  }

  Future<List<TyreStockItem>> getAvailableTyres({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      try {
        final payloads = await bootstrapFromFirebase(
          collectionName: tyreStockCollection,
        );
        final items = payloads.map((d) {
          final data = Map<String, dynamic>.from(d);
          data['id'] = data['id'];
          return TyreStockItem.fromJson(data);
        }).toList();
        await _cacheTyreItemsFromRemote(items);
      } catch (e) {
        debugPrint('Error refreshing available tyres from Firebase: $e');
        // Fallback to local data
      }
    }

    final entities = await _dbService.tyreStocks
        .filter()
        .statusEqualTo("In Stock")
        .findAll();
    return entities.map(_mapTyreStockEntityToModel).toList();
  }

  Future<List<String>> getTyreBrands() async {
    final brands = <String>{
      'Apollo',
      'MRF',
      'Ceat',
      'JK Tyre',
      'Goodyear',
      'Bridgestone',
    };
    final entities = await _dbService.tyreStocks.where().findAll();
    for (final entity in entities) {
      final value = entity.brand.trim();
      if (value.isNotEmpty) {
        brands.add(value);
      }
    }
    final sorted = brands.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  Future<List<String>> getTyreSizes() async {
    final sizes = <String>{
      '90/90-12',
      '100/20',
      '100/90-17',
      '110/90-17',
      '120/80-18',
      '165/80R14',
      '185/65R15',
      '195/65R15',
      '205/55R16',
      '215/75R17.5',
      '235/75R17.5',
      '295/80R22.5',
      '315/80R22.5',
    };
    final entities = await _dbService.tyreStocks.where().findAll();
    for (final entity in entities) {
      final value = entity.size.trim();
      if (value.isNotEmpty) {
        sizes.add(value);
      }
    }
    final sorted = sizes.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  // --- Route Management (Offline First) ---
  Future<List<Map<String, dynamic>>> getRoutes({
    bool refreshRemote = false,
  }) async {
    final localRoutes = await _getLocalRoutes();
    if (!refreshRemote) {
      return localRoutes;
    }

    final firestore = db;
    if (firestore == null) {
      return localRoutes;
    }

    try {
      final snapshot = await firestore.collection(routesCollection).get();
      if (snapshot.docs.isEmpty) {
        return localRoutes;
      }

      final remoteRoutes = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
        return _normalizeRouteMap(data);
      }).toList();

      await _upsertRouteCache(remoteRoutes);

      // Merge remote with local so unsynced local routes remain visible in
      // offline-first flows even when remote refresh succeeds.
      final mergedById = <String, Map<String, dynamic>>{};
      for (final route in localRoutes) {
        final id = _asTrimmedString(route['id']);
        if (id.isEmpty) continue;
        mergedById[id] = Map<String, dynamic>.from(route);
      }
      for (final route in remoteRoutes) {
        final id = _asTrimmedString(route['id']);
        if (id.isEmpty) continue;
        mergedById[id] = route;
      }

      final visibleRoutes =
          mergedById.values
              .where((route) => route['isDeleted'] != true)
              .toList()
            ..sort(_routeSortComparator);

      return visibleRoutes;
    } catch (e) {
      debugPrint('Error refreshing routes from Firebase: $e');
      return localRoutes;
    }
  }

  Future<List<Map<String, dynamic>>> _getLocalRoutes() async {
    final entities = await _dbService.routes
        .filter()
        .isDeletedEqualTo(false)
        .sortByIsActiveDesc()
        .thenByCreatedAtDesc()
        .findAll();

    final routes = entities
        .map(
          (e) => _normalizeRouteMap({
            'id': e.id,
            'name': e.name,
            'description': e.description ?? '',
            'area': e.description ?? '',
            'isActive': e.isActive,
            'status': e.isActive ? 'active' : 'inactive',
            'isDeleted': e.isDeleted,
            'createdAt': e.createdAt,
          }),
        )
        .toList();

    routes.sort(_routeSortComparator);
    return routes;
  }

  Future<void> _upsertRouteCache(List<Map<String, dynamic>> routes) async {
    await _dbService.db.writeTxn(() async {
      for (final route in routes) {
        final id = _asTrimmedString(route['id']);
        if (id.isEmpty) continue;

        final existing = await _dbService.routes
            .filter()
            .idEqualTo(id)
            .findFirst();
        final createdAt = _asTrimmedString(route['createdAt']);
        final localDescription = _routeDescriptionForLocal(route);
        final isActive = _resolveRouteActive(route);
        final isDeleted = route['isDeleted'] == true;

        final entity =
            existing ??
            (RouteEntity()
              ..id = id
              ..createdAt = createdAt.isNotEmpty
                  ? createdAt
                  : DateTime.now().toIso8601String());

        entity
          ..name = _asTrimmedString(route['name'])
          ..description = localDescription.isNotEmpty ? localDescription : null
          ..isActive = isActive
          ..isDeleted = isDeleted
          ..updatedAt = DateTime.now()
          ..syncStatus = SyncStatus.synced;

        await _dbService.routes.put(entity);
      }
    });
  }

  Future<void> addRoute(Map<String, dynamic> data) async {
    final id = generateId();
    final now = DateTime.now();
    final payload = _buildRouteSyncPayload(
      id: id,
      data: data,
      fallbackActive: true,
      createdAt: now,
    );
    final localDescription = _routeDescriptionForLocal(payload);

    final entity = RouteEntity()
      ..id = id
      ..name = _asTrimmedString(payload['name'])
      ..description = localDescription.isNotEmpty ? localDescription : null
      ..isActive = _resolveRouteActive(payload)
      ..isDeleted = false
      ..createdAt = _asTrimmedString(payload['createdAt']).isNotEmpty
          ? _asTrimmedString(payload['createdAt'])
          : now.toIso8601String()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;
    await _routeRepository.saveRoute(entity);
  }

  Future<void> updateRoute(String id, Map<String, dynamic> data) async {
    final existing = await _dbService.routes.filter().idEqualTo(id).findFirst();
    final payload = _buildRouteSyncPayload(
      id: id,
      data: data,
      fallbackActive: existing?.isActive ?? true,
    );
    final entity = existing;
    if (entity != null) {
      final updatedName = _asTrimmedString(payload['name']);
      if (updatedName.isNotEmpty) {
        entity.name = updatedName;
      }

      if (data.containsKey('description') ||
          data.containsKey('district') ||
          data.containsKey('area')) {
        final description = _routeDescriptionForLocal(payload);
        entity.description = description.isNotEmpty ? description : null;
      }

      if (data.containsKey('status') || data.containsKey('isActive')) {
        entity.isActive = _resolveRouteActive(
          payload,
          fallback: entity.isActive,
        );
      }

      entity.updatedAt = DateTime.now();
      entity.syncStatus = SyncStatus.pending;
      await _routeRepository.saveRoute(entity);
    }
  }

  Future<void> deleteRoute(String id) async {
    await _routeRepository.deleteRoute(id);
  }

  Map<String, dynamic> _normalizeRouteMap(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    final district = _asTrimmedString(normalized['district']);
    final description = _asTrimmedString(normalized['description']);
    final rawArea = _asTrimmedString(normalized['area']);
    final area = rawArea.isNotEmpty
        ? rawArea
        : (district.isNotEmpty ? district : description);
    final isActive = _resolveRouteActive(normalized);
    final status = _asTrimmedString(normalized['status']).toLowerCase();

    return {
      ...normalized,
      'id': _asTrimmedString(normalized['id']),
      'name': _asTrimmedString(normalized['name']),
      'zone': _asTrimmedString(normalized['zone']),
      'district': district,
      'description': description,
      'area': area,
      'salesmanId': _asTrimmedString(normalized['salesmanId']),
      'salesmanName': _asTrimmedString(normalized['salesmanName']),
      'status': status.isNotEmpty ? status : (isActive ? 'active' : 'inactive'),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> _buildRouteSyncPayload({
    required String id,
    required Map<String, dynamic> data,
    required bool fallbackActive,
    DateTime? createdAt,
  }) {
    final payload = Map<String, dynamic>.from(data)..['id'] = id;

    final isActive = _resolveRouteActive(payload, fallback: fallbackActive);
    payload['isActive'] = isActive;
    payload['status'] = isActive ? 'active' : 'inactive';

    final district = _asTrimmedString(payload['district']);
    final area = _asTrimmedString(payload['area']);
    if (district.isNotEmpty && area.isEmpty) {
      payload['area'] = district;
    }

    if (createdAt != null && _asTrimmedString(payload['createdAt']).isEmpty) {
      payload['createdAt'] = createdAt.toIso8601String();
    }

    return _normalizeRouteMap(payload);
  }

  String _routeDescriptionForLocal(Map<String, dynamic> data) {
    final description = _asTrimmedString(data['description']);
    if (description.isNotEmpty) return description;

    final district = _asTrimmedString(data['district']);
    if (district.isNotEmpty) return district;

    return _asTrimmedString(data['area']);
  }

  bool _resolveRouteActive(Map<String, dynamic> data, {bool fallback = true}) {
    if (data['isActive'] is bool) {
      return data['isActive'] as bool;
    }

    final status = _asTrimmedString(data['status']).toLowerCase();
    if (status == 'active') return true;
    if (status == 'inactive') return false;

    return fallback;
  }

  String _asTrimmedString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static int _routeSortComparator(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final activeA = a['isActive'] == true;
    final activeB = b['isActive'] == true;
    if (activeA != activeB) {
      return activeA ? -1 : 1;
    }

    final nameA = (a['name'] ?? '').toString().toLowerCase();
    final nameB = (b['name'] ?? '').toString().toLowerCase();
    return nameA.compareTo(nameB);
  }

  // --- Maintenance Log Update ---
  Future<void> updateMaintenanceLog(
    String id,
    Map<String, dynamic> data,
  ) async {
    // 1. Update Local ISAR
    final entity = await _dbService.maintenanceLogs
        .filter()
        .idEqualTo(id)
        .findFirst();

    if (entity != null) {
      if (data.containsKey('vehicleId')) {
        final vehicleId = data['vehicleId']?.toString().trim() ?? '';
        if (vehicleId.isNotEmpty) {
          entity.vehicleId = vehicleId;
        }
      }
      if (data.containsKey('vehicleNumber')) {
        final vehicleNumber = data['vehicleNumber']?.toString().trim() ?? '';
        if (vehicleNumber.isNotEmpty) {
          entity.vehicleNumber = vehicleNumber;
        }
      }
      if (data.containsKey('description')) {
        entity.description = data['description']?.toString() ?? '';
      }
      if (data.containsKey('vendor')) {
        entity.vendor = data['vendor']?.toString() ?? '';
      }
      if (data.containsKey('mechanicName')) {
        final mechanicName = data['mechanicName']?.toString().trim() ?? '';
        entity.mechanicName = mechanicName.isEmpty ? null : mechanicName;
      }
      if (data.containsKey('serviceDate')) {
        final parsed = DateTime.tryParse(data['serviceDate'].toString());
        if (parsed != null) {
          entity.serviceDate = parsed;
        }
      }
      if (data.containsKey('nextServiceDate')) {
        final raw = data['nextServiceDate']?.toString().trim();
        entity.nextServiceDate = (raw == null || raw.isEmpty)
            ? null
            : DateTime.tryParse(raw);
      }
      if (data.containsKey('odometerReading')) {
        final raw = data['odometerReading'];
        if (raw == null || raw.toString().trim().isEmpty) {
          entity.odometerReading = null;
        } else {
          final parsed = _toDouble(raw);
          entity.odometerReading = parsed == 0.0 ? null : parsed;
        }
      }
      if (data.containsKey('totalCost')) {
        entity.totalCost = _toDouble(data['totalCost']);
      }
      if (data.containsKey('type')) {
        final type = data['type']?.toString().trim() ?? '';
        if (type.isNotEmpty) {
          entity.type = type;
        }
      }
      if (data.containsKey('items')) {
        final rawItems = data['items'];
        if (rawItems is List) {
          entity.items = rawItems.map((item) {
            if (item is MaintenanceItem) {
              return MaintenanceItemEntity()
                ..partName = item.partName
                ..description = item.description
                ..quantity = item.quantity
                ..price = item.price;
            }
            final map = Map<String, dynamic>.from(item as Map);
            return MaintenanceItemEntity()
              ..partName = map['partName']
              ..description = map['description']
              ..quantity = _toDouble(map['quantity'])
              ..price = _toDouble(map['price']);
          }).toList();
        }
      }
      entity
        ..syncStatus = SyncStatus.pending
        ..updatedAt = DateTime.now();
      await _fleetRepository.saveMaintenanceLog(entity);
    }
  }

  // --- Convenience Alias for getVehicles ---
  Future<List<Vehicle>> getVehiclesOnce({
    String? status,
    int? limitCount,
  }) async {
    return getVehicles(status: status, limitCount: limitCount);
  }

  // --- Document Expiry Alerts ---
  Future<Map<String, dynamic>> getExpiryAlerts() async {
    final vehicles = await getVehicles();
    final now = DateTime.now();
    final alerts = <String, List<Map<String, dynamic>>>{
      'critical': [],
      'warning': [],
    };

    for (final vehicle in vehicles) {
      // Insurance (60 days)
      if (vehicle.insuranceExpiryDate != null) {
        final days = vehicle.insuranceExpiryDate!.difference(now).inDays;
        if (days < 0) {
          alerts['critical']!.add({
            'type': 'Insurance',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.insuranceExpiryDate,
            'daysLeft': days,
          });
        } else if (days <= 60) {
          alerts['warning']!.add({
            'type': 'Insurance',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.insuranceExpiryDate,
            'daysLeft': days,
          });
        }
      }

      // PUC (30 days)
      if (vehicle.pucExpiryDate != null) {
        final days = vehicle.pucExpiryDate!.difference(now).inDays;
        if (days < 0) {
          alerts['critical']!.add({
            'type': 'PUC',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.pucExpiryDate,
            'daysLeft': days,
          });
        } else if (days <= 30) {
          alerts['warning']!.add({
            'type': 'PUC',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.pucExpiryDate,
            'daysLeft': days,
          });
        }
      }

      // Permit (30 days)
      if (vehicle.permitExpiryDate != null) {
        final days = vehicle.permitExpiryDate!.difference(now).inDays;
        if (days < 0) {
          alerts['critical']!.add({
            'type': 'Permit',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.permitExpiryDate,
            'daysLeft': days,
          });
        } else if (days <= 30) {
          alerts['warning']!.add({
            'type': 'Permit',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.permitExpiryDate,
            'daysLeft': days,
          });
        }
      }

      // Fitness (30 days)
      if (vehicle.fitnessExpiryDate != null) {
        final days = vehicle.fitnessExpiryDate!.difference(now).inDays;
        if (days < 0) {
          alerts['critical']!.add({
            'type': 'Fitness',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.fitnessExpiryDate,
            'daysLeft': days,
          });
        } else if (days <= 30) {
          alerts['warning']!.add({
            'type': 'Fitness',
            'vehicle': vehicle.number,
            'vehicleId': vehicle.id,
            'expiry': vehicle.fitnessExpiryDate,
            'daysLeft': days,
          });
        }
      }
    }

    return alerts;
  }

  int getExpiryAlertCount() {
    // This will be called synchronously, so we cache the count
    return 0; // Placeholder, will be updated via notifyListeners
  }

  // --- Vehicle Issues ---

  Future<void> _hydrateVehicleIssuesFromFirebaseIfNeeded({
    bool forceRefresh = false,
  }) async {
    final localCount = await _dbService.vehicleIssues.count();
    if (localCount > 0 && !forceRefresh) return;

    final items = await bootstrapFromFirebase(
      collectionName: vehicleIssuesCollection,
    );
    if (items.isEmpty) return;

    final now = DateTime.now();
    await _dbService.db.writeTxn(() async {
      for (final item in items) {
        final id = (item['id'] ?? '').toString().trim();
        if (id.isEmpty) continue;
        if (item['isDeleted'] == true) continue;

        final existing = await _dbService.vehicleIssues
            .filter()
            .idEqualTo(id)
            .findFirst();
        final entity = existing ?? VehicleIssueEntity();

        entity
          ..id = id
          ..vehicleId = item['vehicleId']?.toString() ?? ''
          ..vehicleNumber = item['vehicleNumber']?.toString() ?? ''
          ..reportedBy = item['reportedBy']?.toString() ?? ''
          ..reportedDate =
              DateTime.tryParse(item['reportedDate']?.toString() ?? '') ?? now
          ..description = item['description']?.toString() ?? ''
          ..priority = item['priority']?.toString() ?? 'Medium'
          ..status = item['status']?.toString() ?? 'Open'
          ..resolutionNotes = item['resolutionNotes']?.toString()
          ..resolvedDate = item['resolvedDate'] != null
              ? DateTime.tryParse(item['resolvedDate'].toString())
              : null
          ..images = (item['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList()
          ..createdAt = item['createdAt']?.toString() ?? now.toIso8601String()
          ..updatedAt =
              DateTime.tryParse(item['updatedAt']?.toString() ?? '') ?? now
          ..syncStatus = SyncStatus.synced;

        await _dbService.vehicleIssues.put(entity);
      }
    });
  }

  Future<List<VehicleIssue>> getVehicleIssues({
    String? vehicleId,
    bool refreshRemote = false,
  }) async {
    await _hydrateVehicleIssuesFromFirebaseIfNeeded(
      forceRefresh: refreshRemote,
    );

    var query = _dbService.vehicleIssues.where();

    // Sort logic handled in memory or improved query later
    final entities = await query.findAll();

    // Filter & Sort
    final sorted = entities.where((e) {
      if (vehicleId != null && e.vehicleId != vehicleId) return false;
      return true;
    }).toList();

    sorted.sort((a, b) => b.reportedDate.compareTo(a.reportedDate));

    return sorted.map((e) => VehicleIssue.fromEntity(e)).toList();
  }

  Future<void> addVehicleIssue(VehicleIssue issue) async {
    final entity = VehicleIssueEntity()
      ..id = generateId()
      ..vehicleId = issue.vehicleId
      ..vehicleNumber = issue.vehicleNumber
      ..reportedBy = issue.reportedBy
      ..reportedDate = DateTime.parse(issue.reportedDate)
      ..description = issue.description
      ..priority = issue.priority
      ..status = issue.status
      ..images = issue.images
      ..createdAt = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now();
    await _fleetRepository.saveVehicleIssue(entity);
    notifyListeners();
  }
}
