import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/products_service.dart';
import '../../services/inventory_service.dart';
import '../../models/types/product_types.dart';
import '../../widgets/ui/shared/app_card.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class InventoryAnalyticsScreen extends StatefulWidget {
  const InventoryAnalyticsScreen({super.key});

  @override
  State<InventoryAnalyticsScreen> createState() =>
      _InventoryAnalyticsScreenState();
}

class _InventoryAnalyticsScreenState extends State<InventoryAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final ProductsService _productsService;
  late final InventoryService _inventoryService;
  late TabController _tabController;

  bool _isLoading = true;
  List<Product> _allProducts = [];
  Map<String, double> _productVelocity = {}; // ProductId -> Monthly Out Qty

  @override
  void initState() {
    super.initState();
    _productsService = context.read<ProductsService>();
    _inventoryService = context.read<InventoryService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productsService.getProducts(status: 'active');

      // Calculate Velocity (Last 30 days movements)
      final now = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));
      final Map<String, double> velocity = {};

      // In a real app we might aggregate this in a service or use specific query
      // For now, we iterate movements or use a simplified heuristic if movements count is high
      // Let's rely on Sales or Stock Movements.
      // Using StockMovements for accurate 'OUT' flow including internal usage.
      final movements = await _inventoryService.getStockMovements(
        movementType: 'out',
        startDate: monthAgo,
      );

      for (var m in movements) {
        final pid = m['productId'] as String;
        final qty = (m['quantity'] as num).toDouble();
        velocity[pid] = (velocity[pid] ?? 0) + qty;
      }

      if (mounted) {
        setState(() {
          _allProducts = products;
          _productVelocity = velocity;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inventory data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MasterScreenHeader(
              title: 'Inventory Analytics',
              subtitle: 'Profitability, Velocity & Health',
              icon: Icons.inventory_2_rounded,
              color: AppColors.lightPrimary,
              actions: [
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSummaryCards(),
            ),
          ),
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface,
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
            bottom: ThemedTabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Profitability'),
                Tab(text: 'Velocity'),
                Tab(text: 'Stock Health'),
              ],
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfitabilityView(),
                  _buildVelocityView(),
                  _buildStockHealthView(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_allProducts.isEmpty) return const SizedBox.shrink();

    double totalStockValue = 0;
    double totalPotentialRevenue = 0;
    int itemsWithMargin = 0;
    double totalMarginPercent = 0;

    for (var p in _allProducts) {
      totalStockValue += (p.stock * (p.averageCost ?? p.purchasePrice ?? 0));
      totalPotentialRevenue += (p.stock * p.price);

      final cost = p.averageCost ?? p.purchasePrice;
      if (cost != null && cost > 0 && p.price > 0) {
        final margin = ((p.price - cost) / p.price) * 100;
        totalMarginPercent += margin;
        itemsWithMargin++;
      }
    }

    final avgMargin = itemsWithMargin > 0
        ? totalMarginPercent / itemsWithMargin
        : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(
              flex: isWide ? 1 : 0,
              child: KPICard(
                title: 'Total Stock Value',
                value: '₹${NumberFormat.compact().format(totalStockValue)}',
                icon: Icons.monetization_on,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
            Expanded(
              flex: isWide ? 1 : 0,
              child: KPICard(
                title: 'Potential Revenue',
                value:
                    '₹${NumberFormat.compact().format(totalPotentialRevenue)}',
                icon: Icons.trending_up,
                color: AppColors.info,
              ),
            ),
            SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
            Expanded(
              flex: isWide ? 1 : 0,
              child: KPICard(
                title: 'Avg. Margin',
                value: '${avgMargin.toStringAsFixed(1)}%',
                icon: Icons.percent,
                color: AppColors.warning,
                subtitle: 'Based on selling price',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfitabilityView() {
    final colorScheme = Theme.of(context).colorScheme;
    // Filter finished goods only for profitability usually
    final finishedGoods = _allProducts
        .where((p) => p.itemType == ProductType.finishedGood)
        .toList();

    // Sort by Margin % High to Low
    finishedGoods.sort((a, b) {
      final marginA = _calculateMargin(a);
      final marginB = _calculateMargin(b);
      return marginB.compareTo(marginA);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: finishedGoods.length,
      itemBuilder: (context, index) {
        final product = finishedGoods[index];
        final margin = _calculateMargin(product);
        final cost = product.averageCost ?? product.purchasePrice ?? 0;

        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getMarginColor(margin).withValues(alpha: 0.1),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: _getMarginColor(margin),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'SP: ₹${product.price} | CP: ₹${cost.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${margin.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _getMarginColor(margin),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Margin',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
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

  double _calculateMargin(Product p) {
    final cost = p.averageCost ?? p.purchasePrice ?? 0;
    final price = p.price;
    // Avoid divide by zero if price is 0 or negative (invalid data)
    if (price <= 0 || cost < 0) return 0;
    return ((price - cost) / price) * 100;
  }

  Color _getMarginColor(double margin) {
    if (margin > 40) return AppColors.success;
    if (margin > 20) return AppColors.info;
    if (margin > 0) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildVelocityView() {
    final colorScheme = Theme.of(context).colorScheme;
    // Fast Moving: High quantity out in last 30 days
    // Slow Moving: Low/Zero quantity out

    final sortedProducts = List<Product>.from(_allProducts);

    // Sort by Velocity High to Low
    sortedProducts.sort((a, b) {
      final velA = _productVelocity[a.id] ?? 0;
      final velB = _productVelocity[b.id] ?? 0;
      return velB.compareTo(velA);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final product = sortedProducts[index];
        final velocity = _productVelocity[product.id] ?? 0;
        final isSlow = velocity == 0;

        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSlow ? Icons.motion_photos_off : Icons.local_fire_department,
                color: isSlow
                    ? colorScheme.onSurfaceVariant
                    : AppColors.warning,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isSlow ? 'No movement in 30 days' : 'Last 30 days sales',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${velocity.toStringAsFixed(0)} ${product.baseUnit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isSlow ? 'Stagnant' : 'Moving',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSlow ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStockHealthView() {
    // Low Stock vs Overstock
    // Overstock logic: if Stock > 3 * Velocity (assuming 30 day velocity) -> > 90 days inventory

    final lowStock = _allProducts.where((p) {
      final threshold = p.reorderLevel ?? 10;
      return p.stock <= threshold;
    }).toList();

    final overStock = _allProducts.where((p) {
      final velocity = _productVelocity[p.id] ?? 0;
      if (velocity == 0 && p.stock > 0) return true; // Dead stock
      if (velocity > 0 && p.stock > (velocity * 3)) {
        return true; // > 3 months stock
      }
      return false;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHealthSection(
          'Low Stock Alert',
          lowStock,
          AppColors.error,
          'Immediate Reorder Needed',
        ),
        const SizedBox(height: 24),
        _buildHealthSection(
          'Overstock / Dead Stock',
          overStock,
          AppColors.warning,
          '> 90 days inventory or no movement',
        ),
      ],
    );
  }

  Widget _buildHealthSection(
    String title,
    List<Product> items,
    Color color,
    String subtitle,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_rounded, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, bottom: 12),
          child: Text(
            subtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              'No items found.',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          ...items
              .take(5)
              .map(
                (p) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        'Stock: ${p.stock.toStringAsFixed(0)} ${p.baseUnit}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        if (items.length > 5)
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 8),
            child: Text(
              '+ ${items.length - 5} more items',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}


