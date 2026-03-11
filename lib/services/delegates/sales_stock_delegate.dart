import '../../models/types/sales_types.dart';
import '../../data/local/entities/sale_entity.dart';

class SaleStockLine {
  final String productId;
  final bool isFree;
  final int quantity;
  final String name;
  final String baseUnit;

  const SaleStockLine({
    required this.productId,
    required this.isFree,
    required this.quantity,
    required this.name,
    required this.baseUnit,
  });

  SaleStockLine copyWith({
    String? productId,
    bool? isFree,
    int? quantity,
    String? name,
    String? baseUnit,
  }) {
    return SaleStockLine(
      productId: productId ?? this.productId,
      isFree: isFree ?? this.isFree,
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
      baseUnit: baseUnit ?? this.baseUnit,
    );
  }
}

class SaleStockDelta {
  final String productId;
  final bool isFree;
  final int quantityDelta;
  final String name;
  final String baseUnit;

  const SaleStockDelta({
    required this.productId,
    required this.isFree,
    required this.quantityDelta,
    required this.name,
    required this.baseUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'isFree': isFree,
      'quantityDelta': quantityDelta,
      'name': name,
      'baseUnit': baseUnit,
    };
  }
}

class SalesStockDelegate {
  String saleItemStockKey(String productId, bool isFree) =>
      '${productId.trim()}|${isFree ? 'F' : 'P'}';

  SaleStockLine? readSaleStockLine(dynamic raw) {
    if (raw is SaleItemForUI) {
      final productId = raw.productId.trim();
      if (productId.isEmpty || raw.quantity <= 0) return null;
      return SaleStockLine(
        productId: productId,
        isFree: raw.isFree,
        quantity: raw.quantity,
        name: raw.name.trim().isEmpty ? productId : raw.name.trim(),
        baseUnit: raw.baseUnit.trim().isEmpty ? 'Unit' : raw.baseUnit.trim(),
      );
    }
    if (raw is SaleItemEntity) {
      final productId = (raw.productId ?? '').trim();
      final quantity = raw.quantity ?? 0;
      if (productId.isEmpty || quantity <= 0) return null;
      final nameRaw = (raw.name ?? '').trim();
      final unitRaw = (raw.baseUnit ?? '').trim();
      return SaleStockLine(
        productId: productId,
        isFree: raw.isFree == true,
        quantity: quantity,
        name: nameRaw.isEmpty ? productId : nameRaw,
        baseUnit: unitRaw.isEmpty ? 'Unit' : unitRaw,
      );
    }
    if (raw is SaleItem) {
      final productId = raw.productId.trim();
      if (productId.isEmpty || raw.quantity <= 0) return null;
      return SaleStockLine(
        productId: productId,
        isFree: raw.isFree,
        quantity: raw.quantity,
        name: raw.name.trim().isEmpty ? productId : raw.name.trim(),
        baseUnit: raw.baseUnit.trim().isEmpty ? 'Unit' : raw.baseUnit.trim(),
      );
    }
    if (raw is Map) {
      final map = raw.map((key, value) => MapEntry(key.toString(), value));
      final productId = (map['productId'] ?? '').toString().trim();
      final quantity = (map['quantity'] as num? ?? 0).toInt();
      if (productId.isEmpty || quantity <= 0) return null;
      final nameRaw = (map['name'] ?? '').toString().trim();
      final unitRaw = (map['baseUnit'] ?? '').toString().trim();
      return SaleStockLine(
        productId: productId,
        isFree: map['isFree'] == true,
        quantity: quantity,
        name: nameRaw.isEmpty ? productId : nameRaw,
        baseUnit: unitRaw.isEmpty ? 'Unit' : unitRaw,
      );
    }
    return null;
  }

  Map<String, SaleStockLine> aggregateSaleStockLines(Iterable<dynamic> items) {
    final aggregated = <String, SaleStockLine>{};
    for (final raw in items) {
      final line = readSaleStockLine(raw);
      if (line == null) continue;
      final key = saleItemStockKey(line.productId, line.isFree);
      final existing = aggregated[key];
      if (existing == null) {
        aggregated[key] = line;
      } else {
        aggregated[key] = existing.copyWith(
          quantity: existing.quantity + line.quantity,
        );
      }
    }
    return aggregated;
  }

  List<SaleStockDelta> calculateSaleStockDeltas({
    required Iterable<dynamic> previousItems,
    required Iterable<dynamic> nextItems,
  }) {
    final previous = aggregateSaleStockLines(previousItems);
    final next = aggregateSaleStockLines(nextItems);
    final keys = <String>{...previous.keys, ...next.keys}.toList()
      ..sort((a, b) => a.compareTo(b));
    final deltas = <SaleStockDelta>[];
    for (final key in keys) {
      final prev = previous[key];
      final curr = next[key];
      final quantityDelta = (curr?.quantity ?? 0) - (prev?.quantity ?? 0);
      if (quantityDelta == 0) continue;
      final sample = curr ?? prev;
      if (sample == null) continue;
      deltas.add(
        SaleStockDelta(
          productId: sample.productId,
          isFree: sample.isFree,
          quantityDelta: quantityDelta,
          name: sample.name,
          baseUnit: sample.baseUnit,
        ),
      );
    }
    deltas.sort((a, b) {
      final byProduct = a.productId.compareTo(b.productId);
      if (byProduct != 0) return byProduct;
      if (a.isFree == b.isFree) return 0;
      return a.isFree ? 1 : -1;
    });
    return deltas;
  }
}
