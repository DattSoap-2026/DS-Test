import '../data/local/entities/warehouse_entity.dart';
import '../data/repositories/procurement_repository.dart';
import '../models/inventory/warehouse.dart';
import 'database_service.dart';

class WarehouseLoadResult {
  final List<Warehouse> warehouses;
  final bool usedFallback;

  const WarehouseLoadResult({
    required this.warehouses,
    required this.usedFallback,
  });
}

class WarehouseService {
  WarehouseService({ProcurementRepository? procurementRepository})
    : _procurementRepository =
          procurementRepository ?? ProcurementRepository(DatabaseService.instance);

  final ProcurementRepository _procurementRepository;

  static final Warehouse _fallbackWarehouse = Warehouse(
    id: 'Main',
    name: 'Main Warehouse',
    location: 'Default',
    isActive: true,
  );

  WarehouseLoadResult _withFallback(List<Warehouse> warehouses) {
    final hasActiveWarehouse = warehouses.any(
      (warehouse) => warehouse.isActive,
    );
    if (hasActiveWarehouse) {
      return WarehouseLoadResult(warehouses: warehouses, usedFallback: false);
    }
    return WarehouseLoadResult(
      warehouses: <Warehouse>[_fallbackWarehouse],
      usedFallback: true,
    );
  }

  /// Fetch all warehouses, falling back to a default Main Warehouse when
  /// the collection is empty after a full reset.
  Future<WarehouseLoadResult> getWarehouseOptions() async {
    final warehouses = await _procurementRepository.getAllWarehouses();
    return _withFallback(warehouses.map(_toModel).toList(growable: false));
  }

  /// Backward-compatible list getter.
  Future<List<Warehouse>> getAllWarehouses() async {
    final result = await getWarehouseOptions();
    return result.warehouses;
  }

  /// Create a new warehouse.
  Future<void> createWarehouse({
    required String name,
    String? location,
    bool isActive = true,
  }) async {
    final warehouse = WarehouseEntity()
      ..id = _buildStableId(name)
      ..name = name
      ..code = await _buildUniqueCode(name)
      ..type = 'main'
      ..address = location
      ..isActive = isActive
      ..createdAt = DateTime.now();
    await _procurementRepository.saveWarehouse(warehouse);
  }

  /// Update existing warehouse.
  Future<void> updateWarehouse(Warehouse warehouse) async {
    final existing = await _procurementRepository.getWarehouseById(warehouse.id);
    final entity = existing ?? WarehouseEntity()
      ..id = warehouse.id
      ..code = await _buildUniqueCode(warehouse.name)
      ..type = 'main'
      ..createdAt = DateTime.now();

    entity
      ..name = warehouse.name
      ..address = warehouse.location
      ..isActive = warehouse.isActive;

    await _procurementRepository.saveWarehouse(entity);
  }

  /// Delete warehouse (soft delete by marking inactive).
  Future<void> deleteWarehouse(String id) async {
    await _procurementRepository.deleteWarehouse(id);
  }

  /// Get warehouse by ID.
  Future<Warehouse?> getWarehouseById(String id) async {
    final entity = await _procurementRepository.getWarehouseById(id);
    return entity == null ? null : _toModel(entity);
  }

  /// Seed initial warehouses for DattSoap.
  Future<void> seedInitialWarehouses() async {
    final now = DateTime.now();
    final warehouses = <WarehouseEntity>[
      WarehouseEntity()
        ..id = 'Main'
        ..name = 'Main Warehouse (Godown)'
        ..code = 'MAIN'
        ..type = 'main'
        ..address = 'Main Storage Facility'
        ..isActive = true
        ..isPrimary = true
        ..createdAt = now,
      WarehouseEntity()
        ..id = 'Gita_Shed'
        ..name = 'Gita Shed'
        ..code = 'GITA_SHED'
        ..type = 'secondary'
        ..address = 'Production Shed - Gita'
        ..isActive = true
        ..createdAt = now,
      WarehouseEntity()
        ..id = 'Sona_Shed'
        ..name = 'Sona Shed'
        ..code = 'SONA_SHED'
        ..type = 'secondary'
        ..address = 'Production Shed - Sona'
        ..isActive = true
        ..createdAt = now,
    ];

    for (final warehouse in warehouses) {
      final existing = await _procurementRepository.getWarehouseById(warehouse.id);
      if (existing == null) {
        await _procurementRepository.saveWarehouse(warehouse);
      }
    }
  }

  Future<String> _buildUniqueCode(String name) async {
    final base = _normalizeCode(name);
    var candidate = base;
    var counter = 1;

    while (true) {
      final existing = await _procurementRepository.getWarehouseByCode(candidate);
      if (existing == null) {
        return candidate;
      }
      candidate = '${base}_$counter';
      counter += 1;
    }
  }

  String _buildStableId(String name) {
    final normalized = _normalizeCode(name);
    return normalized.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : normalized;
  }

  String _normalizeCode(String name) {
    final normalized = name
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return normalized.isEmpty ? 'WAREHOUSE' : normalized;
  }

  Warehouse _toModel(WarehouseEntity entity) {
    return Warehouse(
      id: entity.id,
      name: entity.name,
      location: entity.address,
      isActive: entity.isActive && !entity.isDeleted,
    );
  }
}
