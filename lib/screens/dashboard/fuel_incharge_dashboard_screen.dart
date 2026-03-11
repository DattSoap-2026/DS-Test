import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/diesel_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/unified_card.dart';

class FuelInchargeDashboardScreen extends StatefulWidget {
  const FuelInchargeDashboardScreen({super.key});

  @override
  State<FuelInchargeDashboardScreen> createState() =>
      _FuelInchargeDashboardScreenState();
}

class _FuelInchargeDashboardScreenState
    extends State<FuelInchargeDashboardScreen> {
  late final DieselService _dieselService;
  final ScrollController _recentHistoryScrollController = ScrollController();
  Timer? _recentHistoryAutoScrollTimer;
  bool _isRecentHistoryScrollForward = true;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  double _fuelStock = 0;
  double _todayTotalDieselLiters = 0;
  double _weekConsumptionLiters = 0;
  double _weekConsumptionCost = 0;
  double _monthConsumptionLiters = 0;
  double _monthConsumptionCost = 0;
  List<DieselLog> _todayEntries = const [];

  int get _todayVehiclesCount {
    final vehicles = _todayEntries
        .map((entry) {
          final id = entry.vehicleId.trim();
          if (id.isNotEmpty) return id;
          return entry.vehicleNumber.trim();
        })
        .where((id) => id.isNotEmpty)
        .toSet();
    return vehicles.length;
  }

  int get _todayEntriesCount => _todayEntries.length;

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    _startRecentHistoryAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _recentHistoryAutoScrollTimer?.cancel();
    _recentHistoryScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData({bool forcePageLoader = false}) async {
    if (!mounted || _isRefreshing) return;
    setState(() {
      final showFullLoader = forcePageLoader && !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      final results = await Future.wait([
        _dieselService.getFuelStock(),
        _dieselService.getDieselLogs(startDate: startOfDay, endDate: endOfDay),
        _dieselService.getDieselLogs(startDate: startOfWeek, endDate: endOfDay),
        _dieselService.getDieselLogs(
          startDate: startOfMonth,
          endDate: endOfDay,
        ),
      ]);

      final fuelStock = results[0] as double;
      final todayEntries = (results[1] as List<DieselLog>)
        ..sort((a, b) => b.fillDate.compareTo(a.fillDate));
      final weekEntries = results[2] as List<DieselLog>;
      final monthEntries = results[3] as List<DieselLog>;

      final todayLiters = todayEntries.fold<double>(
        0,
        (sum, e) => sum + e.liters,
      );
      final weekLiters = weekEntries.fold<double>(
        0,
        (sum, e) => sum + e.liters,
      );
      final weekCost = weekEntries.fold<double>(
        0,
        (sum, e) => sum + e.totalCost,
      );
      final monthLiters = monthEntries.fold<double>(
        0,
        (sum, e) => sum + e.liters,
      );
      final monthCost = monthEntries.fold<double>(
        0,
        (sum, e) => sum + e.totalCost,
      );

      if (!mounted) return;
      setState(() {
        _fuelStock = fuelStock;
        _todayEntries = todayEntries;
        _todayTotalDieselLiters = todayLiters;
        _weekConsumptionLiters = weekLiters;
        _weekConsumptionCost = weekCost;
        _monthConsumptionLiters = monthLiters;
        _monthConsumptionCost = monthCost;
        _isLoading = false;
        _isRefreshing = false;
        _hasLoadedOnce = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isRefreshing = false;
        _hasLoadedOnce = true;
      });
    }
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  String _formatCurrency(double amount) {
    final formatted = NumberFormat.decimalPattern('en_IN').format(amount);
    return 'Rs $formatted';
  }

  String _formatLiters(double liters) {
    final whole = liters.roundToDouble();
    if ((liters - whole).abs() < 0.01) {
      return whole.toStringAsFixed(0);
    }
    return liters.toStringAsFixed(2);
  }

  String _stockStatusText() {
    if (_fuelStock <= 0) return 'Out of stock';
    if (_fuelStock < 300) return 'Stock level low';
    return 'Stock level good';
  }

  void _startRecentHistoryAutoScroll() {
    _recentHistoryAutoScrollTimer?.cancel();
    _recentHistoryAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (
      _,
    ) {
      if (!mounted || !_recentHistoryScrollController.hasClients) return;
      final max = _recentHistoryScrollController.position.maxScrollExtent;
      if (max <= 0) return;

      const step = 220.0;
      var nextOffset =
          _recentHistoryScrollController.offset +
          (_isRecentHistoryScrollForward ? step : -step);

      if (nextOffset >= max) {
        nextOffset = max;
        _isRecentHistoryScrollForward = false;
      } else if (nextOffset <= 0) {
        nextOffset = 0;
        _isRecentHistoryScrollForward = true;
      }

      _recentHistoryScrollController.animateTo(
        nextOffset,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollRecentHistoryManually(bool scrollRight) {
    if (!_recentHistoryScrollController.hasClients) return;
    const step = 260.0;
    final target = scrollRight
        ? (_recentHistoryScrollController.offset + step)
        : (_recentHistoryScrollController.offset - step);
    final bounded = target.clamp(
      0.0,
      _recentHistoryScrollController.position.maxScrollExtent,
    );
    _recentHistoryScrollController.animateTo(
      bounded,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const MasterScreenHeader(
          title: 'Fuel Dashboard',
          subtitle: 'Fuel stock and today fuel entries',
          icon: Icons.local_gas_station,
          isDashboardHeader: true,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: Responsive.screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading && !_hasLoadedOnce)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 56),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_errorMessage != null)
                    UnifiedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard data load nahi ho paya',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _loadDashboardData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _buildKpisSection(context),
                    const SizedBox(height: 20),
                    _buildTodayEntriesSection(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpisSection(BuildContext context) {
    const spacing = 16.0;
    final kpiCards = [
      _buildMainKpiCard(
        icon: Icons.opacity_rounded,
        accentColor: const Color(0xFF22D3EE),
        title: 'Available Diesel Stock',
        value: '${_formatLiters(_fuelStock)} L',
        detail: _stockStatusText(),
      ),
      _buildMainKpiCard(
        icon: Icons.local_gas_station,
        accentColor: const Color(0xFFF59E0B),
        title: 'Today\'s Total Diesel',
        value: '${_formatLiters(_todayTotalDieselLiters)} L',
        detail: '$_todayEntriesCount entries',
      ),
      _buildMainKpiCard(
        icon: Icons.local_shipping_rounded,
        accentColor: const Color(0xFF3B82F6),
        title: 'Vehicles Refueled Today',
        value: _todayVehiclesCount.toString(),
        detail: 'Unique vehicles',
      ),
      _buildMainKpiCard(
        icon: Icons.calendar_today_rounded,
        accentColor: const Color(0xFFA855F7),
        title: 'This Week\'s Consumption',
        value: '${_formatLiters(_weekConsumptionLiters)} L',
        detail: _formatCurrency(_weekConsumptionCost),
      ),
      _buildMainKpiCard(
        icon: Icons.bar_chart_rounded,
        accentColor: const Color(0xFF6366F1),
        title: 'This Month\'s Consumption',
        value: '${_formatLiters(_monthConsumptionLiters)} L',
        detail: _formatCurrency(_monthConsumptionCost),
      ),
      _buildMainKpiCard(
        icon: Icons.monitor_heart_outlined,
        accentColor: const Color(0xFFF43F5E),
        title: 'Total Fuel Entries',
        value: _todayEntriesCount.toString(),
        detail: 'Logged today',
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < kpiCards.length; i += 2) {
      final secondCard = i + 1 < kpiCards.length ? kpiCards[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: kpiCards[i]),
            const SizedBox(width: spacing),
            Expanded(child: secondCard ?? const SizedBox.shrink()),
          ],
        ),
      );
      if (i + 2 < kpiCards.length) {
        rows.add(const SizedBox(height: spacing));
      }
    }

    return Column(children: rows);
  }

  Widget _buildMainKpiCard({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String value,
    required String detail,
  }) {
    final theme = Theme.of(context);

    return UnifiedCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 190;
          final iconSize = compact ? 16.0 : 18.0;
          final iconContainer = compact ? 30.0 : 34.0;
          final valueStyle = compact
              ? theme.textTheme.headlineSmall
              : theme.textTheme.headlineMedium;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? theme.textTheme.labelLarge
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 10),
                  Container(
                    width: iconContainer,
                    height: iconContainer,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: iconSize),
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 14),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? theme.textTheme.bodySmall
                            : theme.textTheme.bodyMedium)
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayEntriesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    return UnifiedCard(
      title: 'Today Fuel Entries',
      actions: [
        if (isMobile && _todayEntries.isNotEmpty)
          IconButton(
            tooltip: 'Scroll left',
            onPressed: () => _scrollRecentHistoryManually(false),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        if (isMobile && _todayEntries.isNotEmpty)
          IconButton(
            tooltip: 'Scroll right',
            onPressed: () => _scrollRecentHistoryManually(true),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadDashboardData,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: _todayEntries.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aaj ki koi fuel entry available nahi hai.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : isMobile
          ? SingleChildScrollView(
              controller: _recentHistoryScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _todayEntries.map((entry) {
                  final vehicleText = entry.vehicleNumber.trim().isEmpty
                      ? 'Vehicle'
                      : entry.vehicleNumber.trim();
                  final driverText = entry.driverName.trim().isEmpty
                      ? 'Driver not set'
                      : entry.driverName.trim();

                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      color: theme.colorScheme.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Driver: $driverText',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(entry.fillDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${entry.liters.toStringAsFixed(1)} Ltr',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(entry.totalCost),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todayEntries.length,
              separatorBuilder: (_, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final entry = _todayEntries[index];
                final vehicleText = entry.vehicleNumber.trim().isEmpty
                    ? 'Vehicle'
                    : entry.vehicleNumber.trim();
                final driverText = entry.driverName.trim().isEmpty
                    ? 'Driver not set'
                    : entry.driverName.trim();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.local_shipping_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Driver: $driverText',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(entry.fillDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.liters.toStringAsFixed(1)} Ltr',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(entry.totalCost),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
