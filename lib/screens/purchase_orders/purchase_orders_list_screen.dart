import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/purchase_order_service.dart';
import '../../models/types/purchase_order_types.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class PurchaseOrdersListScreen extends StatefulWidget {
  const PurchaseOrdersListScreen({super.key});

  @override
  State<PurchaseOrdersListScreen> createState() =>
      _PurchaseOrdersListScreenState();
}

class _PurchaseOrdersListScreenState extends State<PurchaseOrdersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<PurchaseOrder> _allOrders = [];
  List<PurchaseOrder> _filteredOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<PurchaseOrderService>();
      // Add timeout to prevent infinite loops
      final orders = await service.getAllPurchaseOrders().timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );

      // Sort by date desc
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _allOrders = orders;
          _filterOrders();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Only show error if it's not just empty
        debugPrint('Error loading orders: $e');
      }
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = _allOrders.where((po) {
        final matchesSearch =
            po.poNumber.toLowerCase().contains(query) ||
            po.supplierName.toLowerCase().contains(query);

        return matchesSearch;
      }).toList();
    });
  }

  List<PurchaseOrder> _getOrdersForTab(int tabIndex) {
    if (tabIndex == 0) return _filteredOrders; // All

    PurchaseOrderStatus? targetStatus;

    switch (tabIndex) {
      case 1:
        targetStatus = PurchaseOrderStatus.draft;
        break;
      case 2:
        targetStatus = PurchaseOrderStatus.ordered;
        break;
      case 3:
        targetStatus = PurchaseOrderStatus.partiallyReceived;
        break;
      case 4:
        targetStatus = PurchaseOrderStatus.received;
        break;
      default:
        targetStatus = PurchaseOrderStatus.draft;
    }

    return _filteredOrders.where((po) {
      if (targetStatus != null) {
        return po.status == targetStatus;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Purchase Orders',
            subtitle: 'Manage and track material supply chain',
            icon: Icons.shopping_cart_checkout_rounded,
            color: theme.colorScheme.primary,
            actions: [
              CustomButton(
                label: 'CREATE PO',
                icon: Icons.add_rounded,
                onPressed: () async {
                  await context.pushNamed('purchase_order_new');
                  _loadOrders();
                },
              ),
            ],
          ),

          Container(
            height: 60,
            alignment: Alignment.centerLeft,
            child: ThemedTabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              tabs: const [
                Tab(text: 'ALL'),
                Tab(text: 'DRAFT'),
                Tab(text: 'ORDERED'),
                Tab(text: 'PARTIAL'),
                Tab(text: 'RECEIVED'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: CustomTextField(
              label: 'SEARCH ORDERS',
              hintText: 'Search by PO number or supplier...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
              onChanged: (v) => _filterOrders(),
              isDense: true,
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(5, (index) {
                      final orders = _getOrdersForTab(index);
                      return _buildOrderList(orders);
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<PurchaseOrder> orders) {
    if (orders.isEmpty) {
      final theme = Theme.of(context);
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'No Purchase Orders Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create your first purchase order to start\ntracking material supply.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildStep(
                          1,
                          'Select Supplier',
                          'Choose from your registered\nsuppliers',
                          AppColors.info,
                        ),
                        _buildStep(
                          2,
                          'Add Items',
                          'Select products and quantities\n',
                          AppColors.info,
                        ),
                        _buildStep(
                          3,
                          'Create Order',
                          'Save and send to supplier\n',
                          AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildStep(int number, String title, String subtitle, Color color) {
    final theme = Theme.of(context);
    return GlassContainer(
      width: 180,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildGroupedOrderList(List<PurchaseOrder> orders) {
    final theme = Theme.of(context);
    final Map<String, List<PurchaseOrder>> grouped = {};
    for (var order in orders) {
      if (!grouped.containsKey(order.supplierName)) {
        grouped[order.supplierName] = [];
      }
      grouped[order.supplierName]!.add(order);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: grouped.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final supplierName = grouped.keys.elementAt(index);
        final supplierOrders = grouped[supplierName]!;
        final totalDue = supplierOrders.fold(
          0.0,
          (sum, po) => sum + po.totalAmount,
        );

        return AnimatedCard(
          child: GlassContainer(
            borderRadius: 24,
            child: ExpansionTile(
              initiallyExpanded: true,
              shape: const Border(),
              title: Text(
                supplierName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                'Total Due: ₹${totalDue.toStringAsFixed(2)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
              children: supplierOrders.map((order) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _buildOrderCard(order, isCompact: true),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(PurchaseOrder order, {bool isCompact = false}) {
    final theme = Theme.of(context);
    Color statusColor;
    switch (order.status) {
      case PurchaseOrderStatus.draft:
        statusColor = AppColors.lightTextMuted;
        break;
      case PurchaseOrderStatus.ordered:
        statusColor = AppColors.warning;
        break;
      case PurchaseOrderStatus.partiallyReceived:
        statusColor = Colors.cyan;
        break;
      case PurchaseOrderStatus.received:
        statusColor = const Color(0xFF10B981); // Emerald
        break;
      case PurchaseOrderStatus.cancelled:
        statusColor = theme.colorScheme.error;
        break;
    }

    final orderedQty = order.items.fold<double>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final receivedQty = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.receivedQuantity ?? 0),
    );
    final invoiceNumber = order.supplierInvoiceNumber?.trim() ?? '';
    final invoiceDateText = _formatOptionalDate(order.invoiceDate);

    return AnimatedCard(
      child: GlassContainer(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () async {
            await context.pushNamed(
              'purchase_order_details',
              pathParameters: {'poId': order.id},
            );
            _loadOrders();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                            order.poNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                              'MMM d, yyyy',
                            ).format(DateTime.parse(order.createdAt)),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(order, statusColor),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.supplierName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        invoiceNumber.isEmpty
                            ? 'Invoice: -'
                            : 'Invoice: $invoiceNumber',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      invoiceDateText == null
                          ? 'Date: -'
                          : 'Date: $invoiceDateText',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Ordered: ${orderedQty.toStringAsFixed(2)} | Received: ${receivedQty.toStringAsFixed(2)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PurchaseOrder order, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            order.status.value.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String? _formatOptionalDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('MMM d, yyyy').format(parsed);
  }
}
