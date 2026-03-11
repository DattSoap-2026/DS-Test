import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/dealer_repository.dart';
import '../../data/repositories/sales_repository.dart';
import '../../data/local/entities/dealer_entity.dart';
import '../../data/local/entities/sale_entity.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/app_logger.dart';
import '../../utils/mobile_header_typography.dart';
import 'package:intl/intl.dart';
import '../../widgets/dashboard/kpi_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class DealerDashboardScreen extends StatefulWidget {
  const DealerDashboardScreen({super.key});

  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen> {
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  double _totalRevenue = 0;
  double _allTimeRevenue = 0;
  int _activeDealers = 0;
  int _totalDealers = 0;
  int _pendingDispatch = 0;
  int _todaysOrders = 0;
  int _monthlyOrders = 0;
  List<SaleEntity> _recentSales = [];
  Map<String, double> _territoryRevenue = {};
  List<MapEntry<String, double>> _topDealers = [];
  Map<int, double> _monthlySalesByDay = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData({bool forcePageLoader = false}) async {
    if (!mounted || _isRefreshing) return;
    setState(() {
      final showFullLoader = forcePageLoader && !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
    });
    try {
      final dealerRepo = context.read<DealerRepository>();
      final salesRepo = context.read<SalesRepository>();

      final dealers = await dealerRepo.getAllDealers();
      final allSales = await salesRepo.getAllSales();
      final dealerSales = allSales.where(_isDealerSale).toList()
        ..sort(
          (a, b) => _parseCreatedAt(b.createdAt).compareTo(
            _parseCreatedAt(a.createdAt),
          ),
        );

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

      final monthlySales = dealerSales.where((sale) {
        final createdAt = _parseCreatedAtOrNull(sale.createdAt);
        if (createdAt == null) return false;
        return !createdAt.isBefore(startOfMonth) && !createdAt.isAfter(endOfMonth);
      }).toList();

      final activeDealersCount = dealers.where(_isActiveDealer).length;
      final totalDealersCount = dealers.length;

      final totalRevenue = monthlySales.fold<double>(
        0,
        (sum, sale) => sum + _saleAmount(sale),
      );
      final allTimeRevenue = dealerSales.fold<double>(
        0,
        (sum, sale) => sum + _saleAmount(sale),
      );
      final pendingDealerSales = dealerSales
          .where(_isPendingDealerDispatchSale)
          .toList();
      final todaysSalesCount = dealerSales.where((sale) {
        final createdAt = _parseCreatedAtOrNull(sale.createdAt);
        if (createdAt == null) return false;
        return createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day &&
            !createdAt.isBefore(startOfToday);
      }).length;

      final sourceSales = monthlySales.isNotEmpty ? monthlySales : dealerSales;
      final dealersById = <String, DealerEntity>{for (final d in dealers) d.id: d};
      final dealersByName = <String, DealerEntity>{};
      for (final dealer in dealers) {
        final normalized = _normalizeToken(dealer.name);
        if (normalized.isNotEmpty) {
          dealersByName[normalized] = dealer;
        }
      }

      final territoryRev = <String, double>{};
      final dealerRev = <String, double>{};
      for (final sale in sourceSales) {
        final amount = _saleAmount(sale);
        if (amount <= 0) continue;

        final linkedDealer =
            dealersById[sale.recipientId] ??
            dealersByName[_normalizeToken(sale.recipientName)];
        final dealerName = _resolveDealerName(sale, linkedDealer);
        dealerRev[dealerName] = (dealerRev[dealerName] ?? 0) + amount;

        final territory = _resolveTerritoryName(linkedDealer);
        territoryRev[territory] = (territoryRev[territory] ?? 0) + amount;
      }

      final sortedTopDealers = dealerRev.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final recentSales = dealerSales.take(5).toList();
      final dailySales = <int, double>{};
      for (final sale in monthlySales) {
        final createdAt = _parseCreatedAtOrNull(sale.createdAt);
        if (createdAt == null) continue;
        final day = createdAt.day;
        dailySales[day] = (dailySales[day] ?? 0) + _saleAmount(sale);
      }

      if (mounted) {
        setState(() {
          _totalDealers = totalDealersCount;
          _activeDealers = activeDealersCount;
          _totalRevenue = totalRevenue;
          _allTimeRevenue = allTimeRevenue;
          _pendingDispatch = pendingDealerSales.length;
          _todaysOrders = todaysSalesCount;
          _monthlyOrders = monthlySales.length;
          _recentSales = recentSales;
          _territoryRevenue = territoryRev;
          _topDealers = sortedTopDealers.take(5).toList();
          _monthlySalesByDay = dailySales;
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      AppLogger.error(
        'Error loading dealer dashboard: $e',
        tag: 'DealerDashboard',
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  String _normalizeToken(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_\-\s]+'), '');
  }

  bool _isDealerSale(SaleEntity sale) {
    final recipientType = _normalizeToken(sale.recipientType);
    final saleType = _normalizeToken(sale.saleType);
    return recipientType == 'dealer' ||
        saleType == 'directdealer' ||
        saleType == 'dealer';
  }

  bool _isActiveDealer(DealerEntity dealer) {
    final status = _normalizeToken(dealer.status);
    return status.isEmpty || status == 'active';
  }

  bool _isPendingDealerDispatchSale(SaleEntity sale) {
    final status = _normalizeToken(sale.status);
    return status == 'created' ||
        status == 'pending' ||
        status == 'pendingdispatch' ||
        status == 'intransit';
  }

  double _saleAmount(SaleEntity sale) {
    return sale.totalAmount ?? sale.taxableAmount ?? sale.subtotal ?? 0;
  }

  DateTime _parseCreatedAt(String value) {
    final parsed = _parseCreatedAtOrNull(value);
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _parseCreatedAtOrNull(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }

  String _resolveDealerName(SaleEntity sale, DealerEntity? dealer) {
    final recipientName = sale.recipientName.trim();
    if (recipientName.isNotEmpty) return recipientName;
    final mappedName = dealer?.name.trim();
    if (mappedName != null && mappedName.isNotEmpty) return mappedName;
    return 'Unknown Dealer';
  }

  String _resolveTerritoryName(DealerEntity? dealer) {
    final territory = dealer?.territory?.trim();
    if (territory != null && territory.isNotEmpty) return territory;
    final routeName = dealer?.assignedRouteName?.trim();
    if (routeName != null && routeName.isNotEmpty) return routeName;
    return 'Unassigned';
  }

  String _formatCurrency(double value, {int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return 'Rs ${formatter.format(value).trim()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final pagePadding = isMobile ? 12.0 : 24.0;

    if (_isLoading && !_hasLoadedOnce) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildWelcomeBanner(theme),
            const SizedBox(height: 24),

            // KPI Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1000;
                // On Desktop: 4 cards in a row
                // On Tablet/Mobile: Grid with 2 columns
                if (isDesktop) {
                  return Row(
                    children: [
                      Expanded(
                        child: KPICard(
                          title: 'Total Revenue',
                          value: _formatCurrency(_totalRevenue),
                          subtitle:
                              'This Month | Total ${_formatCurrency(_allTimeRevenue)}',
                          icon: Icons.show_chart,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KPICard(
                          title: 'Active Dealers',
                          value: '$_activeDealers',
                          subtitle:
                              'Active / Total: $_activeDealers / $_totalDealers',
                          icon: Icons.people_outline,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KPICard(
                          title: 'Pending Dispatch',
                          value: '$_pendingDispatch',
                          subtitle: 'Orders to Ship',
                          icon: Icons.local_shipping_outlined,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KPICard(
                          title: 'Today\'s Orders',
                          value: '$_todaysOrders',
                          subtitle: 'This Month: $_monthlyOrders',
                          icon: Icons.shopping_cart_outlined,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  );
                } else {
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    childAspectRatio: constraints.maxWidth > 700
                        ? 1.35
                        : (constraints.maxWidth < 380 ? 0.92 : 1.02),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      KPICard(
                        title: 'Total Revenue',
                        value: _formatCurrency(_totalRevenue),
                        subtitle:
                            'This Month | Total ${_formatCurrency(_allTimeRevenue)}',
                        icon: Icons.show_chart,
                        color: AppColors.info,
                      ),
                      KPICard(
                        title: 'Active Dealers',
                        value: '$_activeDealers',
                        subtitle:
                            'Active / Total: $_activeDealers / $_totalDealers',
                        icon: Icons.people_outline,
                        color: AppColors.info,
                      ),
                      KPICard(
                        title: 'Pending Dispatch',
                        value: '$_pendingDispatch',
                        subtitle: 'Orders to Ship',
                        icon: Icons.local_shipping_outlined,
                        color: AppColors.warning,
                      ),
                      KPICard(
                        title: 'Today\'s Orders',
                        value: '$_todaysOrders',
                        subtitle: 'This Month: $_monthlyOrders',
                        icon: Icons.shopping_cart_outlined,
                        color: AppColors.lightPrimary,
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Middle Section: Territories and Top Dealers
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                return isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildTerritorySummary(theme)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildTopDealersCard(theme)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTerritorySummary(theme),
                          const SizedBox(height: 24),
                          _buildTopDealersCard(theme),
                        ],
                      );
              },
            ),

            const SizedBox(height: 24),

            // Recent Sales & Monthly Sales Trend
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildRecentSalesCard(theme, isDark),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _buildMonthlySalesChartCard(theme, isDark),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRecentSalesCard(theme, isDark),
                      const SizedBox(height: 24),
                      _buildMonthlySalesChartCard(theme, isDark),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSalesCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      constraints: const BoxConstraints(minHeight: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Dealer Sales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Latest transactions from dealers',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          if (_recentSales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Recent sales list will appear here',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSales.length,
              separatorBuilder: (_, index) => const Divider(),
              itemBuilder: (context, index) {
                final sale = _recentSales[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(sale.recipientName),
                  subtitle: Text(
                    _formatDateSafe(sale.createdAt),
                  ),
                  trailing: Text(_formatCurrency(_saleAmount(sale))),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlySalesChartCard(ThemeData theme, bool isDark) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthTotal = _monthlySalesByDay.values.fold<double>(0.0, (a, b) => a + b);
    final maxDailyValue = _monthlySalesByDay.isEmpty
        ? 0.0
        : _monthlySalesByDay.values.reduce((a, b) => a > b ? a : b);
    final bestDay = _monthlySalesByDay.entries.isEmpty
        ? null
        : _monthlySalesByDay.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final compactFormatter = NumberFormat.compact(locale: 'en_IN');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
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
          const Text(
            'Monthly Sales Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$monthLabel | Date-wise dealer sales',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          if (_monthlySalesByDay.isEmpty)
            Text(
              'No monthly sales data available.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else ...[
            SizedBox(
              height: 190,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(daysInMonth, (index) {
                    final day = index + 1;
                    final value = _monthlySalesByDay[day] ?? 0.0;
                    final ratio = maxDailyValue > 0 ? (value / maxDailyValue) : 0.0;
                    final barHeight = value <= 0
                        ? 6.0
                        : (ratio * 118).clamp(12.0, 118.0);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 26,
                            child: Text(
                              value > 0 ? compactFormatter.format(value) : '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 18,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: value > 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 22,
                            child: Text(
                              '$day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  'Total: ${_formatCurrency(monthTotal, decimalDigits: 0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (bestDay != null)
                  Text(
                    'Peak Day: ${bestDay.key} (${_formatCurrency(bestDay.value, decimalDigits: 0)})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = _parseCreatedAtOrNull(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Widget _buildTerritorySummary(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Territory Revenue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_territoryRevenue.isEmpty)
            Text(
              'No dealer sales data available.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else
            ..._territoryRevenue.entries.map((e) {
              final double percentage = _totalRevenue > 0
                  ? (e.value / _totalRevenue)
                  : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatCurrency(e.value, decimalDigits: 0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTopDealersCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Dealers',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_topDealers.isEmpty)
            const Text('No data available')
          else
            ..._topDealers.map((e) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    e.key[0],
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  _formatCurrency(e.value, decimalDigits: 0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(ThemeData theme) {
    final user = context.watch<AuthProvider>().state.user;
    if (user == null) return const SizedBox.shrink();
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.name}!',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: isMobile ? mobileHeaderTitleFontSize : 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: isMobile ? -0.1 : 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dealer network overview',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
