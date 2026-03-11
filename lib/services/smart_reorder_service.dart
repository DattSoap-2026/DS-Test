import 'base_service.dart';

const purchaseOrdersCollection = 'purchase_orders';

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
  SmartReorderService(super.firebase);

  List<ReorderSuggestion> getReorderSuggestions(
    List<Map<String, dynamic>> products,
  ) {
    final suggestions = <ReorderSuggestion>[];

    for (var product in products) {
      if (product['status'] != 'active') continue;

      final stock = (product['stock'] as num? ?? 0).toDouble();
      final reorderLevel = (product['reorderLevel'] as num? ?? 0).toDouble();

      if (reorderLevel <= 0) continue; // Skip if not set

      if (stock <= reorderLevel) {
        final stockAlertLevel = (product['stockAlertLevel'] as num? ?? 0)
            .toDouble();
        String priority = 'medium';
        if (stockAlertLevel > 0 && stock <= stockAlertLevel) {
          priority = 'critical';
        }

        // Target = reorderLevel * 1.2
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

    final firestore = db;
    if (firestore == null) {
      return {'success': false, 'message': 'Offline', 'createdCount': 0};
    }

    final batch = firestore.batch();
    int poCount = 0;

    try {
      // Create PO for each supplier
      final now = DateTime.now();

      for (var entry in supplierGroups.entries) {
        final supplierId = entry.key;
        final group = entry.value;
        final poRef = firestore.collection(purchaseOrdersCollection).doc();

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
            .toList();

        final poData = {
          'id': poRef.id,
          'orderNumber': 'PO-${now.millisecondsSinceEpoch}-${poCount + 1}',
          'supplierId': supplierId,
          'supplierName': group['supplierName'],
          'status': 'Draft',
          'orderDate': now.toIso8601String(),
          'expectedDeliveryDate': now
              .add(const Duration(days: 7))
              .toIso8601String(),
          'items': items,
          'totalAmount': 0,
          'notes': 'Auto-generated via Smart Reorder',
          'createdBy': {'id': userId, 'name': userName},
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        batch.set(poRef, poData);
        poCount++;
      }

      // Unknown Supplier PO
      if (unknownSupplierItems.isNotEmpty) {
        final poRef = firestore.collection(purchaseOrdersCollection).doc();
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
            .toList();

        final poData = {
          'id': poRef.id,
          'orderNumber': 'PO-${now.millisecondsSinceEpoch}-GEN',
          'supplierId': 'unknown',
          'supplierName': 'Unknown Supplier (Please Assign)',
          'status': 'Draft',
          'orderDate': now.toIso8601String(),
          'items': items,
          'totalAmount': 0,
          'notes': 'Auto-generated (No Supplier Linked)',
          'createdBy': {'id': userId, 'name': userName},
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };
        batch.set(poRef, poData);
        poCount++;
      }

      await batch.commit();
      return {
        'success': true,
        'message': 'Successfully created $poCount Draft POs.',
        'createdCount': poCount,
      };
    } catch (e) {
      handleError(e, 'createBulkReorders');
      return {'success': false, 'message': e.toString(), 'createdCount': 0};
    }
  }
}
