import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/diesel_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/responsive.dart';

class FuelHistoryScreen extends StatefulWidget {
  const FuelHistoryScreen({super.key});

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final DieselService _dieselService;
  late final TabController _tabController;
  final ScrollController _logsHistoryScrollController = ScrollController();
  final ScrollController _purchasesHistoryScrollController = ScrollController();
  Timer? _logsAutoScrollTimer;
  Timer? _purchasesAutoScrollTimer;
  bool _isLogsScrollForward = true;
  bool _isPurchasesScrollForward = true;

  List<DieselLog> _allLogs = [];
  List<DieselLog> _filteredLogs = [];
  List<FuelPurchase> _purchases = [];

  String _selectedDriver = 'all';
  String _selectedMonthKey = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    _tabController = TabController(length: 2, vsync: this);
    _startMobileHistoryAutoScroll();
    _loadHistory();
  }

  @override
  void dispose() {
    _logsAutoScrollTimer?.cancel();
    _purchasesAutoScrollTimer?.cancel();
    _logsHistoryScrollController.dispose();
    _purchasesHistoryScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final results = await Future.wait([
        _dieselService.getDieselLogs(),
        _dieselService.getFuelPurchases(),
      ]);

      final logs = (results[0] as List<DieselLog>)
        ..sort((a, b) => b.fillDate.compareTo(a.fillDate));
      final purchases = results[1] as List<FuelPurchase>;

      if (mounted) {
        setState(() {
          _allLogs = logs;
          _purchases = purchases;
          _applyFilters();
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

  List<String> get _availableDrivers {
    final set =
        _allLogs
            .map((l) => l.driverName.trim())
            .where((d) => d.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['all', ...set];
  }

  List<String> get _availableMonthKeys {
    final set = <String>{};
    for (final log in _allLogs) {
      final date = DateTime.tryParse(log.fillDate);
      if (date != null) {
        set.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
      }
    }

    final keys = set.toList()..sort((a, b) => b.compareTo(a));
    return ['all', ...keys];
  }

  String _monthLabel(String key) {
    if (key == 'all') return 'All Months';
    final parts = key.split('-');
    if (parts.length != 2) return key;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return key;
    return DateFormat('MMM yyyy').format(DateTime(year, month));
  }

  void _applyFilters() {
    var logs = [..._allLogs];

    if (_selectedDriver != 'all') {
      logs = logs.where((l) => l.driverName == _selectedDriver).toList();
    }

    if (_selectedMonthKey != 'all') {
      final parts = _selectedMonthKey.split('-');
      final year = int.tryParse(parts.first);
      final month = parts.length > 1 ? int.tryParse(parts[1]) : null;
      if (year != null && month != null) {
        logs = logs.where((l) {
          final date = DateTime.tryParse(l.fillDate);
          return date != null && date.year == year && date.month == month;
        }).toList();
      }
    }

    final start = _startDate;
    if (start != null) {
      final startDateTime = DateTime(start.year, start.month, start.day);
      logs = logs.where((l) {
        final date = DateTime.tryParse(l.fillDate);
        return date != null &&
            (date.isAfter(startDateTime) ||
                date.isAtSameMomentAs(startDateTime));
      }).toList();
    }

    final end = _endDate;
    if (end != null) {
      final endDateTime = DateTime(end.year, end.month, end.day, 23, 59, 59);
      logs = logs.where((l) {
        final date = DateTime.tryParse(l.fillDate);
        return date != null &&
            (date.isBefore(endDateTime) || date.isAtSameMomentAs(endDateTime));
      }).toList();
    }

    _filteredLogs = logs;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? _endDate ?? now,
      firstDate: DateTime(2020),
      lastDate: _endDate ?? now,
    );

    if (picked == null) return;
    setState(() {
      _startDate = picked;
      _applyFilters();
    });
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final minDate = _startDate ?? DateTime(2020);
    final rawInitial = _endDate ?? _startDate ?? now;
    final initialDate = rawInitial.isBefore(minDate) ? minDate : rawInitial;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: now,
    );

    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _applyFilters();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDriver = 'all';
      _selectedMonthKey = 'all';
      _startDate = null;
      _endDate = null;
      _applyFilters();
    });
  }

  void _startMobileHistoryAutoScroll() {
    _logsAutoScrollTimer?.cancel();
    _purchasesAutoScrollTimer?.cancel();

    _logsAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _autoScrollHorizontally(
        controller: _logsHistoryScrollController,
        isForward: _isLogsScrollForward,
        onDirectionChange: (forward) => _isLogsScrollForward = forward,
      );
    });

    _purchasesAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _autoScrollHorizontally(
        controller: _purchasesHistoryScrollController,
        isForward: _isPurchasesScrollForward,
        onDirectionChange: (forward) => _isPurchasesScrollForward = forward,
      );
    });
  }

  void _autoScrollHorizontally({
    required ScrollController controller,
    required bool isForward,
    required ValueChanged<bool> onDirectionChange,
  }) {
    if (!mounted || !controller.hasClients) return;
    final max = controller.position.maxScrollExtent;
    if (max <= 0) return;

    const step = 220.0;
    var nextOffset = controller.offset + (isForward ? step : -step);

    if (nextOffset >= max) {
      nextOffset = max;
      onDirectionChange(false);
    } else if (nextOffset <= 0) {
      nextOffset = 0;
      onDirectionChange(true);
    }

    controller.animateTo(
      nextOffset,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
    );
  }

  void _scrollHistoryManually(ScrollController controller, bool scrollRight) {
    if (!controller.hasClients) return;
    const step = 260.0;
    final target = scrollRight
        ? (controller.offset + step)
        : (controller.offset - step);
    final bounded = target.clamp(0.0, controller.position.maxScrollExtent);
    controller.animateTo(
      bounded,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fuel History',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Diesel logs with driver, month and date filters',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _loadHistory();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      indicator: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.28,
                          ),
                        ),
                      ),
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      tabs: const [
                        SizedBox(height: 44, child: Tab(text: 'Diesel Logs')),
                        SizedBox(height: 44, child: Tab(text: 'Purchases')),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildDieselLogsTab(), _buildPurchasesTab()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDieselLogsTab() {
    final currency = NumberFormat.currency(symbol: 'Rs ', locale: 'en_IN');
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final totalLiters = _filteredLogs.fold<double>(0, (s, l) => s + l.liters);
    final totalCost = _filteredLogs.fold<double>(0, (s, l) => s + l.totalCost);
    final validMileages = _filteredLogs
        .map((l) => l.cycleEfficiency ?? l.mileage ?? 0)
        .where((m) => m > 0 && m < 50)
        .toList();
    final avgMileage = validMileages.isNotEmpty
        ? validMileages.reduce((a, b) => a + b) / validMileages.length
        : 0;
    final avgRate = totalLiters > 0 ? totalCost / totalLiters : 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset + 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterCard(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final cardWidth = isMobile
                  ? ((constraints.maxWidth - 12) / 2).clamp(120.0, 260.0)
                  : 190.0;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _kpiCard(
                    'Total Logs',
                    '${_filteredLogs.length}',
                    Icons.receipt,
                    width: cardWidth,
                  ),
                  _kpiCard(
                    'Total Liters',
                    '${totalLiters.toStringAsFixed(1)} L',
                    Icons.local_gas_station,
                    width: cardWidth,
                  ),
                  _kpiCard(
                    'Total Cost',
                    currency.format(totalCost),
                    Icons.payments,
                    width: cardWidth,
                  ),
                  _kpiCard(
                    'Avg Mileage',
                    '${avgMileage.toStringAsFixed(2)} km/L',
                    Icons.speed_rounded,
                    width: cardWidth,
                  ),
                  _kpiCard(
                    'Avg Cost/L',
                    'Rs ${avgRate.toStringAsFixed(2)}',
                    Icons.trending_up_rounded,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _buildLogsTable(currency),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            final useSingleColumn = isMobile && constraints.maxWidth < 360;
            const fieldGap = 12.0;
            final mobileFieldWidth = useSingleColumn
                ? constraints.maxWidth
                : ((constraints.maxWidth - fieldGap) / 2).clamp(
                    120.0,
                    constraints.maxWidth,
                  );
            final driverWidth = isMobile ? mobileFieldWidth : 220.0;
            final monthWidth = isMobile ? mobileFieldWidth : 220.0;
            final dateWidth = isMobile ? mobileFieldWidth : 200.0;
            final clearWidth = isMobile ? mobileFieldWidth : 140.0;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: driverWidth,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDriver,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Driver',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _availableDrivers
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d == 'all' ? 'All Drivers' : d,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedDriver = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: monthWidth,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMonthKey,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _availableMonthKeys
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              _monthLabel(m),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedMonthKey = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: dateWidth,
                  child: InkWell(
                    onTap: _pickStartDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        _startDate == null
                            ? 'Any'
                            : DateFormat('dd MMM yyyy').format(_startDate!),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: dateWidth,
                  child: InkWell(
                    onTap: _pickEndDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        _endDate == null
                            ? 'Any'
                            : DateFormat('dd MMM yyyy').format(_endDate!),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: clearWidth,
                  child: OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kpiCard(
    String label,
    String value,
    IconData icon, {
    double width = 190,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogsTable(NumberFormat currencyFormatter) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    if (_filteredLogs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_toggle_off_rounded,
        title: 'No diesel logs found',
        subtitle: 'Try changing driver, month or date filters.',
      );
    }

    final table = DataTable(
      headingRowColor: WidgetStatePropertyAll(
        theme.colorScheme.surfaceContainerHighest,
      ),
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Vehicle')),
        DataColumn(label: Text('Driver')),
        DataColumn(numeric: true, label: Text('Liters')),
        DataColumn(numeric: true, label: Text('Rate')),
        DataColumn(numeric: true, label: Text('Total')),
        DataColumn(numeric: true, label: Text('Avg (km/L)')),
        DataColumn(label: Text('Status')),
      ],
      rows: _filteredLogs.map((log) {
        final parsed = DateTime.tryParse(log.fillDate);
        final mileage = log.cycleEfficiency ?? log.mileage ?? 0;
        final mileageText = mileage > 0 ? mileage.toStringAsFixed(2) : '-';
        final status = log.status.isEmpty ? 'PENDING' : log.status;

        return DataRow(
          cells: [
            DataCell(
              Text(
                parsed != null
                    ? DateFormat('dd MMM yyyy').format(parsed)
                    : log.fillDate,
              ),
            ),
            DataCell(Text(log.vehicleNumber)),
            DataCell(Text(log.driverName.isEmpty ? 'N/A' : log.driverName)),
            DataCell(Text(log.liters.toStringAsFixed(1))),
            DataCell(Text(log.rate.toStringAsFixed(2))),
            DataCell(Text(currencyFormatter.format(log.totalCost))),
            DataCell(Text(mileageText)),
            DataCell(
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: status == 'GOOD_AVERAGE'
                      ? AppColors.success
                      : (status == 'LOW_AVERAGE'
                            ? AppColors.warning
                            : theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMobile)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
              child: Row(
                children: [
                  Text(
                    'History',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _scrollHistoryManually(
                      _logsHistoryScrollController,
                      false,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => _scrollHistoryManually(
                      _logsHistoryScrollController,
                      true,
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            controller: isMobile ? _logsHistoryScrollController : null,
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesTab() {
    final currencyFormatter = NumberFormat.currency(
      symbol: 'Rs ',
      locale: 'en_IN',
    );
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final totalQty = _purchases.fold<double>(0, (s, p) => s + p.quantity);
    final totalAmount = _purchases.fold<double>(0, (s, p) => s + p.totalAmount);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset + 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final cardWidth = isMobile
                  ? ((constraints.maxWidth - 12) / 2).clamp(120.0, 260.0)
                  : 190.0;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _kpiCard(
                    'Total Purchases',
                    '${_purchases.length}',
                    Icons.receipt_long_rounded,
                    width: cardWidth,
                  ),
                  _kpiCard(
                    'Purchased Qty',
                    '${totalQty.toStringAsFixed(1)} L',
                    Icons.opacity_rounded,
                    width: cardWidth,
                  ),
                  _kpiCard(
                    'Total Purchase Cost',
                    currencyFormatter.format(totalAmount),
                    Icons.account_balance_wallet_rounded,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (_purchases.isEmpty)
            _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No purchase history found',
              subtitle: 'Add stock entries to see purchase records.',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final table = DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Supplier')),
                    DataColumn(numeric: true, label: Text('Qty (L)')),
                    DataColumn(numeric: true, label: Text('Rate')),
                    DataColumn(numeric: true, label: Text('Total')),
                  ],
                  rows: _purchases.map((p) {
                    final parsed = DateTime.tryParse(p.purchaseDate);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            parsed != null
                                ? DateFormat('dd MMM yyyy').format(parsed)
                                : p.purchaseDate,
                          ),
                        ),
                        DataCell(Text(p.supplierName)),
                        DataCell(Text(p.quantity.toStringAsFixed(1))),
                        DataCell(Text(p.rate.toStringAsFixed(2))),
                        DataCell(Text(currencyFormatter.format(p.totalAmount))),
                      ],
                    );
                  }).toList(),
                );

                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isMobile)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                          child: Row(
                            children: [
                              Text(
                                'History',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.chevron_left_rounded),
                                onPressed: () => _scrollHistoryManually(
                                  _purchasesHistoryScrollController,
                                  false,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.chevron_right_rounded),
                                onPressed: () => _scrollHistoryManually(
                                  _purchasesHistoryScrollController,
                                  true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SingleChildScrollView(
                        controller: isMobile
                            ? _purchasesHistoryScrollController
                            : null,
                        scrollDirection: Axis.horizontal,
                        child: table,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
