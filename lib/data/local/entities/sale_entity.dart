import 'package:isar/isar.dart';
import '../base_entity.dart';
import 'package:flutter_app/models/types/sales_types.dart';

part 'sale_entity.g.dart';

@Collection()
class SaleEntity extends BaseEntity {
  SaleEntity();
  @Index()
  String? humanReadableId;

  @Index()
  late String recipientType;
  @Index()
  late String recipientId;
  late String recipientName;

  List<SaleItemEntity>? items;
  List<String>? itemProductIds;

  double? subtotal;
  double? itemDiscountAmount;
  double? discountPercentage;
  double? discountAmount;
  double? additionalDiscountPercentage;
  double? additionalDiscountAmount;
  double? taxableAmount;

  String? gstType;
  double? gstPercentage;
  double? cgstAmount;
  double? sgstAmount;
  double? igstAmount;

  double? totalAmount;
  double? roundOff;

  @Index()
  String? tripId;
  String? saleType;
  String? createdByRole;

  @Index()
  String? status;
  bool? dispatchRequired;

  String? vehicleNumber;
  String? route;

  @Index()
  late String salesmanId;
  late String salesmanName;

  @Index()
  late String createdAt;

  double? paidAmount;
  String? paymentStatus;

  int? month;
  int? year;

  // Cancellation Fields
  String? cancelReason;
  String? cancelledBy;
  String? cancelledAt;
  double? commissionAmount;
  String? commissionType;

  Sale toDomain() {
    return Sale(
      id: id,
      humanReadableId: humanReadableId,
      recipientType: recipientType,
      recipientId: recipientId,
      recipientName: recipientName,
      items: items?.map((e) => e.toDomain()).toList() ?? [],
      itemProductIds: itemProductIds ?? [],
      subtotal: subtotal ?? 0.0,
      itemDiscountAmount: itemDiscountAmount ?? 0.0,
      discountPercentage: discountPercentage ?? 0.0,
      discountAmount: discountAmount ?? 0.0,
      additionalDiscountPercentage: additionalDiscountPercentage ?? 0.0,
      additionalDiscountAmount: additionalDiscountAmount ?? 0.0,
      taxableAmount: taxableAmount ?? 0.0,
      gstType: gstType ?? 'None',
      gstPercentage: gstPercentage ?? 0.0,
      cgstAmount: cgstAmount ?? 0.0,
      sgstAmount: sgstAmount ?? 0.0,
      igstAmount: igstAmount ?? 0.0,
      totalAmount: totalAmount ?? 0.0,
      roundOff: roundOff ?? 0.0,
      tripId: tripId,
      saleType: saleType,
      createdByRole: createdByRole,
      status: status ?? 'completed',
      dispatchRequired: dispatchRequired,
      vehicleNumber: vehicleNumber,
      route: route,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
      createdAt: createdAt,
      paidAmount: paidAmount ?? 0.0,
      paymentStatus: paymentStatus ?? 'pending',
      month: month ?? DateTime.now().month,
      year: year ?? DateTime.now().year,
      cancelReason: cancelReason,
      cancelledBy: cancelledBy,
      cancelledAt: cancelledAt,
      commissionAmount: commissionAmount,
      commissionType: commissionType,
    );
  }

  factory SaleEntity.fromDomain(Sale sale) {
    return SaleEntity()
      ..id = sale.id
      ..humanReadableId = sale.humanReadableId
      ..recipientType = sale.recipientType
      ..recipientId = sale.recipientId
      ..recipientName = sale.recipientName
      ..items = sale.items.map((e) => SaleItemEntity.fromDomain(e)).toList()
      ..itemProductIds = sale.itemProductIds
      ..subtotal = sale.subtotal
      ..itemDiscountAmount = sale.itemDiscountAmount
      ..discountPercentage = sale.discountPercentage
      ..discountAmount = sale.discountAmount
      ..additionalDiscountPercentage = sale.additionalDiscountPercentage
      ..additionalDiscountAmount = sale.additionalDiscountAmount
      ..taxableAmount = sale.taxableAmount
      ..gstType = sale.gstType
      ..gstPercentage = sale.gstPercentage
      ..cgstAmount = sale.cgstAmount
      ..sgstAmount = sale.sgstAmount
      ..igstAmount = sale.igstAmount
      ..totalAmount = sale.totalAmount
      ..roundOff = sale.roundOff
      ..tripId = sale.tripId
      ..saleType = sale.saleType
      ..createdByRole = sale.createdByRole
      ..status = sale.status
      ..dispatchRequired = sale.dispatchRequired
      ..vehicleNumber = sale.vehicleNumber
      ..route = sale.route
      ..salesmanId = sale.salesmanId
      ..salesmanName = sale.salesmanName
      ..createdAt = sale.createdAt
      ..paidAmount = sale.paidAmount
      ..paymentStatus = sale.paymentStatus
      ..month = sale.month
      ..year = sale.year
      ..cancelReason = sale.cancelReason
      ..cancelledBy = sale.cancelledBy
      ..cancelledAt = sale.cancelledAt
      ..commissionAmount = sale.commissionAmount
      ..commissionType = sale.commissionType;
  }
}

@Embedded()
class SaleItemEntity {
  String? productId;
  String? name;
  int? quantity;
  double? price;
  bool? isFree;
  double? discount;
  double? secondaryPrice;
  double? conversionFactor;
  String? baseUnit;
  String? secondaryUnit;
  String? schemeName;
  int? returnedQuantity;
  double? lineSubtotal;
  double? lineItemDiscountAmount;
  double? linePrimaryDiscountShare;
  double? lineAdditionalDiscountShare;
  double? lineNetAmount;
  double? lineTaxAmount;
  double? lineTotalAmount;

  /// AUDIT LOCK: Base-unit quantity actually deducted at sale time. Immutable.
  int? finalBaseQuantity;

  SaleItemEntity();

  factory SaleItemEntity.fromDomain(SaleItem item) {
    return SaleItemEntity()
      ..productId = item.productId
      ..name = item.name
      ..quantity = item.quantity
      ..price = item.price
      ..isFree = item.isFree
      ..discount = item.discount
      ..secondaryPrice = item.secondaryPrice
      ..conversionFactor = item.conversionFactor
      ..baseUnit = item.baseUnit
      ..secondaryUnit = item.secondaryUnit
      ..schemeName = item.schemeName
      ..returnedQuantity = item.returnedQuantity
      ..lineSubtotal = item.lineSubtotal
      ..lineItemDiscountAmount = item.lineItemDiscountAmount
      ..linePrimaryDiscountShare = item.linePrimaryDiscountShare
      ..lineAdditionalDiscountShare = item.lineAdditionalDiscountShare
      ..lineNetAmount = item.lineNetAmount
      ..lineTaxAmount = item.lineTaxAmount
      ..lineTotalAmount = item.lineTotalAmount
      ..finalBaseQuantity = item.finalBaseQuantity;
  }

  SaleItem toDomain() {
    return SaleItem(
      productId: productId ?? '',
      name: name ?? '',
      quantity: quantity ?? 0,
      price: price ?? 0.0,
      isFree: isFree ?? false,
      discount: discount ?? 0.0,
      secondaryPrice: secondaryPrice,
      conversionFactor: conversionFactor,
      baseUnit: baseUnit ?? '',
      secondaryUnit: secondaryUnit,
      schemeName: schemeName,
      returnedQuantity: returnedQuantity ?? 0,
      lineSubtotal: lineSubtotal,
      lineItemDiscountAmount: lineItemDiscountAmount,
      linePrimaryDiscountShare: linePrimaryDiscountShare,
      lineAdditionalDiscountShare: lineAdditionalDiscountShare,
      lineNetAmount: lineNetAmount,
      lineTaxAmount: lineTaxAmount,
      lineTotalAmount: lineTotalAmount,
      finalBaseQuantity: finalBaseQuantity ?? quantity,
    );
  }
}
