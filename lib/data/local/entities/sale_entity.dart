import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:flutter_app/models/types/sales_types.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

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
  String? sourceWarehouseId;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    final serializedItems = items
            ?.map((item) => item.toJson())
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
    return <String, dynamic>{
      'id': id,
      'humanReadableId': humanReadableId,
      'recipientType': recipientType,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'items': serializedItems,
      'itemsJson': jsonEncode(serializedItems),
      'itemProductIds': itemProductIds,
      'subtotal': subtotal,
      'itemDiscountAmount': itemDiscountAmount,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'additionalDiscountPercentage': additionalDiscountPercentage,
      'additionalDiscountAmount': additionalDiscountAmount,
      'taxableAmount': taxableAmount,
      'gstType': gstType,
      'gstPercentage': gstPercentage,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'totalAmount': totalAmount,
      'roundOff': roundOff,
      'tripId': tripId,
      'saleType': saleType,
      'createdByRole': createdByRole,
      'status': status,
      'dispatchRequired': dispatchRequired,
      'vehicleNumber': vehicleNumber,
      'route': route,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'createdAt': createdAt,
      'paidAmount': paidAmount,
      'paymentStatus': paymentStatus,
      'month': month,
      'year': year,
      'cancelReason': cancelReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt,
      'commissionAmount': commissionAmount,
      'commissionType': commissionType,
      'sourceWarehouseId': sourceWarehouseId,
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  /// Builds an entity from a sync-safe json map.
  static SaleEntity fromJson(Map<String, dynamic> json) {
    final sale = SaleEntity()
      ..id = parseString(json['id'])
      ..humanReadableId = json['humanReadableId']?.toString()
      ..recipientType = parseString(json['recipientType'])
      ..recipientId = parseString(json['recipientId'])
      ..recipientName = parseString(json['recipientName'])
      ..items = _decodeItems(json)
      ..itemProductIds = parseStringList(json['itemProductIds'])
      ..subtotal = json['subtotal'] == null ? null : parseDouble(json['subtotal'])
      ..itemDiscountAmount = json['itemDiscountAmount'] == null
          ? null
          : parseDouble(json['itemDiscountAmount'])
      ..discountPercentage = json['discountPercentage'] == null
          ? null
          : parseDouble(json['discountPercentage'])
      ..discountAmount =
          json['discountAmount'] == null ? null : parseDouble(json['discountAmount'])
      ..additionalDiscountPercentage =
          json['additionalDiscountPercentage'] == null
              ? null
              : parseDouble(json['additionalDiscountPercentage'])
      ..additionalDiscountAmount = json['additionalDiscountAmount'] == null
          ? null
          : parseDouble(json['additionalDiscountAmount'])
      ..taxableAmount = json['taxableAmount'] == null
          ? null
          : parseDouble(json['taxableAmount'])
      ..gstType = json['gstType']?.toString()
      ..gstPercentage =
          json['gstPercentage'] == null ? null : parseDouble(json['gstPercentage'])
      ..cgstAmount = json['cgstAmount'] == null ? null : parseDouble(json['cgstAmount'])
      ..sgstAmount = json['sgstAmount'] == null ? null : parseDouble(json['sgstAmount'])
      ..igstAmount = json['igstAmount'] == null ? null : parseDouble(json['igstAmount'])
      ..totalAmount =
          json['totalAmount'] == null ? null : parseDouble(json['totalAmount'])
      ..roundOff = json['roundOff'] == null ? null : parseDouble(json['roundOff'])
      ..tripId = json['tripId']?.toString()
      ..saleType = json['saleType']?.toString()
      ..createdByRole = json['createdByRole']?.toString()
      ..status = json['status']?.toString()
      ..dispatchRequired = json['dispatchRequired'] == null
          ? null
          : parseBool(json['dispatchRequired'])
      ..vehicleNumber = json['vehicleNumber']?.toString()
      ..route = json['route']?.toString()
      ..salesmanId = parseString(json['salesmanId'])
      ..salesmanName = parseString(json['salesmanName'])
      ..createdAt = parseString(
        json['createdAt'],
        fallback: DateTime.now().toIso8601String(),
      )
      ..paidAmount = json['paidAmount'] == null ? null : parseDouble(json['paidAmount'])
      ..paymentStatus = json['paymentStatus']?.toString()
      ..month = json['month'] == null ? null : parseInt(json['month'])
      ..year = json['year'] == null ? null : parseInt(json['year'])
      ..cancelReason = json['cancelReason']?.toString()
      ..cancelledBy = json['cancelledBy']?.toString()
      ..cancelledAt = json['cancelledAt']?.toString()
      ..commissionAmount = json['commissionAmount'] == null
          ? null
          : parseDouble(json['commissionAmount'])
      ..commissionType = json['commissionType']?.toString()
      ..sourceWarehouseId = json['sourceWarehouseId']?.toString()
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');

    final createdAtDate = DateTime.tryParse(sale.createdAt);
    sale.month ??= createdAtDate?.month;
    sale.year ??= createdAtDate?.year;
    return sale;
  }

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
      sourceWarehouseId: sourceWarehouseId,
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
      ..commissionType = sale.commissionType
      ..sourceWarehouseId = sale.sourceWarehouseId;
  }

  static List<SaleItemEntity>? _decodeItems(Map<String, dynamic> json) {
    dynamic rawItems = json['items'];
    if (rawItems == null && json['itemsJson'] is String) {
      final encoded = json['itemsJson']?.toString() ?? '';
      if (encoded.isNotEmpty) {
        try {
          rawItems = jsonDecode(encoded);
        } catch (_) {
          rawItems = const <dynamic>[];
        }
      }
    }
    if (rawItems is! List) {
      return const <SaleItemEntity>[];
    }
    return rawItems
        .whereType<Object?>()
        .map((item) => SaleItemEntity.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList(growable: false);
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

  /// Converts this embedded item into json.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'isFree': isFree,
      'discount': discount,
      'secondaryPrice': secondaryPrice,
      'conversionFactor': conversionFactor,
      'baseUnit': baseUnit,
      'secondaryUnit': secondaryUnit,
      'schemeName': schemeName,
      'returnedQuantity': returnedQuantity,
      'lineSubtotal': lineSubtotal,
      'lineItemDiscountAmount': lineItemDiscountAmount,
      'linePrimaryDiscountShare': linePrimaryDiscountShare,
      'lineAdditionalDiscountShare': lineAdditionalDiscountShare,
      'lineNetAmount': lineNetAmount,
      'lineTaxAmount': lineTaxAmount,
      'lineTotalAmount': lineTotalAmount,
      'finalBaseQuantity': finalBaseQuantity,
    };
  }

  /// Builds an embedded item from json.
  static SaleItemEntity fromJson(Map<String, dynamic> json) {
    return SaleItemEntity()
      ..productId = json['productId']?.toString()
      ..name = json['name']?.toString()
      ..quantity = json['quantity'] == null ? null : parseInt(json['quantity'])
      ..price = json['price'] == null ? null : parseDouble(json['price'])
      ..isFree = json['isFree'] == null ? null : parseBool(json['isFree'])
      ..discount = json['discount'] == null ? null : parseDouble(json['discount'])
      ..secondaryPrice = json['secondaryPrice'] == null
          ? null
          : parseDouble(json['secondaryPrice'])
      ..conversionFactor = json['conversionFactor'] == null
          ? null
          : parseDouble(json['conversionFactor'])
      ..baseUnit = json['baseUnit']?.toString()
      ..secondaryUnit = json['secondaryUnit']?.toString()
      ..schemeName = json['schemeName']?.toString()
      ..returnedQuantity = json['returnedQuantity'] == null
          ? null
          : parseInt(json['returnedQuantity'])
      ..lineSubtotal = json['lineSubtotal'] == null
          ? null
          : parseDouble(json['lineSubtotal'])
      ..lineItemDiscountAmount = json['lineItemDiscountAmount'] == null
          ? null
          : parseDouble(json['lineItemDiscountAmount'])
      ..linePrimaryDiscountShare = json['linePrimaryDiscountShare'] == null
          ? null
          : parseDouble(json['linePrimaryDiscountShare'])
      ..lineAdditionalDiscountShare =
          json['lineAdditionalDiscountShare'] == null
              ? null
              : parseDouble(json['lineAdditionalDiscountShare'])
      ..lineNetAmount =
          json['lineNetAmount'] == null ? null : parseDouble(json['lineNetAmount'])
      ..lineTaxAmount =
          json['lineTaxAmount'] == null ? null : parseDouble(json['lineTaxAmount'])
      ..lineTotalAmount = json['lineTotalAmount'] == null
          ? null
          : parseDouble(json['lineTotalAmount'])
      ..finalBaseQuantity = json['finalBaseQuantity'] == null
          ? null
          : parseInt(json['finalBaseQuantity']);
  }
}
