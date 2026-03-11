import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sale_entity.dart';
import 'package:flutter_app/data/local/entities/stock_ledger_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/notification_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/reports_service.dart';
import 'package:flutter_app/services/reporting_service.dart';
import 'package:flutter_app/services/settings_service.dart';
import 'package:flutter_app/services/vehicles_service.dart';
import 'package:flutter_app/services/whatsapp_invoice_pipeline_service.dart';
import 'package:flutter_app/utils/pdf_generator.dart';

const bool _runDbTests = bool.fromEnvironment(
  'RUN_DB_TESTS',
  defaultValue: false,
);

String? _detectDbSkipReason() {
  if (!_runDbTests) {
    return 'Requires Isar native library. Run with --dart-define=RUN_DB_TESTS=true';
  }
  if (Platform.isWindows) {
    final dllPath =
        '${Directory.current.path}${Platform.pathSeparator}isar.dll';
    try {
      DynamicLibrary.open(dllPath);
    } catch (e) {
      return 'RUN_DB_TESTS=true but Isar native library is unavailable: $e';
    }
  }
  return null;
}

final String? _dbSkipReason = _detectDbSkipReason();
bool get _shouldSkipDbTests => _dbSkipReason != null;

double _msAvg(List<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

double _msMax(List<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce(max);
}

Map<String, dynamic> _legacyMainIsolateAggregate(
  List<SalesReportRecord> records,
) {
  final trend = <String, Map<String, dynamic>>{};
  final byDivision = <String, Map<String, dynamic>>{};
  final byRoute = <String, Map<String, dynamic>>{};
  var totalRevenue = 0.0;
  var totalQuantity = 0;
  var totalLineItems = 0;

  void accumulate(
    Map<String, Map<String, dynamic>> map,
    String key,
    String label,
    SalesReportRecord record,
  ) {
    final entry = map.putIfAbsent(
      key,
      () => <String, dynamic>{
        'label': label,
        'transactions': 0,
        'quantity': 0,
        'lineItems': 0,
        'revenue': 0.0,
      },
    );
    entry['transactions'] = (entry['transactions'] as int) + 1;
    entry['quantity'] = (entry['quantity'] as int) + record.quantity;
    entry['lineItems'] = (entry['lineItems'] as int) + record.lineItems;
    entry['revenue'] = (entry['revenue'] as double) + record.totalAmount;
  }

  for (final record in records) {
    totalRevenue += record.totalAmount;
    totalQuantity += record.quantity;
    totalLineItems += record.lineItems;
    final date = record.createdAt;
    final trendKey =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
    final trendLabel = '${date.month}/${date.year}';
    accumulate(trend, trendKey, trendLabel, record);
    accumulate(byDivision, record.division.toLowerCase(), record.division, record);
    accumulate(byRoute, record.route.toLowerCase(), record.route, record);
  }

  return <String, dynamic>{
    'records': records.length,
    'totalRevenue': totalRevenue,
    'totalQuantity': totalQuantity,
    'totalLineItems': totalLineItems,
    'trendCount': trend.length,
    'divisionCount': byDivision.length,
    'routeCount': byRoute.length,
  };
}

Sale _buildBenchmarkSale({required String id, int itemCount = 120}) {
  final now = DateTime.now();
  final items = List<SaleItem>.generate(
    itemCount,
    (i) => SaleItem(
      productId: 'prod_$i',
      name: 'Product $i',
      quantity: 2 + (i % 3),
      price: 99.0 + i,
      baseUnit: 'pcs',
      isFree: false,
      discount: 0,
      lineSubtotal: (2 + (i % 3)) * (99.0 + i),
      lineTotalAmount: (2 + (i % 3)) * (99.0 + i),
    ),
  );
  final subtotal = items.fold<double>(
    0,
    (sum, item) => sum + (item.lineTotalAmount ?? item.quantity * item.price),
  );

  return Sale(
    id: id,
    humanReadableId: 'INV-$id',
    recipientType: 'customer',
    recipientId: 'cust-1',
    recipientName: 'Benchmark Customer',
    items: items,
    itemProductIds: items.map((e) => e.productId).toList(growable: false),
    subtotal: subtotal,
    discountPercentage: 0,
    discountAmount: 0,
    taxableAmount: subtotal,
    gstType: 'none',
    gstPercentage: 0,
    totalAmount: subtotal,
    salesmanId: 'salesman_bench',
    salesmanName: 'Bench Salesman',
    createdAt: now.toIso8601String(),
    month: now.month,
    year: now.year,
  );
}

CompanyProfileData _benchmarkCompanyProfile() {
  return CompanyProfileData(
    name: 'Datt Soap ERP',
    address: 'Industrial Area',
    phone: '9999999999',
    email: 'bench@example.com',
    gstin: '22AAAAA0000A1Z5',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService dbService;
  late Directory tempDir;
  late ReportsService reportsService;
  late InventoryService inventoryService;
  late VehiclesService vehiclesService;

  Future<void> seedProduct({
    required String id,
    required String name,
    required double stock,
    String itemType = 'finished_good',
  }) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = id
      ..name = name
      ..sku = 'SKU-$id'
      ..itemType = itemType
      ..type = itemType
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = 'pcs'
      ..price = 100
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  Future<void> seedSalesForReport({required int count}) async {
    final now = DateTime.now().toUtc();
    final entities = <SaleEntity>[];
    for (var i = 0; i < count; i++) {
      final createdAt = now.subtract(Duration(minutes: i));
      final itemAQty = 2 + (i % 4);
      final itemBQty = 1 + (i % 3);
      final amount = (itemAQty * 120.0) + (itemBQty * 80.0);
      final entity = SaleEntity()
        ..id = 'sale_perf_$i'
        ..humanReadableId = 'INV-PERF-${i + 1}'
        ..recipientType = 'customer'
        ..recipientId = 'cust_${i % 40}'
        ..recipientName = 'Customer ${i % 40}'
        ..items = [
          SaleItemEntity()
            ..productId = 'prod_A'
            ..name = 'Prod A'
            ..quantity = itemAQty
            ..price = 120.0
            ..isFree = false
            ..baseUnit = 'pcs',
          SaleItemEntity()
            ..productId = 'prod_B'
            ..name = 'Prod B'
            ..quantity = itemBQty
            ..price = 80.0
            ..isFree = false
            ..baseUnit = 'pcs',
        ]
        ..itemProductIds = const ['prod_A', 'prod_B']
        ..subtotal = amount
        ..discountPercentage = 0
        ..discountAmount = 0
        ..taxableAmount = amount
        ..gstType = 'none'
        ..gstPercentage = 0
        ..totalAmount = amount
        ..status = 'completed'
        ..salesmanId = 'salesman_${i % 8}'
        ..salesmanName = 'Salesman ${i % 8}'
        ..route = 'Route ${i % 6}'
        ..createdAt = createdAt.toIso8601String()
        ..month = createdAt.month
        ..year = createdAt.year
        ..updatedAt = createdAt
        ..syncStatus = SyncStatus.synced
        ..isDeleted = false;
      entities.add(entity);
    }
    await dbService.db.writeTxn(() async {
      await dbService.sales.putAll(entities);
    });
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tempDir = await Directory.systemTemp.createTemp(
      'final_runtime_validation_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);
    final firebase = FirebaseServices();
    reportsService = ReportsService(firebase);
    inventoryService = InventoryService(firebase, dbService);
    vehiclesService = VehiclesService(firebase);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.sales.clear();
      await dbService.products.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
      await dbService.vehicles.clear();
      await dbService.maintenanceLogs.clear();
    });
  });

  tearDownAll(() async {
    if (_shouldSkipDbTests) return;
    await dbService.db.close();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  test(
    'runtime: heavy report aggregation benchmark (before vs after proxy)',
    () async {
      await seedSalesForReport(count: 2200);
      final query = SalesReportQuery(
        groupBy: SalesReportGroupBy.monthly,
        includeCancelled: false,
      );

      final memBefore = ProcessInfo.currentRss;

      final swAfter = Stopwatch()..start();
      final report = await reportsService.getSalesAdvancedReport(query);
      swAfter.stop();

      final swBefore = Stopwatch()..start();
      final legacy = _legacyMainIsolateAggregate(report.records);
      swBefore.stop();

      final memAfter = ProcessInfo.currentRss;
      final memDeltaMb = (memAfter - memBefore) / (1024 * 1024);

      // ignore: avoid_print
      print(
        'RUNTIME_METRIC_REPORT: '
        '${jsonEncode({
          'records': report.records.length,
          'before_main_isolate_ms': swBefore.elapsedMilliseconds,
          'after_isolate_path_ms': swAfter.elapsedMilliseconds,
          'memory_delta_mb': double.parse(memDeltaMb.toStringAsFixed(2)),
          'trend_buckets': report.trend.length,
          'legacy_summary': legacy,
        })}',
      );

      expect(report.records.length, greaterThan(1500));
      expect(report.totalTransactions, report.records.length);
    },
    skip: _dbSkipReason ?? false,
  );

  test('runtime: pdf generation frame timing proxy (before vs after)', () async {
    final sale = _buildBenchmarkSale(id: 'bench_pdf', itemCount: 140);
    final company = _benchmarkCompanyProfile();

    Future<List<double>> measureOps(Future<void> Function(int i) op) async {
      final samples = <double>[];
      for (var i = 0; i < 2; i++) {
        final sw = Stopwatch()..start();
        await op(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
      }
      return samples;
    }

    final baselineSamples = await measureOps((_) async {
      final bytes = await ReportingService().generateInvoicePdf(sale);
      expect(bytes, isNotEmpty);
    });
    final hardenedSamples = await measureOps((_) async {
        final bytes = await PdfGenerator.generateSaleInvoicePdfBytes(
          sale,
          company,
        );
        expect(bytes, isNotEmpty);
    });

    // ignore: avoid_print
    print(
      'RUNTIME_METRIC_PDF: '
      '${jsonEncode({
        'before_avg_frame_proxy_ms': _msAvg(baselineSamples),
        'before_worst_frame_proxy_ms': _msMax(baselineSamples),
        'after_avg_frame_proxy_ms': _msAvg(hardenedSamples),
        'after_worst_frame_proxy_ms': _msMax(hardenedSamples),
        'samples': hardenedSamples.length,
      })}',
    );

    expect(hardenedSamples.isNotEmpty, isTrue);
  });

  test('runtime: notification outbox stress under forced publish failure', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = NotificationService();

    final sw = Stopwatch()..start();
    for (var i = 0; i < 120; i++) {
      await service.publishNotificationEvent(
        title: 'Stress $i',
        body: 'Notification event stress body $i',
        eventType: 'stress_test',
        targetRoles: const {UserRole.admin},
        data: {'idx': i},
      );
    }
    sw.stop();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notification_events_outbox_v1') ?? '[]';
    final decoded = jsonDecode(raw) as List<dynamic>;
    final ids = decoded
        .map((e) => (e as Map)['eventId']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    final uniqueIds = ids.toSet();

    // ignore: avoid_print
    print(
      'RUNTIME_METRIC_NOTIFICATION_OUTBOX: '
      '${jsonEncode({
        'events_enqueued': decoded.length,
        'elapsed_ms': sw.elapsedMilliseconds,
        'unique_ids': uniqueIds.length,
        'duplicate_ids': ids.length - uniqueIds.length,
      })}',
    );

    await service.dispose();
    expect(decoded.length, greaterThanOrEqualTo(100));
    expect(uniqueIds.length, decoded.length);
  });

  test('runtime: whatsapp replay-safe recovery (ack survives crash window)', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'whatsapp_enabled': 'false',
    });

    final service = WhatsAppInvoicePipelineService.instance;
    final sale = _buildBenchmarkSale(id: 'wa_replay_test', itemCount: 4);
    final company = _benchmarkCompanyProfile();

    await service.enqueueInvoicePdfJob(
      sale: sale,
      companyProfile: company,
      customerName: 'Replay Customer',
      customerPhone: '9876543210',
      source: 'runtime_validation',
    );

    final prefs = await SharedPreferences.getInstance();
    final queueRaw = prefs.getString('whatsapp_invoice_pdf_jobs_v1') ?? '[]';
    final queue = jsonDecode(queueRaw) as List<dynamic>;
    expect(queue, isNotEmpty);

    final first = Map<String, dynamic>.from(queue.first as Map);
    final jobId = first['jobId']?.toString() ?? '';
    expect(jobId, isNotEmpty);

    final successAckRaw =
        prefs.getString('whatsapp_invoice_pdf_success_ack_v1') ?? '{}';
    final successAck = Map<String, dynamic>.from(
      jsonDecode(successAckRaw) as Map,
    );
    successAck[jobId] = DateTime.now().toUtc().toIso8601String();
    await prefs.setString(
      'whatsapp_invoice_pdf_success_ack_v1',
      jsonEncode(successAck),
    );

    await service.processPendingJobs();

    final queueAfterRaw =
        prefs.getString('whatsapp_invoice_pdf_jobs_v1') ?? '[]';
    final queueAfter = jsonDecode(queueAfterRaw) as List<dynamic>;
    final sameJob = queueAfter
        .map((e) => Map<String, dynamic>.from(e as Map))
        .firstWhere((e) => e['jobId'] == jobId);

    // ignore: avoid_print
    print(
      'RUNTIME_METRIC_WHATSAPP_REPLAY: '
      '${jsonEncode({
        'job_id': jobId,
        'status_after_recovery': sameJob['status'],
        'attempt_after_recovery': sameJob['attempt'],
      })}',
    );

    expect(sameJob['status'], 'success');
  });

  test(
    'runtime: concurrent stock mutation stress keeps math exact',
    () async {
      await seedProduct(
        id: 'prod_concurrent_1',
        name: 'Concurrent Product',
        stock: 10000,
      );

      const operations = 600;
      final sw = Stopwatch()..start();
      await Future.wait(
        List<Future<void>>.generate(operations, (i) async {
          await dbService.db.writeTxn(() async {
            await inventoryService.applyProductStockChangeInTxn(
              productId: 'prod_concurrent_1',
              quantityChange: -1,
              updatedAt: DateTime.now(),
              markSyncPending: false,
              createLedger: true,
              transactionType: 'VALIDATION_STRESS',
              performedBy: 'runtime_validation',
              reason: 'concurrent_mutation',
              referenceId: 'stress_$i',
            );
          });
        }),
      );
      sw.stop();

      final product = await dbService.products.getById('prod_concurrent_1');
      final ledger = await dbService.stockLedger
          .filter()
          .transactionTypeEqualTo('VALIDATION_STRESS')
          .findAll();
      final duplicateRefCount = _countDuplicateReferences(ledger);

      // ignore: avoid_print
      print(
        'RUNTIME_METRIC_STOCK_CONCURRENCY: '
        '${jsonEncode({
          'operations': operations,
          'elapsed_ms': sw.elapsedMilliseconds,
          'final_stock': product?.stock,
          'expected_stock': 10000 - operations,
          'ledger_entries': ledger.length,
          'duplicate_reference_count': duplicateRefCount,
        })}',
      );

      expect(product, isNotNull);
      expect(product!.stock, 10000 - operations);
      expect(ledger.length, operations);
      expect(duplicateRefCount, 0);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'runtime: offline replay dedup under load keeps single latest queue intent',
    () async {
      await vehiclesService.addVehicle({
        'id': 'veh-load-1',
        'name': 'Replay Vehicle',
        'number': 'RJ14AB1234',
        'type': 'Truck',
        'status': 'active',
        'totalDistance': 100,
      });

      await vehiclesService.addMaintenanceLog({
        'id': '',
        'vehicleId': 'veh-load-1',
        'vehicleNumber': 'RJ14AB1234',
        'serviceDate': DateTime(2026, 2, 10).toIso8601String(),
        'vendor': 'Vendor A',
        'description': 'Initial service',
        'totalCost': 1000.0,
        'type': 'Regular',
      });
      final logsAfterAdd = await dbService.maintenanceLogs.where().findAll();
      final logId = logsAfterAdd.single.id;

      final sw = Stopwatch()..start();
      for (var i = 0; i < 120; i++) {
        await vehiclesService.updateMaintenanceLog(logId, {
          'description': 'Update $i',
          'totalCost': 1000.0 + i,
          'serviceDate': DateTime(2026, 2, 10).add(Duration(days: i % 5))
              .toIso8601String(),
        });
      }
      await vehiclesService.deleteMaintenanceLog(logId, 'veh-load-1', 1119.0);
      sw.stop();

      final queueItems = await dbService.syncQueue
          .filter()
          .collectionEqualTo(maintenanceLogsCollection)
          .findAll();
      final matchingQueueItems = <SyncQueueEntity>[];
      for (final queueItem in queueItems) {
        final payload = OutboxCodec.decode(
          queueItem.dataJson,
          fallbackQueuedAt: queueItem.createdAt,
        ).payload;
        if (payload['id'] == logId) {
          matchingQueueItems.add(queueItem);
        }
      }

      final latest = matchingQueueItems.single;
      // ignore: avoid_print
      print(
        'RUNTIME_METRIC_SYNC_REPLAY: '
        '${jsonEncode({
          'events_applied': 122,
          'elapsed_ms': sw.elapsedMilliseconds,
          'queue_items_for_record': matchingQueueItems.length,
          'latest_action': latest.action,
        })}',
      );

      expect(matchingQueueItems.length, 1);
      expect(latest.action, 'delete');
    },
    skip: _dbSkipReason ?? false,
  );
}

int _countDuplicateReferences(List<StockLedgerEntity> entries) {
  final counts = <String, int>{};
  for (final entry in entries) {
    final ref = entry.referenceId ?? '';
    if (ref.isEmpty) continue;
    counts[ref] = (counts[ref] ?? 0) + 1;
  }
  return counts.values.where((c) => c > 1).length;
}
