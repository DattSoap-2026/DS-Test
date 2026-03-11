// lib/services/analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'base_service.dart';

const statsCollection = "daily_stats";

class DailyStats {
  final String date; // YYYY-MM-DD
  final DailySalesStats sales;
  final DailyProductionStats production;
  final DailyExpensesStats expenses;
  final String updatedAt;

  DailyStats({
    required this.date,
    required this.sales,
    required this.production,
    required this.expenses,
    required this.updatedAt,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] as String,
      sales: DailySalesStats.fromJson(
        json['sales'] as Map<String, dynamic>? ?? {},
      ),
      production: DailyProductionStats.fromJson(
        json['production'] as Map<String, dynamic>? ?? {},
      ),
      expenses: DailyExpensesStats.fromJson(
        json['expenses'] as Map<String, dynamic>? ?? {},
      ),
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class DailySalesStats {
  final double totalAmount;
  final int count;
  final double cashAmount;
  final double creditAmount;

  DailySalesStats({
    this.totalAmount = 0,
    this.count = 0,
    this.cashAmount = 0,
    this.creditAmount = 0,
  });

  factory DailySalesStats.fromJson(Map<String, dynamic> json) {
    return DailySalesStats(
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      cashAmount: (json['cashAmount'] as num?)?.toDouble() ?? 0,
      creditAmount: (json['creditAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DailyProductionStats {
  final int totalBoxes;
  final int totalBatches;
  final int gitaBatches;
  final int sonaBatches;

  DailyProductionStats({
    this.totalBoxes = 0,
    this.totalBatches = 0,
    this.gitaBatches = 0,
    this.sonaBatches = 0,
  });

  factory DailyProductionStats.fromJson(Map<String, dynamic> json) {
    return DailyProductionStats(
      totalBoxes: (json['totalBoxes'] as num?)?.toInt() ?? 0,
      totalBatches: (json['totalBatches'] as num?)?.toInt() ?? 0,
      gitaBatches: (json['gitaBatches'] as num?)?.toInt() ?? 0,
      sonaBatches: (json['sonaBatches'] as num?)?.toInt() ?? 0,
    );
  }
}

class DailyExpensesStats {
  final double total;

  DailyExpensesStats({this.total = 0});

  factory DailyExpensesStats.fromJson(Map<String, dynamic> json) {
    return DailyExpensesStats(total: (json['total'] as num?)?.toDouble() ?? 0);
  }
}

class AnalyticsService extends BaseService {
  AnalyticsService(super.firebase);

  Future<void> updateDailyStats(
    DateTime date, {
    Map<String, dynamic>? sales, // { amount: number, type: 'cash'|'credit' }
    Map<String, dynamic>? production, // { boxes: number, bhatti: string }
    Map<String, dynamic>? expense, // { amount: number }
    Transaction? existingTransaction,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final firestore = db;
    if (firestore == null) return;

    final statsRef = firestore.collection(statsCollection).doc(dateStr);

    // Common logic for generating updates
    Map<String, dynamic> prepareUpdates() {
      final Map<String, dynamic> updates = {
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

    // Common initial data
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
    } else {
      // 🔒 WINDOWS SAFETY: Use Batch instead of Transaction to avoid FFI segfault
      // We check for Windows platform explicitly.
      final bool isWindows =
          defaultTargetPlatform == TargetPlatform.windows && !kIsWeb;

      if (isWindows) {
        final statsDoc = await statsRef.get();
        final batch = firestore.batch();
        if (!statsDoc.exists) {
          batch.set(statsRef, initialStats());
        }
        batch.update(statsRef, prepareUpdates());
        await batch.commit();
      } else {
        await firestore.runTransaction((transaction) async {
          final statsDoc = await transaction.get(statsRef);
          if (!statsDoc.exists) {
            transaction.set(statsRef, initialStats());
          }
          transaction.update(statsRef, prepareUpdates());
        });
      }
    }
  }
}
