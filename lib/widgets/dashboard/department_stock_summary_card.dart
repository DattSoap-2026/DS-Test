import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import '../../services/database_service.dart';
import '../../data/local/entities/department_stock_entity.dart';
import '../ui/unified_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class DepartmentStockSummaryCard extends StatefulWidget {
  const DepartmentStockSummaryCard({super.key});

  @override
  State<DepartmentStockSummaryCard> createState() => _DepartmentStockSummaryCardState();
}

class _DepartmentStockSummaryCardState extends State<DepartmentStockSummaryCard> {
  Map<String, double> _departmentTotals = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartmentStocks();
  }

  Future<void> _loadDepartmentStocks() async {
    setState(() => _isLoading = true);
    try {
      final db = context.read<DatabaseService>();
      final allStocks = await db.db.departmentStockEntitys.where().findAll();
      final stocks = allStocks.where((s) => s.stock > 0 && !s.isDeleted).toList();
      
      final totals = <String, double>{};
      for (final stock in stocks) {
        totals[stock.departmentName] = (totals[stock.departmentName] ?? 0) + stock.stock;
      }
      
      if (mounted) {
        setState(() {
          _departmentTotals = totals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return UnifiedCard(
        padding: const EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_departmentTotals.isEmpty) {
      return UnifiedCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No department stocks',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return UnifiedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_rounded, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'DEPARTMENT STOCKS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._departmentTotals.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${entry.value.toStringAsFixed(1)} units',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
