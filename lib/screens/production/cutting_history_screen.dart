import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/cutting_types.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/cutting_batch_service.dart';
import '../../utils/unit_scope_utils.dart';
import '../../utils/access_guard.dart';
import 'package:intl/intl.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class CuttingHistoryScreen extends StatefulWidget {
  const CuttingHistoryScreen({super.key});

  @override
  State<CuttingHistoryScreen> createState() => _CuttingHistoryScreenState();
}

class _CuttingHistoryScreenState extends State<CuttingHistoryScreen> {
  static const int _historyPageSize = 50;

  late final CuttingBatchService _cuttingService;

  @override
  void initState() {
    super.initState();
    AccessGuard.checkProductionAccess(context);
    _cuttingService = context.read<CuttingBatchService>();
    _checkAccess();
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.role.canAccessProduction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied: Production operations restricted to authorized roles')),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    _loadHistory();
  }

  List<CuttingBatch> _batches = [];
  bool _isLoading = true;
  DateTime? _selectedDate;
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});
  bool _isScopeFallbackMode = false;
  bool _isSupervisorCompatibilityMode = false;
  int _historyLimit = _historyPageSize;
  bool _hasMoreRecentData = false;

  String get _unitScopeDisplayLabel {
    if (_isSupervisorCompatibilityMode) {
      return 'All Units (Compatibility Mode)';
    }
    return _unitScope.label;
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().state.user;
      _unitScope = resolveUserUnitScope(user);
      final hasNoScopeTokens = !_unitScope.canViewAll && _unitScope.keys.isEmpty;
      final isSupervisorCompatibilityMode =
          hasNoScopeTokens && user?.role == UserRole.productionSupervisor;
      final isScopeFallbackMode =
          hasNoScopeTokens && !isSupervisorCompatibilityMode;
      final effectiveScope = hasNoScopeTokens ? null : _unitScope;

      late final List<CuttingBatch> batches;
      if (_selectedDate != null) {
        // Query-level date filtering avoids false empty state caused by
        // filtering only the latest N records.
        final selected = _selectedDate!;
        final start = DateTime(selected.year, selected.month, selected.day);
        final end = DateTime(selected.year, selected.month, selected.day, 23, 59, 59, 999);
        batches = await _cuttingService.getCuttingBatchesByDateRange(
          startDate: start,
          endDate: end,
          unitScope: effectiveScope,
        );
      } else {
        // Keep recent history pagination behavior for performance.
        batches = await _cuttingService.getCuttingBatches(
          limit: _historyLimit,
          unitScope: effectiveScope,
        );
      }
      batches.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _batches = batches;
          _hasMoreRecentData =
              _selectedDate == null && batches.length >= _historyLimit;
          _isScopeFallbackMode = isScopeFallbackMode;
          _isSupervisorCompatibilityMode = isSupervisorCompatibilityMode;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading history: $e')));
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadHistory();
    }
  }

  Future<void> _loadMoreRecentHistory() async {
    if (_selectedDate != null || _isLoading) return;
    setState(() => _historyLimit += _historyPageSize);
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MasterScreenHeader(
                    title: 'Cutting History',
                    subtitle: 'Logs of material cutting & wastage',
                    helperText:
                        'Track weight loss during the soap cutting process.',
                    color: AppColors.warning,
                    icon: Icons.content_cut,
                    emoji: '',
                  ),
                  const SizedBox(height: 24),
                  if (_isScopeFallbackMode) ...[
                    _buildScopeFallbackBanner(),
                    const SizedBox(height: 12),
                  ],
                  // Filter Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Unit Scope: $_unitScopeDisplayLabel',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedDate == null
                                        ? 'Select Date'
                                        : DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_selectedDate!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                                _historyLimit = _historyPageSize;
                              });
                              _loadHistory();
                            },
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            tooltip: 'Clear Filter',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // History List
                  if (_batches.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const Text('', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'No batches found',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _batches.length,
                          itemBuilder: (context, index) {
                            final batch = _batches[index];
                            return _buildBatchCard(batch);
                          },
                        ),
                        if (_selectedDate == null && _hasMoreRecentData) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _loadMoreRecentHistory,
                            icon: const Icon(Icons.expand_more_rounded),
                            label: const Text('Load more recent batches'),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildBatchCard(CuttingBatch batch) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateFormatted = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(batch.createdAt);
    final statusColor = batch.stage == CuttingStage.completed
        ? AppColors.success
        : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Batch ID and Date
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BATCH #${batch.batchNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormatted.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Operator: ${batch.operatorName}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    batch.stage.value.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEMI-FINISHED INPUT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        batch.semiFinishedProductName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${batch.boxesCount} BOX • ${batch.totalBatchWeightKg.toStringAsFixed(2)} KG',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FINISHED GOOD OUTPUT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        batch.finishedGoodName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${batch.unitsProduced} PCS • ${batch.totalFinishedWeightKg.toStringAsFixed(2)} KG',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Metrics Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.1,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildMetricBox(
                  'WASTAGE',
                  '${batch.cuttingWasteKg.toStringAsFixed(2)} KG',
                  AppColors.error.withValues(alpha: 0.1),
                  AppColors.error,
                ),
                const SizedBox(width: 8),
                _buildMetricBox(
                  'WEIGHT BALANCE',
                  '${batch.weightDifferencePercent.toStringAsFixed(2)}%',
                  AppColors.info.withValues(alpha: 0.1),
                  AppColors.info,
                ),
                const SizedBox(width: 8),
                _buildMetricBox(
                  'WEIGHT CHECK',
                  'Std: ${batch.standardWeightGm.toStringAsFixed(0)}g\nAct: ${batch.actualAvgWeightGm.toStringAsFixed(0)}g',
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.primary,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '${batch.shift.name.toUpperCase()} - ${batch.departmentName.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (batch.packagingConsumptions != null && batch.packagingConsumptions!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Packaging Used:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...batch.packagingConsumptions!.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 22, bottom: 4),
                    child: Text(
                      '• ${item['materialName'] ?? 'Unknown'}: ${item['quantity']} ${item['unit'] ?? ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          if (batch.wasteRemark != null && batch.wasteRemark!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Remarks: ${batch.wasteRemark}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
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

  Widget _buildMetricBox(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: textColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}



