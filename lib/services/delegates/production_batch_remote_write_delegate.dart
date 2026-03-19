import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionBatchRemoteWriteDelegate {
  const ProductionBatchRemoteWriteDelegate(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> createBatch(
    DocumentReference<Map<String, dynamic>> batchRef,
    Map<String, dynamic> payload,
  ) async {
    final batch = _firestore.batch();
    batch.set(batchRef, payload);
    await batch.commit();
  }

  Future<void> updateBatch(
    DocumentReference<Map<String, dynamic>> batchRef,
    Map<String, dynamic> updates,
  ) async {
    final batch = _firestore.batch();
    batch.update(batchRef, updates);
    await batch.commit();
  }
}
