import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

const analyticsStatsCollection = 'daily_stats';

class AnalyticsRemoteWriteDelegate {
  const AnalyticsRemoteWriteDelegate(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> updateDailyStats(
    DateTime date, {
    Map<String, dynamic>? sales,
    Map<String, dynamic>? production,
    Map<String, dynamic>? expense,
    Transaction? existingTransaction,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final statsRef = _firestore.collection(analyticsStatsCollection).doc(dateStr);

    Map<String, dynamic> prepareUpdates() {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (sales != null) {
        final amount = (sales['amount'] as num).toDouble();
        updates['sales.totalAmount'] = FieldValue.increment(amount);
        updates['sales.count'] = FieldValue.increment(1);
        if (sales['type'] == 'cash') {
          updates['sales.cashAmount'] = FieldValue.increment(amount);
        } else {
          updates['sales.creditAmount'] = FieldValue.increment(amount);
        }
      }

      if (production != null) {
        final boxes = (production['boxes'] as num).toInt();
        updates['production.totalBoxes'] = FieldValue.increment(boxes);
        updates['production.totalBatches'] = FieldValue.increment(1);
        if (production['bhatti'] == 'Gita Bhatti') {
          updates['production.gitaBatches'] = FieldValue.increment(1);
        } else {
          updates['production.sonaBatches'] = FieldValue.increment(1);
        }
      }

      if (expense != null) {
        final amount = (expense['amount'] as num).toDouble();
        updates['expenses.total'] = FieldValue.increment(amount);
      }

      return updates;
    }

    Map<String, dynamic> initialStats() {
      return {
        'date': dateStr,
        'sales': {
          'totalAmount': 0,
          'count': 0,
          'cashAmount': 0,
          'creditAmount': 0,
        },
        'production': {
          'totalBoxes': 0,
          'totalBatches': 0,
          'gitaBatches': 0,
          'sonaBatches': 0,
        },
        'expenses': {'total': 0},
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }

    if (existingTransaction != null) {
      final statsDoc = await existingTransaction.get(statsRef);
      if (!statsDoc.exists) {
        existingTransaction.set(statsRef, initialStats());
      }
      existingTransaction.update(statsRef, prepareUpdates());
      return;
    }

    final isWindows =
        defaultTargetPlatform == TargetPlatform.windows && !kIsWeb;
    if (isWindows) {
      final statsDoc = await statsRef.get();
      final batch = _firestore.batch();
      if (!statsDoc.exists) {
        batch.set(statsRef, initialStats());
      }
      batch.update(statsRef, prepareUpdates());
      await batch.commit();
      return;
    }

    await _firestore.runTransaction((transaction) async {
      final statsDoc = await transaction.get(statsRef);
      if (!statsDoc.exists) {
        transaction.set(statsRef, initialStats());
      }
      transaction.update(statsRef, prepareUpdates());
    });
  }
}
