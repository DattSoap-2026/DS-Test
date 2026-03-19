import 'dart:convert';

import '../data/local/entities/purchase_order_entity.dart';
import '../data/repositories/procurement_repository.dart';
import 'base_service.dart';
import 'database_service.dart';

class ReorderSuggestion {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final String category;
  final double currentStock;
  final double reorderLevel;
  final double suggestedOrderQuantity;
  final String? unit;
  final String? supplierId;
  final String? supplierName;
  final String priority;
  final String status;
  final String type;
  bool isSelected;

  ReorderSuggestion({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.category,
    required this.currentStock,
    required this.reorderLevel,
    required this.suggestedOrderQuantity,
    this.unit,
    this.supplierId,
    this.supplierName,
    required this.priority,
    required this.status,
    required this.type,
    this.isSelected = true,
  });
}

class SmartReorderService extends BaseService {
  SmartReorderService(super.firebase)
    : _procurementRepository = ProcurementRepository(DatabaseService.instance);

  final ProcurementRepository _procurementRepository;

  List<ReorderSuggestion> getReorderSuggestions(
    List<Map<String, dynamic>> products,
  ) {
    final suggestions = <ReorderSuggestion>[];

    for (var product in products) {
      if (product['status'] != 'active') continue;

      final stock = (product['stock'] as num? ?? 0).toDouble();
      final reorderLevel = (product['reorderLevel'] as num? ?? 0).toDouble();

      if (reorderLevel <= 0) continue;

      if (stock <= reorderLevel) {
        final stockAlertLevel = (product['stockAlertLevel'] as num? ?? 0)
            .toDouble();
        String priority = 'medium';
        if (stockAlertLevel > 0 && stock <= stockAlertLevel) {
          priority = 'critical';
        }

        final target = (reorderLevel * 1.2).ceilToDouble();
        final suggestedQty = (target - stock) > 0 ? (target - stock) : 0.0;

        suggestions.add(
          ReorderSuggestion(
            id: 'alert-${product['id']}',
            productId: product['id'],
            productName: product['name'],
            productSku: product['sku'] ?? '',
            category: product['category'] ?? 'General',
            currentStock: stock,
            reorderLevel: reorderLevel,
            suggestedOrderQuantity: suggestedQty,
            unit: product['baseUnit'],
            supplierId: product['supplierId'],
            supplierName: product['supplierName'],
            priority: priority,
            status: 'pending',
            type: 'auto',
            isSelected: true,
          ),
        );
      }
    }
    return suggestions;
  }

  Future<Map<String, dynamic>> createBulkReorders(
    List<ReorderSuggestion> suggestions,
    String userId,
    String userName,
  ) async {
    if (suggestions.isEmpty) {
      return {
        'success': false,
        'message': 'No items selected',
        'createdCount': 0,
      };
    }

    final supplierGroups = <String, Map<String, dynamic>>{};
    final unknownSupplierItems = <ReorderSuggestion>[];

    for (var item in suggestions) {
      if (item.supplierId != null && item.supplierId!.isNotEmpty) {
        if (!supplierGroups.containsKey(item.supplierId)) {
          supplierGroups[item.supplierId!] = {
            'supplierName': item.supplierName ?? 'Unknown Supplier',
            'items': <ReorderSuggestion>[],
          };
        }
        (supplierGroups[item.supplierId!]!['items'] as List<ReorderSuggestion>)
            .add(item);
      } else {
        unknownSupplierItems.add(item);
      }
    }

    int poCount = 0;

    try {
      final now = DateTime.now();

      for (final entry in supplierGroups.entries) {
        final supplierId = entry.key;
        final group = entry.value;
        final items = (group['items'] as List<ReorderSuggestion>)
            .map(
              (item) => {
                'productId': item.productId,
                'name': item.productName,
                'quantity': item.suggestedOrderQuantity,
                'unit': item.unit,
                'price': 0,
                'total': 0,
              },
            )
            .toList(growable: false);

        final purchaseOrder = PurchaseOrderEntity()
          ..supplierId = supplierId
          ..supplierName = group['supplierName']?.toString() ?? 'Unknown Supplier'
          ..itemsJson = jsonEncode(items)
          ..totalAmount = 0
          ..status = 'pending'
          ..orderDate = now
          ..expectedDeliveryDate = now.add(const Duration(days: 7))
          ..notes = 'Auto-generated via Smart Reorder'
          ..createdBy = userId
          ..createdByName = userName
          ..createdAt = now;

        await _procurementRepository.savePurchaseOrder(purchaseOrder);
        poCount++;
      }

      if (unknownSupplierItems.isNotEmpty) {
        final items = unknownSupplierItems
            .map(
              (item) => {
                'productId': item.productId,
                'name': item.productName,
                'quantity': item.suggestedOrderQuantity,
                'unit': item.unit,
                'price': 0,
                'total': 0,
              },
            )
            .toList(growable: false);

        final purchaseOrder = PurchaseOrderEntity()
          ..supplierId = 'unknown'
          ..supplierName = 'Unknown Supplier (Please Assign)'
          ..itemsJson = jsonEncode(items)
          ..totalAmount = 0
          ..status = 'pending'
          ..orderDate = now
          ..notes = 'Auto-generated (No Supplier Linked)'
          ..createdBy = userId
          ..createdByName = userName
          ..createdAt = now;

        await _procurementRepository.savePurchaseOrder(purchaseOrder);
        poCount++;
      }

      return {
        'success': true,
        'message': 'Successfully created $poCount pending POs.',
        'createdCount': poCount,
      };
    } catch (e) {
      handleError(e, 'createBulkReorders');
      return {'success': false, 'message': e.toString(), 'createdCount': 0};
    }
  }
}
