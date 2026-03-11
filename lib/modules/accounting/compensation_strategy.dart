class CompensationPlan {
  final String module;
  final String transactionRefId;
  final List<Map<String, dynamic>> operations;

  const CompensationPlan({
    required this.module,
    required this.transactionRefId,
    required this.operations,
  });
}

class CompensationStrategy {
  static CompensationPlan salesRollbackPlan({
    required Map<String, dynamic> saleData,
    required List<Map<String, dynamic>> itemLines,
  }) {
    final saleId = (saleData['id'] ?? '').toString();
    final recipientType = (saleData['recipientType'] ?? '')
        .toString()
        .toLowerCase();
    final recipientId = (saleData['recipientId'] ?? '').toString();
    final totalAmount = _toDouble(saleData['totalAmount']);
    final operations = <Map<String, dynamic>>[];

    if (recipientType == 'customer') {
      operations.add({'type': 'reverse_allocated_stock', 'items': itemLines});
      operations.add({
        'type': 'reverse_customer_balance',
        'recipientId': recipientId,
        'amount': totalAmount,
      });
    } else {
      operations.add({'type': 'reverse_warehouse_stock', 'items': itemLines});
    }
    operations.add({'type': 'delete_local_sale', 'saleId': saleId});

    return CompensationPlan(
      module: 'sales',
      transactionRefId: saleId,
      operations: operations,
    );
  }

  static CompensationPlan purchaseReceiveRollbackPlan({
    required String purchaseOrderId,
    required List<Map<String, dynamic>> appliedBulkItems,
  }) {
    return CompensationPlan(
      module: 'purchase_orders',
      transactionRefId: purchaseOrderId,
      operations: [
        {'type': 'reverse_grn_stock', 'items': appliedBulkItems},
        {
          'type': 'restore_purchase_order_snapshot',
          'purchaseOrderId': purchaseOrderId,
        },
      ],
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
