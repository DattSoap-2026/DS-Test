import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/tank_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../data/repositories/tank_repository.dart';
import './widgets/tank_adjust_dialog.dart';
import './widgets/tank_fill_dialog.dart';
import './widgets/tank_transfer_dialog.dart';
import 'dialogs/add_storage_unit_dialog.dart';
import 'widgets/storage_themes.dart';
import 'widgets/tank_visualization.dart';
import 'widgets/godown_visualization.dart';
import '../../utils/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/custom_button.dart';
import '../../utils/storage_unit_helper.dart';

class TankDetailsScreen extends StatefulWidget {
  final String tankId;
  const TankDetailsScreen({super.key, required this.tankId});

  @override
  State<TankDetailsScreen> createState() => _TankDetailsScreenState();
}

class _TankDetailsScreenState extends State<TankDetailsScreen> {
  late final TankService _tankService;
  Tank? _tank;
  List<TankTransaction> _transactions = [];
  List<TankLot> _activeLots = [];
  bool _isLoading = true;

  String get _storageUnit => StorageUnitHelper.tankDisplayUnit(_tank?.unit);

  @override
  void initState() {
    super.initState();
    _tankService = context.read<TankService>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final tank = await _tankService.getTankById(widget.tankId);
      final transactions = await _tankService.getTankTransactions(
        widget.tankId,
        limitCount: 50,
      );
      final lots = await _tankService.getActiveLots(widget.tankId);

      if (mounted) {
        setState(() {
          _tank = tank;
          _transactions = transactions;
          _activeLots = lots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_tank == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Tank not found')),
      );
    }

    final theme = getThemeForDepartment(_tank!.department);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: _tank!.name,
            subtitle: 'Detailed inventory & transaction logs',
            icon: theme.icon,
            color: theme.primary,
            onBack: () => Navigator.pop(context),
            actions: [
              if (!Responsive.isMobile(context)) ...[
                CustomButton(
                  label: 'EDIT',
                  icon: Icons.edit_rounded,
                  onPressed: _showEditDialog,
                  variant: ButtonVariant.outline,
                  isDense: true,
                ),
                const SizedBox(width: 8),
                CustomButton(
                  label: 'TRANSFER',
                  icon: Icons.swap_horiz_rounded,
                  onPressed: _showTransferDialog,
                  variant: ButtonVariant.outline,
                  isDense: true,
                ),
                const SizedBox(width: 8),
                CustomButton(
                  label: 'REFILL',
                  icon: Icons.add_business_rounded,
                  onPressed: _showFillDialog,
                  variant: ButtonVariant.outline,
                  isDense: true,
                ),
                const SizedBox(width: 8),
                CustomButton(
                  label: 'ADJUST',
                  icon: Icons.edit_note_rounded,
                  onPressed: _showAdjustDialog,
                  variant: ButtonVariant.primary,
                  isDense: true,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Data',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                ),
              ],
            ],
          ),
          Expanded(
            child: Padding(
              padding: Responsive.screenPadding(context),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildVisualSection(theme)),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildHistorySection(theme)),
                      ],
                    )
                  : ListView(
                      children: [
                        _buildVisualSection(theme),
                        const SizedBox(height: 24),
                        _buildHistorySection(theme, isScrollable: false),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSection(StorageTheme theme) {
    final themeData = Theme.of(context);
    final isTank = _tank!.type == 'tank';
    return UnifiedCard(
      padding: const EdgeInsets.all(24),
      // Allow vertical scrolling when card height is bounded to avoid overflow.
      disableScroll: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVisualHeader(),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: Responsive.clamp(
                context,
                min: 220,
                max: 320,
                ratio: 0.24,
              ),
              maxHeight: Responsive.clamp(
                context,
                min: 240,
                max: 360,
                ratio: 0.3,
              ),
            ),
            child: Center(
              child: isTank
                  ? TankVisualization(
                      fillLevel: _tank!.fillLevel,
                      liquidColor: theme.liquidColor,
                      label: StorageUnitHelper.tankDisplayQuantity(
                        _tank!.currentStock,
                        storageUnit: _tank!.unit,
                      ).toStringAsFixed(2),
                      unitLabel: _storageUnit,
                    )
                  : GodownVisualization(
                      usagePercent: (_tank!.maxBags ?? 100) > 0
                          ? ((_tank!.bags ?? 0) /
                                (_tank!.maxBags ?? 100) *
                                100.0)
                          : 0.0,
                      bagColor: theme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 32),
          _buildVisualFooter(),
          if (_activeLots.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'ACTIVE LOTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: themeData.colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: Responsive.clamp(
                  context,
                  min: 96,
                  max: 120,
                  ratio: 0.12,
                ),
                maxHeight: Responsive.clamp(
                  context,
                  min: 110,
                  max: 150,
                  ratio: 0.14,
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _activeLots.length,
                itemBuilder: (context, index) {
                  final lot = _activeLots[index];
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.clamp(
                        context,
                        min: 180,
                        max: 260,
                        ratio: 0.26,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeData.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lot.supplierName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${StorageUnitHelper.tankDisplayQuantity(lot.quantity, storageUnit: _tank?.unit).toStringAsFixed(2)} $_storageUnit',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd').format(lot.receivedDate),
                                style: TextStyle(
                                  color: themeData.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ... (keeping helper methods same) ...

  Widget _buildVisualHeader() {
    return Row(
      children: [
        _metricBox(
          'STOCK',
          StorageUnitHelper.tankDisplayQuantity(
            _tank!.currentStock,
            storageUnit: _tank!.unit,
          ).toStringAsFixed(2),
          _storageUnit,
        ),
        const SizedBox(width: 16),
        _metricBox(
          'CAPACITY',
          StorageUnitHelper.tankDisplayQuantity(
            _tank!.capacity,
            storageUnit: _tank!.unit,
          ).toStringAsFixed(2),
          _storageUnit,
        ),
        const SizedBox(width: 16),
        _metricBox(
          'FILL',
          '${_tank!.fillLevel.toStringAsFixed(0)}%',
          'LEVEL',
          isGreen: true,
        ),
      ],
    );
  }

  Widget _metricBox(
    String label,
    String value,
    String unit, {
    bool isGreen = false,
  }) {
    final themeData = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeData.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: themeData.colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isGreen
                        ? AppColors.success
                        : themeData.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: themeData.colorScheme.onSurface.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _footerInfo('PRESSURE', '2.4 bar', Icons.bolt),
            _footerInfo(
              'MIN LEVEL',
              '${_tank!.minStockLevel.toStringAsFixed(2)} $_storageUnit',
              Icons.waves_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Coming soon: tank alerts configuration.',
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.notifications_outlined),
                  label: const Text('Set Alerts'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Tooltip(
                message: 'Coming soon: detailed tank report view.',
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Full Report'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footerInfo(String label, String value, IconData icon) {
    final themeData = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeData.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeData.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: themeData.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: themeData.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeData.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(StorageTheme theme, {bool isScrollable = false}) {
    return UnifiedCard(
      disableScroll:
          isScrollable, // Disable internal scroll if we want Expanded logic
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _tank!.type == 'godown'
                          ? 'Purchase History'
                          : 'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_transactions.isEmpty)
            isScrollable
                ? Expanded(child: Center(child: _buildEmptyHistory(context)))
                : SizedBox(
                    height: 200,
                    child: Center(child: _buildEmptyHistory(context)),
                  )
          else
            isScrollable
                ? Expanded(child: _buildTransactionList(isScrollable: true))
                : _buildTransactionList(isScrollable: false),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'No history available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList({required bool isScrollable}) {
    return ListView.separated(
      shrinkWrap: !isScrollable,
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final isAdd =
            tx.type == 'fill' ||
            tx.type == 'transfer' ||
            (tx.type == 'adjustment' && tx.quantity > 0);
        final subtitleText =
            ((tx.type == 'fill' || tx.type == 'transfer') &&
                (tx.supplierName?.trim().isNotEmpty ?? false))
            ? tx.supplierName!
            : tx.operatorName;
        final quantityText = tx.type == 'consumption'
            ? '${isAdd ? '+' : '-'}${StorageUnitHelper.tankDisplayQuantityToKg(tx.quantity.abs()).toStringAsFixed(1)} ${StorageUnitHelper.kgUnit}'
            : '${isAdd ? '+' : '-'}${tx.quantity.abs().toStringAsFixed(1)} $_storageUnit';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isAdd ? AppColors.success : AppColors.warning).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isAdd ? Icons.add_chart_rounded : Icons.show_chart_rounded,
              size: 20,
              color: isAdd ? AppColors.success : AppColors.warning,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.referenceType.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    quantityText,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isAdd ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    _formatDateSafe(tx.timestamp, pattern: 'dd MMM, hh:mm a'),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdjustDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TankAdjustDialog(
        tank: _tank!,
        onAdjust: (newStock, reason) async {
          final user = context.read<AuthProvider>().state.user;
          await _tankService.adjustTankStock(
            tankId: _tank!.id,
            newStock: newStock,
            reason: reason,
            operatorId: user?.id ?? 'unknown',
            operatorName: user?.name ?? 'Unknown',
          );
          _loadData();
        },
      ),
    );
  }

  void _showFillDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TankFillDialog(
        tank: _tank!,
        onFill: (qty, supplierId, supplierName) async {
          final user = context.read<AuthProvider>().state.user;
          await _tankService.fillTank(
            tankId: _tank!.id,
            quantity: qty,
            operatorId: user?.id ?? 'unknown',
            operatorName: user?.name ?? 'Unknown',
            supplierId: supplierId,
            supplierName: supplierName,
            referenceId: 'manual',
          );
          _loadData();
        },
      ),
    );
  }

  void _showTransferDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TankTransferDialog(
        tank: _tank!,
        onTransfer: (productId, qty) async {
          final user = context.read<AuthProvider>().state.user;
          await _tankService.transferToTank(
            sourceProductId: productId,
            destinationTankId: _tank!.id,
            quantity: qty,
            operatorId: user?.id ?? 'unknown',
            operatorName: user?.name ?? 'Unknown',
            unit: _tank!.unit,
          );
          _loadData();
        },
      ),
    );
  }

  void _showEditDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddStorageUnitDialog(
        tankRepo: context.read<TankRepository>(),
        initialTank: _tank,
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }
}
