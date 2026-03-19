import 'package:isar/isar.dart';

import '../core/sync/sync_queue_service.dart';
import '../core/sync/sync_service.dart';
import '../data/local/entities/sale_entity.dart';
import 'base_service.dart';
import 'database_service.dart';

class AgingCustomerDetail {
  final String customerId;
  final String customerName;
  final String invoiceNumber;
  final String invoiceId;
  final String invoiceDate;
  final String dueDate;
  final double totalAmount;
  final double paidAmount;
  final double balanceAmount;
  final int daysOverdue;
  final String
  status; // 'current' | 'overdue_30' | 'overdue_60' | 'overdue_90' | 'overdue_90plus'

  AgingCustomerDetail({
    required this.customerId,
    required this.customerName,
    required this.invoiceNumber,
    required this.invoiceId,
    required this.invoiceDate,
    required this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.daysOverdue,
    required this.status,
  });
}

class AgingBucket {
  final String range;
  final String daysRange;
  final List<AgingCustomerDetail> customers;
  final double totalAmount;
  final int count;

  AgingBucket({
    required this.range,
    required this.daysRange,
    required this.customers,
    required this.totalAmount,
    required this.count,
  });
}

class AgingSummary {
  final AgingBucket current;
  final AgingBucket overdue30;
  final AgingBucket overdue60;
  final AgingBucket overdue90;
  final double totalOutstanding;
  final int totalInvoices;
  final List<String> criticalCustomers;

  AgingSummary({
    required this.current,
    required this.overdue30,
    required this.overdue60,
    required this.overdue90,
    required this.totalOutstanding,
    required this.totalInvoices,
    required this.criticalCustomers,
  });
}

class AgingService extends BaseService {
  static const int _salesPageSize = 500;
  final DatabaseService _dbService;

  AgingService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Future<List<SaleEntity>> _fetchAllSalesPaged() async {
    final allSales = <SaleEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.sales
          .where()
          .offset(offset)
          .limit(_salesPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      allSales.addAll(chunk);
      if (chunk.length < _salesPageSize) {
        break;
      }
      offset += _salesPageSize;
    }
    return allSales;
  }

  Future<String> _enqueueOutbox(
    String collection,
    Map<String, dynamic> payload, {
    required String action,
    String? explicitRecordKey,
  }) async {
    final documentId =
        explicitRecordKey?.trim().isNotEmpty == true
        ? explicitRecordKey!.trim()
        : (payload['id']?.toString().trim() ?? '');
    if (documentId.isEmpty) {
      return '';
    }

    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
    return documentId;
  }

  Future<void> _dequeueOutbox(String documentId, String collection) async {
    if (documentId.trim().isEmpty) {
      return;
    }
    await SyncQueueService.instance.removeFromQueue(
      collectionName: collection,
      documentId: documentId,
    );
  }

  Future<AgingSummary> generateAgingReport() async {
    try {
      final sales = await _fetchAllSalesPaged();
      if (sales.isEmpty) {
        return AgingSummary(
          current: AgingBucket(
            range: 'Current',
            daysRange: '0-30 days',
            customers: [],
            totalAmount: 0,
            count: 0,
          ),
          overdue30: AgingBucket(
            range: 'Overdue 30',
            daysRange: '31-60 days',
            customers: [],
            totalAmount: 0,
            count: 0,
          ),
          overdue60: AgingBucket(
            range: 'Overdue 60',
            daysRange: '61-90 days',
            customers: [],
            totalAmount: 0,
            count: 0,
          ),
          overdue90: AgingBucket(
            range: 'Overdue 90+',
            daysRange: '90+ days',
            customers: [],
            totalAmount: 0,
            count: 0,
          ),
          totalOutstanding: 0,
          totalInvoices: 0,
          criticalCustomers: [],
        );
      }

      final current = <AgingCustomerDetail>[];
      final overdue30 = <AgingCustomerDetail>[];
      final overdue60 = <AgingCustomerDetail>[];
      final overdue90 = <AgingCustomerDetail>[];
      final criticalCustomers = <String>{};

      final today = DateTime.now();

      for (var sale in sales) {
        if (sale.paymentStatus != 'pending' &&
            sale.paymentStatus != 'partial') {
          continue;
        }

        final total = (sale.totalAmount ?? 0).toDouble();
        final paid = (sale.paidAmount ?? 0).toDouble();
        final balance = total - paid;

        if (balance <= 0) {
          continue;
        }

        final createdAtStr = sale.createdAt;
        final invoiceDate = DateTime.tryParse(createdAtStr) ?? DateTime.now();

        // Credit period
        final creditPeriod = 30;
        final dueDate = invoiceDate.add(Duration(days: creditPeriod));

        final daysOverdue = today.difference(dueDate).inDays;

        String status = 'current';
        if (daysOverdue > 90) {
          status = 'overdue_90plus';
        } else if (daysOverdue > 60) {
          status = 'overdue_90'; // Wait, TS bucket naming logic mismatch?
        }
        // TS: overdue_90 bucket is 61-90. overdue_90plus is >90.
        // TS Logic: <=0 current, <=30 overdue_30, <=60 overdue_60, <=90 overdue_90, else 90plus.

        if (daysOverdue <= 0) {
          status = 'current';
        } else if (daysOverdue <= 30) {
          status = 'overdue_30';
        } else if (daysOverdue <= 60) {
          status = 'overdue_60';
        } else if (daysOverdue <= 90) {
          status = 'overdue_90';
        } else {
          status = 'overdue_90plus';
        }

        final detail = AgingCustomerDetail(
          customerId: sale.recipientId,
          customerName: sale.recipientName,
          invoiceNumber: sale.humanReadableId ?? sale.id.substring(0, 8),
          invoiceId: sale.id,
          invoiceDate: createdAtStr,
          dueDate: dueDate.toIso8601String(),
          totalAmount: total,
          paidAmount: paid,
          balanceAmount: balance,
          daysOverdue: daysOverdue,
          status: status,
        );

        if (daysOverdue <= 0) {
          current.add(detail);
        } else if (daysOverdue <= 30) {
          overdue30.add(detail);
        } else if (daysOverdue <= 60) {
          overdue60.add(detail);
        } else if (daysOverdue <= 90) {
          overdue90.add(detail);
        } else {
          overdue90.add(
            detail,
          ); // TS puts >90 in overdue90 bucket but also flags critical?
          // TS: overdue90 bucket is 'Overdue 90+', range '90+ days'. Wait.
          // TS Logic: } else { overdue90.push(detail); criticalCustomers.add... }
          // So TS `overdue90` bucket actually creates the "Overdue 90+" group.
          // My logic: overdue_90 variable is used for this bucket.
          criticalCustomers.add(detail.customerId);
        }
      }

      AgingBucket createBucket(
        String range,
        String daysRange,
        List<AgingCustomerDetail> items,
      ) {
        return AgingBucket(
          range: range,
          daysRange: daysRange,
          customers: items,
          totalAmount: items.fold(0.0, (acc, i) => acc + i.balanceAmount),
          count: items.length,
        );
      }

      return AgingSummary(
        current: createBucket('Current', '0-30 days', current),
        overdue30: createBucket('Overdue 30', '31-60 days', overdue30),
        overdue60: createBucket('Overdue 60', '61-90 days', overdue60),
        // TS: overdue90 bucket label 'Overdue 90+', range '90+ days'.
        overdue90: createBucket('Overdue 90+', '90+ days', overdue90),
        totalOutstanding:
            current.fold(0.0, (s, i) => s + i.balanceAmount) +
            overdue30.fold(0.0, (s, i) => s + i.balanceAmount) +
            overdue60.fold(0.0, (s, i) => s + i.balanceAmount) +
            overdue90.fold(0.0, (s, i) => s + i.balanceAmount),
        totalInvoices:
            current.length +
            overdue30.length +
            overdue60.length +
            overdue90.length,
        criticalCustomers: criticalCustomers.toList(),
      );
    } catch (e) {
      handleError(e, 'generateAgingReport');
      rethrow;
    }
  }

  Future<Map<String, int>> lockCriticalCustomers(
    List<String> customerIds,
  ) async {
    int success = 0;
    int failed = 0;

    for (var id in customerIds) {
      try {
        final now = DateTime.now().toIso8601String();
        final payload = <String, dynamic>{
          'id': id,
          'creditStatus': 'blocked',
          'creditBlockedReason': 'Payment overdue 90+ days',
          'creditBlockedAt': now,
          'updatedAt': now,
        };
        final queueId = await _enqueueOutbox(
          'customers',
          payload,
          action: 'update',
          explicitRecordKey: id,
        );

        if (db != null) {
          try {
            await SyncService.instance.pushAllPending();
            await _dequeueOutbox(queueId, 'customers');
          } catch (_) {
            // Keep queued item for sync coordinator retry.
          }
        }
        success++;
      } catch (e) {
        failed++;
      }
    }
    return {'success': success, 'failed': failed};
  }
}
