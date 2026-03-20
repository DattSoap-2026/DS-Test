import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/inventory_service.dart';
import '../../services/database_service.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/user_entity.dart';
import '../../models/types/user_types.dart';
import '../../utils/responsive.dart';
import '../../utils/unit_converter.dart';
import '../../widgets/responsive/responsive_layout.dart';

import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/ui/unified_card.dart';

class MyStockScreen extends StatefulWidget {
  const MyStockScreen({super.key});

  @override
  State<MyStockScreen> createState() => _MyStockScreenState();
}

class _MyStockScreenState extends State<MyStockScreen> {
  static const double _minVisibleAllocatedQty = 0.0001;

  late final InventoryService _inventoryService;
  late final AuthProvider _authProvider;
  StreamSubscription<UserEntity?>? _userSubscription;
  final ScrollController _stockTableScrollController = ScrollController();
  Timer? _stockTableAutoScrollTimer;
  AppUser? _localUser;
  String? _watchedUserId;
  String? _lastAllocSignature;
  List<StockUsageData> _allStock = [];
  List<StockUsageData> _filteredStock = [];
  bool _isLoading = true;
  String _sortBy = 'name'; // 'name', 'available', 'usage'
  String _filterStatus = 'all'; // 'all', 'in_stock', 'out_of_stock'

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<InventoryService>();
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_handleAuthStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startLocalUserWatcher();
        _loadStock();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startLocalUserWatcher();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthStateChanged);
    _userSubscription?.cancel();
    _stockTableAutoScrollTimer?.cancel();
    _stockTableScrollController.dispose();
    super.dispose();
  }

  void _handleAuthStateChanged() {
    if (!mounted) return;
    final authUserId = _authProvider.state.user?.id;
    if (authUserId != _watchedUserId) {
      _startLocalUserWatcher();
    }
  }

  void _startLocalUserWatcher() {
    final authUser = _authProvider.state.user;
    if (authUser == null) {
      _userSubscription?.cancel();
      _userSubscription = null;
      _watchedUserId = null;
      _localUser = null;
      _lastAllocSignature = null;
      if (mounted) {
        setState(() {
          _allStock = [];
          _filteredStock = [];
          _isLoading = false;
        });
      }
      _stopStockTableAutoScroll();
      return;
    }
    if (_watchedUserId == authUser.id) return;

    _userSubscription?.cancel();
    _watchedUserId = authUser.id;
    _localUser = null;
    _lastAllocSignature = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStock();
      }
    });

    final db = context.read<DatabaseService>();
    _userSubscription = db.users
        .watchObject(fastHash(authUser.id), fireImmediately: true)
        .listen((entity) {
          if (!mounted) return;
          if (entity == null) {
            final hadLocalUser = _localUser != null;
            _localUser = null;
            _lastAllocSignature = null;
            if (hadLocalUser) {
              _loadStock();
            }
            return;
          }
          final localUser = entity.toDomain();
          final signature = entity.allocatedStockJson ?? '';
          final shouldReload = signature != _lastAllocSignature;
          _lastAllocSignature = signature;
          _localUser = localUser;
          if (shouldReload) {
            _loadStock();
          }
        });
  }

  AppUser? _resolveUser() {
    return _localUser ?? context.read<AuthProvider>().state.user;
  }

  List<StockUsageData> _onlyCurrentlyAllocated(List<StockUsageData> usage) {
    return usage
        .where(
          (item) =>
              item.availableToday > _minVisibleAllocatedQty ||
              item.remainingTotal > _minVisibleAllocatedQty,
        )
        .toList(growable: false);
  }

  Future<void> _loadStock() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = _resolveUser();
      if (user == null) {
        if (mounted) {
          setState(() {
            _allStock = [];
            _filteredStock = [];
            _isLoading = false;
          });
        }
        _stopStockTableAutoScroll();
        return;
      }

      var allocatedStock = user.allocatedStock;
      if (user.role == UserRole.salesman) {
        try {
          final refreshed = await _inventoryService.getSalesmanCurrentStock(
            user.id,
          );
          if (refreshed.isNotEmpty ||
              allocatedStock == null ||
              allocatedStock.isEmpty) {
            allocatedStock = refreshed;
          }
        } catch (e) {
          debugPrint('Stock refresh skipped: $e');
        }
      }

      if (allocatedStock == null || allocatedStock.isEmpty) {
        if (mounted) {
          setState(() {
            _allStock = [];
            _filteredStock = [];
            _isLoading = false;
          });
        }
        _stopStockTableAutoScroll();
        return;
      }

      final usage = await _inventoryService.calculateStockUsage(
        user.id,
        allocatedStock,
      );
      final currentAllocatedOnly = _onlyCurrentlyAllocated(usage);

      if (mounted) {
        setState(() {
          _allStock = currentAllocatedOnly;
          _applyFiltersAndSort();
          _isLoading = false;
        });
        _startStockTableAutoScrollIfNeeded();
      }
    } catch (e) {
      debugPrint('Error loading stock: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading stock: $e')));
        });
      }
    }
  }

  void _stopStockTableAutoScroll() {
    _stockTableAutoScrollTimer?.cancel();
    _stockTableAutoScrollTimer = null;
    if (_stockTableScrollController.hasClients) {
      _stockTableScrollController.jumpTo(0);
    }
  }

  void _startStockTableAutoScrollIfNeeded() {
    _stockTableAutoScrollTimer?.cancel();
    _stockTableAutoScrollTimer = null;
  }

  void _applyFiltersAndSort() {
    List<StockUsageData> filtered = _allStock.where((item) {
      final matchesStatus =
          _filterStatus == 'all' ||
          (_filterStatus == 'out_of_stock' && item.availableToday <= 0) ||
          (_filterStatus == 'in_stock' && item.availableToday > 0);
      return matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'name') {
        return a.productName.compareTo(b.productName);
      } else if (_sortBy == 'available') {
        return b.availableToday.compareTo(a.availableToday);
      } else if (_sortBy == 'usage') {
        return b.percentageSold.compareTo(a.percentageSold);
      }
      return 0;
    });

    _filteredStock = filtered;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_filteredStock.isEmpty) {
        _stopStockTableAutoScroll();
      } else {
        _startStockTableAutoScrollIfNeeded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = Responsive.screenPadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Stock',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Track your allocated inventory and sales',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _loadStock,
                          icon: const Icon(Icons.replay_rounded),
                          iconSize: 20,
                          tooltip: 'Reload Stock',
                          style: IconButton.styleFrom(
                            minimumSize: const Size(36, 36),
                            padding: const EdgeInsets.all(6),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadStock,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenPadding.horizontal / 2,
                              vertical: 12,
                            ),
                            sliver: SliverToBoxAdapter(child: _buildKPIGrid()),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenPadding.horizontal / 2,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenPadding.horizontal / 2,
                              vertical: 12,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildStockDetailsSection(
                                fillHeight: _filteredStock.isEmpty,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildKPIGrid() {
    final todayAllocated = _allStock.fold(
      0.0,
      (sum, item) => sum + item.todayAllocated,
    );
    final soldToday = _allStock.fold(0.0, (sum, item) => sum + item.todaySold);
    final availableNow = _allStock.fold(
      0.0,
      (sum, item) => sum + item.availableToday,
    );
    final outOfStockCount = _allStock
        .where((item) => item.availableToday <= 0)
        .length;

    final cards = [
      KPICard(
        title: 'Today Allocated',
        value: todayAllocated.toInt().toString(),
        subtitle: 'Total units',
        icon: Icons.inventory_2,
        color: Theme.of(context).colorScheme.primary,
        isGlass: true,
      ),
      KPICard(
        title: 'Sold Today',
        value: soldToday.toInt().toString(),
        subtitle: 'Units sold',
        icon: Icons.trending_up,
        color: Theme.of(context).colorScheme.secondary,
        isGlass: true,
      ),
      KPICard(
        title: 'Available Now',
        value: availableNow.toInt().toString(),
        subtitle: 'Ready to sell',
        icon: Icons.check_circle,
        color: Theme.of(context).colorScheme.tertiary,
        isGlass: true,
      ),
      KPICard(
        title: 'Out of Stock',
        value: outOfStockCount.toString(),
        subtitle: 'Products',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        isGlass: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : Responsive.width(context);
        final columns = constraints.maxWidth >= Responsive.tabletBreakpoint
            ? 4
            : 2;
        const spacing = 12.0;
        final rawWidth = (availableWidth - spacing * (columns - 1)) / columns;
        final itemWidth = rawWidth.clamp(120.0, 420.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildStockDetailsSection({bool fillHeight = false}) {
    final theme = Theme.of(context);
    final showControls = _allStock.isNotEmpty;
    return UnifiedCard(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      useLayoutBuilder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final useVerticalHeader =
                  constraints.maxWidth < Responsive.mobileBreakpoint;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'View and manage your inventory',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              );

              if (useVerticalHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    if (showControls) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildFilterDropdown(compact: true)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildSortDropdown(compact: true)),
                        ],
                      ),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  if (showControls) ...[
                    const SizedBox(width: 16),
                    Flexible(
                      child: LayoutBuilder(
                        builder: (context, controlConstraints) {
                          final compactControls = controlConstraints.maxWidth < 380;
                          return AdaptiveFormLayout(
                            maxColumns: compactControls ? 1 : 2,
                            minColumnWidth: compactControls ? 180 : 170,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _buildFilterDropdown(compact: compactControls),
                              _buildSortDropdown(compact: compactControls),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          if (_filteredStock.isEmpty)
            _buildEmptyState(fillHeight: fillHeight)
          else
            _buildStockTable(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({bool compact = false}) {
    final theme = Theme.of(context);
    const labels = <String, String>{
      'all': 'ALL STOCK',
      'in_stock': 'IN STOCK',
      'out_of_stock': 'OUT OF STOCK',
    };
    const compactLabels = <String, String>{
      'all': 'ALL',
      'in_stock': 'IN',
      'out_of_stock': 'OUT',
    };
    return UnifiedCard(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.2,
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
      useLayoutBuilder: false,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterStatus,
          isExpanded: true,
          icon: Icon(
            Icons.filter_list_rounded,
            size: compact ? 12 : 16,
            color: theme.colorScheme.primary,
          ),
          padding: EdgeInsets.zero,
          isDense: true,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: compact ? 8.5 : 10,
            letterSpacing: compact ? 0 : 0.5,
          ),
          dropdownColor: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          selectedItemBuilder: (context) {
            return <String>['all', 'in_stock', 'out_of_stock']
                .map(
                  (value) => Text(
                    (compact ? compactLabels[value] : labels[value]) ?? value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                .toList();
          },
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _filterStatus = newValue;
                _applyFiltersAndSort();
              });
            }
          },
          items: <String>['all', 'in_stock', 'out_of_stock']
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(labels[value] ?? value),
                );
              })
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSortDropdown({bool compact = false}) {
    final theme = Theme.of(context);
    const labels = <String, String>{
      'name': 'BY NAME',
      'available': 'BY STOCK',
      'usage': 'BY USAGE',
    };
    const compactLabels = <String, String>{
      'name': 'NAME',
      'available': 'STOCK',
      'usage': 'USAGE',
    };
    return UnifiedCard(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.2,
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
      useLayoutBuilder: false,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isExpanded: true,
          icon: Icon(
            Icons.sort_rounded,
            size: compact ? 12 : 16,
            color: theme.colorScheme.primary,
          ),
          padding: EdgeInsets.zero,
          isDense: true,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: compact ? 8.5 : 10,
            letterSpacing: compact ? 0 : 0.5,
          ),
          dropdownColor: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          selectedItemBuilder: (context) {
            return <String>['name', 'available', 'usage']
                .map(
                  (value) => Text(
                    (compact ? compactLabels[value] : labels[value]) ?? value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                .toList();
          },
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _sortBy = newValue;
                _applyFiltersAndSort();
              });
            }
          },
          items: <String>['name', 'available', 'usage']
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(labels[value] ?? value),
                );
              })
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStockTable() {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final minTableWidth = isMobile ? 0.0 : 620.0;
    final productColumnWidth = isMobile ? 118.0 : 260.0;

    return Scrollbar(
      controller: _stockTableScrollController,
      thumbVisibility: Responsive.isMobile(context),
      child: SingleChildScrollView(
        controller: _stockTableScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: minTableWidth > 0
              ? BoxConstraints(minWidth: minTableWidth)
              : const BoxConstraints(),
          child: DataTable(
            showBottomBorder: true,
            headingRowHeight: isMobile ? 40 : 46,
            dataRowMinHeight: isMobile ? 56 : 62,
            dataRowMaxHeight: isMobile ? 76 : 88,
            horizontalMargin: isMobile ? 8 : 12,
            columnSpacing: isMobile ? 10 : 20,
            dividerThickness: 0.8,
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            ),
            columns: [
              DataColumn(
                label: _buildHeaderText('Product'),
                tooltip: 'Product Name',
              ),
              DataColumn(
                numeric: true,
                label: _buildHeaderText('Alloc'),
                tooltip: 'Total Allocated (in Pcs)',
              ),
              DataColumn(
                numeric: true,
                label: _buildHeaderText('Sold'),
                tooltip: 'Sold Today (in Pcs)',
              ),
              DataColumn(
                numeric: true,
                label: _buildHeaderText('Available'),
                tooltip: 'Available Now (Box + Pcs)',
              ),
            ],
            rows: _filteredStock.map((item) {
              final isOutOfStock = item.availableToday <= 0;
              final hasBox = UnitConverter.hasSecondaryUnit(
                item.secondaryUnit,
                item.conversionFactor,
              );
              return DataRow(
                color: isOutOfStock
                    ? WidgetStatePropertyAll(
                        theme.colorScheme.errorContainer.withValues(
                          alpha: 0.22,
                        ),
                      )
                    : null,
                cells: [
                  DataCell(
                    SizedBox(
                      width: productColumnWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (hasBox)
                            Text(
                              '1 ${item.secondaryUnit} = ${item.conversionFactor.toInt()} ${item.baseUnit}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    _buildQtyCell(
                      theme: theme,
                      baseQty: item.totalAllocated,
                      baseUnit: item.baseUnit,
                      secondaryUnit: item.secondaryUnit,
                      conversionFactor: item.conversionFactor,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DataCell(
                    _buildQtyCell(
                      theme: theme,
                      baseQty: item.totalSold,
                      baseUnit: item.baseUnit,
                      secondaryUnit: item.secondaryUnit,
                      conversionFactor: item.conversionFactor,
                      color: theme.colorScheme.primary,
                      bold: true,
                    ),
                  ),
                  DataCell(
                    _buildQtyCell(
                      theme: theme,
                      baseQty: item.availableToday,
                      baseUnit: item.baseUnit,
                      secondaryUnit: item.secondaryUnit,
                      conversionFactor: item.conversionFactor,
                      color: isOutOfStock
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                      bold: true,
                      highlight: !isOutOfStock && hasBox,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Builds a quantity cell displaying Box + Pcs split when applicable.
  Widget _buildQtyCell({
    required ThemeData theme,
    required double baseQty,
    required String baseUnit,
    String? secondaryUnit,
    double conversionFactor = 1,
    Color? color,
    bool bold = false,
    bool highlight = false,
  }) {
    final isMobile = Responsive.isMobile(context);
    final hasBox = UnitConverter.hasSecondaryUnit(
      secondaryUnit,
      conversionFactor,
    );

    if (!hasBox) {
      return Text(
        '${baseQty.toInt()} $baseUnit',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontSize: isMobile ? 13 : null,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    final boxes = UnitConverter.fullSecondaryUnits(baseQty, conversionFactor);
    final loose = UnitConverter.remainingBaseUnitsExact(
      baseQty,
      conversionFactor,
    );
    final looseDisplay = (loose - loose.roundToDouble()).abs() < 0.001
        ? loose.round().toString()
        : loose.toStringAsFixed(1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (boxes > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: highlight
                ? BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMobile) ...[
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 11,
                    color: (color ?? theme.colorScheme.onSurface).withValues(
                      alpha: 0.7,
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  '$boxes ${secondaryUnit!}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
        if (loose > 0.001 || boxes == 0)
          Text(
            '+ $looseDisplay $baseUnit',
            style: theme.textTheme.labelSmall?.copyWith(
              color: (color ?? theme.colorScheme.onSurface).withValues(
                alpha: 0.65,
              ),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 9 : 10,
            ),
          ),
      ],
    );
  }

  @override
  void deactivate() {
    _stockTableAutoScrollTimer?.cancel();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    if (_filteredStock.isNotEmpty) {
      _startStockTableAutoScrollIfNeeded();
    }
  }

  Widget _buildHeaderText(String label) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: isMobile ? 12 : null,
        letterSpacing: isMobile ? 0.1 : 0.3,
      ),
    );
  }

  Widget _buildEmptyState({bool fillHeight = false}) {
    final theme = Theme.of(context);
    final message = _allStock.isEmpty
        ? 'No stock assigned yet'
        : 'No products found';
    final emptyContent = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: fillHeight ? 240 : 180),
        child: emptyContent,
      ),
    );
  }
}
