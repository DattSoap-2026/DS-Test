import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMigrationDelegate {
  FirestoreMigrationDelegate([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> setVersion(String schemaVersionDoc, int version) async {
    await _firestore.collection('settings').doc(schemaVersionDoc).set({
      'version': version,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> migrateAddIsDeleted(List<String> collections) async {
    var updatedCount = 0;
    for (final collection in collections) {
      final snapshot = await _firestore
          .collection(collection)
          .where('isDeleted', isNull: true)
          .limit(500)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDeleted': false});
      }
      await batch.commit();
      updatedCount += snapshot.docs.length;
    }
    return updatedCount;
  }

  Future<int> migrateSalesmanUid() async {
    final snapshot = await _firestore
        .collection('sales')
        .where('salesmanId', isNull: false)
        .limit(500)
        .get();

    final batch = _firestore.batch();
    var updated = 0;

    for (final doc in snapshot.docs) {
      final salesmanId = doc.data()['salesmanId'];
      if (salesmanId != null && !salesmanId.toString().contains('@')) {
        continue;
      }

      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: salesmanId)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final uid = userSnapshot.docs.first.id;
        batch.update(doc.reference, {
          'salesmanId': uid,
          'migratedToUid': true,
        });
        updated++;
      }
    }

    await batch.commit();
    return updated;
  }

  Future<int> migrateSyncStatus(List<String> collections) async {
    var updatedCount = 0;
    for (final collection in collections) {
      final snapshot = await _firestore
          .collection(collection)
          .where('syncStatus', isNull: true)
          .limit(500)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'syncStatus': 'synced',
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      updatedCount += snapshot.docs.length;
    }
    return updatedCount;
  }
}
