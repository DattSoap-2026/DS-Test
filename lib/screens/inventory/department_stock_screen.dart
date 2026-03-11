import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/unified_card.dart';
import '../../data/local/entities/department_stock_entity.dart';

class DepartmentStockScreen extends StatefulWidget {
  const DepartmentStockScreen({super.key});

  @override
  State<DepartmentStockScreen> createState() => _DepartmentStockScreenState();
}

class _DepartmentStockScreenState extends State<DepartmentStockScreen> {
  List<DepartmentStockEntity> _stocks = [];
  bool _isLoading = true;
  String? _userDepartment;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      final db = context.read<DatabaseService>();

      _userDepartment = user?.department?.toLowerCase();

      if (_userDepartment == null) {
        setState(() {
          _stocks = [];
          _isLoading = false;
        });
        return;
      }

      final allStocks = await db.db.departmentStockEntitys.where().findAll();
      final stocks = allStocks
          .where(
            (s) =>
                s.departmentName == _userDepartment &&
                !s.isDeleted &&
                s.stock > 0,
          )
          .toList();

      setState(() {
        _stocks = stocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Department Stock',
            subtitle: _userDepartment != null
                ? 'Stock issued to ${_userDepartment!.toUpperCase()}'
                : 'No department assigned',
            actions: [
              IconButton(
                onPressed: _loadStocks,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stocks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stock issued to this department',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadStocks,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _stocks.length,
                      itemBuilder: (context, index) {
                        final stock = _stocks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UnifiedCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stock.productName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Product ID: ${stock.productId}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${stock.stock.toStringAsFixed(2)} ${stock.unit}',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                    Text(
                                      'Available',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
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
          ),
        ],
      ),
    );
  }
}
