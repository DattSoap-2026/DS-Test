import 'package:cloud_firestore/cloud_firestore.dart';

import 'base_service.dart';
import 'delegates/analytics_remote_write_delegate.dart';

const statsCollection = analyticsStatsCollection;

class DailyStats {
  final String date;
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
    Map<String, dynamic>? sales,
    Map<String, dynamic>? production,
    Map<String, dynamic>? expense,
    Transaction? existingTransaction,
  }) async {
    final firestore = db;
    if (firestore == null) return;

    await AnalyticsRemoteWriteDelegate(firestore).updateDailyStats(
      date,
      sales: sales,
      production: production,
      expense: expense,
      existingTransaction: existingTransaction,
    );
  }
}
