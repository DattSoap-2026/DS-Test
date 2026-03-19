import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';

import '../../data/local/base_entity.dart';
import '../../data/local/entities/inventory_command_entity.dart';
import '../../data/local/entities/inventory_location_entity.dart';
import '../../data/local/entities/product_entity.dart';
import '../../data/local/entities/stock_balance_entity.dart';
import '../../data/local/entities/user_entity.dart';
import '../../services/database_service.dart';
import '../../services/delegates/sales_remote_write_delegate.dart';
import '../../services/inventory_movement_engine.dart';
import '../../services/inventory_projection_service.dart';

class SalesRemoteProvider {
  final FirebaseFirestore _firestore;
  final DatabaseService _dbService;
  final InventoryMovementEngine _inventoryMovementEngine;
  static const String salesCollection = 'sales';

  SalesRemoteProvider(
    this._firestore, {
    DatabaseService? dbService,
    InventoryMovementEngine? inventoryMovementEngine,
  }) : _dbService = dbService ?? DatabaseService.instance,
       _inventoryMovementEngine =
            inventoryMovementEngine ??
            InventoryMovementEngine(
              dbService ?? DatabaseService.instance,
              InventoryProjectionService(dbService ?? DatabaseService.instance),
            );

  SalesRemoteWriteDelegate _writeDelegate() {
    return SalesRemoteWriteDelegate(
      firestore: _firestore,
      ensureSaleInventoryAppliedIfNeeded: _ensureSaleInventoryAppliedIfNeeded,
      ensureSaleEditInventoryAppliedIfNeeded:
          _ensureSaleEditInventoryAppliedIfNeeded,
      stripEditSyncMetadata: _stripEditSyncMetadata,
    );
  }

  Map<String, dynamic> _stripEditSyncMetadata(Map<String, dynamic> payload) {
    final cleaned = Map<String, dynamic>.from(payload);
    cleaned.remove('stockDeltas');
    cleaned.remove('totalDelta');
    cleaned.remove('oldTotalAmount');
    cleaned.remove('editedBy');
    cleaned.remove('editedAt');
    return cleaned;
  }

  String _normalizeRecipientType(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  List<InventoryCommandItem> _commandItemsFromMaps(
    List<Map<String, dynamic>> items,
  ) {
    return items
        .map(
          (item) => InventoryCommandItem(
            productId: item['productId']?.toString().trim() ?? '',
            quantityBase:
                (item['finalBaseQuantity'] as num?)?.toDouble() ??
                (item['quantity'] as num?)?.toDouble() ??
                0.0,
          ),
        )
        .where(
          (item) =>
              item.productId.isNotEmpty && item.quantityBase.abs() >= 1e-9,
        )
        .toList(growable: false);
  }

  Future<void> _ensureInventoryLocationInTxn(String locationId) async {
    final normalized = locationId.trim();
    if (normalized.isEmpty || normalized.startsWith('virtual:')) {
      return;
    }
    final existing = await _dbService.inventoryLocations.getById(normalized);
    if (existing != null) {
      return;
    }

    final now = DateTime.now();
    if (normalized == InventoryProjectionService.warehouseMainLocationId) {
      final entity = InventoryLocationEntity()
        ..id = normalized
        ..type = InventoryLocationEntity.warehouseType
        ..name = 'Main Warehouse'
        ..code = 'WAREHOUSE_MAIN'
        ..parentLocationId = null
        ..ownerUserUid = null
        ..isActive = true
        ..isPrimaryMainWarehouse = true
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      await _dbService.inventoryLocations.put(entity);
      return;
    }

    const salesmanPrefix = 'salesman_van_';
    if (normalized.startsWith(salesmanPrefix)) {
      final ownerUid = normalized.substring(salesmanPrefix.length).trim();
      final user = await _dbService.users.getById(ownerUid);
      final userName = (user?.name ?? '').trim();
      final entity = InventoryLocationEntity()
        ..id = normalized
        ..type = InventoryLocationEntity.salesmanVanType
        ..name = userName.isNotEmpty ? '$userName Van' : 'Salesman Van'
        ..code = 'SALESMAN_VAN_${ownerUid.toUpperCase()}'
        ..parentLocationId = InventoryProjectionService.warehouseMainLocationId
        ..ownerUserUid = ownerUid.isEmpty ? null : ownerUid
        ..isActive = true
        ..isPrimaryMainWarehouse = false
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      await _dbService.inventoryLocations.put(entity);
    }
  }

  Future<bool> _hasSufficientLocationBalanceInTxn({
    required String locationId,
    required List<InventoryCommandItem> items,
  }) async {
    await _ensureInventoryLocationInTxn(locationId);
    for (final item in items) {
      final balance = await _dbService.stockBalances.getById(
        '${locationId}_${item.productId}',
      );
      var available = balance?.quantity ?? 0.0;
      if (balance == null &&
          locationId == InventoryProjectionService.warehouseMainLocationId) {
        final product = await _dbService.products.getById(item.productId);
        available = product?.stock ?? 0.0;
      } else if (balance == null && locationId.startsWith('salesman_van_')) {
        final ownerUid = locationId.substring('salesman_van_'.length);
        final user = await _dbService.users.getById(ownerUid);
        final allocatedItem = user?.getAllocatedStock()[item.productId];
        available =
            ((allocatedItem?.quantity ?? 0) +
                    (allocatedItem?.freeQuantity ?? 0))
                .toDouble();
      }
      if (available + 1e-9 < item.quantityBase) {
        return false;
      }
    }
    return true;
  }

  Future<void> _seedSourceBalancesInTxn({
    required String sourceLocationId,
    required List<InventoryCommandItem> items,
    required DateTime occurredAt,
  }) async {
    for (final item in items) {
      final balanceId = StockBalanceEntity.composeId(
        sourceLocationId,
        item.productId,
      );
      final existing = await _dbService.stockBalances.getById(balanceId);
      if (existing != null) {
        continue;
      }

      double seedQuantity = 0.0;
      if (sourceLocationId ==
          InventoryProjectionService.warehouseMainLocationId) {
        final product = await _dbService.products.getById(item.productId);
        seedQuantity = product?.stock ?? 0.0;
      } else if (sourceLocationId.startsWith('salesman_van_')) {
        final ownerUid = sourceLocationId.substring('salesman_van_'.length);
        final user = await _dbService.users.getById(ownerUid);
        final allocatedItem = user?.getAllocatedStock()[item.productId];
        seedQuantity =
            ((allocatedItem?.quantity ?? 0) +
                    (allocatedItem?.freeQuantity ?? 0))
                .toDouble();
      }

      final balance = StockBalanceEntity()
        ..id = balanceId
        ..locationId = sourceLocationId
        ..productId = item.productId
        ..quantity = seedQuantity
        ..updatedAt = occurredAt
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      await _dbService.stockBalances.put(balance);
    }
  }

  Future<String> _resolveSaleSourceLocationInTxn({
    required String recipientType,
    required String salesmanUid,
    required List<InventoryCommandItem> items,
  }) async {
    if (_normalizeRecipientType(recipientType) == 'customer' &&
        salesmanUid.trim().isNotEmpty) {
      final vanLocationId = InventoryProjectionService.salesmanLocationIdForUid(
        salesmanUid,
      );
      if (await _hasSufficientLocationBalanceInTxn(
        locationId: vanLocationId,
        items: items,
      )) {
        return vanLocationId;
      }
    }
    return InventoryProjectionService.warehouseMainLocationId;
  }

  Future<void> _ensureCommandLocationsInTxn(InventoryCommand command) async {
    final sourceLocationId = command.payload['sourceLocationId']?.toString();
    final destinationLocationId = command.payload['destinationLocationId']
        ?.toString();
    if (sourceLocationId != null && sourceLocationId.trim().isNotEmpty) {
      await _ensureInventoryLocationInTxn(sourceLocationId);
    }
    if (destinationLocationId != null &&
        destinationLocationId.trim().isNotEmpty) {
      await _ensureInventoryLocationInTxn(destinationLocationId);
    }
  }

  InventoryCommand _buildSaleCompleteCommand({
    required String saleIdToken,
    required String sourceLocationId,
    required List<InventoryCommandItem> items,
    required String actorUid,
    String? actorLegacyAppUserId,
    String? editCommandKey,
    DateTime? createdAt,
  }) {
    final normalizedEditKey = editCommandKey?.trim();
    return InventoryCommand(
      commandId: 'sale:$saleIdToken',
      commandType: InventoryCommandType.saleComplete,
      payload: <String, dynamic>{
        'saleId': saleIdToken,
        'sourceLocationId': sourceLocationId,
        'destinationLocationId':
            InventoryProjectionService.virtualSoldLocationId,
        'referenceId': saleIdToken,
        'referenceType': 'sale',
        'reasonCode': 'sale_complete',
        'items': items.map((item) => item.toJson()).toList(growable: false),
        if (normalizedEditKey != null && normalizedEditKey.isNotEmpty)
          'editCommandKey': normalizedEditKey,
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
      retryMeta: normalizedEditKey == null || normalizedEditKey.isEmpty
          ? null
          : jsonEncode(<String, dynamic>{'editCommandKey': normalizedEditKey}),
    );
  }

  InventoryCommand _buildSaleReversalCommand({
    required String originalCommandId,
    required String restoreLocationId,
    required List<InventoryCommandItem> items,
    required String actorUid,
    String? actorLegacyAppUserId,
    String? editCommandKey,
    DateTime? createdAt,
  }) {
    final normalizedEditKey = editCommandKey?.trim();
    return InventoryCommand(
      commandId: 'reversal:$originalCommandId',
      commandType: InventoryCommandType.saleReversal,
      payload: <String, dynamic>{
        'originalCommandId': originalCommandId,
        'sourceLocationId': InventoryProjectionService.virtualSoldLocationId,
        'destinationLocationId': restoreLocationId,
        'referenceId': originalCommandId,
        'referenceType': 'sale_reversal',
        'reasonCode': 'sale_reversal',
        'items': items.map((item) => item.toJson()).toList(growable: false),
        if (normalizedEditKey != null && normalizedEditKey.isNotEmpty)
          'editCommandKey': normalizedEditKey,
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
      retryMeta: normalizedEditKey == null || normalizedEditKey.isEmpty
          ? null
          : jsonEncode(<String, dynamic>{'editCommandKey': normalizedEditKey}),
    );
  }

  int _parseSaleEditSequence(String commandId, String saleId) {
    if (commandId == 'sale:$saleId') {
      return 0;
    }
    final prefix = 'sale:$saleId:edit:';
    if (!commandId.startsWith(prefix)) {
      return -1;
    }
    return int.tryParse(commandId.substring(prefix.length)) ?? -1;
  }

  Map<String, dynamic> _decodeInventoryCommandPayload(
    InventoryCommandEntity command,
  ) {
    try {
      final decoded = jsonDecode(command.payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } catch (_) {}
    return const <String, dynamic>{};
  }

  String? _extractEditCommandKey(
    InventoryCommandEntity command,
    Map<String, dynamic> payload,
  ) {
    final payloadKey = payload['editCommandKey']?.toString().trim();
    if (payloadKey != null && payloadKey.isNotEmpty) {
      return payloadKey;
    }
    final retryMeta = command.retryMeta?.trim();
    if (retryMeta == null || retryMeta.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(retryMeta);
      if (decoded is Map) {
        final value = decoded['editCommandKey']?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<_RemoteSaleInventoryCommandContext?> _loadLatestSaleCommandContext(
    String saleId,
  ) async {
    final allCommands = await _dbService.inventoryCommands.where().findAll();
    _RemoteSaleInventoryCommandContext? latest;
    for (final command in allCommands) {
      final commandId = command.commandId;
      if (commandId != 'sale:$saleId' &&
          !commandId.startsWith('sale:$saleId:edit:')) {
        continue;
      }
      final sequence = _parseSaleEditSequence(commandId, saleId);
      final payload = _decodeInventoryCommandPayload(command);
      final sourceLocationId = payload['sourceLocationId']?.toString().trim();
      if (sourceLocationId == null || sourceLocationId.isEmpty) {
        continue;
      }
      final candidate = _RemoteSaleInventoryCommandContext(
        commandId: commandId,
        sourceLocationId: sourceLocationId,
        sequence: sequence,
        createdAt: command.createdAt,
        editCommandKey: _extractEditCommandKey(command, payload),
      );
      if (latest == null ||
          candidate.sequence > latest.sequence ||
          (candidate.sequence == latest.sequence &&
              candidate.createdAt.isAfter(latest.createdAt))) {
        latest = candidate;
      }
    }
    return latest;
  }

  Future<String> _resolveSaleEditCommandId({
    required String saleId,
    required String commandKey,
  }) async {
    final allCommands = await _dbService.inventoryCommands.where().findAll();
    var maxSequence = 0;
    for (final command in allCommands) {
      final sequence = _parseSaleEditSequence(command.commandId, saleId);
      if (sequence < 1) continue;
      if (sequence > maxSequence) {
        maxSequence = sequence;
      }
      final payload = _decodeInventoryCommandPayload(command);
      final existingKey = _extractEditCommandKey(command, payload);
      if (existingKey == commandKey.trim()) {
        return '$saleId:edit:$sequence';
      }
    }
    return '$saleId:edit:${maxSequence + 1}';
  }

  Future<void> _ensureSaleInventoryAppliedIfNeeded({
    required String saleId,
    required String recipientType,
    required String salesmanUid,
    required List<Map<String, dynamic>> items,
    String? recipientSalesmanUid,
    String? actorUid,
    String? actorLegacyAppUserId,
  }) async {
    final commandItems = _commandItemsFromMaps(items);
    if (commandItems.isEmpty) {
      return;
    }

    final effectiveActorUid = actorUid?.trim().isNotEmpty == true
        ? actorUid!.trim()
        : (salesmanUid.trim().isEmpty ? 'system' : salesmanUid.trim());
    final effectiveLegacyId = actorLegacyAppUserId?.trim().isNotEmpty == true
        ? actorLegacyAppUserId!.trim()
        : null;

    await _dbService.db.writeTxn(() async {
      if (_normalizeRecipientType(recipientType) == 'salesman') {
        final recipientUid = recipientSalesmanUid?.trim();
        if (recipientUid == null || recipientUid.isEmpty) {
          return;
        }
        final command = InventoryCommand.dispatchCreate(
          dispatchId: saleId,
          salesmanUid: recipientUid,
          items: commandItems,
          actorUid: effectiveActorUid,
          actorLegacyAppUserId: effectiveLegacyId,
        );
        await _ensureCommandLocationsInTxn(command);
        await _inventoryMovementEngine.applyCommandInTxn(command);
        return;
      }

      final sourceLocationId = await _resolveSaleSourceLocationInTxn(
        recipientType: recipientType,
        salesmanUid: salesmanUid,
        items: commandItems,
      );
      await _seedSourceBalancesInTxn(
        sourceLocationId: sourceLocationId,
        items: commandItems,
        occurredAt: DateTime.now(),
      );
      final command = _buildSaleCompleteCommand(
        saleIdToken: saleId,
        sourceLocationId: sourceLocationId,
        items: commandItems,
        actorUid: effectiveActorUid,
        actorLegacyAppUserId: effectiveLegacyId,
      );
      await _ensureCommandLocationsInTxn(command);
      await _inventoryMovementEngine.applyCommandInTxn(command);
    });
  }

  Future<void> _ensureSaleEditInventoryAppliedIfNeeded({
    required String saleId,
    required String previousRecipientType,
    required String nextRecipientType,
    required String salesmanUid,
    required List<Map<String, dynamic>> previousItems,
    required List<Map<String, dynamic>> nextItems,
    required String commandKey,
    String? actorUid,
    String? actorLegacyAppUserId,
  }) async {
    final effectiveActorUid = actorUid?.trim().isNotEmpty == true
        ? actorUid!.trim()
        : (salesmanUid.trim().isEmpty ? 'system' : salesmanUid.trim());
    final effectiveLegacyId = actorLegacyAppUserId?.trim().isNotEmpty == true
        ? actorLegacyAppUserId!.trim()
        : null;

    await _dbService.db.writeTxn(() async {
      final previousCommand = await _loadLatestSaleCommandContext(saleId);
      final previousCommandItems = _commandItemsFromMaps(previousItems);
      final nextCommandItems = _commandItemsFromMaps(nextItems);
      if (previousCommand != null && previousCommandItems.isNotEmpty) {
        final reversalCommand = _buildSaleReversalCommand(
          originalCommandId: previousCommand.commandId,
          restoreLocationId: previousCommand.sourceLocationId,
          items: previousCommandItems,
          actorUid: effectiveActorUid,
          actorLegacyAppUserId: effectiveLegacyId,
          editCommandKey: commandKey,
        );
        await _ensureCommandLocationsInTxn(reversalCommand);
        await _inventoryMovementEngine.applyCommandInTxn(reversalCommand);
      } else if (previousCommandItems.isNotEmpty) {
        final fallbackSourceLocationId = await _resolveSaleSourceLocationInTxn(
          recipientType: previousRecipientType,
          salesmanUid: salesmanUid,
          items: previousCommandItems,
        );
        final reversalCommand = _buildSaleReversalCommand(
          originalCommandId: 'sale:$saleId',
          restoreLocationId: fallbackSourceLocationId,
          items: previousCommandItems,
          actorUid: effectiveActorUid,
          actorLegacyAppUserId: effectiveLegacyId,
          editCommandKey: commandKey,
        );
        await _ensureCommandLocationsInTxn(reversalCommand);
        await _inventoryMovementEngine.applyCommandInTxn(reversalCommand);
      }

      final nextSaleIdToken = await _resolveSaleEditCommandId(
        saleId: saleId,
        commandKey: commandKey,
      );
      if (nextCommandItems.isEmpty) {
        return;
      }
      final sourceLocationId = await _resolveSaleSourceLocationInTxn(
        recipientType: nextRecipientType,
        salesmanUid: salesmanUid,
        items: nextCommandItems,
      );
      final saleCommand = _buildSaleCompleteCommand(
        saleIdToken: nextSaleIdToken,
        sourceLocationId: sourceLocationId,
        items: nextCommandItems,
        actorUid: effectiveActorUid,
        actorLegacyAppUserId: effectiveLegacyId,
        editCommandKey: commandKey,
      );
      await _ensureCommandLocationsInTxn(saleCommand);
      await _inventoryMovementEngine.applyCommandInTxn(saleCommand);
    });
  }

  Future<void> performSyncAdd(Map<String, dynamic> data) async {
    await _writeDelegate().performSyncAdd(data);
  }

  Future<void> performSyncEdit(Map<String, dynamic> data) async {
    await _writeDelegate().performSyncEdit(data);
  }

  Future<void> dispatchSale({
    required String saleId,
    required String vehicleNumber,
  }) async {
    await _writeDelegate().dispatchSale(
      saleId: saleId,
      vehicleNumber: vehicleNumber,
    );
  }

  Future<void> updateReturnedQuantity({
    required String saleId,
    required String productId,
    required int additionalReturnedQty,
  }) async {
    await _writeDelegate().updateReturnedQuantity(
      saleId: saleId,
      productId: productId,
      additionalReturnedQty: additionalReturnedQty,
    );
  }

  Future<void> cancelSale({
    required String saleId,
    required String reason,
    required String userId,
    String? nowIso,
  }) async {
    await _writeDelegate().cancelSale(
      saleId: saleId,
      reason: reason,
      userId: userId,
      nowIso: nowIso,
    );
  }
}

class _RemoteSaleInventoryCommandContext {
  const _RemoteSaleInventoryCommandContext({
    required this.commandId,
    required this.sourceLocationId,
    required this.sequence,
    required this.createdAt,
    this.editCommandKey,
  });

  final String commandId;
  final String sourceLocationId;
  final int sequence;
  final DateTime createdAt;
  final String? editCommandKey;
}
