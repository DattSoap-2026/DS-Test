import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/models/inventory/stock_dispatch.dart';
import 'package:flutter_app/services/outbox_codec.dart';

const _stockMovementsCollection = 'stock_movements';
const _dispatchesCollection = 'dispatches';
const _stockLedgerCollection = 'stock_ledger';
const _syncCommandsCollection = 'sync_commands';

class InventoryQueueSyncDelegate {
  InventoryQueueSyncDelegate(this._firestore);

  final firestore.FirebaseFirestore _firestore;

  Future<bool> performSync(
    String action,
    String collection,
    Map<String, dynamic> data, {
    required bool useWindowsSafeMode,
  }) async {
    if (useWindowsSafeMode) {
      final handled = await _performSafeModeSync(action, collection, data);
      if (handled) {
        return true;
      }
    }

    if (collection == _stockLedgerCollection) {
      await _firestore.collection(collection).doc(data['id']).set(data);
      return true;
    }

    if (action == 'add' && collection == _stockMovementsCollection) {
      final movementId = data['id']?.toString().trim();
      if (movementId == null || movementId.isEmpty) {
        throw Exception(
          'Deterministic stock movement id is required for sync payload',
        );
      }
      await _firestore.runTransaction((transaction) async {
        final productId = data['productId'];
        final quantity = (data['quantity'] as num).toDouble();
        final movementType = data['movementType'];
        final docRef = _firestore.collection(collection).doc(movementId);
        final existingMovement = await transaction.get(docRef);
        if (existingMovement.exists) {
          return;
        }

        final refType = data['referenceType'];
        if (refType == 'dispatch' ||
            refType == 'sale' ||
            refType == 'production' ||
            refType == 'sales_return') {
          transaction.set(docRef, {
            ...data,
            'id': movementId,
            'createdAt':
                data['createdAt'] ?? firestore.FieldValue.serverTimestamp(),
          }, firestore.SetOptions(merge: true));
          return;
        }

        final productRef = _firestore.collection('products').doc(productId);
        final productSnap = await transaction.get(productRef);

        if (productSnap.exists) {
          final pData = productSnap.data() as Map<String, dynamic>;
          final currentStock = (pData['stock'] as num? ?? 0).toDouble();

          if (movementType == 'out' && currentStock < quantity) {
            throw Exception(
              'Insufficient stock for product ${pData['name']}. Available: $currentStock',
            );
          }

          final change = movementType == 'in' ? quantity : -quantity;
          transaction.update(productRef, {
            'stock': firestore.FieldValue.increment(change),
          });
        }

        transaction.set(docRef, {
          ...data,
          'id': movementId,
          'createdAt':
              data['createdAt'] ?? firestore.FieldValue.serverTimestamp(),
        });
      });
      return true;
    }

    if (collection == 'department_stocks' &&
        (action == 'issue_to_department' ||
            action == 'return_from_department')) {
      final deptName = data['departmentName']?.toString().trim();
      final productId = data['productId']?.toString().trim();
      final payloadId = data['id']?.toString().trim();
      if (deptName == null ||
          deptName.isEmpty ||
          productId == null ||
          productId.isEmpty) {
        throw Exception(
          'Department stock issue payload must include departmentName and productId',
        );
      }
      final expectedId = '${deptName}_$productId';
      if (payloadId == null || payloadId.isEmpty) {
        throw Exception(
          'Deterministic issue payload id is required for department stock sync',
        );
      }
      await _firestore.runTransaction((transaction) async {
        final qty = (data['quantity'] as num).toDouble();
        final docId = expectedId;
        if (payloadId != docId) {
          throw Exception(
            'Department stock payload id mismatch. expected=$docId, received=$payloadId',
          );
        }
        final deptStockRef = _firestore.collection(collection).doc(docId);
        final commandKey = _buildStockMutationCommandKey(
          collection: collection,
          action: action,
          payload: data,
        );
        final commandRef = _firestore
            .collection(_syncCommandsCollection)
            .doc(_commandAuditDocId(commandKey));
        final existingCommand = await transaction.get(commandRef);
        if (existingCommand.exists) {
          return;
        }

        final isReturn = action == 'return_from_department';
        final productRef = _firestore.collection('products').doc(productId);
        final pSnap = await transaction.get(productRef);
        if (!pSnap.exists) {
          throw Exception('Product $productId not found');
        }

        final pData = pSnap.data() as Map<String, dynamic>;
        final currentMainStock = (pData['stock'] as num? ?? 0).toDouble();
        if (!isReturn && currentMainStock < qty) {
          throw Exception(
            'Insufficient warehouse stock for $productId. Available: $currentMainStock',
          );
        }
        transaction.update(productRef, {
          'stock': firestore.FieldValue.increment(isReturn ? qty : -qty),
        });

        final deptPayload = <String, dynamic>{
          'departmentName': deptName,
          'productId': productId,
          'productName': data['productName'],
          'stock': firestore.FieldValue.increment(isReturn ? -qty : qty),
          'unit': data['unit'],
          'updatedAt': DateTime.now().toIso8601String(),
        };

        if (isReturn) {
          final deptSnap = await transaction.get(deptStockRef);
          final currentDeptStock = (deptSnap.data()?['stock'] as num? ?? 0)
              .toDouble();
          if (currentDeptStock < qty) {
            throw Exception(
              'Insufficient department stock for $productId in $deptName. Available: $currentDeptStock',
            );
          }
        }

        transaction.set(
          deptStockRef,
          deptPayload,
          firestore.SetOptions(merge: true),
        );

        transaction.set(commandRef, {
          'collectionName': collection,
          'docId': docId,
          'action': isReturn ? 'return_stock_command' : 'issue_stock_command',
          'commandKey': commandKey,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      return true;
    }

    if (action == 'add' && collection == _dispatchesCollection) {
      final dispatchDocId = data['id']?.toString().trim();
      if (dispatchDocId == null || dispatchDocId.isEmpty) {
        throw Exception('Deterministic dispatch id is required for sync payload');
      }
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(collection).doc(dispatchDocId);
        final existingDispatch = await transaction.get(docRef);
        if (existingDispatch.exists) {
          return;
        }

        final seriesRef = _firestore
            .collection('transaction_series')
            .doc('Dispatch');
        final seriesSnap = await transaction.get(seriesRef);

        var nextNumber = 1;
        var prefix = 'DSP-';
        if (seriesSnap.exists) {
          final sData = seriesSnap.data() as Map<String, dynamic>;
          nextNumber = (sData['current'] as num? ?? 0).toInt() + 1;
          prefix = sData['prefix'] ?? 'DSP-';
          transaction.update(seriesRef, {'current': nextNumber});
        }

        final humanReadableId = '$prefix$nextNumber';
        final items = (data['items'] as List).cast<Map<String, dynamic>>();
        final movementIds = Map<String, dynamic>.from(data['movementIds'] ?? {});

        for (final item in items) {
          final productId = item['productId'];
          final quantity = (item['quantity'] as num).toDouble();

          final pRef = _firestore.collection('products').doc(productId);
          final pSnap = await transaction.get(pRef);

          if (!pSnap.exists) {
            throw Exception('Product $productId not found');
          }
          final pData = pSnap.data() as Map<String, dynamic>;
          final currentStock = (pData['stock'] as num? ?? 0).toDouble();
          if (currentStock < quantity) {
            throw Exception(
              'Insufficient stock for ${item['name']}. Available: $currentStock',
            );
          }

          final uRef = _firestore.collection('users').doc(data['salesmanId']);
          final isFree = item['isFree'] == true;

          final itemUpdate = <String, dynamic>{
            'productId': productId,
            'name': item['name'],
            'price': item['price'] ?? 0.0,
            'baseUnit': item['baseUnit'] ?? '',
            'secondaryUnit': item['secondaryUnit'],
            'conversionFactor': item['conversionFactor'] ?? 1.0,
          };

          if (isFree) {
            itemUpdate['freeQuantity'] = firestore.FieldValue.increment(quantity);
          } else {
            itemUpdate['quantity'] = firestore.FieldValue.increment(quantity);
          }

          transaction.set(uRef, {
            'allocatedStock': {productId: itemUpdate},
          }, firestore.SetOptions(merge: true));

          final movementId = _resolveDispatchMovementId(
            item: item,
            movementIds: movementIds,
          );
          if (movementId == null || movementId.isEmpty) {
            throw Exception(
              'Deterministic movement id missing for dispatch=$dispatchDocId product=$productId',
            );
          }

          final moveRef = _firestore
              .collection(_stockMovementsCollection)
              .doc(movementId);
          transaction.set(moveRef, {
            'id': movementId,
            'productId': productId,
            'productName': item['name'],
            'quantity': quantity,
            'type': 'out',
            'movementType': 'out',
            'source': 'dispatch',
            'reason': 'dispatch',
            'referenceId': data['id'],
            'referenceNumber': humanReadableId,
            'referenceType': 'dispatch',
            'notes': 'Dispatch: $humanReadableId',
            'userId': data['createdBy'],
            'userName': data['createdByName'],
            'createdBy': data['createdBy'],
            'createdAt': firestore.FieldValue.serverTimestamp(),
            'isSynced': true,
          }, firestore.SetOptions(merge: true));
        }

        final normalizedStatus = _normalizeDispatchStatus(data['status']);
        transaction.set(docRef, {
          ...data,
          'dispatchId': humanReadableId,
          'status': normalizedStatus,
          if (normalizedStatus == DispatchStatus.received.name)
            'receivedAt':
                data['receivedAt'] ?? firestore.FieldValue.serverTimestamp(),
          'isSynced': true,
        });

        final sourceOrderId = data['orderId']?.toString().trim();
        if (sourceOrderId != null && sourceOrderId.isNotEmpty) {
          final routeOrderRef = _firestore
              .collection('route_orders')
              .doc(sourceOrderId);
          final routeOrderSnap = await transaction.get(routeOrderRef);

          if (routeOrderSnap.exists) {
            transaction.update(routeOrderRef, {
              'dispatchStatus': 'dispatched',
              'dispatchId': humanReadableId,
              'dispatchedAt': firestore.FieldValue.serverTimestamp(),
              'dispatchedById': data['createdBy'],
              'dispatchedByName': data['createdByName'],
              'updatedAt': firestore.FieldValue.serverTimestamp(),
            });
          }
        }
      });
      return true;
    }

    if (action == 'add' && collection == 'salesman_returns') {
      final salesmanId = data['salesmanId']?.toString().trim();
      if (salesmanId == null || salesmanId.isEmpty) {
        throw Exception('Salesman ID required for return sync');
      }

      final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (items.isEmpty) {
        throw Exception('Return must include at least one item');
      }

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(salesmanId);
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) {
          throw Exception('Salesman $salesmanId not found');
        }

        for (final item in items) {
          final productId = item['productId']?.toString().trim();
          if (productId == null || productId.isEmpty) {
            continue;
          }

          final returnQty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
          if (returnQty <= 0) {
            continue;
          }

          final isFree = item['isFree'] == true;
          final field = isFree
              ? 'allocatedStock.$productId.freeQuantity'
              : 'allocatedStock.$productId.quantity';
          transaction.update(userRef, {
            field: firestore.FieldValue.increment(-returnQty),
          });

          final productRef = _firestore.collection('products').doc(productId);
          transaction.update(productRef, {
            'stock': firestore.FieldValue.increment(returnQty),
          });
        }
      });
      return true;
    }

    return false;
  }

  Future<bool> _performSafeModeSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    if (collection == _stockLedgerCollection) {
      await _firestore.collection(collection).doc(data['id']).set(data);
      return true;
    }

    if (action == 'add' && collection == _dispatchesCollection) {
      await _safeDispatchSync(data);
      return true;
    }

    return false;
  }

  Future<void> _safeDispatchSync(Map<String, dynamic> data) async {
    final dispatchId = data['id'];
    if (dispatchId == null) {
      return;
    }

    final dispatchRef = _firestore.collection(_dispatchesCollection).doc(dispatchId);
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    final movementIds = Map<String, dynamic>.from(data['movementIds'] ?? {});
    final salesmanId = data['salesmanId'];
    final normalizedStatus = _normalizeDispatchStatus(data['status']);

    final existing = await dispatchRef.get();
    if (existing.exists) {
      return;
    }

    final batch = _firestore.batch();

    for (final item in items) {
      final productId = item['productId'];
      final quantity = (item['quantity'] as num? ?? 0).toDouble();
      final isFree = item['isFree'] == true;

      final productRef = _firestore.collection('products').doc(productId);
      final productSnap = await productRef.get();
      if (!productSnap.exists) {
        throw Exception('Product $productId not found during safe dispatch.');
      }

      final currentStock = (productSnap.data()?['stock'] as num? ?? 0)
          .toDouble();
      if (currentStock - quantity < -1e-9) {
        throw Exception(
          'Insufficient stock for $productId during safe dispatch. Available: $currentStock, requested: $quantity',
        );
      }

      batch.update(productRef, {
        'stock': firestore.FieldValue.increment(-quantity),
      });

      final userRef = _firestore.collection('users').doc(salesmanId);
      final itemUpdate = <String, dynamic>{
        'productId': productId,
        'name': item['name'],
        'price': item['price'] ?? 0.0,
        'baseUnit': item['baseUnit'] ?? '',
        'secondaryUnit': item['secondaryUnit'],
        'conversionFactor': item['conversionFactor'] ?? 1.0,
      };

      if (isFree) {
        itemUpdate['freeQuantity'] = firestore.FieldValue.increment(quantity);
      } else {
        itemUpdate['quantity'] = firestore.FieldValue.increment(quantity);
      }

      batch.set(userRef, {
        'allocatedStock': {productId: itemUpdate},
      }, firestore.SetOptions(merge: true));

      final movementId = _resolveDispatchMovementId(
        item: item,
        movementIds: movementIds,
      );
      if (movementId == null || movementId.isEmpty) {
        throw Exception(
          'Deterministic movement id missing in safe dispatch payload for product=$productId',
        );
      }
      final moveRef = _firestore
          .collection(_stockMovementsCollection)
          .doc(movementId);
      batch.set(moveRef, {
        'id': movementId,
        'productId': productId,
        'productName': item['name'],
        'quantity': quantity,
        'type': 'out',
        'movementType': 'out',
        'source': 'dispatch',
        'reason': 'dispatch',
        'referenceId': dispatchId,
        'referenceNumber': data['dispatchId'],
        'referenceType': 'dispatch',
        'notes': 'Dispatch: ${data['dispatchId']}',
        'userId': data['createdBy'],
        'userName': data['createdByName'],
        'createdBy': data['createdBy'],
        'createdAt': firestore.FieldValue.serverTimestamp(),
        'isSynced': true,
      }, firestore.SetOptions(merge: true));
    }

    batch.set(dispatchRef, {
      ...data,
      'status': normalizedStatus,
      if (normalizedStatus == DispatchStatus.received.name)
        'receivedAt':
            data['receivedAt'] ?? firestore.FieldValue.serverTimestamp(),
      'isSynced': true,
    }, firestore.SetOptions(merge: true));

    final sourceOrderId = data['orderId']?.toString().trim();
    if (sourceOrderId != null && sourceOrderId.isNotEmpty) {
      final routeOrderRef = _firestore.collection('route_orders').doc(sourceOrderId);
      final routeOrderSnap = await routeOrderRef.get();

      if (routeOrderSnap.exists) {
        batch.update(routeOrderRef, {
          'dispatchStatus': 'dispatched',
          'dispatchId': data['dispatchId'],
          'dispatchedAt': firestore.FieldValue.serverTimestamp(),
          'dispatchedById': data['createdBy'],
          'dispatchedByName': data['createdByName'],
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  String _normalizeDispatchStatus(dynamic value) {
    final raw = value?.toString().trim().toLowerCase();
    if (raw == null || raw.isEmpty) {
      return DispatchStatus.received.name;
    }
    for (final status in DispatchStatus.values) {
      if (status.name.toLowerCase() == raw) {
        return status.name;
      }
    }
    return DispatchStatus.received.name;
  }

  String _sanitizeDeterministicToken(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'unknown';
    }
    return normalized.replaceAll(RegExp(r'[^a-z0-9_\\-]'), '_');
  }

  String _buildStockMutationCommandKey({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
  }) {
    final explicit = OutboxCodec.readIdempotencyKey(payload);
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    final normalized = Map<String, dynamic>.from(payload)
      ..remove(OutboxCodec.idempotencyKeyField);
    final digest = fastHash(jsonEncode(normalized)).toString();
    return '${_sanitizeDeterministicToken(collection)}_${_sanitizeDeterministicToken(action)}_$digest';
  }

  String _commandAuditDocId(String commandKey) {
    final token = _sanitizeDeterministicToken(commandKey);
    if (token.length <= 480) {
      return 'cmd_$token';
    }
    final digest = fastHash(commandKey).toString();
    return 'cmd_${token.substring(0, 420)}_$digest';
  }

  String? _resolveDispatchMovementId({
    required Map<String, dynamic> item,
    required Map<String, dynamic> movementIds,
  }) {
    final inlineId = item['movementId']?.toString().trim();
    if (inlineId != null && inlineId.isNotEmpty) {
      return inlineId;
    }

    final productId = item['productId']?.toString().trim();
    if (productId == null || productId.isEmpty) {
      return null;
    }

    final fallbackId = movementIds[productId]?.toString().trim();
    if (fallbackId != null && fallbackId.isNotEmpty) {
      return fallbackId;
    }

    return null;
  }
}
