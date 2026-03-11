// ⚠️ CRITICAL FILE - DO NOT MODIFY WITHOUT PERMISSION
// This file contains core business logic for scheme management.
// Modified: updatedAt field initialization in addScheme, updateScheme, _persistSchemesToLocal
// Contact: Developer before making changes

import 'package:isar/isar.dart' hide Query;
import 'offline_first_service.dart';
import 'database_service.dart';
import '../data/local/entities/scheme_entity.dart';
import '../core/firebase/firebase_config.dart';

const schemesCollection = 'schemes';

class Scheme {
  final String id;
  final String name;
  final String description;
  final String type; // 'buy_x_get_y_free'
  final String status; // 'active', 'inactive'
  final String validFrom;
  final String validTo;
  final String buyProductId;
  final int buyQuantity;
  final String getProductId;
  final int getQuantity;
  final String createdAt;

  Scheme({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.validFrom,
    required this.validTo,
    required this.buyProductId,
    required this.buyQuantity,
    required this.getProductId,
    required this.getQuantity,
    required this.createdAt,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'buy_x_get_y_free',
      status: json['status'] as String? ?? 'active',
      validFrom: json['validFrom'] as String? ?? '',
      validTo: json['validTo'] as String? ?? '',
      buyProductId: json['buyProductId'] as String? ?? '',
      buyQuantity: (json['buyQuantity'] as num? ?? 0).toInt(),
      getProductId: json['getProductId'] as String? ?? '',
      getQuantity: (json['getQuantity'] as num? ?? 0).toInt(),
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'status': status,
      'validFrom': validFrom,
      'validTo': validTo,
      'buyProductId': buyProductId,
      'buyQuantity': buyQuantity,
      'getProductId': getProductId,
      'getQuantity': getQuantity,
      'createdAt': createdAt,
    };
  }
}

class AddSchemePayload {
  final String name;
  final String description;
  final String type;
  final String status;
  final String validFrom;
  final String validTo;
  final String buyProductId;
  final int buyQuantity;
  final String getProductId;
  final int getQuantity;

  AddSchemePayload({
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.validFrom,
    required this.validTo,
    required this.buyProductId,
    required this.buyQuantity,
    required this.getProductId,
    required this.getQuantity,
  });
}

class SchemesService extends OfflineFirstService {
  final DatabaseService _db;

  SchemesService(super.firebase, this._db);

  @override
  String get localStorageKey => 'local_schemes';

  Future<List<Scheme>> getSchemes({String? status}) async {
    try {
      // 1. Check Local First (Offline-First Priority)
      List<SchemeEntity> localEntities;

      if (status != null && status != 'all') {
        // Using filter() for flexible status query since usage mixes where/filter
        // If status is indexed (it is), where().statusEqualTo is better but types differ.
        // Consistent approach:
        localEntities = await _db.schemes
            .filter()
            .statusEqualTo(status)
            .findAll();
      } else {
        localEntities = await _db.schemes.where().findAll();
      }

      if (localEntities.isNotEmpty) {
        // Sort by createdAt descending in memory
        localEntities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final schemes = localEntities.map((e) => e.toDomain()).toList();
        // DEDUPLICATE local schemes
        return deduplicate(schemes, (s) => s.id);
      }

      // 2. Fallback to Firebase (Background Sync or initial fetch)
      final firestore = db;
      if (firestore == null) {
        if (FirebaseConfig.isMockMode) {
          return _getMockSchemes();
        }
        return [];
      }

      var q = firestore
          .collection(schemesCollection)
          .orderBy('createdAt', descending: true);

      if (status != null && status != 'all') {
        q = q.where('status', isEqualTo: status);
      }

      final snapshot = await q.get().timeout(const Duration(seconds: 3));
      final remoteSchemes = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        return Scheme.fromJson(data);
      }).toList();

      // OPTIONAL: Persist fetched remote schemes to local for next time
      // We skip this for now to keep remediation scope tight,
      // OR we can do it to truly enabling offline next time.
      // Let's do a safe basic persist if empty to help bootstrapping.
      if (localEntities.isEmpty && remoteSchemes.isNotEmpty) {
        await _persistSchemesToLocal(remoteSchemes);
      }

      // DEDUPLICATE remote schemes
      return deduplicate(remoteSchemes, (s) => s.id);
    } catch (e) {
      handleError(e, 'getSchemes');
      return [];
    }
  }

  Future<void> _persistSchemesToLocal(List<Scheme> schemes) async {
    await _db.db.writeTxn(() async {
      for (var s in schemes) {
        final now = DateTime.now();
        final entity = SchemeEntity()
          ..id = s.id
          ..name = s.name
          ..description = s.description
          ..type = s.type
          ..status = s.status
          ..validFrom = DateTime.parse(s.validFrom)
          ..validTo = DateTime.parse(s.validTo)
          ..buyProductId = s.buyProductId
          ..buyQuantity = s.buyQuantity
          ..getProductId = s.getProductId
          ..getQuantity = s.getQuantity
          ..createdAt = DateTime.parse(s.createdAt)
          ..updatedAt = now;

        await _db.schemes.put(entity);
      }
    });
  }

  List<Scheme> _getMockSchemes() {
    return [
      Scheme(
        id: 'mock_s1',
        name: 'Buy 10 Get 1 Free',
        description: 'Buy 10 cases of Original Soap, get 1 Lemon Soap Free',
        type: 'buy_x_get_y_free',
        status: 'active',
        validFrom: '2024-01-01',
        validTo: '2025-12-31',
        buyProductId: 'p1',
        buyQuantity: 10,
        getProductId: 'p2',
        getQuantity: 1,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  // Not strictly used by UI currently but good to have for consistency if needed
  Stream<List<Scheme>> subscribeToSchemes() {
    // Stream from Isar for reactive local updates
    return _db.schemes
        .where()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  Future<bool> addScheme(AddSchemePayload payload) async {
    try {
      final id = generateId(); // Offline ID
      final now = DateTime.now();

      final data = {
        'id': id,
        'name': payload.name,
        'description': payload.description,
        'type': payload.type,
        'status': payload.status,
        'validFrom': payload.validFrom,
        'validTo': payload.validTo,
        'buyProductId': payload.buyProductId,
        'buyQuantity': payload.buyQuantity,
        'getProductId': payload.getProductId,
        'getQuantity': payload.getQuantity,
        'createdAt': now.toIso8601String(),
      };

      // 1. Save to Local Isar
      await _db.db.writeTxn(() async {
        final entity = SchemeEntity()
          ..id = id
          ..name = payload.name
          ..description = payload.description
          ..type = payload.type
          ..status = payload.status
          ..validFrom = DateTime.parse(payload.validFrom)
          ..validTo = DateTime.parse(payload.validTo)
          ..buyProductId = payload.buyProductId
          ..buyQuantity = payload.buyQuantity
          ..getProductId = payload.getProductId
          ..getQuantity = payload.getQuantity
          ..createdAt = now
          ..updatedAt = now;

        await _db.schemes.put(entity);
      });

      // 2. Queue for Sync
      await syncToFirebase('add', data, collectionName: schemesCollection);

      return true;
    } catch (e) {
      handleError(e, 'addScheme');
      return false;
    }
  }

  Future<bool> updateScheme(String id, AddSchemePayload payload) async {
    try {
      final now = DateTime.now();

      // 1. Update Local Isar
      await _db.db.writeTxn(() async {
        final entity = await _db.schemes.filter().idEqualTo(id).findFirst();
        if (entity != null) {
          entity
            ..name = payload.name
            ..description = payload.description
            ..type = payload.type
            ..status = payload.status
            ..validFrom = DateTime.parse(payload.validFrom)
            ..validTo = DateTime.parse(payload.validTo)
            ..buyProductId = payload.buyProductId
            ..buyQuantity = payload.buyQuantity
            ..getProductId = payload.getProductId
            ..getQuantity = payload.getQuantity
            ..updatedAt = now;

          await _db.schemes.put(entity);
        }
      });

      // 2. Queue for Sync
      final data = {
        'id': id,
        'name': payload.name,
        'description': payload.description,
        'type': payload.type,
        'status': payload.status,
        'validFrom': payload.validFrom,
        'validTo': payload.validTo,
        'buyProductId': payload.buyProductId,
        'buyQuantity': payload.buyQuantity,
        'getProductId': payload.getProductId,
        'getQuantity': payload.getQuantity,
        'updatedAt': now.toIso8601String(),
      };

      await syncToFirebase('update', data, collectionName: schemesCollection);

      return true;
    } catch (e) {
      handleError(e, 'updateScheme');
      return false;
    }
  }

  Future<bool> deleteScheme(String id) async {
    try {
      // 1. Delete from Local Isar
      await _db.db.writeTxn(() async {
        // Isar delete requires Id (int). If SchemeEntity uses implicit String ID,
        // Isar generator usually creates an integer hash ID for it.
        // However, if the error says delete expects String, we pass String.
        // If it expects int, we use fastHash.
        // Based on previous errors, we assume String/fastHash ambiguity needs resolving.
        // If 'id' is String in entity, delete filter should be used or delete by correct ID.
        // Safest: find then delete? Or try fastHash if IsarId is indeed int.
        // Returning to fastHash for delete IF SchemeEntity has integer ID.
        // BUT we determined SchemeEntity has String id.
        // Let's try explicit delete by query to be safe given the ambiguity without generated code.
        await _db.schemes.filter().idEqualTo(id).deleteAll();
      });

      // 2. Queue for Sync
      await syncToFirebase('delete', {
        'id': id,
      }, collectionName: schemesCollection);

      return true;
    } catch (e) {
      handleError(e, 'deleteScheme');
      return false;
    }
  }
}
