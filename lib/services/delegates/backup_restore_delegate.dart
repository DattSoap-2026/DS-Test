import 'package:cloud_firestore/cloud_firestore.dart';

class BackupRestoreDelegate {
  const BackupRestoreDelegate(this._firestore);

  final FirebaseFirestore _firestore;

  Future<int> restoreFirebaseData(
    Map<String, Map<String, dynamic>> firebaseData, {
    required int totalSteps,
    required int currentStep,
    Function(int current, int total, String message)? onProgress,
  }) async {
    const batchSize = 450;

    for (final entry in firebaseData.entries) {
      final collectionName = entry.key;
      final docs = entry.value;
      final docEntries = docs.entries.toList();

      for (var i = 0; i < docEntries.length; i += batchSize) {
        final batch = _firestore.batch();
        final end = (i + batchSize < docEntries.length)
            ? i + batchSize
            : docEntries.length;
        final chunk = docEntries.sublist(i, end);

        for (final docEntry in chunk) {
          if (docEntry.key == '_error') {
            continue;
          }

          final docRef = _firestore.collection(collectionName).doc(docEntry.key);
          batch.set(docRef, docEntry.value, SetOptions(merge: true));
        }

        await batch.commit();
        currentStep++;
        if (onProgress != null) {
          onProgress(
            currentStep,
            totalSteps,
            'Restoring Fire: $collectionName...',
          );
        }
      }
    }

    return currentStep;
  }
}
