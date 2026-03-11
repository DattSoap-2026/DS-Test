import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for FirebaseAuth
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar/isar.dart';
import 'offline_first_service.dart';
import 'outbox_codec.dart';
import '../data/local/entities/sync_queue_entity.dart';

const formulasCollection = 'formulas';

DateTime _parseFormulaDate(dynamic value, {DateTime? fallback}) {
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  return parsed ?? fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
}

String _parseFormulaDateIso(dynamic value, {DateTime? fallback}) {
  return _parseFormulaDate(value, fallback: fallback).toIso8601String();
}

class Formula {
  final String id;
  final String productId;
  final String productName;
  final String? category;
  final List<FormulaItem> items;
  final String status; // 'completed' or 'incomplete'
  final int version;
  final WastageConfig wastageConfig;
  final String? assignedBhatti; // 'Gita Bhatti', 'Sona Bhatti', or 'All'
  final String createdAt;
  final String updatedAt;

  Formula({
    required this.id,
    required this.productId,
    required this.productName,
    this.category,
    required this.items,
    required this.status,
    required this.version,
    required this.wastageConfig,
    this.assignedBhatti,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    final createdAtDate = _parseFormulaDate(json['createdAt']);
    return Formula(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      category: json['category'] as String?,
      items: (json['items'] as List? ?? [])
          .map((item) => FormulaItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'incomplete',
      version: json['version'] as int? ?? 1,
      wastageConfig: WastageConfig.fromJson(
        json['wastageConfig'] as Map<String, dynamic>? ?? {},
      ),
      assignedBhatti: json['assignedBhatti'] as String?,
      createdAt: createdAtDate.toIso8601String(),
      updatedAt: _parseFormulaDateIso(
        json['updatedAt'],
        fallback: createdAtDate,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      if (category != null) 'category': category,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'version': version,
      'wastageConfig': wastageConfig.toJson(),
      if (assignedBhatti != null) 'assignedBhatti': assignedBhatti,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class WastageConfig {
  final String type; // 'qty' or 'percent'
  final double value;
  final String? unit; // 'kg' or 'drum'
  final bool isReusable;
  final String? wastageMaterialId;

  WastageConfig({
    required this.type,
    required this.value,
    this.unit,
    required this.isReusable,
    this.wastageMaterialId,
  });

  factory WastageConfig.fromJson(Map<String, dynamic> json) {
    return WastageConfig(
      type: json['type'] as String? ?? 'qty',
      value: (json['value'] as num? ?? 0).toDouble(),
      unit: json['unit'] as String?,
      isReusable: json['isReusable'] as bool? ?? true,
      wastageMaterialId: json['wastageMaterialId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      if (unit != null) 'unit': unit,
      'isReusable': isReusable,
      if (wastageMaterialId != null) 'wastageMaterialId': wastageMaterialId,
    };
  }
}

// Formula Item model (ingredient in a recipe)
class FormulaItem {
  final String
  materialId; // Rename from ingredientId for consistency with ProductRecipeItem
  final String name; // Rename from ingredientName
  final double quantity;
  final String unit;
  final double? wastagePercent;

  FormulaItem({
    required this.materialId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.wastagePercent,
  });

  factory FormulaItem.fromJson(Map<String, dynamic> json) {
    // Handle both old 'ingredientId' and new 'materialId' keys
    return FormulaItem(
      materialId: (json['materialId'] ?? json['ingredientId']) as String,
      name: (json['name'] ?? json['ingredientName']) as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      wastagePercent: json['wastagePercent'] != null
          ? (json['wastagePercent'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      if (wastagePercent != null) 'wastagePercent': wastagePercent,
    };
  }
}

// ARCHITECTURE LOCK: Formula-Inventory Separation
// This service manages RECIPES and BATCH CALCULATIONS only.
// It MUST NOT perform direct inventory stock updates.
// Stock updates are the responsibility of InventoryService or ProductionBatchService (upon completion).
class FormulasService extends OfflineFirstService {
  bool _formulasPermissionDenied = false;

  FormulasService(super.firebase);

  @override
  String get localStorageKey => 'local_formulas';

  DateTime _formulaUpdatedAt(Map<String, dynamic> data) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final updated = _parseFormulaDate(data['updatedAt'], fallback: epoch);
    if (updated != epoch) return updated;
    final lastUpdated = _parseFormulaDate(
      data['lastUpdatedAt'],
      fallback: epoch,
    );
    if (lastUpdated != epoch) return lastUpdated;
    return _parseFormulaDate(data['createdAt'], fallback: epoch);
  }

  Map<String, dynamic> _mergeFormulaRecord(
    Map<String, dynamic>? local,
    Map<String, dynamic> remote,
  ) {
    if (local == null) return Map<String, dynamic>.from(remote);
    final localUpdatedAt = _formulaUpdatedAt(local);
    final remoteUpdatedAt = _formulaUpdatedAt(remote);
    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      return {...local, ...remote};
    }
    return local;
  }

  Future<Set<String>> _queuedFormulaIds() async {
    try {
      final queued = await dbService.syncQueue
          .filter()
          .collectionEqualTo(formulasCollection)
          .findAll();
      final ids = <String>{};
      for (final item in queued) {
        final decoded = OutboxCodec.decode(
          item.dataJson,
          fallbackQueuedAt: item.createdAt,
        );
        final payload = decoded.payload;
        final id = payload['id']?.toString().trim();
        if (id != null && id.isNotEmpty) {
          ids.add(id);
        }
      }
      return ids;
    } catch (_) {
      return <String>{};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteFormulas() async {
    if (_formulasPermissionDenied) return const <Map<String, dynamic>>[];
    final firestore = db;
    if (firestore == null) return const <Map<String, dynamic>>[];
    try {
      final snapshot = await firestore.collection(formulasCollection).get();
      return snapshot.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _formulasPermissionDenied = true;
        return const <Map<String, dynamic>>[];
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _mergeRemoteIntoLocal(
    List<Map<String, dynamic>> localItems, {
    List<Map<String, dynamic>>? remoteItems,
  }) async {
    final pendingIds = await _queuedFormulaIds();
    final mergedById = <String, Map<String, dynamic>>{};

    for (final local in localItems) {
      final id = local['id']?.toString().trim();
      if (id == null || id.isEmpty) continue;
      mergedById[id] = Map<String, dynamic>.from(local);
    }

    final remoteList = remoteItems ?? await _fetchRemoteFormulas();
    for (final remote in remoteList) {
      final id = remote['id']?.toString().trim();
      if (id == null || id.isEmpty) continue;

      // Preserve local unsynced edits; queue flush happens before cloud pull.
      if (pendingIds.contains(id)) continue;

      mergedById[id] = _mergeFormulaRecord(mergedById[id], remote);
    }

    final merged = mergedById.values.toList()
      ..sort((a, b) => _formulaUpdatedAt(b).compareTo(_formulaUpdatedAt(a)));
    await saveToLocal(merged);
    return merged;
  }

  // Get all formulas
  Future<List<Formula>> getFormulas() async {
    try {
      // Always merge remote into local to avoid cross-device stale formulas.
      var items = await loadFromLocal();
      try {
        items = await _mergeRemoteIntoLocal(items);
      } catch (e) {
        debugPrint('Formulas cloud merge fallback to local: $e');
        // If cloud pull fails, fall back to local safely.
      }

      // Convert to Formula objects
      return items
          .where((item) => item['isDeleted'] != true)
          .map((item) => Formula.fromJson(item))
          .toList();
    } catch (e) {
      throw handleError(e, 'getFormulas');
    }
  }

  Stream<List<Formula>> subscribeToFormulas() async* {
    final firestore = db;
    if (firestore == null) {
      yield const <Formula>[];
      return;
    }

    final query = firestore.collection(formulasCollection);

    Future<List<Formula>> mapSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) async {
      final remote = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
      final local = await loadFromLocal();
      final merged = await _mergeRemoteIntoLocal(local, remoteItems: remote);
      return merged
          .where((data) => data['isDeleted'] != true)
          .map((data) => Formula.fromJson(data))
          .toList();
    }

    try {
      while (true) {
        final snapshot = await query.get();
        yield await mapSnapshot(snapshot);
        await Future<void>.delayed(const Duration(seconds: 30));
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        yield const <Formula>[];
        return;
      }
      handleError(e, 'subscribeToFormulas');
      yield const <Formula>[];
    } catch (e) {
      handleError(e, 'subscribeToFormulas');
      yield const <Formula>[];
    }
  }

  // Add formula
  Future<String?> addFormula({
    required String productId,
    required String productName,
    String? category,
    required List<FormulaItem> items,
    String status = 'incomplete',
    int version = 1,
    WastageConfig? wastageConfig,
    String? assignedBhatti,
  }) async {
    try {
      // 1. Generate ID and prepare data
      final formulaId = generateId();
      final now = getCurrentTimestamp();

      final formulaData = {
        'id': formulaId,
        'productId': productId,
        'productName': productName,
        if (category != null) 'category': category,
        'items': items.map((item) => item.toJson()).toList(),
        'status': status,
        'version': version,
        if (wastageConfig != null) 'wastageConfig': wastageConfig.toJson(),
        if (assignedBhatti != null) 'assignedBhatti': assignedBhatti,
        'createdAt': now,
        'updatedAt': now,
        'lastUpdatedAt': now,
        'isDeleted': false,
      };

      // 2. MANDATORY: Save to local storage FIRST
      await addToLocal(formulaData);

      // 3. Queue for durable Firebase sync
      await syncToFirebase(
        'set',
        formulaData,
        collectionName: formulasCollection,
        syncImmediately: false,
      );

      return formulaId;
    } catch (e) {
      throw handleError(e, 'addFormula');
    }
  }

  // Update formula
  Future<bool> updateFormula({
    required String id,
    String? productName,
    String? category,
    List<FormulaItem>? items,
    String? status,
    int? version,
    WastageConfig? wastageConfig,
    String? assignedBhatti,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final updates = <String, dynamic>{
        'id': id,
        'lastUpdatedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (productName != null) updates['productName'] = productName;
      if (category != null) updates['category'] = category;
      if (items != null) {
        updates['items'] = items.map((e) => e.toJson()).toList();
      }
      if (status != null) updates['status'] = status;
      if (version != null) updates['version'] = version;
      if (wastageConfig != null) {
        updates['wastageConfig'] = wastageConfig.toJson();
      }
      if (assignedBhatti != null) updates['assignedBhatti'] = assignedBhatti;

      await updateInLocal(id, updates);
      await syncToFirebase(
        'update',
        updates,
        collectionName: formulasCollection,
        syncImmediately: false,
      );

      await createAuditLog(
        collectionName: formulasCollection,
        docId: id,
        action: 'update',
        changes: updates,
        userId: userId,
      );

      return true;
    } catch (e) {
      throw handleError(e, 'updateFormula');
    }
  }

  // Delete formula
  Future<bool> deleteFormula(String id) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final updates = <String, dynamic>{
        'id': id,
        'isDeleted': true,
        'lastUpdatedAt': getCurrentTimestamp(),
        'updatedAt': getCurrentTimestamp(),
      };
      await updateInLocal(id, updates);
      await syncToFirebase(
        'update',
        updates,
        collectionName: formulasCollection,
        syncImmediately: false,
      );

      // Create Audit Log
      await createAuditLog(
        collectionName: formulasCollection,
        docId: id,
        action: 'delete',
        changes: {},
        userId: userId,
      );

      return true;
    } catch (e) {
      throw handleError(e, 'deleteFormula');
    }
  }

  // Get single formula by product ID
  Future<Formula?> getFormulaByProductId(String productId) async {
    try {
      final formulas = await getFormulas();
      final matches = formulas
          .where((f) => f.productId.trim() == productId.trim())
          .toList();
      if (matches.isEmpty) return null;
      matches.sort((a, b) {
        final versionCompare = b.version.compareTo(a.version);
        if (versionCompare != 0) return versionCompare;
        final aUpdated =
            DateTime.tryParse(a.updatedAt) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bUpdated =
            DateTime.tryParse(b.updatedAt) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bUpdated.compareTo(aUpdated);
      });
      return matches.first;
    } catch (e) {
      throw handleError(e, 'getFormulaByProductId');
    }
  }

  /// Explicit hard refresh path for screens that need deterministic cloud merge.
  Future<List<Formula>> refreshFromCloud() async {
    try {
      final local = await loadFromLocal();
      final remote = await _fetchRemoteFormulas();
      final merged = await _mergeRemoteIntoLocal(local, remoteItems: remote);
      return merged
          .where((item) => item['isDeleted'] != true)
          .map((item) => Formula.fromJson(item))
          .toList();
    } catch (e) {
      throw handleError(e, 'refreshFromCloud');
    }
  }
}
