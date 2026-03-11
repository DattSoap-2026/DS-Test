import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/entities/sync_metric_entity.dart';
import '../../core/firebase/firebase_config.dart';
import '../../services/database_service.dart';
import '../../services/forensic_audit_service.dart';
import '../../services/sync_analytics_service.dart';
import '../../services/conflict_service.dart';
import '../../widgets/ui/shared/app_card.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../utils/app_logger.dart';
import '../../widgets/dashboard/kpi_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';

class SyncAnalyticsDashboardScreen extends StatefulWidget {
  const SyncAnalyticsDashboardScreen({super.key});

  @override
  State<SyncAnalyticsDashboardScreen> createState() =>
      _SyncAnalyticsDashboardScreenState();
}

class _SyncAnalyticsDashboardScreenState
    extends State<SyncAnalyticsDashboardScreen> {
  bool _isLoading = true;
  int _pendingConflicts = 0;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  Map<String, dynamic> _summary = {};
  List<SyncMetricEntity> _recentFailures = [];
  ForensicAuditSnapshot? _forensicSnapshot;
  String? _forensicExportPath;
  bool _isForensicRunning = false;
  String? _forensicError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _runForensicAudit();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final analyticsService = context.read<SyncAnalyticsService>();
      final conflictService = context.read<ConflictService>();

      final summary = await analyticsService.getSyncSummary(
        _dateRange.start,
        _dateRange.end,
      );

      final failures = await analyticsService.getRecentFailures(limit: 10);
      final conflicts = await conflictService.getPendingConflicts();

      if (mounted) {
        setState(() {
          _summary = summary;
          _recentFailures = failures;
          _pendingConflicts = conflicts.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error(
        'Error loading sync analytics',
        error: e,
        tag: 'Analytics',
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading analytics: $e')));
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadData();
    }
  }

  Future<void> _runForensicAudit() async {
    if (!mounted) return;
    setState(() {
      _isForensicRunning = true;
      _forensicError = null;
    });
    try {
      final dbService = context.read<DatabaseService>();
      final service = ForensicAuditService(dbService, firebaseServices);
      final snapshot = await service.collectSnapshot();
      final exported = await service.exportSnapshotJson(snapshot);
      if (!mounted) return;
      setState(() {
        _forensicSnapshot = snapshot;
        _forensicExportPath = exported.path;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _forensicError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isForensicRunning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MasterScreenHeader(
              title: 'Sync Analytics',
              subtitle: 'Monitor synchronization health and performance',
              icon: Icons.sync_problem_rounded,
              color: AppColors.warning, // Semantic color, acceptable
              isDashboardHeader: true,
              actions: [
                if (_pendingConflicts > 0)
                  ElevatedButton.icon(
                    onPressed: () => context.pushNamed('sync_conflicts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                    icon: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: Text('$_pendingConflicts Conflicts'),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    '${DateFormat('MMM d').format(_dateRange.start)} - ${DateFormat('MMM d').format(_dateRange.end)}',
                  ),
                ),
                IconButton(
                  onPressed: _isForensicRunning ? null : _runForensicAudit,
                  icon: const Icon(Icons.fact_check_outlined),
                  tooltip: 'Run forensic audit and export JSON',
                ),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_summary.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No sync data available for this range',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildForensicAuditCard(theme),
                  const SizedBox(height: 24),
                  _buildSummaryCards(theme),
                  const SizedBox(height: 24),
                  _buildChartsRow(theme),
                  const SizedBox(height: 24),
                  _buildRecentFailures(theme),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    final successRate = (_summary['successRate'] as num?)?.toDouble() ?? 0.0;
    final totalOps = _summary['totalOperations'] as int? ?? 0;
    final totalRecords = _summary['totalRecordsSynced'] as int? ?? 0;
    final avgDuration = _summary['avgDurationMs'] as int? ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final cardWidth = isWide
            ? (constraints.maxWidth - (3 * 16)) / 4
            : (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Success Rate',
                value: '${successRate.toStringAsFixed(1)}%',
                icon: Icons.check_circle_outline,
                color: successRate > 95
                    ? AppColors.success
                    : (successRate > 80
                          ? AppColors.warning
                          : theme.colorScheme.error),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Total Operations',
                value: totalOps.toString(),
                icon: Icons.sync,
                color: AppColors.info,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Records Synced',
                value: totalRecords.toString(),
                icon: Icons.data_usage,
                color: AppColors.info,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Avg Duration',
                value: '${avgDuration}ms',
                icon: Icons.timer_outlined,
                color: AppColors.lightPrimary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForensicAuditCard(ThemeData theme) {
    final forensic = _forensicSnapshot;

    if (forensic == null) {
      return AppCard(
        title: Text('Forensic Audit', style: theme.textTheme.titleMedium),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_isForensicRunning)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (_isForensicRunning) const SizedBox(width: 12),
            Expanded(
              child: Text(
                _forensicError != null
                    ? 'Forensic audit failed: $_forensicError'
                    : 'Run forensic audit to verify local vs Firebase partner state.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final generatedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(
      forensic.generatedAt,
    );
    final customer = forensic.localCustomers;
    final dealer = forensic.localDealers;

    return AppCard(
      title: Text('Forensic Audit', style: theme.textTheme.titleMedium),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generated: $generatedAt', style: theme.textTheme.bodySmall),
          if (_forensicExportPath != null) ...[
            const SizedBox(height: 6),
            SelectableText(
              'JSON: $_forensicExportPath',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Customers (Local): total ${customer.total}, active ${customer.notDeleted}, pending ${customer.pending}, synced ${customer.synced}, conflict ${customer.conflict}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Dealers (Local): total ${dealer.total}, active ${dealer.notDeleted}, pending ${dealer.pending}, synced ${dealer.synced}, conflict ${dealer.conflict}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Firebase counts: customers ${forensic.firebaseCustomers}, dealers ${forensic.firebaseDealers}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Outbox: total ${forensic.outboxTotal}, customers ${forensic.outboxCustomers}, dealers ${forensic.outboxDealers}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Outbox permanent failures: ${forensic.outboxPermanentFailures}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: forensic.outboxPermanentFailures > 0
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
              fontWeight: forensic.outboxPermanentFailures > 0
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Unresolved conflicts: ${forensic.unresolvedConflicts}',
            style: theme.textTheme.bodyMedium,
          ),
          if (forensic.lastSyncAttempt != null) ...[
            const SizedBox(height: 8),
            Text('Last Sync Attempt', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('yyyy-MM-dd HH:mm:ss').format(forensic.lastSyncAttempt!.timestamp)} | '
              '${forensic.lastSyncAttempt!.entityType}/${forensic.lastSyncAttempt!.operation} | '
              '${forensic.lastSyncAttempt!.success ? 'SUCCESS' : 'FAILED'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: forensic.lastSyncAttempt!.success
                    ? AppColors.success
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            if ((forensic.lastSyncAttempt!.errorMessage ?? '').isNotEmpty)
              Text(
                forensic.lastSyncAttempt!.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
          const SizedBox(height: 8),
          Text(
            forensic.customers100ExistsLocally
                ? 'Check: Local physical customers >= 100'
                : 'Check: Local physical customers < 100',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: forensic.customers100ExistsLocally
                  ? AppColors.success
                  : theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (forensic.moduleAudits.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Module Pending Status', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            ...forensic.moduleAudits
                .where((m) => m.local.pending > 0 || m.outboxCount > 0)
                .take(12)
                .map(
                  (m) => Text(
                    '${m.moduleKey}: pending ${m.local.pending}, outbox ${m.outboxCount}, conflicts ${m.local.conflict}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: m.local.pending > 0
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
          ],
          if (forensic.riskFlags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Risk Flags', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            ...forensic.riskFlags.take(8).map(
              (flag) => Text(
                flag,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (forensic.lastSyncTimestamps.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Last Sync Timestamps', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            ...forensic.lastSyncTimestamps.entries.map(
              (e) => Text(
                '${e.key}: ${e.value}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
          if (forensic.recentFailures.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Recent Failures', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            ...forensic.recentFailures.take(5).map(
              (f) => Text(
                '[${f.entityType}/${f.operation}] ${f.message}',
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartsRow(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _buildEntityBreakdownChart(theme)),
              const SizedBox(width: 24),
              Expanded(child: _buildSuccessFailureChart(theme)),
            ],
          );
        }
        return Column(
          children: [
            _buildEntityBreakdownChart(theme),
            const SizedBox(height: 24),
            _buildSuccessFailureChart(theme),
          ],
        );
      },
    );
  }

  Widget _buildEntityBreakdownChart(ThemeData theme) {
    final metrics = _summary['metrics'] as List<SyncMetricEntity>? ?? [];
    final entityCounts = <String, int>{};
    for (var m in metrics) {
      entityCounts[m.entityType] = (entityCounts[m.entityType] ?? 0) + 1;
    }

    final sortedItems = entityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topItems = sortedItems.take(5).toList();

    return AppCard(
      title: Text('Top Synced Entities', style: theme.textTheme.titleMedium),
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: Responsive.clamp(context, min: 200, max: 280, ratio: 0.3),
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < 0 || value.toInt() >= topItems.length) {
                      return const SizedBox.shrink();
                    }
                    final label = topItems[value.toInt()].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        label.length > 8 ? label.substring(0, 8) : label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(topItems.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: topItems[index].value.toDouble(),
                    color: theme.colorScheme.primary,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessFailureChart(ThemeData theme) {
    final success = _summary['successRate'] as double? ?? 0.0;
    final failure = 100.0 - success;
    final onPrimary = theme.colorScheme.onPrimary;

    return AppCard(
      title: Text('Success vs Failure', style: theme.textTheme.titleMedium),
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: Responsive.clamp(context, min: 200, max: 280, ratio: 0.3),
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: AppColors.success,
                value: success,
                title: '${success.round()}%',
                radius: 60,
                titleStyle: theme.textTheme.labelLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PieChartSectionData(
                color: theme.colorScheme.error,
                value: failure,
                title: failure > 0 ? '${failure.round()}%' : '',
                radius: 60,
                titleStyle: theme.textTheme.labelLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFailures(ThemeData theme) {
    return AppCard(
      title: Text('Recent Failures', style: theme.textTheme.titleMedium),
      padding: EdgeInsets.zero,
      child: _recentFailures.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No recent failures detected ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentFailures.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                final failure = _recentFailures[index];
                return ListTile(
                  leading: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    failure.entityType,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    failure.errorMessage ?? 'Unknown error',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Text(
                    DateFormat('HH:mm').format(failure.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
    );
  }
}


