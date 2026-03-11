// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/sales_service.dart';

int? _parseLimit(List<String> args) {
  for (final arg in args) {
    if (!arg.startsWith('--limit=')) continue;
    final value = arg.substring('--limit='.length).trim();
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      throw ArgumentError('Invalid --limit value: $value');
    }
    return parsed;
  }
  return null;
}

void _printUsage() {
  print(
    'Usage: flutter run -d windows -t scripts/backfill_sales_accounting_dimensions.dart --no-resident -- '
    '[--dry-run] [--sync-now] [--include-cancelled] [--limit=<N>]',
  );
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  final dryRun = args.contains('--dry-run');
  final syncNow = args.contains('--sync-now');
  final includeCancelled = args.contains('--include-cancelled');
  int? limit;

  try {
    limit = _parseLimit(args);
  } catch (e) {
    print(e);
    _printUsage();
    exitCode = 64;
    return;
  }

  final firebase = FirebaseServices();
  final db = DatabaseService.instance;

  try {
    await db.init();

    if (syncNow) {
      await firebase.initialize();
    }

    final inventoryService = InventoryService(firebase, db);
    final salesService = SalesService(firebase, db, inventoryService);

    final summary = await salesService.accountingDelegate
        .backfillHistoricalAccountingDimensions(
          dryRun: dryRun,
          syncImmediately: syncNow,
          limit: limit,
          includeCancelled: includeCancelled,
        );

    print('Backfill completed.');
    summary.forEach((key, value) {
      print('  $key: $value');
    });

    final errors = summary['errors'] ?? 0;
    if (errors > 0) {
      exitCode = 2;
    }
  } catch (e, stack) {
    print('Backfill failed: $e');
    print(stack);
    exitCode = 1;
  }
}
