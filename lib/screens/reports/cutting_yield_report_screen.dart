import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/types/cutting_types.dart';
import '../../models/types/product_types.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/cutting_batch_service.dart';
import '../../services/products_service.dart';
import '../../utils/unit_scope_utils.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class CuttingYieldReportScreen extends StatefulWidget {
  const CuttingYieldReportScreen({super.key});

  @override
  State<CuttingYieldReportScreen> createState() =>
      _CuttingYieldReportScreenState();
}

class _CuttingYieldReportScreenState extends State<CuttingYieldReportScreen>
    with
        SingleTickerProviderStateMixin,
        ReportPdfMixin<CuttingYieldReportScreen> {
  late final CuttingBatchService _cuttingService;

  @override
  void initState() {
    super.initState();
    _cuttingService = context.read<CuttingBatchService>();
    _productsService = context.read<ProductsService>();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadInitialData();
  }

  late final ProductsService _productsService;

  late TabController _tabController;
  bool _isLoading = false;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  Product? _selectedProduct;
  List<Product> _finishedProducts = [];
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});
  bool _isScopeFallbackMode = false;
  bool _isSupervisorCompatibilityMode = false;
  bool _shouldUseCompatibilityScopeAll = false;

  List<CuttingYieldReport> _yieldReports = [];
  List<CuttingBatch> _allBatches = [];

  UserUnitScope? get _effectiveScope =>
      _shouldUseCompatibilityScopeAll ? null : _unitScope;

  String get _unitScopeDisplayLabel {
    if (_isSupervisorCompatibilityMode) {
      return 'All Units (Compatibility Mode)';
    }
    return _unitScope.label;
  }

  bool _matchesProductScope(
    Product product, {
    UserUnitScope? scope,
  }) {
    if (scope == null) return true;
    return matchesUnitScope(
      scope: scope,
      tokens: [product.departmentId, ...product.allowedDepartmentIds],
      defaultIfNoScopeTokens: false,
    );
  }

  bool _isFinishedProduct(Product product) {
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    return product.type == ProductTypeEnum.finished ||
        normalizedType == ProductType.finishedGood.value;
  }

  bool _matchesBatchScope(
    CuttingBatch batch, {
    UserUnitScope? scope,
  }) {
    if (scope == null) return true;
    return matchesUnitScope(
      scope: scope,
      tokens: [
        batch.departmentId,
        batch.departmentName,
        batch.semiFinishedProductName,
        batch.finishedGoodName,
      ],
      defaultIfNoScopeTokens: false,
    );
  }

  CuttingYieldReport? _buildYieldReport({
    required Product product,
    required List<CuttingBatch> batches,
  }) {
    if (batches.isEmpty) return null;

    final totalInputKg = batches.fold(
      0.0,
      (sum, b) => sum + b.totalBatchWeightKg,
    );
    final totalUnitsProduced = batches.fold(
      0,
      (sum, b) => sum + b.unitsProduced,
    );
    final totalWasteKg = batches.fold(0.0, (sum, b) => sum + b.cuttingWasteKg);
    final totalOutputKg = batches.fold(0.0, (sum, b) => sum + b.outputWeightKg);
    final yieldPercent = totalInputKg > 0
        ? (totalOutputKg / totalInputKg) * 100
        : 0.0;
    final avgWeightDiff =
        batches.fold(0.0, (sum, b) => sum + b.weightDifferencePercent) /
        batches.length;

    return CuttingYieldReport(
      productName: product.name,
      productId: product.id,
      batchCount: batches.length,
      totalInputKg: totalInputKg,
      totalUnitsProduced: totalUnitsProduced,
      totalWasteKg: totalWasteKg,
      yieldPercent: yieldPercent,
      avgWeightDifference: avgWeightDiff,
      batches: batches,
    );
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = context.read<AuthProvider>().currentUser;
      _unitScope = resolveUserUnitScope(currentUser);
      final hasNoScopeTokens = !_unitScope.canViewAll && _unitScope.keys.isEmpty;
      final isSupervisorCompatibilityMode =
          hasNoScopeTokens && currentUser?.role == UserRole.productionSupervisor;
      final effectiveScope = hasNoScopeTokens ? null : _unitScope;
      final showScopeFallbackBanner =
          hasNoScopeTokens && !isSupervisorCompatibilityMode;
      final products = await _productsService.getProducts();
      final finished = products
          .where(_isFinishedProduct)
          .where((product) => _matchesProductScope(product, scope: effectiveScope))
          .toList();

      if (mounted) {
        setState(() {
          _finishedProducts = finished;
          _selectedProduct = finished.isNotEmpty ? finished.first : null;
          _isScopeFallbackMode = showScopeFallbackBanner;
          _isSupervisorCompatibilityMode = isSupervisorCompatibilityMode;
          _shouldUseCompatibilityScopeAll = hasNoScopeTokens;
          _isLoading = false;
        });
      }

      if (finished.isNotEmpty) {
        await _loadYieldData(finished.first);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load data: $e');
      }
    }
  }

  Future<void> _loadYieldData(Product product) async {
    setState(() => _isLoading = true);
    try {
      final batches = await _cuttingService.getCuttingBatchesByDateRange(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
        productId: product.id,
        unitScope: _effectiveScope,
      );
      final scopedBatches = batches
          .where((batch) => _matchesBatchScope(batch, scope: _effectiveScope))
          .toList();
      final report = _buildYieldReport(
        product: product,
        batches: scopedBatches,
      );

      if (mounted) {
        setState(() {
          _selectedProduct = product;
          _yieldReports = report != null ? [report] : [];
          _allBatches = scopedBatches;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load yield data: $e');
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await ResponsiveDatePickers.pickDateRange(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      if (_selectedProduct != null) {
        await _loadYieldData(_selectedProduct!);
      }
    }
  }

  void _showError(String message) {
    AppToast.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutting Yield Report'),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Cutting Yield Report'),
            onPrint: () => printReport('Cutting Yield Report'),
          ),
        ],
        bottom: ThemedTabBar(
          controller: _tabController,
          unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Batch Details'),
          ],
        ),
      ),
      body: _isLoading && _finishedProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_isScopeFallbackMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildScopeFallbackBanner(),
                  ),
                // Filters
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unit Scope: $_unitScopeDisplayLabel',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButton<Product>(
                              isExpanded: true,
                              value: _selectedProduct,
                              hint: const Text('Select Product'),
                              items: _finishedProducts
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (product) {
                                if (product != null) {
                                  _loadYieldData(product);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDateRange,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('dd-MMM').format(_dateRange.start)} - ${DateFormat('dd-MMM').format(_dateRange.end)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ReportDateRangeButtons(
                        value: _dateRange,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onChanged: (range) async {
                          setState(() => _dateRange = range);
                          if (_selectedProduct != null) {
                            await _loadYieldData(_selectedProduct!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Summary Tab
                      _buildSummaryTab(),
                      // Batch Details Tab
                      _buildBatchDetailsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildScopeFallbackBanner() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No unit assigned. Contact admin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (_yieldReports.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No data for selected period',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    final report = _yieldReports.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width < 520 ? 1 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              KPICard(
                title: 'Total Batches',
                value: report.batchCount.toString(),
                icon: Icons.production_quantity_limits,
                color: AppColors.info,
              ),
              KPICard(
                title: 'Total Input',
                value: '${report.totalInputKg.toStringAsFixed(1)} kg',
                icon: Icons.input,
                color: AppColors.warning,
              ),
              KPICard(
                title: 'Finished Units',
                value: report.totalUnitsProduced.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
              KPICard(
                title: 'Total Waste',
                value: '${report.totalWasteKg.toStringAsFixed(1)} kg',
                icon: Icons.delete,
                color: AppColors.error,
              ),
              KPICard(
                title: 'Yield %',
                value: '${report.yieldPercent.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: AppColors.info,
              ),
              KPICard(
                title: 'Avg Weight Diff',
                value: '${report.avgWeightDifference.toStringAsFixed(2)}%',
                icon: Icons.scale,
                color: AppColors.lightPrimary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Batch-wise Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batch-wise Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      columns: [
                        DataColumn(label: Text('Batch #')),
                        DataColumn(label: Text('Input (kg)'), numeric: true),
                        DataColumn(label: Text('Output (kg)'), numeric: true),
                        DataColumn(label: Text('Waste (kg)'), numeric: true),
                        DataColumn(label: Text('Yield %'), numeric: true),
                      ],
                      rows: report.batches
                          .map(
                            (batch) => DataRow(
                              cells: [
                                DataCell(Text(batch.batchNumber)),
                                DataCell(
                                  Text(
                                    batch.totalBatchWeightKg.toStringAsFixed(1),
                                  ),
                                ),
                                DataCell(
                                  Text(batch.outputWeightKg.toStringAsFixed(2)),
                                ),
                                DataCell(
                                  Text(batch.cuttingWasteKg.toStringAsFixed(1)),
                                ),
                                DataCell(
                                  Text(
                                    '${((batch.outputWeightKg / batch.totalBatchWeightKg) * 100).toStringAsFixed(1)}%',
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchDetailsTab() {
    if (_allBatches.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No batches found',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allBatches.length,
      itemBuilder: (context, index) {
        final batch = _allBatches[index];
        return _buildBatchCard(batch);
      },
    );
  }

  Widget _buildBatchCard(CuttingBatch batch) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  batch.batchNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    batch.stage.value,
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Date: ${batch.date}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Shift: ${batch.shift.displayName}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width < 520
                  ? 1
                  : (MediaQuery.sizeOf(context).width < 760 ? 2 : 3),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: MediaQuery.sizeOf(context).width < 520
                  ? 2.0
                  : 1.5,
              children: [
                _buildDataPoint(
                  'Input',
                  '${batch.totalBatchWeightKg.toStringAsFixed(1)} kg',
                ),
                _buildDataPoint('Output', '${batch.unitsProduced} units'),
                _buildDataPoint(
                  'Waste',
                  '${batch.cuttingWasteKg.toStringAsFixed(1)} kg',
                ),
                _buildDataPoint(
                  'Weight Diff',
                  '${batch.weightDifferenceKg.toStringAsFixed(2)} kg',
                ),
                _buildDataPoint('Operator', batch.operatorName),
                _buildDataPoint(
                  'Yield %',
                  '${((batch.outputWeightKg / batch.totalBatchWeightKg) * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPoint(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get hasExportData => _allBatches.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return ['Batch No', 'Input', 'Output', 'Waste', 'Yield %'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _allBatches.map((batch) {
      final yieldPercent = batch.totalBatchWeightKg > 0
          ? (batch.outputWeightKg / batch.totalBatchWeightKg) * 100
          : 0.0;
      return [
        batch.batchNumber,
        '${batch.totalBatchWeightKg.toStringAsFixed(1)} kg',
        '${batch.outputWeightKg.toStringAsFixed(2)} kg',
        '${batch.cuttingWasteKg.toStringAsFixed(1)} kg',
        '${yieldPercent.toStringAsFixed(1)}%',
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    final summary = <String, String>{
      'Product': _selectedProduct?.name ?? 'All',
      'Date Range':
          '${DateFormat('dd-MMM-yyyy').format(_dateRange.start)} - ${DateFormat('dd-MMM-yyyy').format(_dateRange.end)}',
      'Unit Scope': _unitScopeDisplayLabel,
    };

    if (_yieldReports.isNotEmpty) {
      final report = _yieldReports.first;
      summary['Total Input'] = '${report.totalInputKg.toStringAsFixed(1)} kg';
      summary['Total Output'] = '${report.totalUnitsProduced} units';
      summary['Total Waste'] = '${report.totalWasteKg.toStringAsFixed(1)} kg';
      summary['Overall Yield'] = '${report.yieldPercent.toStringAsFixed(1)}%';
    }

    return summary;
  }
}
