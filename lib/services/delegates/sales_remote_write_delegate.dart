import 'package:cloud_firestore/cloud_firestore.dart';

class SalesRemoteWriteDelegate {
  SalesRemoteWriteDelegate({
    required FirebaseFirestore firestore,
    required Future<void> Function({
      required String saleId,
      required String recipientType,
      required String salesmanUid,
      required List<Map<String, dynamic>> items,
      String? recipientSalesmanUid,
      String? actorUid,
      String? actorLegacyAppUserId,
    })
    ensureSaleInventoryAppliedIfNeeded,
    required Future<void> Function({
      required String saleId,
      required String previousRecipientType,
      required String nextRecipientType,
      required String salesmanUid,
      required List<Map<String, dynamic>> previousItems,
      required List<Map<String, dynamic>> nextItems,
      required String commandKey,
      String? actorUid,
      String? actorLegacyAppUserId,
    })
    ensureSaleEditInventoryAppliedIfNeeded,
    required Map<String, dynamic> Function(Map<String, dynamic> payload)
    stripEditSyncMetadata,
  }) : _firestore = firestore,
       _ensureSaleInventoryAppliedIfNeeded =
           ensureSaleInventoryAppliedIfNeeded,
       _ensureSaleEditInventoryAppliedIfNeeded =
           ensureSaleEditInventoryAppliedIfNeeded,
       _stripEditSyncMetadata = stripEditSyncMetadata;

  final FirebaseFirestore _firestore;
  final Future<void> Function({
    required String saleId,
    required String recipientType,
    required String salesmanUid,
    required List<Map<String, dynamic>> items,
    String? recipientSalesmanUid,
    String? actorUid,
    String? actorLegacyAppUserId,
  })
  _ensureSaleInventoryAppliedIfNeeded;
  final Future<void> Function({
    required String saleId,
    required String previousRecipientType,
    required String nextRecipientType,
    required String salesmanUid,
    required List<Map<String, dynamic>> previousItems,
    required List<Map<String, dynamic>> nextItems,
    required String commandKey,
    String? actorUid,
    String? actorLegacyAppUserId,
  })
  _ensureSaleEditInventoryAppliedIfNeeded;
  final Map<String, dynamic> Function(Map<String, dynamic> payload)
  _stripEditSyncMetadata;

  static const String salesCollection = 'sales';

  Future<void> performSyncAdd(Map<String, dynamic> data) async {
    final recipientType = data['recipientType'];
    final seriesType = recipientType == 'customer' ? 'Sale' : 'Dispatch';

    final salesmanId = data['salesmanId']?.toString();
    if (salesmanId == null || salesmanId.isEmpty) {
      throw Exception('Salesman ID is missing in sync payload');
    }

    final saleId = data['id']?.toString();
    if (saleId == null || saleId.isEmpty) {
      throw Exception('Sale ID is missing in sync payload');
    }

    final itemsRaw = data['items'];
    if (itemsRaw is! List) {
      throw Exception('Items is missing or invalid in sync payload');
    }
    final items = itemsRaw.cast<Map<String, dynamic>>();

    final batch = _firestore.batch();

    final salesmanRef = _firestore.collection('users').doc(salesmanId);
    final salesmanSnap = await salesmanRef.get();
    if (!salesmanSnap.exists) {
      throw Exception('User (Salesman/Creator) not found.');
    }
    final salesmanData = salesmanSnap.data() ?? const <String, dynamic>{};
    final salesmanRole = (salesmanData['role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final isAdminRole = salesmanRole == 'admin' || salesmanRole == 'owner';
    final canWriteTransactionSeries = isAdminRole;
    final canWriteStockMovements =
        isAdminRole ||
        salesmanRole == 'sales manager' ||
        salesmanRole == 'production manager' ||
        salesmanRole == 'dealer manager' ||
        salesmanRole == 'dispatch manager' ||
        salesmanRole == 'store incharge' ||
        salesmanRole == 'production supervisor' ||
        salesmanRole == 'bhatti supervisor';

    final seriesRef = _firestore
        .collection('transaction_series')
        .doc(seriesType);
    Map<String, dynamic>? seriesData;
    if (canWriteTransactionSeries) {
      final seriesSnap = await seriesRef.get();
      if (seriesSnap.exists) {
        seriesData = seriesSnap.data();
      }
    }

    final saleRef = _firestore.collection(salesCollection).doc(saleId);
    final existingSaleSnap = await saleRef.get();
    if (existingSaleSnap.exists) {
      return;
    }

    final salePayload = Map<String, dynamic>.from(data);
    salePayload.remove('isSynced');
    salePayload['status'] = salePayload['status'] == 'pending_sync'
        ? 'completed'
        : salePayload['status'];

    if (seriesData != null) {
      final sData = seriesData;
      final current = sData['current'] ?? 0;
      final next = current + 1;
      batch.update(seriesRef, {'current': next});
      salePayload['humanReadableId'] = '${sData['prefix'] ?? "INV"}-$next';
    }

    batch.set(saleRef, salePayload);

    await _ensureSaleInventoryAppliedIfNeeded(
      saleId: saleId,
      recipientType: recipientType.toString(),
      salesmanUid: salesmanId,
      items: items,
      recipientSalesmanUid: data['recipientId']?.toString(),
      actorUid: salesmanId,
      actorLegacyAppUserId: data['editedBy']?.toString(),
    );

    if (canWriteStockMovements) {
      final movementSource = (data['saleType'] == 'DIRECT_DEALER')
          ? 'sale'
          : 'dispatch';
      for (final item in items) {
        final movementRef = _firestore.collection('stock_movements').doc();
        batch.set(movementRef, {
          'type': 'out',
          'source': movementSource,
          'productId': item['productId'],
          'productName': item['name'],
          'quantity': item['quantity'],
          'referenceId': data['id'],
          'referenceNumber': salePayload['humanReadableId'],
          'referenceType': 'sale',
          'notes': 'Sync: Sale to ${data['recipientName']}',
          'createdBy': salesmanId,
          'createdByName': data['salesmanName'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    if (recipientType == 'customer') {
      final totalAmt = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      if (totalAmt > 0 &&
          (data['recipientId'] as String?)?.isNotEmpty == true) {
        final customerRef = _firestore
            .collection('customers')
            .doc(data['recipientId']);
        final customerSnap = await customerRef.get();
        if (customerSnap.exists) {
          batch.update(customerRef, {
            'balance': FieldValue.increment(totalAmt),
          });
        }
      }
    }

    await batch.commit();
  }

  Future<void> performSyncEdit(Map<String, dynamic> data) async {
    final saleId = data['id']?.toString().trim();
    if (saleId == null || saleId.isEmpty) {
      throw Exception('Sale ID is required for edit sync');
    }

    final saleRef = _firestore.collection(salesCollection).doc(saleId);
    final precheck = await saleRef.get();
    if (!precheck.exists) {
      final createPayload = _stripEditSyncMetadata(data);
      await performSyncAdd(createPayload);
      return;
    }

    final batch = _firestore.batch();
    final saleSnap = await saleRef.get();
    if (!saleSnap.exists) {
      throw Exception('Sale not found for edit sync: $saleId');
    }
    final currentData = Map<String, dynamic>.from(
      saleSnap.data() ?? <String, dynamic>{},
    );
    final currentStatus = (currentData['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (currentStatus == 'cancelled') {
      throw Exception('Cannot edit cancelled sale: $saleId');
    }

    final recipientType =
        (data['recipientType'] ?? currentData['recipientType'] ?? '').toString();
    final recipientId =
        (data['recipientId'] ?? currentData['recipientId'] ?? '').toString();
    final previousRecipientType =
        (data['previousRecipientType'] ?? currentData['recipientType'] ?? '')
            .toString();
    final previousRecipientId =
        (data['previousRecipientId'] ?? currentData['recipientId'] ?? '')
            .toString();
    final oldTotalAmount =
        (data['oldTotalAmount'] as num? ??
                currentData['totalAmount'] as num? ??
                0)
            .toDouble();
    final newTotalAmount =
        (data['totalAmount'] as num? ?? currentData['totalAmount'] as num? ?? 0)
            .toDouble();
    final totalDelta =
        (data['totalDelta'] as num?)?.toDouble() ??
        (newTotalAmount - oldTotalAmount);
    final salesmanId = (data['salesmanId'] ?? currentData['salesmanId'] ?? '')
        .toString();
    final commandKey =
        (data['inventoryEditCommandKey'] ??
                data['editedAt'] ??
                '${saleId}_${data['updatedAt'] ?? DateTime.now().toIso8601String()}')
            .toString();
    final previousItems = (currentData['items'] is List)
        ? (currentData['items'] as List)
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList(growable: false)
        : const <Map<String, dynamic>>[];
    final nextItems = (data['items'] is List)
        ? (data['items'] as List)
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList(growable: false)
        : const <Map<String, dynamic>>[];

    await _ensureSaleEditInventoryAppliedIfNeeded(
      saleId: saleId,
      previousRecipientType: previousRecipientType,
      nextRecipientType: recipientType,
      salesmanUid: salesmanId,
      previousItems: previousItems,
      nextItems: nextItems,
      commandKey: commandKey,
      actorUid: data['editedBy']?.toString(),
      actorLegacyAppUserId: data['editedBy']?.toString(),
    );

    if (recipientType == 'customer') {
      final normalizedRecipientId = recipientId.trim();
      final normalizedPreviousRecipientId = previousRecipientId.trim();
      final recipientChanged =
          normalizedPreviousRecipientId.isNotEmpty &&
          normalizedRecipientId.isNotEmpty &&
          normalizedPreviousRecipientId != normalizedRecipientId;

      if (recipientChanged &&
          previousRecipientType.trim().toLowerCase() == 'customer') {
        if (oldTotalAmount.abs() >= 1e-9) {
          final previousCustomerRef = _firestore
              .collection('customers')
              .doc(normalizedPreviousRecipientId);
          batch.update(previousCustomerRef, {
            'balance': FieldValue.increment(-oldTotalAmount),
          });
        }
        if (newTotalAmount.abs() >= 1e-9) {
          final nextCustomerRef = _firestore
              .collection('customers')
              .doc(normalizedRecipientId);
          batch.update(nextCustomerRef, {
            'balance': FieldValue.increment(newTotalAmount),
          });
        }
      } else if (normalizedRecipientId.isNotEmpty && totalDelta.abs() >= 1e-9) {
        final customerRef = _firestore
            .collection('customers')
            .doc(normalizedRecipientId);
        batch.update(customerRef, {'balance': FieldValue.increment(totalDelta)});
      }
    }

    final salePatch = _stripEditSyncMetadata(Map<String, dynamic>.from(data))
      ..remove('id')
      ..['updatedAt'] = DateTime.now().toIso8601String();
    batch.set(saleRef, salePatch, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> dispatchSale({
    required String saleId,
    required String vehicleNumber,
  }) async {
    final saleRef = _firestore.collection(salesCollection).doc(saleId);
    final batch = _firestore.batch();
    batch.update(saleRef, {
      'vehicleNumber': vehicleNumber,
      'status': 'inTransit',
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await batch.commit();
  }

  Future<void> updateReturnedQuantity({
    required String saleId,
    required String productId,
    required int additionalReturnedQty,
  }) async {
    final saleRef = _firestore.collection(salesCollection).doc(saleId);
    final saleSnap = await saleRef.get();
    if (!saleSnap.exists) {
      return;
    }

    final data = saleSnap.data();
    if (data == null) {
      return;
    }

    final rawItems = data['items'];
    if (rawItems is! List) {
      return;
    }

    final parsedItems = <Map<String, dynamic>>[];
    for (final raw in rawItems) {
      if (raw is! Map) {
        continue;
      }
      parsedItems.add(
        Map<String, dynamic>.from(
          raw.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }
    if (parsedItems.isEmpty) {
      return;
    }

    var matchedProduct = false;
    for (final item in parsedItems) {
      if (item['productId']?.toString() == productId) {
        final currentReturned = (item['returnedQuantity'] as num?)?.toInt() ?? 0;
        item['returnedQuantity'] = currentReturned + additionalReturnedQty;
        matchedProduct = true;
        break;
      }
    }
    if (!matchedProduct) {
      return;
    }

    final batch = _firestore.batch();
    batch.update(saleRef, {'items': parsedItems});
    await batch.commit();
  }

  Future<void> cancelSale({
    required String saleId,
    required String reason,
    required String userId,
    String? nowIso,
  }) async {
    final saleRef = _firestore.collection(salesCollection).doc(saleId);
    final saleSnap = await saleRef.get();
    if (!saleSnap.exists) {
      return;
    }

    final effectiveNowIso = nowIso ?? DateTime.now().toIso8601String();
    final batch = _firestore.batch();
    batch.update(saleRef, {
      'status': 'cancelled',
      'cancelReason': reason,
      'cancelledBy': userId,
      'cancelledAt': effectiveNowIso,
      'paidAmount': 0,
      'paymentStatus': 'cancelled',
      'commissionAmount': 0,
      'updatedAt': effectiveNowIso,
    });

    final saleData = saleSnap.data();
    if ((saleData?['recipientType'] as String?) == 'customer') {
      final customerId = saleData?['recipientId']?.toString();
      if (customerId != null && customerId.isNotEmpty) {
        final totalRemote = (saleData?['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final customerRef = _firestore.collection('customers').doc(customerId);
        batch.update(customerRef, {
          'balance': FieldValue.increment(-totalRemote),
        });
      }
    }

    await batch.commit();
  }
}
