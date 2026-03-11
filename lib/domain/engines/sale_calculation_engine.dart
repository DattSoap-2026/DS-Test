import '../../models/types/sales_types.dart';

class LineTotals {
  final SaleItemForUI item;
  final double subtotal;
  final double itemDiscount;
  final double primaryDiscountShare;
  final double additionalDiscountShare;
  final double net;
  final double tax;
  final double total;

  LineTotals({
    required this.item,
    required this.subtotal,
    required this.itemDiscount,
    required this.primaryDiscountShare,
    required this.additionalDiscountShare,
    required this.net,
    required this.tax,
    required this.total,
  });

  Map<String, dynamic> toPersistedMap() {
    return {
      'productId': item.productId,
      'name': item.name,
      'quantity': item.quantity,
      'price': item.price,
      'secondaryPrice': item.secondaryPrice ?? 0.0,
      'baseUnit': item.baseUnit,
      'secondaryUnit': item.secondaryUnit,
      'conversionFactor': item.conversionFactor ?? 1.0,
      'isFree': item.isFree,
      'discount': item.discount,
      'schemeName': item.schemeName,
      'lineSubtotal': subtotal,
      'lineItemDiscountAmount': itemDiscount,
      'linePrimaryDiscountShare': primaryDiscountShare,
      'lineAdditionalDiscountShare': additionalDiscountShare,
      'lineNetAmount': net,
      'lineTaxAmount': tax,
      'lineTotalAmount': total,
    };
  }
}

class SaleCalculationResult {
  final List<LineTotals> lines;
  final double subtotal;
  final double itemDiscountTotal;
  final double discountAmount;
  final double additionalDiscountAmount;
  final double taxableAmount;
  final double totalGstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;

  SaleCalculationResult({
    required this.lines,
    required this.subtotal,
    required this.itemDiscountTotal,
    required this.discountAmount,
    required this.additionalDiscountAmount,
    required this.taxableAmount,
    required this.totalGstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
  });
}

class SaleCalculationEngine {
  double _round2(num value) => (value * 100).roundToDouble() / 100;

  List<double> allocateProportionally(
    List<double> rawValues,
    double targetRounded,
  ) {
    if (rawValues.isEmpty) return [];
    final targetCents = (targetRounded * 100).round();
    final floors = rawValues.map((v) => (v * 100).floor()).toList();
    var current = floors.fold<int>(0, (a, b) => a + b);
    var remainder = targetCents - current;

    final residuals = rawValues.asMap().entries.map((entry) {
      final cents = entry.value * 100;
      final floor = floors[entry.key];
      return MapEntry(entry.key, cents - floor);
    }).toList()..sort((a, b) => b.value.compareTo(a.value));

    final result = List<int>.from(floors);

    var idx = 0;
    while (remainder > 0 && residuals.isNotEmpty) {
      result[residuals[idx].key] += 1;
      remainder--;
      idx = (idx + 1) % residuals.length;
    }

    while (remainder < 0 && residuals.isNotEmpty) {
      for (final entry in residuals) {
        if (remainder == 0) break;
        if (result[entry.key] > 0) {
          result[entry.key] -= 1;
          remainder++;
        }
      }
      if (remainder < 0) break;
    }

    return result.map((c) => c / 100).toList();
  }

  SaleCalculationResult calculateSale({
    required List<SaleItemForUI> items,
    required double discountPercentage,
    required double additionalDiscountPercentage,
    required double gstPercentage,
    required String gstType,
  }) {
    final subtotalRaw = <double>[];
    final itemDiscountsRaw = <double>[];

    for (final item in items) {
      final actualSecondaryPrice = item.secondaryPrice ?? 0.0;
      final actualConversionFactor = item.conversionFactor ?? 1.0;
      double lineSubtotal = 0;
      if (item.isFree) {
        lineSubtotal = 0;
      } else if (actualSecondaryPrice > 0 &&
          actualConversionFactor > 0 &&
          item.quantity >= actualConversionFactor) {
        final secondaryUnits = (item.quantity / actualConversionFactor).floor();
        final baseUnits = (item.quantity % actualConversionFactor).toInt();
        lineSubtotal =
            (secondaryUnits * actualSecondaryPrice) + (baseUnits * item.price);
      } else {
        lineSubtotal = item.price * item.quantity;
      }
      final itemDiscount = lineSubtotal * (item.discount / 100);
      subtotalRaw.add(lineSubtotal);
      itemDiscountsRaw.add(itemDiscount);
    }

    final subtotalRounded = _round2(
      subtotalRaw.fold<double>(0.0, (a, b) => a + b),
    );
    final itemDiscountTotalRaw = itemDiscountsRaw.fold<double>(
      0.0,
      (a, b) => a + b,
    );
    final itemDiscountRounded = _round2(itemDiscountTotalRaw);

    final lineSubtotalRounded = allocateProportionally(
      subtotalRaw,
      subtotalRounded,
    );
    final lineItemDiscountRounded = allocateProportionally(
      itemDiscountsRaw,
      itemDiscountRounded,
    );

    final afterItemRaw = <double>[];
    for (var i = 0; i < lineSubtotalRounded.length; i++) {
      afterItemRaw.add(lineSubtotalRounded[i] - lineItemDiscountRounded[i]);
    }
    final afterItemTotalRaw = afterItemRaw.fold(0.0, (a, b) => a + b);

    final validDiscountPercentage = discountPercentage.clamp(0.0, 100.0);
    final validAdditionalDiscountPercentage = additionalDiscountPercentage
        .clamp(0.0, 100.0);

    final discountAmountRaw =
        afterItemTotalRaw * (validDiscountPercentage / 100);
    final discountAmountRounded = _round2(discountAmountRaw);

    final primarySharesRaw = afterItemRaw
        .map<double>(
          (val) => afterItemTotalRaw == 0
              ? 0
              : (val / afterItemTotalRaw) * discountAmountRaw,
        )
        .toList();
    final primarySharesRounded = allocateProportionally(
      primarySharesRaw,
      discountAmountRounded,
    );

    final afterPrimaryRaw = <double>[];
    for (var i = 0; i < afterItemRaw.length; i++) {
      afterPrimaryRaw.add(afterItemRaw[i] - primarySharesRounded[i]);
    }
    final afterPrimaryTotalRaw = afterPrimaryRaw.fold(0.0, (a, b) => a + b);

    final additionalDiscountRaw =
        afterPrimaryTotalRaw * (validAdditionalDiscountPercentage / 100);
    final additionalDiscountRounded = _round2(additionalDiscountRaw);

    final additionalSharesRaw = afterPrimaryRaw
        .map<double>(
          (val) => afterPrimaryTotalRaw == 0
              ? 0
              : (val / afterPrimaryTotalRaw) * additionalDiscountRaw,
        )
        .toList();
    final additionalSharesRounded = allocateProportionally(
      additionalSharesRaw,
      additionalDiscountRounded,
    );

    final lineNetRounded = <double>[];
    for (var i = 0; i < afterPrimaryRaw.length; i++) {
      lineNetRounded.add(afterPrimaryRaw[i] - additionalSharesRounded[i]);
    }

    final taxableAmountRounded = _round2(
      lineNetRounded.fold(0.0, (a, b) => a + b),
    );

    double totalGstRounded = 0;
    double cgstAmount = 0;
    double sgstAmount = 0;
    double igstAmount = 0;
    if (gstType != 'None' && gstPercentage > 0) {
      final gstRaw = taxableAmountRounded * (gstPercentage / 100);
      totalGstRounded = _round2(gstRaw);
      if (gstType == 'CGST+SGST') {
        cgstAmount = _round2(totalGstRounded / 2);
        sgstAmount = _round2(totalGstRounded - cgstAmount);
      } else if (gstType == 'IGST') {
        igstAmount = totalGstRounded;
      }
    }

    final taxSharesRaw = lineNetRounded
        .map<double>(
          (val) => taxableAmountRounded == 0
              ? 0
              : (val / taxableAmountRounded) * totalGstRounded,
        )
        .toList();
    final taxSharesRounded = allocateProportionally(
      taxSharesRaw,
      totalGstRounded,
    );

    final lines = <LineTotals>[];
    for (var i = 0; i < items.length; i++) {
      final totalWithTax = lineNetRounded[i] + taxSharesRounded[i];
      lines.add(
        LineTotals(
          item: items[i],
          subtotal: lineSubtotalRounded[i],
          itemDiscount: lineItemDiscountRounded[i],
          primaryDiscountShare: primarySharesRounded[i],
          additionalDiscountShare: additionalSharesRounded[i],
          net: lineNetRounded[i],
          tax: taxSharesRounded[i],
          total: _round2(totalWithTax),
        ),
      );
    }

    final totalAmountRounded = _round2(
      lines.fold<double>(0.0, (acc, l) => acc + l.total),
    );

    return SaleCalculationResult(
      lines: lines,
      subtotal: subtotalRounded,
      itemDiscountTotal: itemDiscountRounded,
      discountAmount: discountAmountRounded,
      additionalDiscountAmount: additionalDiscountRounded,
      taxableAmount: taxableAmountRounded,
      totalGstAmount: totalGstRounded,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      totalAmount: totalAmountRounded,
    );
  }
}
