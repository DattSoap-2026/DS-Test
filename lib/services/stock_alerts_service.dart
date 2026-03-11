import 'package:isar/isar.dart';

import '../data/local/entities/product_entity.dart';
import 'base_service.dart';
import 'database_service.dart';

class StockAlert {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final String category;
  final double currentStock;
  final double reorderLevel;
  final double suggestedOrderQuantity;
  final String unit;
  final String? supplierId;
  final String? supplierName;
  final String priority;
  final String status;
  final String type;
  final String? notes;
  final String createdAt;

  StockAlert({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.category,
    required this.currentStock,
    required this.reorderLevel,
    required this.suggestedOrderQuantity,
    required this.unit,
    this.supplierId,
    this.supplierName,
    required this.priority,
    required this.status,
    required this.type,
    this.notes,
    required this.createdAt,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      currentStock: (json['currentStock'] as num).toDouble(),
      reorderLevel: (json['reorderLevel'] as num).toDouble(),
      suggestedOrderQuantity: (json['suggestedOrderQuantity'] as num)
          .toDouble(),
      unit: json['unit'] as String? ?? 'Pcs',
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
      type: json['type'] as String? ?? 'auto',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}

class StockAlertsService extends BaseService {
  final DatabaseService _dbService;

  StockAlertsService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  List<StockAlert> _buildAlerts(List<ProductEntity> products) {
    final now = DateTime.now().toIso8601String();
    final alerts = <StockAlert>[];

    for (final product in products) {
      if (product.status != null && product.status != 'active') continue;

      final reorderLevel = (product.reorderLevel ?? 0).toDouble();
      if (reorderLevel <= 0) continue;

      final currentStock = (product.stock ?? 0).toDouble();
      if (currentStock > reorderLevel) continue;

      final shortage = reorderLevel - currentStock;
      final suggested = (shortage * 1.5).ceilToDouble();

      String priority = 'medium';
      if (currentStock == 0) {
        priority = 'critical';
      } else if (currentStock < reorderLevel * 0.5) {
        priority = 'high';
      }

      alerts.add(
        StockAlert(
          id: product.id,
          productId: product.id,
          productName: product.name,
          productSku: product.sku,
          category: product.category ?? 'General',
          currentStock: currentStock,
          reorderLevel: reorderLevel,
          suggestedOrderQuantity: suggested,
          unit: product.baseUnit,
          supplierId: product.supplierId,
          supplierName: product.supplierName,
          priority: priority,
          status: 'pending',
          type: 'auto',
          notes:
              'Stock level ($currentStock) is below reorder point ($reorderLevel)',
          createdAt: now,
        ),
      );
    }

    return alerts;
  }

  Future<Map<String, dynamic>> checkLowStockAndCreateAlerts(
    String userId,
    String userName,
  ) async {
    // Returns { 'alertsCreated': int, 'lowStockCount': int }
    try {
      final products = await _dbService.products.where().findAll();
      if (products.isEmpty) {
        return {'alertsCreated': 0, 'lowStockCount': 0};
      }

      final alerts = _buildAlerts(products);
      return {'alertsCreated': alerts.length, 'lowStockCount': alerts.length};
    } catch (e) {
      handleError(e, 'checkLowStockAndCreateAlerts');
      return {'alertsCreated': 0, 'lowStockCount': 0};
    }
  }

  Future<List<StockAlert>> getStockAlerts({String? status}) async {
    try {
      final products = await _dbService.products.where().findAll();
      if (products.isEmpty) return [];

      final alerts = _buildAlerts(products);
      if (status == null) return alerts;
      return alerts.where((a) => a.status == status).toList();
    } catch (e) {
      handleError(e, 'getStockAlerts');
      return [];
    }
  }

  Future<int> getPendingAlertsCount() async {
    try {
      final products = await _dbService.products.where().findAll();
      if (products.isEmpty) return 0;
      return _buildAlerts(products).length;
    } catch (e) {
      handleError(e, 'getPendingAlertsCount');
      return 0;
    }
  }
}
