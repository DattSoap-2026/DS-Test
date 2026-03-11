import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory/warehouse.dart';
import 'package:uuid/uuid.dart';

class WarehouseLoadResult {
  final List<Warehouse> warehouses;
  final bool usedFallback;

  const WarehouseLoadResult({
    required this.warehouses,
    required this.usedFallback,
  });
}

class WarehouseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  static final Warehouse _fallbackWarehouse = Warehouse(
    id: 'Main',
    name: 'Main Warehouse',
    location: 'Default',
    isActive: true,
  );

  CollectionReference<Map<String, dynamic>> get _warehousesRef =>
      _firestore.collection('warehouses');

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
    try {
      // Try fetching from server with a short timeout to prevent blocking offline
      final snapshot = await _warehousesRef
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 3));
      final warehouses = snapshot.docs
          .map((doc) => Warehouse.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      return _withFallback(warehouses);
    } catch (_) {
      try {
        // Fallback to offline cache if server fetch times out or fails
        final snapshot = await _warehousesRef.get(
          const GetOptions(source: Source.cache),
        );
        final warehouses = snapshot.docs
            .map((doc) => Warehouse.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
        return _withFallback(warehouses);
      } catch (_) {
        return WarehouseLoadResult(
          warehouses: <Warehouse>[_fallbackWarehouse],
          usedFallback: true,
        );
      }
    }
  }

  /// Backward-compatible list getter.
  Future<List<Warehouse>> getAllWarehouses() async {
    final result = await getWarehouseOptions();
    return result.warehouses;
  }

  /// Create a new warehouse
  Future<void> createWarehouse({
    required String name,
    String? location,
    bool isActive = true,
  }) async {
    final id = _uuid.v4();
    final warehouse = Warehouse(
      id: id,
      name: name,
      location: location,
      isActive: isActive,
    );
    await _warehousesRef.doc(id).set(warehouse.toJson());
  }

  /// Update existing warehouse
  Future<void> updateWarehouse(Warehouse warehouse) async {
    await _warehousesRef.doc(warehouse.id).update(warehouse.toJson());
  }

  /// Delete warehouse (soft delete by marking inactive)
  Future<void> deleteWarehouse(String id) async {
    await _warehousesRef.doc(id).update({'isActive': false});
  }

  /// Get warehouse by ID
  Future<Warehouse?> getWarehouseById(String id) async {
    try {
      final doc = await _warehousesRef.doc(id).get();
      if (!doc.exists) return null;
      return Warehouse.fromJson({...doc.data()!, 'id': doc.id});
    } catch (_) {
      return null;
    }
  }

  /// Seed initial warehouses for DattSoap
  Future<void> seedInitialWarehouses() async {
    final warehouses = [
      Warehouse(
        id: 'Main',
        name: 'Main Warehouse (Godown)',
        location: 'Main Storage Facility',
        isActive: true,
      ),
      Warehouse(
        id: 'Gita_Shed',
        name: 'Gita Shed',
        location: 'Production Shed - Gita',
        isActive: true,
      ),
      Warehouse(
        id: 'Sona_Shed',
        name: 'Sona Shed',
        location: 'Production Shed - Sona',
        isActive: true,
      ),
    ];

    for (final warehouse in warehouses) {
      final existing = await getWarehouseById(warehouse.id);
      if (existing == null) {
        await _warehousesRef.doc(warehouse.id).set(warehouse.toJson());
      }
    }
  }
}
