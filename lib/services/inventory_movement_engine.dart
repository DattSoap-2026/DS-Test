import 'dart:convert';

import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/core/sync/sync_queue_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/inventory_command_entity.dart';
import 'package:flutter_app/data/local/entities/inventory_location_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/stock_balance_entity.dart';
import 'package:flutter_app/data/local/entities/stock_movement_entity.dart';

import 'database_service.dart';
import 'inventory_projection_service.dart';

enum InventoryCommandType {
  internalTransfer('internal_transfer'),
  warehouseTransfer('warehouse_transfer'),
  openingSetBalance('opening_set_balance'),
  departmentIssue('department_issue'),
  departmentReturn('department_return'),
  bhattiProductionComplete('bhatti_production_complete'),
  cuttingProductionComplete('cutting_production_complete'),
  dispatchCreate('dispatch_create'),
  saleComplete('sale_complete'),
  saleReversal('sale_reversal');

  const InventoryCommandType(this.value);

  final String value;
}

class InventoryCommand {
  final String commandId;
  final InventoryCommandType commandType;
  final Map<String, dynamic> payload;
  final String actorUid;
  final String? actorLegacyAppUserId;
  final DateTime createdAt;
  final String? retryMeta;

  const InventoryCommand({
    required this.commandId,
    required this.commandType,
    required this.payload,
    required this.actorUid,
    this.actorLegacyAppUserId,
    required this.createdAt,
    this.retryMeta,
  });

  factory InventoryCommand.internalTransfer({
    required String sourceLocationId,
    required String destinationLocationId,
    required String referenceId,
    required String productId,
    required double quantityBase,
    required String actorUid,
    String? actorLegacyAppUserId,
    String? reasonCode,
    String? referenceType,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId:
          'transfer:$sourceLocationId:$destinationLocationId:$referenceId:$productId',
      commandType: InventoryCommandType.internalTransfer,
      payload: <String, dynamic>{
        'sourceLocationId': sourceLocationId,
        'destinationLocationId': destinationLocationId,
        'referenceId': referenceId,
        'referenceType': referenceType ?? 'internal_transfer',
        'productId': productId,
        'quantityBase': quantityBase,
        'reasonCode': reasonCode ?? 'internal_transfer',
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.warehouseTransfer({
    required String transferId,
    required String fromLocationId,
    required String toLocationId,
    required String productId,
    required double quantity,
    required String actorUid,
    String? actorLegacyAppUserId,
    String? notes,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId: 'warehouse_transfer:$transferId',
      commandType: InventoryCommandType.warehouseTransfer,
      payload: <String, dynamic>{
        'transferId': transferId,
        'sourceLocationId': fromLocationId,
        'destinationLocationId': toLocationId,
        'referenceId': transferId,
        'referenceType': 'warehouse_transfer',
        'productId': productId,
        'quantityBase': quantity,
        'reasonCode': 'warehouse_transfer',
        'notes': notes,
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.departmentIssue({
    required String departmentLocationId,
    required String referenceId,
    required String productId,
    required double quantityBase,
    required String actorUid,
    String? actorLegacyAppUserId,
    String? reasonCode,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId:
          'transfer:${InventoryProjectionService.warehouseMainLocationId}:'
          '$departmentLocationId:$referenceId:$productId',
      commandType: InventoryCommandType.departmentIssue,
      payload: <String, dynamic>{
        'sourceLocationId': InventoryProjectionService.warehouseMainLocationId,
        'destinationLocationId': departmentLocationId,
        'referenceId': referenceId,
        'referenceType': 'department_issue',
        'productId': productId,
        'quantityBase': quantityBase,
        'reasonCode': reasonCode ?? 'department_issue',
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.departmentReturn({
    required String departmentLocationId,
    required String referenceId,
    required String productId,
    required double quantityBase,
    required String actorUid,
    String? actorLegacyAppUserId,
    String? reasonCode,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId:
          'transfer:$departmentLocationId:'
          '${InventoryProjectionService.warehouseMainLocationId}:'
          '$referenceId:$productId',
      commandType: InventoryCommandType.departmentReturn,
      payload: <String, dynamic>{
        'sourceLocationId': departmentLocationId,
        'destinationLocationId':
            InventoryProjectionService.warehouseMainLocationId,
        'referenceId': referenceId,
        'referenceType': 'department_return',
        'productId': productId,
        'quantityBase': quantityBase,
        'reasonCode': reasonCode ?? 'department_return',
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.openingSetBalance({
    required String warehouseId,
    required String productId,
    required String openingWindowId,
    required double setQuantityBase,
    required String actorUid,
    String? actorLegacyAppUserId,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId: 'opening:$warehouseId:$productId:$openingWindowId',
      commandType: InventoryCommandType.openingSetBalance,
      payload: <String, dynamic>{
        'locationId': warehouseId,
        'productId': productId,
        'openingWindowId': openingWindowId,
        'setQuantityBase': setQuantityBase,
        'referenceId': openingWindowId,
        'referenceType': 'opening_set_balance',
        'reasonCode': 'opening_set_balance',
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.dispatchCreate({
    required String dispatchId,
    required String salesmanUid,
    required List<InventoryCommandItem> items,
    required String actorUid,
    String? actorLegacyAppUserId,
    DateTime? createdAt,
    String? sourceLocationId,
  }) {
    return InventoryCommand(
      commandId: 'dispatch:$dispatchId',
      commandType: InventoryCommandType.dispatchCreate,
      payload: <String, dynamic>{
        'dispatchId': dispatchId,
        'sourceLocationId':
            sourceLocationId ?? InventoryProjectionService.warehouseMainLocationId,
        'salesmanUid': salesmanUid,
        'destinationLocationId':
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid),
        'referenceId': dispatchId,
        'referenceType': 'dispatch',
        'reasonCode': 'dispatch_create',
        'items': items.map((item) => item.toJson()).toList(growable: false),
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.saleComplete({
    required String saleId,
    required String salesmanUid,
    required List<InventoryCommandItem> items,
    required String actorUid,
    String? actorLegacyAppUserId,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId: 'sale:$saleId',
      commandType: InventoryCommandType.saleComplete,
      payload: <String, dynamic>{
        'saleId': saleId,
        'sourceLocationId': InventoryProjectionService.salesmanLocationIdForUid(
          salesmanUid,
        ),
        'destinationLocationId':
            InventoryProjectionService.virtualSoldLocationId,
        'referenceId': saleId,
        'referenceType': 'sale',
        'reasonCode': 'sale_complete',
        'items': items.map((item) => item.toJson()).toList(growable: false),
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.saleReversal({
    required String originalCommandId,
    required String salesmanUid,
    required List<InventoryCommandItem> items,
    required String actorUid,
    String? actorLegacyAppUserId,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId: 'reversal:$originalCommandId',
      commandType: InventoryCommandType.saleReversal,
      payload: <String, dynamic>{
        'originalCommandId': originalCommandId,
        'sourceLocationId': InventoryProjectionService.virtualSoldLocationId,
        'destinationLocationId':
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid),
        'referenceId': originalCommandId,
        'referenceType': 'sale_reversal',
        'reasonCode': 'sale_reversal',
        'items': items.map((item) => item.toJson()).toList(growable: false),
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.bhattiProductionComplete({
    required String batchId,
    required String consumptionLocationId,
    required String outputLocationId,
    required List<InventoryCommandItem> consumptions,
    required List<InventoryCommandItem> outputs,
    required String actorUid,
    String? actorLegacyAppUserId,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId: 'bhatti:$batchId',
      commandType: InventoryCommandType.bhattiProductionComplete,
      payload: <String, dynamic>{
        'batchId': batchId,
        'consumptionLocationId': consumptionLocationId,
        'outputLocationId': outputLocationId,
        'referenceId': batchId,
        'referenceType': 'bhatti_batch',
        'reasonCode': 'bhatti_production_complete',
        'consumptions': consumptions
            .map((item) => item.toJson())
            .toList(growable: false),
        'outputs': outputs.map((item) => item.toJson()).toList(growable: false),
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory InventoryCommand.cuttingProductionComplete({
    required String batchId,
    required String consumptionLocationId,
    required String outputLocationId,
    required List<InventoryCommandItem> consumptions,
    required List<InventoryCommandItem> outputs,
    required String actorUid,
    String? actorLegacyAppUserId,
    DateTime? createdAt,
  }) {
    return InventoryCommand(
      commandId: 'cutting:$batchId',
      commandType: InventoryCommandType.cuttingProductionComplete,
      payload: <String, dynamic>{
        'batchId': batchId,
        'consumptionLocationId': consumptionLocationId,
        'outputLocationId': outputLocationId,
        'referenceId': batchId,
        'referenceType': 'cutting_batch',
        'reasonCode': 'cutting_production_complete',
        'consumptions': consumptions
            .map((item) => item.toJson())
            .toList(growable: false),
        'outputs': outputs.map((item) => item.toJson()).toList(growable: false),
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toOutboxPayload() {
    return <String, dynamic>{
      'id': commandId,
      'commandId': commandId,
      'commandType': commandType.value,
      'payload': jsonEncode(payload),
      'actorUid': actorUid,
      'actorLegacyAppUserId': actorLegacyAppUserId,
      'createdAt': createdAt.toIso8601String(),
      'appliedLocally': true,
      'appliedRemotely': false,
      'retryMeta': retryMeta,
      'idempotencyKey': commandId,
    };
  }
}

class InventoryCommandItem {
  final String productId;
  final double quantityBase;
  final String? sourceLocationId;
  final String? destinationLocationId;

  const InventoryCommandItem({
    required this.productId,
    required this.quantityBase,
    this.sourceLocationId,
    this.destinationLocationId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'quantityBase': quantityBase,
      if (sourceLocationId != null) 'sourceLocationId': sourceLocationId,
      if (destinationLocationId != null)
        'destinationLocationId': destinationLocationId,
    };
  }
}

class InventoryMovementEngine {
  InventoryMovementEngine(
    this._dbService,
    this._projectionService,
  );

  final DatabaseService _dbService;
  final InventoryProjectionService _projectionService;

  Future<void> applyCommand(InventoryCommand command) async {
    await _dbService.db.writeTxn(() async {
      await applyCommandInTxn(command);
    });
  }

  Future<bool> applyCommandInTxn(InventoryCommand command) async {
    _validateCommand(command);

    final existing = await _dbService.inventoryCommands.getById(
      command.commandId,
    );
    if (existing?.appliedLocally == true) {
      return false;
    }

    final resolvedLocations = await _resolveLocations(command);
    final balanceSnapshot = await _loadBalanceSnapshot(command);
    final movements = _generateMovementLines(
      command,
      balanceSnapshot: balanceSnapshot,
    );
    final productNames = await _loadProductNames(movements);

    final existingInTxn = await _dbService.inventoryCommands.getById(
      command.commandId,
    );
    if (existingInTxn?.appliedLocally == true) {
      return false;
    }

    await _ensureLocationsInTxn(
      resolvedLocations.values.toList(growable: false),
      occurredAt: command.createdAt,
    );

    final commandEntity = InventoryCommandEntity()
      ..commandId = command.commandId
      ..commandType = command.commandType.value
      ..payload = jsonEncode(command.payload)
      ..actorUid = command.actorUid
      ..actorLegacyAppUserId = command.actorLegacyAppUserId
      ..createdAt = command.createdAt
      ..appliedLocally = true
      ..appliedRemotely = existingInTxn?.appliedRemotely ?? false
      ..retryMeta = command.retryMeta
      ..updatedAt = command.createdAt
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
    await _dbService.inventoryCommands.put(commandEntity);

    if (movements.isNotEmpty) {
      final movementEntities = movements
          .map(
            (movement) => _toMovementEntity(
              movement,
              command,
              productNames: productNames,
            ),
          )
          .toList(growable: false);
      await _dbService.stockMovements.putAll(movementEntities);
    }

    final touchedBalances = <String, _TouchedBalance>{};
    for (final movement in movements) {
      await _applyMovementInTxn(
        movement,
        occurredAt: command.createdAt,
        touchedBalances: touchedBalances,
      );
    }

    for (final touched in touchedBalances.values) {
      await _projectionService.applyCompatibilityProjectionInTxn(
        locationId: touched.locationId,
        productId: touched.productId,
        quantity: touched.quantity,
        updatedAt: command.createdAt,
        syncStatus: SyncStatus.pending,
      );
    }

    await _enqueueCommand(command);
    return true;
  }

  void _validateCommand(InventoryCommand command) {
    if (command.commandId.trim().isEmpty) {
      throw ArgumentError('commandId is required');
    }
    if (command.actorUid.trim().isEmpty) {
      throw ArgumentError('actorUid is required');
    }

    switch (command.commandType) {
      case InventoryCommandType.internalTransfer:
      case InventoryCommandType.warehouseTransfer:
      case InventoryCommandType.departmentIssue:
      case InventoryCommandType.departmentReturn:
        _validateTransferCommand(command);
        return;
      case InventoryCommandType.openingSetBalance:
        _validateOpeningCommand(command);
        return;
      case InventoryCommandType.dispatchCreate:
      case InventoryCommandType.saleComplete:
      case InventoryCommandType.saleReversal:
        _validateItemListCommand(command);
        return;
      case InventoryCommandType.bhattiProductionComplete:
      case InventoryCommandType.cuttingProductionComplete:
        _validateProductionCommand(command);
        return;
    }
  }

  void _validateTransferCommand(InventoryCommand command) {
    final sourceLocationId = _requiredString(
      command.payload,
      'sourceLocationId',
    );
    final destinationLocationId = _requiredString(
      command.payload,
      'destinationLocationId',
    );
    final referenceId = _requiredString(command.payload, 'referenceId');
    final productId = _requiredString(command.payload, 'productId');
    _requiredPositiveDouble(command.payload, 'quantityBase');

    if (sourceLocationId == destinationLocationId) {
      throw ArgumentError('source and destination locations must differ');
    }

    if (command.commandType == InventoryCommandType.warehouseTransfer) {
      final transferId = _requiredString(command.payload, 'transferId');
      final expectedCommandId = 'warehouse_transfer:$transferId';
      if (command.commandId != expectedCommandId) {
        throw ArgumentError(
          'commandId mismatch. Expected $expectedCommandId, got ${command.commandId}',
        );
      }
      return;
    }

    final expectedCommandId =
        'transfer:$sourceLocationId:$destinationLocationId:$referenceId:$productId';
    if (command.commandId != expectedCommandId) {
      throw ArgumentError(
        'commandId mismatch. Expected $expectedCommandId, got ${command.commandId}',
      );
    }
  }

  void _validateOpeningCommand(InventoryCommand command) {
    final locationId = _requiredString(command.payload, 'locationId');
    final productId = _requiredString(command.payload, 'productId');
    final openingWindowId = _requiredString(command.payload, 'openingWindowId');
    _requiredDouble(command.payload, 'setQuantityBase');

    final expectedCommandId = 'opening:$locationId:$productId:$openingWindowId';
    if (command.commandId != expectedCommandId) {
      throw ArgumentError(
        'commandId mismatch. Expected $expectedCommandId, got ${command.commandId}',
      );
    }
  }

  void _validateItemListCommand(InventoryCommand command) {
    final sourceLocationId = _requiredString(
      command.payload,
      'sourceLocationId',
    );
    final destinationLocationId = _requiredString(
      command.payload,
      'destinationLocationId',
    );
    final items = _requiredItemList(command.payload, 'items');
    if (items.isEmpty) {
      throw ArgumentError('items must not be empty');
    }
    if (sourceLocationId == destinationLocationId) {
      throw ArgumentError('source and destination locations must differ');
    }
    for (final item in items) {
      _requiredString(item, 'productId');
      _requiredPositiveDouble(item, 'quantityBase');
    }

    switch (command.commandType) {
      case InventoryCommandType.dispatchCreate:
        final dispatchId = _requiredString(command.payload, 'dispatchId');
        if (command.commandId != 'dispatch:$dispatchId') {
          throw ArgumentError('dispatch commandId mismatch');
        }
        break;
      case InventoryCommandType.saleComplete:
        final saleId = _requiredString(command.payload, 'saleId');
        if (command.commandId != 'sale:$saleId') {
          throw ArgumentError('sale commandId mismatch');
        }
        break;
      case InventoryCommandType.saleReversal:
        final originalCommandId = _requiredString(
          command.payload,
          'originalCommandId',
        );
        if (command.commandId != 'reversal:$originalCommandId') {
          throw ArgumentError('reversal commandId mismatch');
        }
        break;
      default:
        break;
    }
  }

  void _validateProductionCommand(InventoryCommand command) {
    final batchId = _requiredString(command.payload, 'batchId');
    final consumptions = _requiredItemList(command.payload, 'consumptions');
    final outputs = _requiredItemList(command.payload, 'outputs');
    final consumptionLocationId = command.payload['consumptionLocationId']
        ?.toString()
        .trim();
    final outputLocationId = command.payload['outputLocationId']
        ?.toString()
        .trim();
    if (consumptions.isEmpty && outputs.isEmpty) {
      throw ArgumentError(
        'production command must have consumptions or outputs',
      );
    }
    if (consumptionLocationId == null ||
        consumptionLocationId.isEmpty ||
        outputLocationId == null ||
        outputLocationId.isEmpty) {
      throw ArgumentError(
        'consumptionLocationId and outputLocationId are required',
      );
    }
    for (final item in consumptions) {
      _requiredString(item, 'productId');
      _requiredPositiveDouble(item, 'quantityBase');
    }
    for (final item in outputs) {
      _requiredString(item, 'productId');
      _requiredPositiveDouble(item, 'quantityBase');
    }

    final expectedCommandId =
        command.commandType == InventoryCommandType.bhattiProductionComplete
        ? 'bhatti:$batchId'
        : 'cutting:$batchId';
    if (command.commandId != expectedCommandId) {
      throw ArgumentError('production commandId mismatch');
    }
  }

  Future<Map<String, _ResolvedLocation>> _resolveLocations(
    InventoryCommand command,
  ) async {
    final locationIds = <String>{};

    switch (command.commandType) {
      case InventoryCommandType.internalTransfer:
      case InventoryCommandType.warehouseTransfer:
      case InventoryCommandType.departmentIssue:
      case InventoryCommandType.departmentReturn:
        locationIds.add(_requiredString(command.payload, 'sourceLocationId'));
        locationIds.add(
          _requiredString(command.payload, 'destinationLocationId'),
        );
        break;
      case InventoryCommandType.openingSetBalance:
        locationIds.add(_requiredString(command.payload, 'locationId'));
        break;
      case InventoryCommandType.dispatchCreate:
      case InventoryCommandType.saleComplete:
      case InventoryCommandType.saleReversal:
        locationIds.add(_requiredString(command.payload, 'sourceLocationId'));
        locationIds.add(
          _requiredString(command.payload, 'destinationLocationId'),
        );
        break;
      case InventoryCommandType.bhattiProductionComplete:
      case InventoryCommandType.cuttingProductionComplete:
        for (final item in _requiredItemList(command.payload, 'consumptions')) {
          final sourceLocationId = item['sourceLocationId']?.toString();
          final destinationLocationId = item['destinationLocationId']
              ?.toString();
          if (sourceLocationId != null && sourceLocationId.trim().isNotEmpty) {
            locationIds.add(sourceLocationId.trim());
          }
          if (destinationLocationId != null &&
              destinationLocationId.trim().isNotEmpty) {
            locationIds.add(destinationLocationId.trim());
          }
        }
        for (final item in _requiredItemList(command.payload, 'outputs')) {
          final sourceLocationId = item['sourceLocationId']?.toString();
          final destinationLocationId = item['destinationLocationId']
              ?.toString();
          if (sourceLocationId != null && sourceLocationId.trim().isNotEmpty) {
            locationIds.add(sourceLocationId.trim());
          }
          if (destinationLocationId != null &&
              destinationLocationId.trim().isNotEmpty) {
            locationIds.add(destinationLocationId.trim());
          }
        }
        final consumptionLocationId = command.payload['consumptionLocationId']
            ?.toString();
        final outputLocationId = command.payload['outputLocationId']
            ?.toString();
        if (consumptionLocationId != null &&
            consumptionLocationId.trim().isNotEmpty) {
          locationIds.add(consumptionLocationId.trim());
        }
        if (outputLocationId != null && outputLocationId.trim().isNotEmpty) {
          locationIds.add(outputLocationId.trim());
        }
        break;
    }

    final resolved = <String, _ResolvedLocation>{};
    for (final locationId in locationIds) {
      final existing = await _dbService.inventoryLocations.getById(locationId);
      if (existing != null) {
        resolved[locationId] = _ResolvedLocation.fromEntity(existing);
        continue;
      }

      if (locationId.startsWith('virtual:')) {
        resolved[locationId] = _ResolvedLocation.virtual(locationId);
        continue;
      }

      throw StateError('Inventory location not found: $locationId');
    }
    return resolved;
  }

  Future<Map<String, double>> _loadBalanceSnapshot(
    InventoryCommand command,
  ) async {
    if (command.commandType != InventoryCommandType.openingSetBalance) {
      return const <String, double>{};
    }

    final locationId = _requiredString(command.payload, 'locationId');
    final productId = _requiredString(command.payload, 'productId');
    final balanceId = StockBalanceEntity.composeId(locationId, productId);
    final existing = await _dbService.stockBalances.getById(balanceId);
    return <String, double>{balanceId: existing?.quantity ?? 0.0};
  }

  List<_InventoryMovementLine> _generateMovementLines(
    InventoryCommand command, {
    required Map<String, double> balanceSnapshot,
  }) {
    switch (command.commandType) {
      case InventoryCommandType.internalTransfer:
      case InventoryCommandType.warehouseTransfer:
      case InventoryCommandType.departmentIssue:
      case InventoryCommandType.departmentReturn:
        return _buildSingleTransferLine(command);
      case InventoryCommandType.openingSetBalance:
        return _buildOpeningLines(command, balanceSnapshot: balanceSnapshot);
      case InventoryCommandType.dispatchCreate:
      case InventoryCommandType.saleComplete:
      case InventoryCommandType.saleReversal:
        return _buildItemTransferLines(command);
      case InventoryCommandType.bhattiProductionComplete:
      case InventoryCommandType.cuttingProductionComplete:
        return _buildProductionLines(command);
    }
  }

  List<_InventoryMovementLine> _buildSingleTransferLine(
    InventoryCommand command,
  ) {
    final sourceLocationId = _requiredString(
      command.payload,
      'sourceLocationId',
    );
    final destinationLocationId = _requiredString(
      command.payload,
      'destinationLocationId',
    );
    final productId = _requiredString(command.payload, 'productId');
    final quantityBase = _requiredPositiveDouble(
      command.payload,
      'quantityBase',
    );

    return <_InventoryMovementLine>[
      _InventoryMovementLine(
        commandId: command.commandId,
        movementIndex: 0,
        productId: productId,
        sourceLocationId: sourceLocationId,
        destinationLocationId: destinationLocationId,
        quantityBase: quantityBase,
        movementType: command.commandType.value,
        reasonCode: command.payload['reasonCode']?.toString(),
        referenceType: command.payload['referenceType']?.toString(),
        referenceId: command.payload['referenceId']?.toString(),
        actorUid: command.actorUid,
        occurredAt: command.createdAt,
        isReversal: false,
      ),
    ];
  }

  List<_InventoryMovementLine> _buildOpeningLines(
    InventoryCommand command, {
    required Map<String, double> balanceSnapshot,
  }) {
    final locationId = _requiredString(command.payload, 'locationId');
    final productId = _requiredString(command.payload, 'productId');
    final setQuantity = _requiredDouble(command.payload, 'setQuantityBase');
    final balanceId = StockBalanceEntity.composeId(locationId, productId);
    final currentBalance = balanceSnapshot[balanceId] ?? 0.0;
    final delta = setQuantity - currentBalance;
    if (delta.abs() < 1e-9) {
      return const <_InventoryMovementLine>[];
    }

    return <_InventoryMovementLine>[
      _InventoryMovementLine(
        commandId: command.commandId,
        movementIndex: 0,
        productId: productId,
        sourceLocationId: delta < 0 ? locationId : null,
        destinationLocationId: delta > 0 ? locationId : null,
        quantityBase: delta.abs(),
        movementType: command.commandType.value,
        reasonCode: command.payload['reasonCode']?.toString(),
        referenceType: command.payload['referenceType']?.toString(),
        referenceId: command.payload['referenceId']?.toString(),
        actorUid: command.actorUid,
        occurredAt: command.createdAt,
        isReversal: false,
      ),
    ];
  }

  List<_InventoryMovementLine> _buildItemTransferLines(
    InventoryCommand command,
  ) {
    final sourceLocationId = _requiredString(
      command.payload,
      'sourceLocationId',
    );
    final destinationLocationId = _requiredString(
      command.payload,
      'destinationLocationId',
    );
    final items = _requiredItemList(command.payload, 'items');

    final lines = <_InventoryMovementLine>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      lines.add(
        _InventoryMovementLine(
          commandId: command.commandId,
          movementIndex: i,
          productId: _requiredString(item, 'productId'),
          sourceLocationId: sourceLocationId,
          destinationLocationId: destinationLocationId,
          quantityBase: _requiredPositiveDouble(item, 'quantityBase'),
          movementType: command.commandType.value,
          reasonCode: command.payload['reasonCode']?.toString(),
          referenceType: command.payload['referenceType']?.toString(),
          referenceId: command.payload['referenceId']?.toString(),
          actorUid: command.actorUid,
          occurredAt: command.createdAt,
          isReversal: command.commandType == InventoryCommandType.saleReversal,
        ),
      );
    }
    return lines;
  }

  List<_InventoryMovementLine> _buildProductionLines(InventoryCommand command) {
    final lines = <_InventoryMovementLine>[];
    final consumptions = _requiredItemList(command.payload, 'consumptions');
    final outputs = _requiredItemList(command.payload, 'outputs');
    final consumptionLocationId = command.payload['consumptionLocationId']
        ?.toString();
    final outputLocationId = command.payload['outputLocationId']?.toString();

    var index = 0;
    for (final item in consumptions) {
      lines.add(
        _InventoryMovementLine(
          commandId: command.commandId,
          movementIndex: index++,
          productId: _requiredString(item, 'productId'),
          sourceLocationId:
              item['sourceLocationId']?.toString() ?? consumptionLocationId,
          destinationLocationId: item['destinationLocationId']?.toString(),
          quantityBase: _requiredPositiveDouble(item, 'quantityBase'),
          movementType: '${command.commandType.value}_consume',
          reasonCode: command.payload['reasonCode']?.toString(),
          referenceType: command.payload['referenceType']?.toString(),
          referenceId: command.payload['referenceId']?.toString(),
          actorUid: command.actorUid,
          occurredAt: command.createdAt,
          isReversal: false,
        ),
      );
    }
    for (final item in outputs) {
      lines.add(
        _InventoryMovementLine(
          commandId: command.commandId,
          movementIndex: index++,
          productId: _requiredString(item, 'productId'),
          sourceLocationId: item['sourceLocationId']?.toString(),
          destinationLocationId:
              item['destinationLocationId']?.toString() ?? outputLocationId,
          quantityBase: _requiredPositiveDouble(item, 'quantityBase'),
          movementType: '${command.commandType.value}_output',
          reasonCode: command.payload['reasonCode']?.toString(),
          referenceType: command.payload['referenceType']?.toString(),
          referenceId: command.payload['referenceId']?.toString(),
          actorUid: command.actorUid,
          occurredAt: command.createdAt,
          isReversal: false,
        ),
      );
    }
    return lines;
  }

  Future<void> _ensureLocationsInTxn(
    List<_ResolvedLocation> locations, {
    required DateTime occurredAt,
  }) async {
    for (final location in locations) {
      final existing = await _dbService.inventoryLocations.getById(location.id);
      if (existing != null) {
        continue;
      }
      if (!location.persistIfMissing) {
        throw StateError('Inventory location not found: ${location.id}');
      }

      final entity = InventoryLocationEntity()
        ..id = location.id
        ..type = location.type
        ..name = location.name
        ..code = location.code
        ..parentLocationId = null
        ..ownerUserUid = null
        ..isActive = true
        ..isPrimaryMainWarehouse = false
        ..updatedAt = occurredAt
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      await _dbService.inventoryLocations.put(entity);
    }
  }

  StockMovementEntity _toMovementEntity(
    _InventoryMovementLine movement,
    InventoryCommand command, {
    required Map<String, String> productNames,
  }) {
    final productName = productNames[movement.productId] ?? movement.productId;
    return StockMovementEntity()
      ..movementId = '${movement.commandId}:${movement.movementIndex}'
      ..commandId = movement.commandId
      ..movementIndex = movement.movementIndex
      ..productId = movement.productId
      ..productName = productName
      ..sourceLocationId = movement.sourceLocationId
      ..destinationLocationId = movement.destinationLocationId
      ..quantityBase = movement.quantityBase
      ..movementType = movement.movementType
      ..reasonCode = movement.reasonCode
      ..referenceType = movement.referenceType
      ..referenceId = movement.referenceId
      ..actorUid = movement.actorUid
      ..occurredAt = movement.occurredAt
      ..createdAt = movement.occurredAt
      ..isReversal = movement.isReversal
      ..type = movement.movementType
      ..referenceNumber = movement.destinationLocationId
      ..createdBy = movement.actorUid
      ..notes = movement.reasonCode
      ..isSynced = false
      ..syncStatus = SyncStatus.pending
      ..updatedAt = command.createdAt
      ..isDeleted = false;
  }

  Future<void> _applyMovementInTxn(
    _InventoryMovementLine movement, {
    required DateTime occurredAt,
    required Map<String, _TouchedBalance> touchedBalances,
  }) async {
    if (movement.sourceLocationId != null) {
      final sourceBalance = await _loadBalanceInTxn(
        locationId: movement.sourceLocationId!,
        productId: movement.productId,
        occurredAt: occurredAt,
      );
      final nextQuantity = sourceBalance.quantity - movement.quantityBase;
      if (nextQuantity < -1e-9 &&
          !_allowsNegativeSourceBalance(movement.sourceLocationId!)) {
        throw StateError(
          'Insufficient stock for ${movement.productId} at ${movement.sourceLocationId}. '
          'Available: ${sourceBalance.quantity}, required: ${movement.quantityBase}',
        );
      }
      sourceBalance
        ..quantity = nextQuantity.abs() < 1e-9 ? 0.0 : nextQuantity
        ..updatedAt = occurredAt
        ..syncStatus = SyncStatus.pending;
      await _dbService.stockBalances.put(sourceBalance);
      touchedBalances[sourceBalance.id] = _TouchedBalance(
        locationId: sourceBalance.locationId,
        productId: sourceBalance.productId,
        quantity: sourceBalance.quantity,
      );
    }

    if (movement.destinationLocationId != null) {
      final destinationBalance = await _loadBalanceInTxn(
        locationId: movement.destinationLocationId!,
        productId: movement.productId,
        occurredAt: occurredAt,
      );
      destinationBalance
        ..quantity = destinationBalance.quantity + movement.quantityBase
        ..updatedAt = occurredAt
        ..syncStatus = SyncStatus.pending;
      await _dbService.stockBalances.put(destinationBalance);
      touchedBalances[destinationBalance.id] = _TouchedBalance(
        locationId: destinationBalance.locationId,
        productId: destinationBalance.productId,
        quantity: destinationBalance.quantity,
      );
    }
  }

  Future<void> _enqueueCommand(InventoryCommand command) async {
    final payload = command.toOutboxPayload();
    await SyncQueueService.instance.addToQueue(
      collectionName: CollectionRegistry.inventoryCommands,
      documentId: command.commandId,
      operation: 'set',
      payload: payload,
    );
  }

  bool _allowsNegativeSourceBalance(String locationId) {
    return locationId.startsWith('virtual:');
  }

  Future<StockBalanceEntity> _loadBalanceInTxn({
    required String locationId,
    required String productId,
    required DateTime occurredAt,
  }) async {
    final balanceId = StockBalanceEntity.composeId(locationId, productId);
    final existing = await _dbService.stockBalances.getById(balanceId);
    if (existing != null) {
      return existing;
    }

    return StockBalanceEntity()
      ..id = balanceId
      ..locationId = locationId
      ..productId = productId
      ..quantity = 0.0
      ..updatedAt = occurredAt
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }

  Future<Map<String, String>> _loadProductNames(
    List<_InventoryMovementLine> movements,
  ) async {
    final productNames = <String, String>{};
    final uniqueProductIds = movements
        .map((movement) => movement.productId)
        .toSet();
    for (final productId in uniqueProductIds) {
      final product = await _dbService.products.getById(productId);
      if (product == null) {
        continue;
      }
      productNames[productId] = product.name;
    }
    return productNames;
  }

  String _requiredString(Map<String, dynamic> source, String key) {
    final value = source[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      throw ArgumentError('$key is required');
    }
    return value;
  }

  double _requiredPositiveDouble(Map<String, dynamic> source, String key) {
    final value = _requiredDouble(source, key);
    if (value <= 0) {
      throw ArgumentError('$key must be greater than zero');
    }
    return value;
  }

  double _requiredDouble(Map<String, dynamic> source, String key) {
    final raw = source[key];
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      final parsed = double.tryParse(raw.trim());
      if (parsed != null) {
        return parsed;
      }
    }
    throw ArgumentError('$key must be a number');
  }

  List<Map<String, dynamic>> _requiredItemList(
    Map<String, dynamic> source,
    String key,
  ) {
    final raw = source[key];
    if (raw is! List) {
      throw ArgumentError('$key must be a list');
    }
    return raw
        .map((item) {
          if (item is! Map) {
            throw ArgumentError('$key contains an invalid item');
          }
          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
  }
}

class _InventoryMovementLine {
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

  const _InventoryMovementLine({
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

class _ResolvedLocation {
  final String id;
  final String type;
  final String name;
  final String code;
  final bool persistIfMissing;

  const _ResolvedLocation({
    required this.id,
    required this.type,
    required this.name,
    required this.code,
    required this.persistIfMissing,
  });

  factory _ResolvedLocation.fromEntity(InventoryLocationEntity entity) {
    return _ResolvedLocation(
      id: entity.id,
      type: entity.type,
      name: entity.name,
      code: entity.code,
      persistIfMissing: false,
    );
  }

  factory _ResolvedLocation.virtual(String id) {
    final suffix = id.replaceFirst('virtual:', '').trim();
    final safeSuffix = suffix.isEmpty ? 'misc' : suffix;
    final normalizedCode = safeSuffix
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final title = safeSuffix
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');

    return _ResolvedLocation(
      id: id,
      type: InventoryLocationEntity.virtualType,
      name: title.isEmpty ? 'Virtual Location' : title,
      code: 'VIRTUAL_${normalizedCode.isEmpty ? 'MISC' : normalizedCode}',
      persistIfMissing: true,
    );
  }
}

class _TouchedBalance {
  final String locationId;
  final String productId;
  final double quantity;

  const _TouchedBalance({
    required this.locationId,
    required this.productId,
    required this.quantity,
  });
}
