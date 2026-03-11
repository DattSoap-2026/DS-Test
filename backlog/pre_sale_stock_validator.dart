import 'package:flutter/material.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class SaleItemForValidation {
  final String productId;
  final String name;
  final double quantity;
  final bool isFree;

  SaleItemForValidation({
    required this.productId,
    required this.name,
    required this.quantity,
    this.isFree = false,
  });
}

class PreSaleStockValidator {
  final DatabaseService _dbService;

  PreSaleStockValidator(this._dbService);

  Future<bool> validateStock({
    required String salesmanId,
    required List<SaleItemForValidation> items,
    required BuildContext context,
  }) async {
    final user = await _dbService.users
        .where()
        .idEqualTo(salesmanId)
        .findFirst();

    if (user == null) {
      if (context.mounted) {
        _showError(context, 'User not found');
      }
      return false;
    }

    final allocated = user.allocatedStockMap;
    final insufficientItems = <String>[];

    for (final item in items) {
      final stockItem = allocated[item.productId];
      final available = item.isFree
          ? (stockItem?.freeQuantity?.toDouble() ?? 0.0)
          : (stockItem?.quantity?.toDouble() ?? 0.0);

      if (available < item.quantity) {
        insufficientItems.add(
          '${item.name}: Available ${available.toStringAsFixed(1)}, '
          'Required ${item.quantity.toStringAsFixed(1)}',
        );
      }
    }

    if (insufficientItems.isNotEmpty) {
      if (context.mounted) {
        _showInsufficientStockDialog(context, insufficientItems);
      }
      return false;
    }

    return true;
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showInsufficientStockDialog(
    BuildContext context,
    List<String> items,
  ) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Insufficient Stock'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You do not have enough allocated stock for:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 What to do:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('1. Request dispatch from admin/store incharge'),
                    Text('2. Or reduce the sale quantities'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
