import 'dart:io';

class _Check {
  const _Check({
    required this.name,
    required this.filePath,
    this.mustContain = const [],
    this.mustContainRegex = const [],
    this.mustNotContain = const [],
  });

  final String name;
  final String filePath;
  final List<String> mustContain;
  final List<RegExp> mustContainRegex;
  final List<String> mustNotContain;
}

void main() {
  final checks = <_Check>[
    _Check(
      name: 'Bhatti daily route should map to supervisor history screen',
      filePath: 'lib/routers/app_router.dart',
      mustContain: [
        "path: 'bhatti/daily-logs'",
        "builder: (context, state) => const BhattiSupervisorScreen()",
      ],
    ),
    _Check(
      name: 'Bhatti nav label should be Batch History for daily-logs route',
      filePath: 'lib/constants/nav_items.dart',
      mustContainRegex: [
        RegExp(
          r'href:\s*"/dashboard/bhatti/daily-logs",[\s\S]{0,120}?label:\s*"Batch History"',
          multiLine: true,
        ),
      ],
    ),
    _Check(
      name: 'Bhatti history page should load from bhatti batches',
      filePath: 'lib/screens/bhatti/bhatti_supervisor_screen.dart',
      mustContain: [
        "Batch History",
        "service.getBhattiBatches(",
        "_openBatchEdit(",
      ],
      mustNotContain: [
        "_AddBhattiEntryDialog",
        "Add Daily Batch Entry",
      ],
    ),
    _Check(
      name: 'Bhatti cooking should include confirm and consumption flow',
      filePath: 'lib/screens/bhatti/bhatti_cooking_screen.dart',
      mustContain: [
        "_ConfirmConsumptionDialog",
        "Consumption Qty (Kg)",
        "_onSubmitPressed()",
      ],
      mustNotContain: [
        "Bulk Refill",
      ],
    ),
    _Check(
      name: 'Bhatti dashboard should compute today batches from batchCount sum',
      filePath: 'lib/screens/bhatti/bhatti_dashboard_screen.dart',
      mustContain: [
        "_todayBatchesCount = todayBatches.fold",
      ],
    ),
    _Check(
      name: 'Bhatti report KPIs should prefer detailed batch source',
      filePath: 'lib/screens/reports/bhatti_report_screen.dart',
      mustContain: [
        "_totalBatches = detailedBatches.fold",
        "_gitaBatches = detailedBatches",
        "_sonaBatches = detailedBatches",
      ],
    ),
    _Check(
      name: 'Inventory analytics should hide sensitive cards for bhatti supervisor',
      filePath: 'lib/widgets/inventory/inventory_analytics_card.dart',
      mustContain: [
        "isBhattiSupervisorView",
        "card['label'] != 'Total Stock Value'",
        "card['label'] != 'Stock Availability'",
      ],
    ),
    _Check(
      name: 'Inventory overview should pass role flag to analytics card',
      filePath: 'lib/screens/inventory/inventory_overview_screen.dart',
      mustContain: [
        "isBhattiSupervisorView: isBhattiSupervisor",
      ],
    ),
  ];

  final failures = <String>[];
  var passes = 0;

  for (final check in checks) {
    final file = File(check.filePath);
    if (!file.existsSync()) {
      failures.add('${check.name}: file not found (${check.filePath})');
      continue;
    }

    final content = file.readAsStringSync();
    var ok = true;

    for (final token in check.mustContain) {
      if (!content.contains(token)) {
        failures.add('${check.name}: missing token -> $token');
        ok = false;
      }
    }

    for (final pattern in check.mustContainRegex) {
      if (!pattern.hasMatch(content)) {
        failures.add('${check.name}: missing pattern -> ${pattern.pattern}');
        ok = false;
      }
    }

    for (final token in check.mustNotContain) {
      if (content.contains(token)) {
        failures.add('${check.name}: forbidden token present -> $token');
        ok = false;
      }
    }

    if (ok) {
      passes++;
      stdout.writeln('[PASS] ${check.name}');
    }
  }

  stdout.writeln('');
  stdout.writeln('Bhatti Supervisor smoke guard summary: $passes/${checks.length} passed');

  if (failures.isNotEmpty) {
    stderr.writeln('');
    stderr.writeln('Failures (${failures.length}):');
    for (final failure in failures) {
      stderr.writeln(' - $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('All critical bhatti supervisor audit checks passed.');
}
