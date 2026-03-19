import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';

// SYNC ENGINE DELEGATE - Direct Firestore access
// intentional. Do not add business logic here.
class DataManagementRemoteDelegate {
  DataManagementRemoteDelegate(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _deletedRecordsCollection =
      CollectionRegistry.deletedRecords;

  void _stageTombstone({
    required WriteBatch batch,
    required DocumentReference<Map<String, dynamic>> docRef,
    String? entityType,
    DateTime? deletedAt,
  }) {
    final now = deletedAt ?? DateTime.now();
    final nowIso = now.toIso8601String();
    final type = (entityType ?? docRef.parent.id).trim();
    final tombstoneRef = _firestore
        .collection(_deletedRecordsCollection)
        .doc('${type}_${docRef.id}_${now.microsecondsSinceEpoch}');
    batch.set(tombstoneRef, {
      'entityType': type,
      'docId': docRef.id,
      'deletedAt': nowIso,
      'createdAt': nowIso,
    });
  }

  String _statusForStock({required double stock, required double capacity}) {
    if (capacity <= 0) {
      return 'inactive';
    }

    final fillLevel = (stock / capacity) * 100;
    if (fillLevel < 5) return 'critical';
    if (fillLevel < 15) return 'low-stock';
    return 'active';
  }

  Future<bool> deleteAllDocs(String collectionName) async {
    try {
      final collection = _firestore.collection(collectionName);
      var iterationCount = 0;
      const maxIterations = 1000;

      while (iterationCount < maxIterations) {
        final snapshot = await collection.limit(200).get().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout deleting $collectionName'),
        );
        if (snapshot.docs.isEmpty) {
          break;
        }

        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          _stageTombstone(
            batch: batch,
            docRef: doc.reference,
            entityType: collectionName,
          );
          batch.delete(doc.reference);
        }

        await batch.commit().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception(
            'Timeout committing batch for $collectionName',
          ),
        );
        iterationCount++;
      }

      return iterationCount < maxIterations;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetRemoteTransactions({
    required List<String> transactionCollections,
    required DateTime now,
    void Function(String message)? onProgress,
  }) async {
    var allSuccess = true;

    for (final collection in transactionCollections) {
      onProgress?.call('Deleting $collection...');
      final success = await deleteAllDocs(collection);
      if (!success) {
        allSuccess = false;
      }
    }

    onProgress?.call('Clearing allocated stock...');
    if (!await clearRemoteAllocatedStock(now)) {
      allSuccess = false;
    }

    onProgress?.call('Resetting tank/godown stock to initial state...');
    if (!await resetRemoteTankAndGodownStock(now)) {
      allSuccess = false;
    }

    onProgress?.call('Resetting fuel stock to zero...');
    if (!await resetFuelStock()) {
      allSuccess = false;
    }

    onProgress?.call('Resetting all product stock to zero...');
    if (!await resetAllProductStockToZero(now)) {
      allSuccess = false;
    }

    return allSuccess;
  }

  Future<bool> clearRemoteAllocatedStock(DateTime now) async {
    try {
      final snapshot = await _firestore.collection('users').get();
      if (snapshot.docs.isEmpty) return true;

      final nowIso = now.toIso8601String();
      for (var i = 0; i < snapshot.docs.length; i += 400) {
        final batch = _firestore.batch();
        final chunk = snapshot.docs.skip(i).take(400);
        for (final doc in chunk) {
          batch.update(doc.reference, {
            'allocatedStock': FieldValue.delete(),
            'allocatedStockJson': FieldValue.delete(),
            'updatedAt': nowIso,
          });
        }
        await batch.commit();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetAllProductStockToZero(DateTime now) async {
    try {
      final productsSnap = await _firestore.collection('products').get();
      if (productsSnap.docs.isEmpty) return true;

      final nowIso = now.toIso8601String();
      for (var i = 0; i < productsSnap.docs.length; i += 400) {
        final batch = _firestore.batch();
        final chunk = productsSnap.docs.skip(i).take(400);
        for (final doc in chunk) {
          batch.update(doc.reference, {'stock': 0.0, 'updatedAt': nowIso});
        }
        await batch.commit();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetRemoteTankAndGodownStock(DateTime now) async {
    try {
      final tanksSnap = await _firestore.collection('tanks').get();
      if (tanksSnap.docs.isEmpty) return true;

      final nowIso = now.toIso8601String();
      for (var i = 0; i < tanksSnap.docs.length; i += 400) {
        final batch = _firestore.batch();
        final chunk = tanksSnap.docs.skip(i).take(400);
        for (final doc in chunk) {
          final data = doc.data();
          final capacity = (data['capacity'] as num?)?.toDouble() ?? 0.0;
          final type = (data['type'] as String?)?.toLowerCase() ?? 'tank';
          final update = <String, dynamic>{
            'currentStock': 0.0,
            'fillLevel': 0.0,
            'status': _statusForStock(stock: 0.0, capacity: capacity),
            'updatedAt': nowIso,
          };
          if (type == 'godown') {
            update['bags'] = 0;
          }
          batch.update(doc.reference, update);
        }
        await batch.commit();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetFuelStock() async {
    try {
      final nowIso = DateTime.now().toIso8601String();
      await _firestore.doc('public_settings/fuel_stock').set({
        'totalLiters': 0.0,
        'lastUpdated': nowIso,
        'resetAt': nowIso,
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetAllSales() async {
    try {
      const pageSize = 100;
      Query<Map<String, dynamic>> salesQuery = _firestore
          .collection('sales')
          .where('recipientType', isEqualTo: 'customer');

      while (true) {
        final snap = await salesQuery.limit(pageSize).get();
        if (snap.docs.isEmpty) break;

        WriteBatch batch = _firestore.batch();
        var opCount = 0;

        Future<void> commitIfNeeded() async {
          if (opCount >= 400) {
            await batch.commit();
            batch = _firestore.batch();
            opCount = 0;
          }
        }

        for (final docSnap in snap.docs) {
          final sale = docSnap.data();
          final items = sale['items'] as List? ?? [];
          final salesmanId = sale['salesmanId'] as String?;

          if (items.isNotEmpty &&
              salesmanId != null &&
              salesmanId.isNotEmpty) {
            final salesmanRef = _firestore.collection('users').doc(salesmanId);
            final salesmanDoc = await salesmanRef.get();
            if (!salesmanDoc.exists) {
              continue;
            }

            for (final item in items) {
              final pid = item['productId'];
              final qty = (item['quantity'] as num?)?.toDouble();
              if (pid == null || pid.toString().isEmpty) continue;
              if (qty == null || qty <= 0) continue;

              batch.update(salesmanRef, {
                'allocatedStock.$pid.quantity': FieldValue.increment(qty),
              });
              opCount++;
              await commitIfNeeded();
            }
          }

          _stageTombstone(
            batch: batch,
            docRef: docSnap.reference,
            entityType: 'sales',
          );
          batch.delete(docSnap.reference);
          opCount += 2;
          await commitIfNeeded();
        }

        if (opCount > 0) {
          await batch.commit();
        }
      }

      return deleteAllDocs('sales_targets');
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetAllDispatches(DateTime now) async {
    try {
      const pageSize = 100;

      Query<Map<String, dynamic>> dealerQuery = _firestore
          .collection('sales')
          .where('recipientType', isEqualTo: 'dealer');
      while (true) {
        final snap = await dealerQuery.limit(pageSize).get();
        if (snap.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          final data = doc.data();
          final items = data['items'] as List? ?? [];

          for (final item in items) {
            final pid = item['productId']?.toString();
            final qty = (item['quantity'] as num?)?.toDouble();
            if (pid != null && pid.isNotEmpty && qty != null && qty > 0) {
              batch.update(_firestore.collection('products').doc(pid), {
                'stock': FieldValue.increment(qty),
              });
            }
          }

          _stageTombstone(
            batch: batch,
            docRef: doc.reference,
            entityType: 'sales',
          );
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      Query<Map<String, dynamic>> salesmanQuery = _firestore
          .collection('sales')
          .where('recipientType', isEqualTo: 'salesman');
      while (true) {
        final snap = await salesmanQuery.limit(pageSize).get();
        if (snap.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          final data = doc.data();
          final items = data['items'] as List? ?? [];

          for (final item in items) {
            final pid = item['productId']?.toString();
            final qty = (item['quantity'] as num?)?.toDouble();
            if (pid != null && pid.isNotEmpty && qty != null && qty > 0) {
              batch.update(_firestore.collection('products').doc(pid), {
                'stock': FieldValue.increment(qty),
              });
            }
          }

          _stageTombstone(
            batch: batch,
            docRef: doc.reference,
            entityType: 'sales',
          );
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      Query<Map<String, dynamic>> dispatchesQuery = _firestore.collection(
        'dispatches',
      );
      while (true) {
        final snap = await dispatchesQuery.limit(pageSize).get();
        if (snap.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          _stageTombstone(
            batch: batch,
            docRef: doc.reference,
            entityType: 'dispatches',
          );
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      return clearRemoteAllocatedStock(now);
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetAllUsers(String currentUserId) async {
    try {
      final snap = await _firestore.collection('users').get();
      WriteBatch batch = _firestore.batch();
      var opCount = 0;

      Future<void> commitIfNeeded() async {
        if (opCount >= 400) {
          await batch.commit();
          batch = _firestore.batch();
          opCount = 0;
        }
      }

      for (final doc in snap.docs) {
        if (doc.id == currentUserId) continue;

        _stageTombstone(
          batch: batch,
          docRef: doc.reference,
          entityType: 'users',
        );
        batch.delete(doc.reference);
        opCount += 2;
        await commitIfNeeded();
      }

      if (opCount > 0) {
        await batch.commit();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> batchImportCollection(
    String collectionName,
    Map<String, dynamic> docs,
  ) async {
    final docEntries = docs.entries.toList();
    for (var i = 0; i < docEntries.length; i += 400) {
      final batch = _firestore.batch();
      final chunk = docEntries.sublist(
        i,
        (i + 400 < docEntries.length) ? i + 400 : docEntries.length,
      );

      for (final entry in chunk) {
        final docRef = _firestore.collection(collectionName).doc(entry.key);
        batch.set(docRef, entry.value, SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  Future<Map<String, int>> fetchDataCounts() async {
    final results = await Future.wait<AggregateQuerySnapshot>([
      _firestore
          .collection('sales')
          .where('recipientType', isEqualTo: 'customer')
          .count()
          .get(),
      _firestore
          .collection('sales')
          .where('recipientType', whereIn: ['dealer', 'salesman'])
          .count()
          .get(),
      _firestore.collection('production_logs').count().get(),
      _firestore.collection('returns').count().get(),
      _firestore.collection('purchase_orders').count().get(),
      _firestore.collection('diesel_logs').count().get(),
      _firestore.collection('tank_transactions').count().get(),
      _firestore.collection('bhatti_batches').count().get(),
      _firestore.collection('vehicle_maintenance_logs').count().get(),
      _firestore.collection('products').count().get(),
      _firestore.collection('routes').count().get(),
      _firestore.collection('route_orders').count().get(),
      _firestore.collection('users').count().get(),
    ]);

    return <String, int>{
      'sales': results[0].count ?? 0,
      'dispatches': results[1].count ?? 0,
      'production': results[2].count ?? 0,
      'returns': results[3].count ?? 0,
      'purchase_orders': results[4].count ?? 0,
      'diesel_logs': results[5].count ?? 0,
      'tank_transactions': results[6].count ?? 0,
      'bhatti_batches': results[7].count ?? 0,
      'maintenance': results[8].count ?? 0,
      'products': results[9].count ?? 0,
      'routes': results[10].count ?? 0,
      'route_orders': results[11].count ?? 0,
      'users': results[12].count ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> fetchCollectionDocuments(String type) async {
    Query<Map<String, dynamic>> query;
    switch (type) {
      case 'sales':
        query = _firestore
            .collection('sales')
            .where('recipientType', isEqualTo: 'customer');
        break;
      case 'dispatches':
        query = _firestore
            .collection('sales')
            .where('recipientType', whereIn: ['dealer', 'salesman']);
        break;
      case 'routes':
        query = _firestore.collection('routes');
        break;
      case 'route_orders':
        query = _firestore.collection('route_orders');
        break;
      case 'products':
        query = _firestore.collection('products');
        break;
      case 'production':
        query = _firestore.collection('production_logs');
        break;
      default:
        query = _firestore.collection(type);
        break;
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
        .toList();
  }
}
