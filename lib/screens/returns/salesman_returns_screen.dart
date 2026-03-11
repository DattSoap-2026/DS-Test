import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/inventory_service.dart';

import '../../services/returns_service.dart';
import '../../services/database_service.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/user_entity.dart';
import '../../models/types/user_types.dart';

import '../../models/types/return_types.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'customer_return_screen.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class SalesmanReturnsScreen extends StatefulWidget {
  const SalesmanReturnsScreen({super.key});

  @override
  State<SalesmanReturnsScreen> createState() => _SalesmanReturnsScreenState();
}

class _SalesmanReturnsScreenState extends State<SalesmanReturnsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final InventoryService _inventoryService;
  late final ReturnsService _returnsService;
  StreamSubscription<UserEntity?>? _userSubscription;
  AppUser? _localUser;
  String? _watchedUserId;
  String? _lastAllocSignature;
  List<StockUsageData> _stockUsage = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedReason;

  final List<String> _returnReasons = [
    'End of Day Return',
    'Vehicle Breakdown',
    'Route Cancelled',
    'Personal Emergency',
    'Damaged Stock',
    'Excess Inventory',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _inventoryService = context.read<InventoryService>();
    _returnsService = context.read<ReturnsService>();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startLocalUserWatcher();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startLocalUserWatcher() {
    final authUser = context.read<AuthProvider>().currentUser;
    if (authUser == null) return;
    if (_watchedUserId == authUser.id) return;

    _userSubscription?.cancel();
    _watchedUserId = authUser.id;

    final db = context.read<DatabaseService>();
    _userSubscription = db.users
        .watchObject(fastHash(authUser.id), fireImmediately: true)
        .listen((entity) {
          if (!mounted || entity == null) return;
          final localUser = entity.toDomain();
          final signature = entity.allocatedStockJson ?? '';
          final shouldReload = signature != _lastAllocSignature;
          _lastAllocSignature = signature;
          _localUser = localUser;
          if (shouldReload) {
            _loadData();
          }
        });
  }

  AppUser? _resolveUser() {
    return _localUser ?? context.read<AuthProvider>().currentUser;
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = _resolveUser();
      if (user != null && user.allocatedStock != null) {
        final usage = await _inventoryService.calculateStockUsage(
          user.id,
          user.allocatedStock!,
        );
        if (mounted) {
          setState(() {
            _stockUsage = usage;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stock: $e')));
      }
    }
  }

  Future<void> _submitBulkReturn() async {
    if (_selectedReason == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for return')),
      );
      return;
    }

    final availableItems = _stockUsage
        .where((item) => item.availableToday > 0)
        .toList();

    if (availableItems.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available stock to return')),
      );
      return;
    }

    if (!mounted) return;
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Bulk Return'),
        content: Text(
          'Return all ${availableItems.length} items with available stock?\n\nReason: $_selectedReason',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm Return'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      final returnItems = availableItems
          .map(
            (item) => ReturnItem(
              productId: item.productId,
              name: item.productName,
              quantity: item.availableToday,
              unit: item.baseUnit,
              price: item.price,
            ),
          )
          .toList();

      final success = await _returnsService.addReturnRequest(
        returnType: 'stock_return',
        salesmanId: user.id,
        salesmanName: user.name,
        items: returnItems,
        reason: _selectedReason!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bulk return request submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _selectedReason = null);
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Return Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Returns',
            subtitle: 'Manage stock and customer returns',
            onBack: () => context.pop(),
          ),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildReturnMyStockTab(),
                const CustomerReturnScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ThemedTabBar(
        controller: _tabController,
        labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        tabs: const [
          Tab(text: 'Return My Stock'),
          Tab(text: 'Customer Return'),
        ],
      ),
    );
  }

  Widget _buildReturnMyStockTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStockOverviewCard(),
          const SizedBox(height: 24),
          _buildCreateReturnCard(),
        ],
      ),
    );
  }

  Widget _buildStockOverviewCard() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Stock Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review your complete stock status.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _buildStockTable(),
        ],
      ),
    );
  }

  Widget _buildStockTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            children: ['Product', 'Allocated', 'Sold', 'Available']
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      h,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Data
          ..._stockUsage.map(
            (item) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Text(
                    item.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
                _buildTableText(
                  '${item.totalAllocated.toInt()} ${item.baseUnit}',
                ),
                _buildTableText('${item.totalSold.toInt()} ${item.baseUnit}'),
                _buildTableText(
                  '${item.availableToday.toInt()} ${item.baseUnit}',
                  isBold: true,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableText(String text, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color:
              color ??
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCreateReturnCard() {
    final availableToReturnCount = _stockUsage
        .where((i) => i.availableToday > 0)
        .length;

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Return Request',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your currently available stock will be requested for return.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reason for Return *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedReason),
            initialValue: _selectedReason,
            decoration: InputDecoration(
              hintText: 'Select a reason...',
              filled: true,
              fillColor:
                  Theme.of(context).inputDecorationTheme.fillColor ??
                  Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            items: _returnReasons
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (val) => setState(() => _selectedReason = val),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || availableToReturnCount == 0)
                  ? null
                  : _submitBulkReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? CircularProgressIndicator(
                      color: theme.colorScheme.onPrimary,
                    )
                  : Text(
                      'Request Return for All Available Stock ($availableToReturnCount Items)',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          if (availableToReturnCount == 0)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  'No stock available to return at this moment.',
                  style: TextStyle(color: AppColors.warning, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

