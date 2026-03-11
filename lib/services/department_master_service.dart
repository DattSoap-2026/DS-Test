import 'package:isar/isar.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/department_master_entity.dart';

import 'database_service.dart';

class DepartmentMasterSeed {
  final String departmentId;
  final String departmentCode;
  final String departmentName;
  final String departmentType;
  final String sourceWarehouseId;
  final bool isProductionDepartment;
  final bool isActive;
  final String legacyMirrorKey;
  final List<String> aliases;

  const DepartmentMasterSeed({
    required this.departmentId,
    required this.departmentCode,
    required this.departmentName,
    required this.departmentType,
    required this.sourceWarehouseId,
    required this.isProductionDepartment,
    required this.isActive,
    required this.legacyMirrorKey,
    required this.aliases,
  });
}

class DepartmentSeedResult {
  final int totalSeedCount;
  final int createdCount;

  const DepartmentSeedResult({
    required this.totalSeedCount,
    required this.createdCount,
  });
}

class DepartmentMasterService {
  static const String warehouseMainLocationId = 'warehouse_main';

  static const List<DepartmentMasterSeed> canonicalSeeds = [
    DepartmentMasterSeed(
      departmentId: 'dept_sona_bhatti',
      departmentCode: 'SONA_BHATTI',
      departmentName: 'Sona Bhatti',
      departmentType: 'bhatti',
      sourceWarehouseId: warehouseMainLocationId,
      isProductionDepartment: true,
      isActive: true,
      legacyMirrorKey: 'sona bhatti',
      aliases: ['Sona Bhatti', 'sona bhatti', 'sona_bhatti'],
    ),
    DepartmentMasterSeed(
      departmentId: 'dept_gita_bhatti',
      departmentCode: 'GITA_BHATTI',
      departmentName: 'Gita Bhatti',
      departmentType: 'bhatti',
      sourceWarehouseId: warehouseMainLocationId,
      isProductionDepartment: true,
      isActive: true,
      legacyMirrorKey: 'gita bhatti',
      aliases: ['Gita Bhatti', 'gita bhatti', 'gita_bhatti'],
    ),
    DepartmentMasterSeed(
      departmentId: 'dept_sona_production',
      departmentCode: 'SONA_PRODUCTION',
      departmentName: 'Sona Production',
      departmentType: 'production',
      sourceWarehouseId: warehouseMainLocationId,
      isProductionDepartment: true,
      isActive: true,
      legacyMirrorKey: 'sona',
      aliases: ['Sona Production', 'sona production', 'sona_production', 'sona'],
    ),
    DepartmentMasterSeed(
      departmentId: 'dept_gita_production',
      departmentCode: 'GITA_PRODUCTION',
      departmentName: 'Gita Production',
      departmentType: 'production',
      sourceWarehouseId: warehouseMainLocationId,
      isProductionDepartment: true,
      isActive: true,
      legacyMirrorKey: 'gita',
      aliases: ['Gita Production', 'gita production', 'gita_production', 'gita'],
    ),
    DepartmentMasterSeed(
      departmentId: 'dept_production',
      departmentCode: 'PRODUCTION',
      departmentName: 'Production',
      departmentType: 'production',
      sourceWarehouseId: warehouseMainLocationId,
      isProductionDepartment: true,
      isActive: true,
      legacyMirrorKey: 'production',
      aliases: ['Production', 'production'],
    ),
    DepartmentMasterSeed(
      departmentId: 'dept_packing',
      departmentCode: 'PACKING',
      departmentName: 'Packing',
      departmentType: 'packing',
      sourceWarehouseId: warehouseMainLocationId,
      isProductionDepartment: true,
      isActive: true,
      legacyMirrorKey: 'packing',
      aliases: ['Packing', 'packing'],
    ),
  ];

  DepartmentMasterService(this._dbService);

  final DatabaseService _dbService;

  static String normalizeDepartmentToken(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<DepartmentSeedResult> ensureSeeded() async {
    final existing = await _dbService.departmentMasters.where().findAll();
    final existingIds = existing.map((entity) => entity.id).toSet();
    final createdCount = canonicalSeeds
        .where((seed) => !existingIds.contains(seed.departmentId))
        .length;

    final entities = canonicalSeeds.map(_toEntity).toList(growable: false);
    await _dbService.db.writeTxn(() async {
      await _dbService.departmentMasters.putAll(entities);
    });

    return DepartmentSeedResult(
      totalSeedCount: canonicalSeeds.length,
      createdCount: createdCount,
    );
  }

  Future<List<DepartmentMasterEntity>> getCanonicalDepartments({
    bool activeOnly = true,
  }) async {
    final departments = await _dbService.departmentMasters.where().findAll();
    final filtered = departments.where((entity) {
      if (entity.isDeleted) return false;
      if (activeOnly && !entity.isActive) return false;
      return true;
    }).toList();
    filtered.sort(
      (left, right) => left.departmentName.compareTo(right.departmentName),
    );
    return filtered;
  }

  DepartmentMasterSeed? resolveSeed(String value) {
    final normalized = normalizeDepartmentToken(value);
    if (normalized.isEmpty) return null;

    for (final seed in canonicalSeeds) {
      if (normalizeDepartmentToken(seed.departmentId) == normalized) {
        return seed;
      }
      if (normalizeDepartmentToken(seed.departmentCode) == normalized) {
        return seed;
      }
      for (final alias in seed.aliases) {
        if (normalizeDepartmentToken(alias) == normalized) {
          return seed;
        }
      }
    }
    return null;
  }

  String? resolveCanonicalDepartmentId(String value) {
    return resolveSeed(value)?.departmentId;
  }

  String? legacyMirrorKeyForDepartmentId(String departmentId) {
    return resolveSeed(departmentId)?.legacyMirrorKey;
  }

  DepartmentMasterEntity _toEntity(DepartmentMasterSeed seed) {
    return DepartmentMasterEntity()
      ..id = seed.departmentId
      ..departmentId = seed.departmentId
      ..departmentCode = seed.departmentCode
      ..departmentName = seed.departmentName
      ..departmentType = seed.departmentType
      ..sourceWarehouseId = seed.sourceWarehouseId
      ..isProductionDepartment = seed.isProductionDepartment
      ..isActive = seed.isActive
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
