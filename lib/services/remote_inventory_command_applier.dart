import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/utils/app_logger.dart';

class _RemoteMovementLine {
  final String commandId;
  final int movementIndex;
  final String productId;
  final String? sourceLocationId;
  final String? destinationLocationId;
  final double quantityBase;
  final String movementType;
  final String? reasonCode;
  final String? referenceType;
  final String? referenceId;
  final String actorUid;
  final DateTime occurredAt;
  final bool isReversal;

  const _RemoteMovementLine({
    required this.commandId,
    required this.movementIndex,
    required this.productId,
    required this.sourceLocationId,
    required this.destinationLocationId,
    required this.quantityBase,
    required this.movementType,
    required this.reasonCode,
    required this.referenceType,
    required this.referenceId,
    required this.actorUid,
    required this.occurredAt,
    required this.isReversal,
  });
}

class _TouchedBalance {
  final String locationId;
  final String productId;
  double quantity;
  _TouchedBalance(this.locationId, this.productId, this.quantity);
}

class RemoteInventoryCommandApplier {
  final firestore.FirebaseFirestore _db;

  RemoteInventoryCommandApplier(this._db);

  Future<void> applyCommand(Map<String, dynamic> commandJson) async {
    final commandId = commandJson['commandId']?.toString();
    if (commandId == null || commandId.isEmpty) {
      throw ArgumentError('commandId is required for remote processing');
    }

    final type = commandJson['commandType']?.toString() ?? 'unknown';
    final payloadRaw = commandJson['payload'];

    Map<String, dynamic> payload = {};
    if (payloadRaw is Map<String, dynamic>) {
      payload = payloadRaw;
    } else if (payloadRaw is String) {
      payload = jsonDecode(payloadRaw) as Map<String, dynamic>;
    }

    final actorUid = commandJson['actorUid']?.toString() ?? 'system';
    final occurredAtStr = commandJson['createdAt']?.toString();
    final occurredAt = occurredAtStr != null
        ? DateTime.tryParse(occurredAtStr) ?? DateTime.now()
        : DateTime.now();

    await _db.runTransaction((tx) async {
      final cmdRef = _db
          .collection(CollectionRegistry.inventoryCommands)
          .doc(commandId);
      final cmdDoc = await tx.get(cmdRef);

      if (cmdDoc.exists && cmdDoc.data()?['appliedRemotely'] == true) {
        AppLogger.info(
          'Command $commandId already applied remotely. Skipping.',
          tag: 'RemoteCommand',
        );
        return;
      }

      final balanceSnapshot = await _loadRequiredBalances(tx, type, payload);
      final movements = _generateMovementLines(
        type,
        commandId,
        payload,
        actorUid,
        occurredAt,
        balanceSnapshot,
      );

      final touchedBalances = <String, _TouchedBalance>{};

      // Apply movements to balances
      for (final movement in movements) {
        if (movement.sourceLocationId != null) {
          final balanceId =
              '${movement.sourceLocationId}_${movement.productId}';
          final balanceRef = _db.collection('stock_balances').doc(balanceId);
          final current = balanceSnapshot[balanceId] ?? 0.0;
          final newQty = current - movement.quantityBase;
          balanceSnapshot[balanceId] = newQty;

          touchedBalances[balanceId] ??= _TouchedBalance(
            movement.sourceLocationId!,
            movement.productId,
            0.0,
          );
          touchedBalances[balanceId]!.quantity = newQty;

          tx.set(balanceRef, {
            'id': balanceId,
            'locationId': movement.sourceLocationId,
            'productId': movement.productId,
            'quantity': newQty,
            'updatedAt': firestore.FieldValue.serverTimestamp(),
          }, firestore.SetOptions(merge: true));
        }

        if (movement.destinationLocationId != null) {
          final balanceId =
              '${movement.destinationLocationId}_${movement.productId}';
          final balanceRef = _db.collection('stock_balances').doc(balanceId);
          final current = balanceSnapshot[balanceId] ?? 0.0;
          final newQty = current + movement.quantityBase;
          balanceSnapshot[balanceId] = newQty;

          touchedBalances[balanceId] ??= _TouchedBalance(
            movement.destinationLocationId!,
            movement.productId,
            0.0,
          );
          touchedBalances[balanceId]!.quantity = newQty;

          tx.set(balanceRef, {
            'id': balanceId,
            'locationId': movement.destinationLocationId,
            'productId': movement.productId,
            'quantity': newQty,
            'updatedAt': firestore.FieldValue.serverTimestamp(),
          }, firestore.SetOptions(merge: true));
        }

        // Create the movement record
        final movementDocId = '$commandId:${movement.movementIndex}';
        final movementRef = _db
            .collection(CollectionRegistry.stockMovements)
            .doc(movementDocId);
        tx.set(movementRef, {
          'id': movementDocId,
          'movementId': movementDocId,
          'commandId': commandId,
          'movementIndex': movement.movementIndex,
          'productId': movement.productId,
          'sourceLocationId': movement.sourceLocationId,
          'destinationLocationId': movement.destinationLocationId,
          'quantityBase': movement.quantityBase,
          'movementType': movement.movementType,
          'reasonCode': movement.reasonCode,
          'referenceType': movement.referenceType,
          'referenceId': movement.referenceId,
          'actorUid': movement.actorUid,
          'occurredAt': movement.occurredAt.toIso8601String(),
          'isReversal': movement.isReversal,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        }, firestore.SetOptions(merge: true));
      }

      // Projections
      for (final touched in touchedBalances.values) {
        await _applyCompatibilityProjection(
          tx,
          touched.locationId,
          touched.productId,
          touched.quantity,
          occurredAt,
        );
      }

      // Command-specific remote side-effects
      if (type == 'dispatch_create') {
        final dispatchId = payload['dispatchId']?.toString();
        if (dispatchId != null) {
          final dispatchRef = _db
              .collection(CollectionRegistry.dispatches)
              .doc(dispatchId);

          final existingDispatch = await tx.get(dispatchRef);
          if (!existingDispatch.exists) {
            final seriesRef = _db
                .collection('transaction_series')
                .doc('Dispatch');
            final seriesSnap = await tx.get(seriesRef);

            int nextNumber = 1;
            String prefix = "DSP-";
            if (seriesSnap.exists) {
              final sData = seriesSnap.data() as Map<String, dynamic>;
              nextNumber = (sData['current'] as num? ?? 0).toInt() + 1;
              prefix = sData['prefix']?.toString() ?? "DSP-";
              tx.update(seriesRef, {'current': nextNumber});
            } else {
              tx.set(seriesRef, {'current': 1, 'prefix': prefix});
            }

            final humanReadableId = "$prefix$nextNumber";

            final dispatchData = Map<String, dynamic>.from(payload);
            dispatchData.remove('items');
            dispatchData['id'] = dispatchId;
            dispatchData['dispatchId'] = humanReadableId;
            dispatchData['humanReadableId'] = humanReadableId;
            dispatchData['isSynced'] = true;
            tx.set(
              dispatchRef,
              dispatchData,
              firestore.SetOptions(merge: true),
            );

            final routeOrderId = payload['routeOrderId']?.toString();
            if (routeOrderId != null && routeOrderId.isNotEmpty) {
              final routeOrderRef = _db
                  .collection(CollectionRegistry.routeOrders)
                  .doc(routeOrderId);
              tx.set(routeOrderRef, {
                'status': 'dispatch_pending_confirmation',
                'actualDispatchId': dispatchId,
                'updatedAt': firestore.FieldValue.serverTimestamp(),
              }, firestore.SetOptions(merge: true));
            }
          }
        }
      }

      // Mark applied remotely
      final Map<String, dynamic> updateData = Map.from(commandJson);
      updateData['appliedRemotely'] = true;
      updateData['updatedAt'] = firestore.FieldValue.serverTimestamp();

      tx.set(cmdRef, updateData, firestore.SetOptions(merge: true));
    });
  }

  Future<void> _applyCompatibilityProjection(
    firestore.Transaction tx,
    String locationId,
    String productId,
    double quantity,
    DateTime occurredAt,
  ) async {
    if (locationId == 'warehouse_main') {
      final productRef = _db
          .collection(CollectionRegistry.products)
          .doc(productId);
      tx.set(productRef, {
        'stock': quantity,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      }, firestore.SetOptions(merge: true));
    } else if (locationId.startsWith('department:')) {
      final deptId = locationId.substring('department:'.length);
      final deptStockRef = _db
          .collection('department_stocks')
          .doc('${deptId}_$productId');
      tx.set(deptStockRef, {
        'id': '${deptId}_$productId',
        'departmentId': deptId,
        'departmentName': deptId, // Assuming ID is roughly the name for legacy
        'productId': productId,
        'quantity': quantity,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      }, firestore.SetOptions(merge: true));
    } else if (locationId.startsWith('salesman_van:')) {
      final salesmanUid = locationId.substring('salesman_van:'.length);
      final userRef = _db.collection(CollectionRegistry.users).doc(salesmanUid);

      // Need to read the user to update array inside map.
      // Firestore transactions require reads before writes.
      // To bypass doing read inside the loop, we use merge and assume top-level replace for the product key.
      tx.set(userRef, {
        'allocatedStock': {productId: quantity},
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      }, firestore.SetOptions(merge: true));
    }
  }

  Future<Map<String, double>> _loadRequiredBalances(
    firestore.Transaction tx,
    String type,
    Map<String, dynamic> payload,
  ) async {
    final Map<String, double> balances = {};
    if (type == 'opening_set_balance') {
      final locationId = payload['locationId']?.toString();
      final productId = payload['productId']?.toString();
      if (locationId != null && productId != null) {
        final balanceId = '${locationId}_$productId';
        final doc = await tx.get(
          _db.collection('stock_balances').doc(balanceId),
        );
        if (doc.exists) {
          balances[balanceId] =
              (doc.data()?['quantity'] as num?)?.toDouble() ?? 0.0;
        }
      }
    } else {
      // For relative transfers we don't strictly need existing balance to calculate delta,
      // but we need it to calculate the absolute updated balance.
      // Let's gather all involved location/product pairs.
      final pairs = <String>{};
      void addPair(String? loc, String? prod) {
        if (loc != null && prod != null) pairs.add('${loc}_$prod');
      }

      if ([
        'internal_transfer',
        'department_issue',
        'department_return',
      ].contains(type)) {
        final productId = payload['productId']?.toString();
        addPair(payload['sourceLocationId']?.toString(), productId);
        addPair(payload['destinationLocationId']?.toString(), productId);
      } else if ([
        'dispatch_create',
        'sale_complete',
        'sale_reversal',
      ].contains(type)) {
        final sourceId = payload['sourceLocationId']?.toString();
        final destId = payload['destinationLocationId']?.toString();
        final items = payload['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          final productId = item['productId']?.toString();
          addPair(sourceId, productId);
          addPair(destId, productId);
        }
      } else if ([
        'bhatti_production_complete',
        'cutting_production_complete',
      ].contains(type)) {
        final consumptions = payload['consumptions'] as List<dynamic>? ?? [];
        final outputs = payload['outputs'] as List<dynamic>? ?? [];
        final defaultConsumptionLoc = payload['consumptionLocationId']
            ?.toString();
        final defaultOutputLoc = payload['outputLocationId']?.toString();

        for (final item in consumptions) {
          final productId = item['productId']?.toString();
          addPair(
            item['sourceLocationId']?.toString() ?? defaultConsumptionLoc,
            productId,
          );
          addPair(item['destinationLocationId']?.toString(), productId);
        }
        for (final item in outputs) {
          final productId = item['productId']?.toString();
          addPair(item['sourceLocationId']?.toString(), productId);
          addPair(
            item['destinationLocationId']?.toString() ?? defaultOutputLoc,
            productId,
          );
        }
      }

      for (final balanceId in pairs) {
        final doc = await tx.get(
          _db.collection('stock_balances').doc(balanceId),
        );
        balances[balanceId] =
            (doc.data()?['quantity'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return balances;
  }

  List<_RemoteMovementLine> _generateMovementLines(
    String type,
    String commandId,
    Map<String, dynamic> payload,
    String actorUid,
    DateTime occurredAt,
    Map<String, double> balanceSnapshot,
  ) {
    if ([
      'internal_transfer',
      'department_issue',
      'department_return',
    ].contains(type)) {
      return [
        _RemoteMovementLine(
          commandId: commandId,
          movementIndex: 0,
          productId: payload['productId'].toString(),
          sourceLocationId: payload['sourceLocationId']?.toString(),
          destinationLocationId: payload['destinationLocationId']?.toString(),
          quantityBase: (payload['quantityBase'] as num).toDouble(),
          movementType: type,
          reasonCode: payload['reasonCode']?.toString(),
          referenceType: payload['referenceType']?.toString(),
          referenceId: payload['referenceId']?.toString(),
          actorUid: actorUid,
          occurredAt: occurredAt,
          isReversal: false,
        ),
      ];
    } else if (type == 'opening_set_balance') {
      final locationId = payload['locationId'].toString();
      final productId = payload['productId'].toString();
      final setQuantity = (payload['setQuantityBase'] as num).toDouble();
      final balanceId = '${locationId}_$productId';
      final currentBalance = balanceSnapshot[balanceId] ?? 0.0;
      final delta = setQuantity - currentBalance;

      if (delta.abs() < 1e-9) return [];

      return [
        _RemoteMovementLine(
          commandId: commandId,
          movementIndex: 0,
          productId: productId,
          sourceLocationId: delta < 0 ? locationId : null,
          destinationLocationId: delta > 0 ? locationId : null,
          quantityBase: delta.abs(),
          movementType: type,
          reasonCode: payload['reasonCode']?.toString(),
          referenceType: payload['referenceType']?.toString(),
          referenceId: payload['referenceId']?.toString(),
          actorUid: actorUid,
          occurredAt: occurredAt,
          isReversal: false,
        ),
      ];
    } else if ([
      'dispatch_create',
      'sale_complete',
      'sale_reversal',
    ].contains(type)) {
      final sourceLocationId = payload['sourceLocationId']?.toString();
      final destinationLocationId = payload['destinationLocationId']
          ?.toString();
      final items = payload['items'] as List<dynamic>? ?? [];
      final isReversal = type == 'sale_reversal';
      final lines = <_RemoteMovementLine>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        lines.add(
          _RemoteMovementLine(
            commandId: commandId,
            movementIndex: i,
            productId: item['productId'].toString(),
            sourceLocationId: sourceLocationId,
            destinationLocationId: destinationLocationId,
            quantityBase: (item['quantityBase'] as num).toDouble(),
            movementType: type,
            reasonCode: payload['reasonCode']?.toString(),
            referenceType: payload['referenceType']?.toString(),
            referenceId: payload['referenceId']?.toString(),
            actorUid: actorUid,
            occurredAt: occurredAt,
            isReversal: isReversal,
          ),
        );
      }
      return lines;
    } else if ([
      'bhatti_production_complete',
      'cutting_production_complete',
    ].contains(type)) {
      final consumptions = payload['consumptions'] as List<dynamic>? ?? [];
      final outputs = payload['outputs'] as List<dynamic>? ?? [];
      final defaultConsumptionLoc = payload['consumptionLocationId']
          ?.toString();
      final defaultOutputLoc = payload['outputLocationId']?.toString();
      final lines = <_RemoteMovementLine>[];
      var index = 0;

      for (final item in consumptions) {
        lines.add(
          _RemoteMovementLine(
            commandId: commandId,
            movementIndex: index++,
            productId: item['productId'].toString(),
            sourceLocationId:
                item['sourceLocationId']?.toString() ?? defaultConsumptionLoc,
            destinationLocationId: item['destinationLocationId']?.toString(),
            quantityBase: (item['quantityBase'] as num).toDouble(),
            movementType: '${type}_consume',
            reasonCode: payload['reasonCode']?.toString(),
            referenceType: payload['referenceType']?.toString(),
            referenceId: payload['referenceId']?.toString(),
            actorUid: actorUid,
            occurredAt: occurredAt,
            isReversal: false,
          ),
        );
      }
      for (final item in outputs) {
        lines.add(
          _RemoteMovementLine(
            commandId: commandId,
            movementIndex: index++,
            productId: item['productId'].toString(),
            sourceLocationId: item['sourceLocationId']?.toString(),
            destinationLocationId:
                item['destinationLocationId']?.toString() ?? defaultOutputLoc,
            quantityBase: (item['quantityBase'] as num).toDouble(),
            movementType: '${type}_output',
            reasonCode: payload['reasonCode']?.toString(),
            referenceType: payload['referenceType']?.toString(),
            referenceId: payload['referenceId']?.toString(),
            actorUid: actorUid,
            occurredAt: occurredAt,
            isReversal: false,
          ),
        );
      }
      return lines;
    }
    return [];
  }
}
