import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/bhatti_service.dart';
import '../../widgets/ui/offline_banner.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/ui/unified_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../utils/mobile_header_typography.dart';
import '../../widgets/reports/report_export_actions.dart';

int bhattiDashboardKpiColumnsForWidth(double width) {
  return width >= 900 ? 4 : 2;
}

double bhattiDashboardKpiAspectRatioForWidth(double width) {
  if (width < 360) return 1.6;
  if (width < 600) return 1.7;
  if (width < 900) return 1.8;
  return 1.9;
}

class BhattiDashboardScreen extends StatefulWidget {
  const BhattiDashboardScreen({super.key});

  @override
  State<BhattiDashboardScreen> createState() => _BhattiDashboardScreenState();
}

class _BhattiDashboardScreenState extends State<BhattiDashboardScreen>
    with ReportPdfMixin<BhattiDashboardScreen> {
  late final BhattiService _bhattiService;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  bool _isOnline = true;
  List<BhattiBatch> _recentBatches = [];
  int _todayBatchesCount = 0;
  int _totalOutputBox = 0;
  double _todayWastageQty = 0.0;

  @override
  void initState() {
    super.initState();
    _bhattiService = context.read<BhattiService>();
    _checkAccess();
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.role.canAccessBhatti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Access Denied: Bhatti operations restricted to authorized roles',
              ),
            ),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  Future<void> _loadData({bool forcePageLoader = false}) async {
    if (!mounted || _isRefreshing) return;
    setState(() {
      final showFullLoader = forcePageLoader && !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
    });
    try {
      final batches = await _bhattiService.getBhattiBatches();
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      final todayBatches = batches.where((b) {
        final createdAt = DateTime.tryParse(b.createdAt);
        if (createdAt == null) return false;
        return !createdAt.isBefore(startOfToday);
      }).toList();

      double todayWastageQty = 0.0;
      try {
        final logs = await _bhattiService.getWastageLogs(
          startDate: startOfToday,
          endDate: now,
        );
        todayWastageQty = logs.fold(0.0, (sum, item) {
          final qty = item['quantity'];
          if (qty is num) return sum + qty.toDouble();
          return sum;
        });
      } catch (_) {
        // Keep dashboard usable even when wastage stream is unavailable.
      }

      if (mounted) {
        setState(() {
          _recentBatches = batches.take(5).toList();
          _todayBatchesCount = todayBatches.fold(
            0,
            (sum, b) => sum + b.batchCount,
          );
          _totalOutputBox = todayBatches.fold(
            0,
            (sum, b) => sum + b.outputBoxes,
          );
          _todayWastageQty = todayWastageQty;

          // Avg Fuel (If available in meta or hardcoded for now until fuel tracking is added)
          // For now, let's keep it 0 or calculate if possible.

          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
          _isOnline = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
          _isOnline = false;
        });
      }
    }
  }

  void _openBhattiSupervisorLogs() {
    context.pushNamed('bhatti_daily_logs');
  }

  @override
  bool get hasExportData => _recentBatches.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Created At',
      'Batch Number',
      'Bhatti',
      'Product',
      'Batch Count',
      'Output Boxes',
      'Status',
      'Supervisor',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    final dateFormatter = DateFormat('dd-MMM-yyyy HH:mm');
    return _recentBatches
        .map(
          (batch) => [
            dateFormatter.format(
              DateTime.tryParse(batch.createdAt) ?? DateTime.now(),
            ),
            batch.batchNumber,
            batch.bhattiName,
            batch.targetProductName,
            batch.batchCount,
            batch.outputBoxes,
            batch.status.toUpperCase(),
            batch.supervisorName,
          ],
        )
        .toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    final avgYield = _todayBatchesCount > 0
        ? (_totalOutputBox / _todayBatchesCount)
        : 0.0;
    return {
      'Scope': 'Today Overview',
      'Today Batches': _todayBatchesCount.toString(),
      'Total Output (Boxes)': _totalOutputBox.toString(),
      'Wastage (Kg)': _todayWastageQty.toStringAsFixed(1),
      'Avg Yield (B/B)': avgYield.toStringAsFixed(1),
      'Recent Batches': _recentBatches.length.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().state.user;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final useMobileTypography = useMobileHeaderTypographyForWidth(width);

    return Scaffold(
      body: (_isLoading && !_hasLoadedOnce)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OfflineBanner(isOffline: !_isOnline),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bhatti Operations',
                                      style: TextStyle(
                                        fontSize: useMobileTypography
                                            ? mobileHeaderTitleFontSize
                                            : 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: useMobileTypography
                                            ? -0.2
                                            : 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Welcome back, ${user?.name}',
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReportExportActions(
                              isLoading: isExporting,
                              onExport: () =>
                                  exportReport('Bhatti Overview Report'),
                              onPrint: () =>
                                  printReport('Bhatti Overview Report'),
                              onRefresh: _loadData,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 20 : 32),
                    _buildKPIGrid(),
                    SizedBox(height: isMobile ? 20 : 32),
                    _buildRecentBatches(),
                    SizedBox(height: isMobile ? 80 : 32),
                  ],
                ),
              ),
            ),
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/dashboard/bhatti/cooking');
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text(
                'NEW BATCH',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.black,
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildKPIGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = bhattiDashboardKpiColumnsForWidth(width);
        final childAspectRatio = bhattiDashboardKpiAspectRatioForWidth(width);
        final spacing = width < 600 ? 10.0 : 12.0;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _openBhattiSupervisorLogs();
              },
              child: KPICard(
                title: 'Today\'s Batches',
                value: '$_todayBatchesCount',
                icon: Icons.local_fire_department,
                color: AppColors.warning,
                dense: true,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _openBhattiSupervisorLogs();
              },
              child: KPICard(
                title: 'Total Output',
                value: '$_totalOutputBox',
                icon: Icons.inventory_2,
                color: AppColors.success,
                dense: true,
              ),
            ),
            KPICard(
              title: 'Wastage',
              value: '${_todayWastageQty.toStringAsFixed(1)} kg',
              icon: Icons.recycling,
              color: AppColors.error,
              dense: true,
            ),
            KPICard(
              title: 'Avg Yield',
              value: _todayBatchesCount > 0
                  ? '${(_totalOutputBox / _todayBatchesCount).toStringAsFixed(1)} B/B'
                  : '0.0 B/B',
              icon: Icons.auto_graph,
              color: AppColors.info,
              dense: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentBatches() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Batches',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_recentBatches.isEmpty)
          const Center(
            child: Column(
              children: [
                SizedBox(height: 32),
                Text('', style: TextStyle(fontSize: 48)),
                SizedBox(height: 16),
                Text('No batches found'),
              ],
            ),
          )
        else
          ..._recentBatches.map(
            (batch) => UnifiedCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.zero,
              child: ListTile(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/dashboard/bhatti/batch/${batch.id}/edit');
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                minVerticalPadding: 12,
                title: Text(
                  batch.targetProductName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Batch #${batch.batchNumber}  ${batch.bhattiName}',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: batch.status == 'cooking'
                        ? AppColors.warning
                        : AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    batch.status.toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
