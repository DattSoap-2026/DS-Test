import 'package:cloud_firestore/cloud_firestore.dart' as fs;

import '../outbox_codec.dart';

class ProductionRemoteWriteDelegate {
  const ProductionRemoteWriteDelegate(this._firestore);

  final fs.FirebaseFirestore _firestore;

  Future<void> syncDetailedProductionLog({
    required String collection,
    required String logId,
    required Map<String, dynamic> data,
    required String commandKey,
    required Object? rawCreatedAt,
    required String productId,
    required int totalBatchQuantity,
    required String productionTargetsCollection,
  }) async {
    final docRef = _firestore.collection(collection).doc(logId);
    final existingLog = await docRef.get();
    if (existingLog.exists) {
      final existingData = existingLog.data();
      if (existingData?[OutboxCodec.idempotencyKeyField] == commandKey ||
          existingData?['isSynced'] == true) {
        return;
      }
    }

    final batch = _firestore.batch();
    String dateStr;
    if (rawCreatedAt is fs.Timestamp) {
      dateStr = rawCreatedAt.toDate().toIso8601String().split('T')[0];
    } else if (rawCreatedAt is String) {
      dateStr = rawCreatedAt.split('T')[0];
    } else {
      dateStr = DateTime.now().toIso8601String().split('T')[0];
    }

    final targetQuery = await _firestore
        .collection(productionTargetsCollection)
        .where('productId', isEqualTo: productId)
        .where('targetDate', isEqualTo: dateStr)
        .limit(1)
        .get();

    if (targetQuery.docs.isNotEmpty) {
      final targetRef = targetQuery.docs.first.reference;
      batch.update(targetRef, {
        'achievedQuantity': fs.FieldValue.increment(totalBatchQuantity),
      });
    }

    batch.set(
      docRef,
      {
        ...data,
        OutboxCodec.idempotencyKeyField: commandKey,
        'createdAt': data['createdAt'] ?? fs.FieldValue.serverTimestamp(),
        'updatedAt': fs.FieldValue.serverTimestamp(),
        'isSynced': true,
      },
      fs.SetOptions(merge: true),
    );

    await batch.commit();
  }
}
