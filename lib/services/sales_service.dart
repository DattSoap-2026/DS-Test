import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart' hide Query; // Hide Query
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/business_rule_exception.dart';
import '../constants/role_access_matrix.dart';
import '../data/local/entities/user_entity.dart'; // User Entity
import '../data/local/entities/customer_entity.dart'; // Customer Entity
import '../data/local/entities/product_entity.dart';
import '../data/local/base_entity.dart'; // Added BaseEntity for SyncStatus
import '../data/local/entities/inventory_command_entity.dart';
import '../data/local/entities/inventory_location_entity.dart';
import '../data/local/entities/stock_balance_entity.dart';
import 'offline_first_service.dart';
import 'database_service.dart'; // Database Service
import 'inventory_service.dart'; // Inventory Service
import 'inventory_movement_engine.dart';
import 'inventory_projection_service.dart';
import 'service_capability_guard.dart';
import '../data/local/entities/stock_ledger_entity.dart'; // Added
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'outbox_codec.dart';

import '../models/types/sales_types.dart';
import '../domain/engines/sale_calculation_engine.dart';
import '../models/types/user_types.dart'
    show AllocatedStockItem, AppUser, UserRole;
import '../modules/accounting/compensation_strategy.dart';
import '../modules/accounting/posting_service.dart';
import '../modules/accounting/voucher_repository.dart';
import 'settings_service.dart';
import '../utils/app_logger.dart';
import '../utils/auth_utils.dart';
import 'delegates/sales_stock_delegate.dart';
import 'delegates/sales_accounting_delegate.dart';
import 'delegates/sales_validation_delegate.dart';

const salesCollection = 'sales';
const accountingCompensationLogCollection = 'accounting_compensation_log';
const salesVoucherPostRetryCollection = 'sales_voucher_posts';

class _LineTotals {
  final SaleItemForUI item;
  final double subtotal;
  final double itemDiscount;
  final double primaryDiscountShare;
  final double additionalDiscountShare;
  final double net;
  final double tax;
  final double total;

  _LineTotals({
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

class _SaleCalculationResult {
  final List<_LineTotals> lines;
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

  _SaleCalculationResult({
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

class SalesService extends OfflineFirstService {
  final SettingsService _settingsService;
  final PostingService _postingService;
  final DatabaseService _dbService; // Isar
  // ignore: unused_field
  final InventoryService _inventoryService; // For ledgers
  final InventoryMovementEngine _inventoryMovementEngine;
  final SaleCalculationEngine _engine = SaleCalculationEngine();

  late final SalesStockDelegate _stockDelegate;
  late final SalesAccountingDelegate _accountingDelegate;
  late final SalesValidationDelegate _validationDelegate;
  Future<void> Function()? _centralQueueSync;
  static const Set<UserRole> _salesMutationRoleOverrides = {
    UserRole.dispatchManager,
  };
  static const Set<UserRole> _accountingMutationRoleOverrides = {
    UserRole.owner,
    UserRole.admin,
    UserRole.accountant,
  };

  SalesAccountingDelegate get accountingDelegate => _accountingDelegate;
  ServiceCapabilityGuard get _capabilityGuard =>
      ServiceCapabilityGuard(auth: auth, dbService: _dbService);

  void bindCentralQueueSync(Future<void> Function() callback) {
    _centralQueueSync = callback;
  }

  Future<UserEntity?> _findLocalSalesmanUser(String firebaseUid) async {
    final authUser = auth?.currentUser;
    final fallbackEmail =
        authUser != null && authUser.uid.trim() == firebaseUid.trim()
        ? authUser.email
        : null;
    return findUserByFirebaseUid(
      _dbService.users,
      firebaseUid,
      fallbackEmail: fallbackEmail,
    );
  }

  SalesService(
    super.firebase,
    DatabaseService dbService,
    this._inventoryService, {
    InventoryMovementEngine? inventoryMovementEngine,
  }) : _dbService = dbService,
       _settingsService = SettingsService(firebase),
       _postingService = PostingService(firebase),
       _inventoryMovementEngine =
           inventoryMovementEngine ??
           InventoryMovementEngine(
             dbService,
             InventoryProjectionService(dbService),
           ) {
    _stockDelegate = SalesStockDelegate();
    _validationDelegate = SalesValidationDelegate();
    _accountingDelegate = SalesAccountingDelegate(
      _dbService,
      (action, payload, {collectionName, syncImmediately = false}) =>
          syncToFirebase(
            action,
            payload,
            collectionName: collectionName ?? salesCollection,
            syncImmediately: syncImmediately,
          ),
      (action, payloads, {collectionName}) => bulkSyncToFirebase(
        action,
        payloads,
        collectionName: collectionName ?? salesCollection,
      ),
    );
  }

  @override
  String get localStorageKey => 'local_sales';

  @override
  bool get useIsar => true;

  static const String _legacyMigrationFlag = 'migrated_sales_to_isar_v1';
  static const int _salesPageSize = 500;

  Future<List<SaleEntity>> _fetchAllSalesPaged() async {
    final allSales = <SaleEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.sales
          .where()
          .offset(offset)
          .limit(_salesPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      allSales.addAll(chunk);
      if (chunk.length < _salesPageSize) {
        break;
      }
      offset += _salesPageSize;
    }
    return allSales;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double _round2(num value) => (value * 100).roundToDouble() / 100;

  String _normalizeGstType(String raw) {
    final normalized = raw.trim().toUpperCase();
    if (normalized == 'CGST+SGST') return 'CGST+SGST';
    if (normalized == 'IGST') return 'IGST';
    return 'None';
  }

  Future<AppUser> _requireSalesMutationActor(String operation) {
    return _capabilityGuard.requireCapabilityOrRole(
      operation: operation,
      capability: RoleCapability.salesMutate,
      allowedRoles: _salesMutationRoleOverrides,
    );
  }

  void _ensureSalesmanAllocationUsesDispatch(String recipientType) {
    final normalized = recipientType.trim().toLowerCase();
    if (normalized == 'salesman') {
      throw BusinessRuleException(
        'Salesman stock allocation must go through dispatch workflow. Use dispatch screen instead.',
      );
    }
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

  String _sanitizeDeterministicToken(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return 'unknown';
    return normalized.replaceAll(RegExp(r'[^a-z0-9_\-]'), '_');
  }

  String _buildSaleMovementId({
    required String saleId,
    required String productId,
    required int itemIndex,
    required bool isFree,
  }) {
    final token =
        '${_sanitizeDeterministicToken(saleId)}_${_sanitizeDeterministicToken(productId)}_${itemIndex}_${isFree ? 'free' : 'paid'}';
    return 'sale_move_${fastHash(token)}';
  }

  String _resolveSaleMovementId({
    required String saleId,
    required Map<String, dynamic> item,
    required int itemIndex,
  }) {
    final explicit = item['movementId']?.toString().trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    final productId = item['productId']?.toString().trim();
    if (productId == null || productId.isEmpty) {
      throw Exception('Sale item payload missing productId for movement sync');
    }
    final isFree = item['isFree'] == true;
    return _buildSaleMovementId(
      saleId: saleId,
      productId: productId,
      itemIndex: itemIndex,
      isFree: isFree,
    );
  }

  String _buildCommandAuditDocId(String commandKey) {
    final token = _sanitizeDeterministicToken(commandKey);
    if (token.length <= 480) {
      return 'cmd_$token';
    }
    return 'cmd_${token.substring(0, 420)}_${fastHash(commandKey)}';
  }

  String _buildSaleEditCommandKey(Map<String, dynamic> payload) {
    final explicit = OutboxCodec.readIdempotencyKey(payload);
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    final normalized = Map<String, dynamic>.from(payload)
      ..remove(OutboxCodec.idempotencyKeyField);
    final digest = fastHash(jsonEncode(normalized)).toString();
    return 'sales_edit_$digest';
  }

  String _normalizeRecipientType(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  String _resolveInventoryActorUid({
    String? explicitActorUid,
    String? fallbackSalesmanUid,
  }) {
    final actorUid = explicitActorUid?.trim();
    if (actorUid != null && actorUid.isNotEmpty) {
      return actorUid;
    }
    final authUid = auth?.currentUser?.uid;
    final normalizedAuthUid = authUid?.trim();
    if (normalizedAuthUid != null && normalizedAuthUid.isNotEmpty) {
      return normalizedAuthUid;
    }
    final salesmanUid = fallbackSalesmanUid?.trim();
    if (salesmanUid != null && salesmanUid.isNotEmpty) {
      return salesmanUid;
    }
    return 'system';
  }

  String? _resolveInventoryActorLegacyId(String? explicitLegacyId) {
    final trimmed = explicitLegacyId?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
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

  List<InventoryCommandItem> _commandItemsFromSaleEntities(
    List<SaleItemEntity> items,
  ) {
    return items
        .map(
          (item) => InventoryCommandItem(
            productId: item.productId?.trim() ?? '',
            quantityBase: (item.finalBaseQuantity ?? item.quantity ?? 0)
                .toDouble(),
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
      final user =
          await _findLocalSalesmanUser(ownerUid) ??
          await _dbService.users.getById(ownerUid);
      final userName = (user?.name ?? '').trim();
      final entity = InventoryLocationEntity()
        ..id = normalized
        ..type = InventoryLocationEntity.salesmanVanType
        ..name = userName.isNotEmpty ? '$userName Van' : 'Salesman Van'
        ..code =
            'SALESMAN_VAN_${_sanitizeDeterministicToken(ownerUid).toUpperCase()}'
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
      final balanceId = '${locationId}_${item.productId}';
      final balance = await _dbService.stockBalances.getById(balanceId);
      var available = balance?.quantity ?? 0.0;
      if (balance == null &&
          locationId == InventoryProjectionService.warehouseMainLocationId) {
        final product = await _dbService.products.getById(item.productId);
        available = product?.stock ?? 0.0;
      } else if (balance == null && locationId.startsWith('salesman_van_')) {
        final ownerUid = locationId.substring('salesman_van_'.length);
        final user =
            await _findLocalSalesmanUser(ownerUid) ??
            await _dbService.users.getById(ownerUid);
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
        final user =
            await _findLocalSalesmanUser(ownerUid) ??
            await _dbService.users.getById(ownerUid);
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
    final normalizedRecipientType = _normalizeRecipientType(recipientType);
    if (normalizedRecipientType == 'customer' &&
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
    DateTime? createdAt,
    String? editCommandKey,
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
    DateTime? createdAt,
    String? editCommandKey,
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

  Future<_SaleInventoryCommandContext?> _loadLatestSaleCommandContext(
    String saleId,
  ) async {
    final normalizedSaleId = saleId.trim();
    if (normalizedSaleId.isEmpty) {
      return null;
    }

    final allCommands = await _dbService.inventoryCommands.where().findAll();
    _SaleInventoryCommandContext? latest;
    for (final command in allCommands) {
      final commandId = command.commandId;
      if (commandId != 'sale:$normalizedSaleId' &&
          !commandId.startsWith('sale:$normalizedSaleId:edit:')) {
        continue;
      }
      final sequence = _parseSaleEditSequence(commandId, normalizedSaleId);
      final payload = _decodeInventoryCommandPayload(command);
      final sourceLocationId = payload['sourceLocationId']?.toString().trim();
      if (sourceLocationId == null || sourceLocationId.isEmpty) {
        continue;
      }
      final candidate = _SaleInventoryCommandContext(
        commandId: commandId,
        sourceLocationId: sourceLocationId,
        sequence: sequence,
        createdAt: command.createdAt,
        editCommandKey: _extractEditCommandKey(command, payload),
      );
      if (latest == null ||
          candidate.sequence > latest.sequence ||
          (candidate.sequence == latest.sequence &&
              command.createdAt.isAfter(latest.createdAt))) {
        latest = candidate;
      }
    }
    return latest;
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

  Future<String> _resolveSaleEditCommandId({
    required String saleId,
    required String commandKey,
  }) async {
    final normalizedSaleId = saleId.trim();
    final normalizedCommandKey = commandKey.trim();
    final allCommands = await _dbService.inventoryCommands.where().findAll();
    var maxSequence = 0;
    for (final command in allCommands) {
      final sequence = _parseSaleEditSequence(
        command.commandId,
        normalizedSaleId,
      );
      if (sequence < 1) {
        continue;
      }
      if (sequence > maxSequence) {
        maxSequence = sequence;
      }
      final payload = _decodeInventoryCommandPayload(command);
      final existingKey = _extractEditCommandKey(command, payload);
      if (existingKey == normalizedCommandKey) {
        return '$normalizedSaleId:edit:$sequence';
      }
    }
    return '$normalizedSaleId:edit:${maxSequence + 1}';
  }

  Future<void> _applySaleCompleteInTxn({
    required String saleIdToken,
    required String recipientType,
    required String salesmanUid,
    required List<InventoryCommandItem> items,
    required String actorUid,
    String? actorLegacyAppUserId,
    DateTime? occurredAt,
    String? editCommandKey,
  }) async {
    if (items.isEmpty) {
      return;
    }
    final sourceLocationId = await _resolveSaleSourceLocationInTxn(
      recipientType: recipientType,
      salesmanUid: salesmanUid,
      items: items,
    );
    await _seedSourceBalancesInTxn(
      sourceLocationId: sourceLocationId,
      items: items,
      occurredAt: occurredAt ?? DateTime.now(),
    );
    final command = _buildSaleCompleteCommand(
      saleIdToken: saleIdToken,
      sourceLocationId: sourceLocationId,
      items: items,
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: occurredAt,
      editCommandKey: editCommandKey,
    );
    await _ensureCommandLocationsInTxn(command);
    await _inventoryMovementEngine.applyCommandInTxn(command);
  }

  Future<void> _applySaleEditInventoryInTxn({
    required String saleId,
    required String previousRecipientType,
    required String nextRecipientType,
    required String salesmanUid,
    required List<InventoryCommandItem> previousItems,
    required List<InventoryCommandItem> nextItems,
    required String actorUid,
    String? actorLegacyAppUserId,
    required String commandKey,
    DateTime? occurredAt,
  }) async {
    final previousCommand = await _loadLatestSaleCommandContext(saleId);
    if (previousCommand != null && previousItems.isNotEmpty) {
      final reversalCommand = _buildSaleReversalCommand(
        originalCommandId: previousCommand.commandId,
        restoreLocationId: previousCommand.sourceLocationId,
        items: previousItems,
        actorUid: actorUid,
        actorLegacyAppUserId: actorLegacyAppUserId,
        createdAt: occurredAt,
        editCommandKey: commandKey,
      );
      await _ensureCommandLocationsInTxn(reversalCommand);
      await _inventoryMovementEngine.applyCommandInTxn(reversalCommand);
    } else if (previousItems.isNotEmpty) {
      final fallbackSourceLocationId = await _resolveSaleSourceLocationInTxn(
        recipientType: previousRecipientType,
        salesmanUid: salesmanUid,
        items: previousItems,
      );
      final reversalCommand = _buildSaleReversalCommand(
        originalCommandId: 'sale:$saleId',
        restoreLocationId: fallbackSourceLocationId,
        items: previousItems,
        actorUid: actorUid,
        actorLegacyAppUserId: actorLegacyAppUserId,
        createdAt: occurredAt,
        editCommandKey: commandKey,
      );
      await _ensureCommandLocationsInTxn(reversalCommand);
      await _inventoryMovementEngine.applyCommandInTxn(reversalCommand);
    }

    final nextSaleIdToken = await _resolveSaleEditCommandId(
      saleId: saleId,
      commandKey: commandKey,
    );
    await _applySaleCompleteInTxn(
      saleIdToken: nextSaleIdToken,
      recipientType: nextRecipientType,
      salesmanUid: salesmanUid,
      items: nextItems,
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      occurredAt: occurredAt,
      editCommandKey: commandKey,
    );
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

    final normalizedRecipientType = _normalizeRecipientType(recipientType);
    final effectiveActorUid = _resolveInventoryActorUid(
      explicitActorUid: actorUid,
      fallbackSalesmanUid: salesmanUid,
    );
    final effectiveLegacyId = _resolveInventoryActorLegacyId(
      actorLegacyAppUserId,
    );

    if (normalizedRecipientType == 'salesman') {
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
      await _dbService.db.writeTxn(() async {
        await _ensureCommandLocationsInTxn(command);
        await _inventoryMovementEngine.applyCommandInTxn(command);
      });
      return;
    }

    await _dbService.db.writeTxn(() async {
      await _applySaleCompleteInTxn(
        saleIdToken: saleId,
        recipientType: recipientType,
        salesmanUid: salesmanUid,
        items: commandItems,
        actorUid: effectiveActorUid,
        actorLegacyAppUserId: effectiveLegacyId,
      );
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
    final effectiveActorUid = _resolveInventoryActorUid(
      explicitActorUid: actorUid,
      fallbackSalesmanUid: salesmanUid,
    );
    final effectiveLegacyId = _resolveInventoryActorLegacyId(
      actorLegacyAppUserId,
    );
    await _dbService.db.writeTxn(() async {
      await _applySaleEditInventoryInTxn(
        saleId: saleId,
        previousRecipientType: previousRecipientType,
        nextRecipientType: nextRecipientType,
        salesmanUid: salesmanUid,
        previousItems: _commandItemsFromMaps(previousItems),
        nextItems: _commandItemsFromMaps(nextItems),
        actorUid: effectiveActorUid,
        actorLegacyAppUserId: effectiveLegacyId,
        commandKey: commandKey,
      );
    });
  }

  List<SaleItemEntity> _toSaleItemEntities(List<_LineTotals> lines) {
    return lines
        .map(
          (line) => SaleItemEntity()
            ..productId = line.item.productId
            ..name = line.item.name
            ..quantity = line.item.quantity
            ..price = line.item.price
            ..isFree = line.item.isFree
            ..discount = line.item.discount
            ..secondaryPrice = line.item.secondaryPrice
            ..conversionFactor = line.item.conversionFactor
            ..baseUnit = line.item.baseUnit
            ..secondaryUnit = line.item.secondaryUnit
            ..schemeName = line.item.schemeName
            ..returnedQuantity = line.item.returnedQuantity
            ..lineSubtotal = line.subtotal
            ..lineItemDiscountAmount = line.itemDiscount
            ..linePrimaryDiscountShare = line.primaryDiscountShare
            ..lineAdditionalDiscountShare = line.additionalDiscountShare
            ..lineNetAmount = line.net
            ..lineTaxAmount = line.tax
            ..lineTotalAmount = line.total,
        )
        .toList(growable: false);
  }

  /// Delegates to [SaleCalculationEngine] and maps engine result types
  /// back to the internal [_SaleCalculationResult] / [_LineTotals].
  _SaleCalculationResult _calculateSale({
    required List<SaleItemForUI> items,
    required double discountPercentage,
    required double additionalDiscountPercentage,
    required double gstPercentage,
    required String gstType,
  }) {
    final engineResult = _engine.calculateSale(
      items: items,
      discountPercentage: discountPercentage,
      additionalDiscountPercentage: additionalDiscountPercentage,
      gstPercentage: gstPercentage,
      gstType: gstType,
    );

    // Map engine LineTotals → internal _LineTotals
    final lines = engineResult.lines
        .map(
          (l) => _LineTotals(
            item: l.item,
            subtotal: l.subtotal,
            itemDiscount: l.itemDiscount,
            primaryDiscountShare: l.primaryDiscountShare,
            additionalDiscountShare: l.additionalDiscountShare,
            net: l.net,
            tax: l.tax,
            total: l.total,
          ),
        )
        .toList();

    return _SaleCalculationResult(
      lines: lines,
      subtotal: engineResult.subtotal,
      itemDiscountTotal: engineResult.itemDiscountTotal,
      discountAmount: engineResult.discountAmount,
      additionalDiscountAmount: engineResult.additionalDiscountAmount,
      taxableAmount: engineResult.taxableAmount,
      totalGstAmount: engineResult.totalGstAmount,
      cgstAmount: engineResult.cgstAmount,
      sgstAmount: engineResult.sgstAmount,
      igstAmount: engineResult.igstAmount,
      totalAmount: engineResult.totalAmount,
    );
  }

  SaleEntity _buildSaleEntityFromMap(
    Map<String, dynamic> data, {
    required SyncStatus syncStatus,
  }) {
    final createdAt =
        data['createdAt']?.toString() ?? DateTime.now().toIso8601String();
    final updatedAt =
        DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
        DateTime.tryParse(createdAt) ??
        DateTime.now();

    final itemsRaw = (data['items'] as List?) ?? [];
    final items = itemsRaw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(
          (item) => SaleItemEntity()
            ..productId = item['productId']?.toString()
            ..name = item['name']?.toString()
            ..quantity = (item['quantity'] as num?)?.toInt()
            ..price = _toDouble(item['price'])
            ..isFree = item['isFree'] == true
            ..discount = _toDouble(item['discount'])
            ..secondaryPrice = _toDouble(item['secondaryPrice'])
            ..conversionFactor = _toDouble(item['conversionFactor'])
            ..baseUnit = item['baseUnit']?.toString()
            ..secondaryUnit = item['secondaryUnit']?.toString()
            ..schemeName = item['schemeName']?.toString()
            ..returnedQuantity = (item['returnedQuantity'] as num?)?.toInt()
            ..lineSubtotal = _toDouble(item['lineSubtotal'])
            ..lineItemDiscountAmount = _toDouble(item['lineItemDiscountAmount'])
            ..linePrimaryDiscountShare = _toDouble(
              item['linePrimaryDiscountShare'],
            )
            ..lineAdditionalDiscountShare = _toDouble(
              item['lineAdditionalDiscountShare'],
            )
            ..lineNetAmount = _toDouble(item['lineNetAmount'])
            ..lineTaxAmount = _toDouble(item['lineTaxAmount'])
            ..lineTotalAmount = _toDouble(item['lineTotalAmount']),
        )
        .toList();

    final itemProductIds =
        (data['itemProductIds'] as List?)?.map((e) => e.toString()).toList() ??
        items
            .where((e) => (e.productId ?? '').isNotEmpty)
            .map((e) => e.productId!)
            .toList();

    final entity = SaleEntity()
      ..id = data['id']?.toString() ?? generateId()
      ..updatedAt = updatedAt
      ..humanReadableId = data['humanReadableId']?.toString()
      ..recipientType = data['recipientType']?.toString() ?? 'customer'
      ..recipientId = data['recipientId']?.toString() ?? ''
      ..recipientName = data['recipientName']?.toString() ?? ''
      ..items = items
      ..itemProductIds = itemProductIds.isEmpty ? null : itemProductIds
      ..subtotal = _toDouble(data['subtotal'])
      ..itemDiscountAmount = _toDouble(data['itemDiscountAmount'])
      ..discountPercentage = _toDouble(data['discountPercentage'])
      ..discountAmount = _toDouble(data['discountAmount'])
      ..additionalDiscountPercentage = _toDouble(
        data['additionalDiscountPercentage'],
      )
      ..additionalDiscountAmount = _toDouble(data['additionalDiscountAmount'])
      ..taxableAmount = _toDouble(data['taxableAmount'])
      ..gstType = data['gstType']?.toString()
      ..gstPercentage = _toDouble(data['gstPercentage'])
      ..cgstAmount = _toDouble(data['cgstAmount'])
      ..sgstAmount = _toDouble(data['sgstAmount'])
      ..igstAmount = _toDouble(data['igstAmount'])
      ..totalAmount = _toDouble(data['totalAmount'])
      ..roundOff = _toDouble(data['roundOff'])
      ..tripId = data['tripId']?.toString()
      ..saleType = data['saleType']?.toString()
      ..createdByRole = data['createdByRole']?.toString()
      ..status = data['status']?.toString()
      ..dispatchRequired = data['dispatchRequired'] == true
      ..vehicleNumber = data['vehicleNumber']?.toString()
      ..route = data['route']?.toString()
      ..salesmanId = data['salesmanId']?.toString() ?? ''
      ..salesmanName = data['salesmanName']?.toString() ?? ''
      ..createdAt = createdAt
      ..paidAmount = _toDouble(data['paidAmount'])
      ..paymentStatus = data['paymentStatus']?.toString()
      ..month = (data['month'] as num?)?.toInt()
      ..year = (data['year'] as num?)?.toInt()
      ..cancelReason = data['cancelReason']?.toString()
      ..cancelledBy = data['cancelledBy']?.toString()
      ..cancelledAt = data['cancelledAt']?.toString()
      ..commissionAmount = _toDouble(data['commissionAmount'])
      ..commissionType = data['commissionType']?.toString()
      ..syncStatus = syncStatus;

    if (entity.month == null || entity.year == null) {
      final parsed = DateTime.tryParse(createdAt) ?? DateTime.now();
      entity.month ??= parsed.month;
      entity.year ??= parsed.year;
    }

    return entity;
  }

  Future<String> _enqueueSaleForSync(
    Map<String, dynamic> saleData, {
    String action = 'add',
  }) async {
    final saleId = saleData['id']?.toString();
    if (saleId == null || saleId.isEmpty) return '';

    final queueId = 'sales_$saleId';
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingEnvelope = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          );
    final existingMeta = existingEnvelope?.meta;
    final preservedAction = (existing?.action.trim().isNotEmpty ?? false)
        ? existing!.action
        : action;
    final payloadForQueue = OutboxCodec.ensureCommandPayload(
      collection: salesCollection,
      action: preservedAction,
      payload: saleData,
      existingMeta: existingMeta,
      queueId: queueId,
    );

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = salesCollection
      ..action = preservedAction
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payloadForQueue,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: existing == null,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = existing?.syncStatus ?? SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(entity);
    });
    return queueId;
  }

  Future<bool> _queueAndSyncSale(
    Map<String, dynamic> saleData, {
    String action = 'add',
  }) async {
    final queueId = await _enqueueSaleForSync(saleData, action: action);
    if (_centralQueueSync == null) return false;
    try {
      await _centralQueueSync!.call();
      final remaining = await _dbService.syncQueue.getById(queueId);
      return remaining == null;
    } catch (_) {
      return false;
    }
  }

  /// Pre-sale stock validation (Audit Recommendation #2A)
  ///
  /// Validates allocated stock for a salesman BEFORE creating a sale.
  /// Prevents sales from getting stuck in the sync queue due to insufficient stock.
  ///
  /// Throws [Exception] with a user-friendly message if stock is insufficient.
  Future<void> validateStockBeforeSale({
    required String salesmanId,
    required List<Map<String, dynamic>> items,
  }) async {
    final localUser = await _findLocalSalesmanUser(salesmanId);

    if (localUser == null) {
      return; // Cannot validate offline; allow optimistically
    }

    Map<String, dynamic> allocatedStock = {};
    try {
      if (localUser.allocatedStockJson != null &&
          localUser.allocatedStockJson!.isNotEmpty) {
        final decoded = localUser.allocatedStockJson!;
        final parsed = (jsonDecode(decoded) as Map?)?.cast<String, dynamic>();
        allocatedStock = parsed ?? {};
      }
    } catch (_) {
      return; // Cannot parse; allow optimistically
    }

    final shortfalls = <String>[];
    for (final item in items) {
      final productId = item['productId']?.toString() ?? '';
      final isFree = item['isFree'] == true;
      final requiredQty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
      final productName = item['name']?.toString() ?? productId;

      if (productId.isEmpty || requiredQty <= 0) continue;

      final stockEntry = allocatedStock[productId];
      if (stockEntry == null) {
        shortfalls.add(
          '• $productName: not allocated (Required: ${requiredQty.toStringAsFixed(0)})',
        );
        continue;
      }

      final entry = stockEntry is Map
          ? Map<String, dynamic>.from(stockEntry)
          : <String, dynamic>{};
      final available = isFree
          ? (entry['freeQuantity'] as num? ?? 0).toDouble()
          : (entry['quantity'] as num? ?? 0).toDouble();

      if (available < requiredQty) {
        shortfalls.add(
          '• $productName: Available ${available.toStringAsFixed(0)}, '
          'Required ${requiredQty.toStringAsFixed(0)}',
        );
      }
    }

    if (shortfalls.isNotEmpty) {
      throw Exception(
        'Insufficient allocated stock:\n${shortfalls.join('\n')}\n\n'
        'Please request dispatch from admin before creating this sale.',
      );
    }
  }

  Future<void> _migrateLegacySalesIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_legacyMigrationFlag) ?? false;
    if (migrated) return;

    final jsonStr = prefs.getString(localStorageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    List<dynamic> legacyList;
    try {
      legacyList = jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return;
    }

    if (legacyList.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    final existingSales = await _fetchAllSalesPaged();
    final existingIds = existingSales.map((e) => e.id).toSet();

    final existingQueueItems = await _dbService.syncQueue
        .filter()
        .collectionEqualTo(salesCollection)
        .findAll();
    final queuedIds = <String>{};
    for (final item in existingQueueItems) {
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      final id = decoded.payload['id']?.toString();
      if (id != null && id.isNotEmpty) queuedIds.add(id);
    }

    await _dbService.db.writeTxn(() async {
      for (final entry in legacyList) {
        if (entry is! Map) continue;
        final data = Map<String, dynamic>.from(entry);
        final id = data['id']?.toString();
        if (id == null || id.isEmpty) continue;
        if (existingIds.contains(id)) continue;

        final isSynced = data['isSynced'] == true;
        final status = data['status']?.toString();
        final needsSync = !isSynced || status == 'pending_sync';

        final entity = _buildSaleEntityFromMap(
          data,
          syncStatus: needsSync ? SyncStatus.pending : SyncStatus.synced,
        );
        await _dbService.sales.put(entity);
        existingIds.add(id);

        if (needsSync && !queuedIds.contains(id)) {
          final queueEntity = SyncQueueEntity()
            ..id = 'sales_$id'
            ..collection = salesCollection
            ..action = 'add'
            ..dataJson = OutboxCodec.encodeEnvelope(
              payload: data,
              now: DateTime.now(),
              resetRetryState: true,
            )
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now()
            ..syncStatus = SyncStatus.pending;
          await _dbService.syncQueue.put(queueEntity);
          queuedIds.add(id);
        }
      }
    });

    await prefs.remove(localStorageKey);
    await prefs.setBool(_legacyMigrationFlag, true);
  }

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    AppLogger.debug(
      'SalesService.performSync STARTED for action=$action',
      tag: 'Sync_Trace',
    );
    if (collection == salesCollection &&
        (action == 'add' || action == 'edit')) {
      await _requireSalesMutationActor('sync sales mutation [$action]');
    }
    final firestore = db;
    if (firestore == null) {
      AppLogger.debug(
        'SalesService.performSync ABORT - db is null',
        tag: 'Sync_Trace',
      );
      return;
    }

    // Custom Transaction Logic for Sales
    if (action == 'add' && collection == salesCollection) {
      final recipientType = data['recipientType'];
      final seriesType = recipientType == 'customer' ? 'Sale' : 'Dispatch';

      final salesmanId = data['salesmanId']?.toString();
      if (salesmanId == null || salesmanId.isEmpty) {
        AppLogger.error(
          'SalesService.performSync ABORT - salesmanId is null or empty',
          tag: 'Sync',
        );
        throw Exception('Salesman ID is missing in sync payload');
      }

      final saleId = data['id']?.toString();
      if (saleId == null || saleId.isEmpty) {
        AppLogger.error(
          'SalesService.performSync ABORT - saleId is null or empty',
          tag: 'Sync',
        );
        throw Exception('Sale ID is missing in sync payload');
      }

      final itemsRaw = data['items'];
      if (itemsRaw is! List) {
        AppLogger.error(
          'SalesService.performSync ABORT - items is not a list',
          tag: 'Sync',
        );
        throw Exception('Items is missing or invalid in sync payload');
      }
      final items = itemsRaw.cast<Map<String, dynamic>>();

      AppLogger.debug('performSync Tx: START', tag: 'Sync');
      try {
        final isWindows = Platform.isWindows;
        if (isWindows) {
          await _performSalesAddSyncWindows(
            firestore: firestore,
            data: data,
            recipientType: recipientType,
            seriesType: seriesType,
            salesmanId: salesmanId,
            saleId: saleId,
            items: items,
          );
          return;
        }
        await firestore.runTransaction((transaction) async {
          // 1. Salesman Data (User)
          final salesmanRef = firestore.collection('users').doc(salesmanId);
          final salesmanSnap = await transaction.get(salesmanRef);
          if (!salesmanSnap.exists) {
            throw Exception('User (Salesman/Creator) not found.');
          }
          final salesmanData = salesmanSnap.data() ?? const <String, dynamic>{};
          final salesmanRole = (salesmanData['role'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
          final isAdminRole =
              salesmanRole == 'admin' || salesmanRole == 'owner';
          final canWriteTransactionSeries = isAdminRole;

          // 2. Transaction Series (admin-only by rules)
          final seriesRef = firestore
              .collection('transaction_series')
              .doc(seriesType);
          Map<String, dynamic>? seriesData;
          if (canWriteTransactionSeries) {
            final seriesSnap = await transaction.get(seriesRef);
            if (seriesSnap.exists) {
              seriesData = seriesSnap.data();
            }
          } else {
            AppLogger.debug(
              'performSync Tx: skipping transaction_series update for role=$salesmanRole',
              tag: 'Sync',
            );
          }

          // 3. Create Sale Document (idempotent on saleId)
          final saleRef = firestore.collection(salesCollection).doc(saleId);
          final existingSaleSnap = await transaction.get(saleRef);
          if (existingSaleSnap.exists) {
            AppLogger.debug(
              'performSync Tx: ABORT due to idempotency',
              tag: 'Sync',
            );
            return;
          }

          final validatedItems = <Map<String, dynamic>>[];
          for (final rawItem in items) {
            final item = Map<String, dynamic>.from(rawItem);
            final productId = item['productId']?.toString().trim() ?? '';
            if (productId.isEmpty) {
              throw Exception('Sale item payload missing productId');
            }

            final productRef = firestore.collection('products').doc(productId);
            final productSnap = await transaction.get(productRef);
            if (!productSnap.exists) {
              throw Exception('Product $productId not found');
            }

            final productData = productSnap.data() ?? const <String, dynamic>{};
            final payloadPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
            final authoritativePrice =
                (productData['price'] as num?)?.toDouble() ?? 0.0;
            final isFreeItem = item['isFree'] == true;
            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
            if (quantity <= 0) {
              throw Exception('Invalid quantity for $productId');
            }

            if (!isFreeItem && authoritativePrice > 0) {
              if ((payloadPrice - authoritativePrice).abs() > 0.009) {
                throw Exception(
                  'Price mismatch for $productId. Expected: $authoritativePrice, Received: $payloadPrice',
                );
              }
            }
            item['price'] = authoritativePrice;

            if (item['secondaryPrice'] != null &&
                productData['secondaryPrice'] != null) {
              final payloadSecondary =
                  (item['secondaryPrice'] as num?)?.toDouble() ?? 0.0;
              final authoritativeSecondary =
                  (productData['secondaryPrice'] as num?)?.toDouble() ?? 0.0;
              if ((payloadSecondary - authoritativeSecondary).abs() > 0.009) {
                throw Exception(
                  'Secondary price mismatch for $productId. Expected: $authoritativeSecondary, Received: $payloadSecondary',
                );
              }
            }
            if (productData['secondaryPrice'] != null) {
              item['secondaryPrice'] = (productData['secondaryPrice'] as num?)
                  ?.toDouble();
            }
            if (productData['conversionFactor'] != null) {
              item['conversionFactor'] =
                  (productData['conversionFactor'] as num?)?.toDouble();
            }
            if (productData['baseUnit'] != null) {
              item['baseUnit'] = productData['baseUnit'];
            }
            if (productData.containsKey('secondaryUnit')) {
              item['secondaryUnit'] = productData['secondaryUnit'];
            }
            if (productData['name'] != null &&
                productData['name'].toString().trim().isNotEmpty) {
              item['name'] = productData['name'];
            }
            item['discount'] = ((item['discount'] as num?)?.toDouble() ?? 0.0)
                .clamp(0.0, 100.0);

            validatedItems.add(item);
          }
          if (validatedItems.isEmpty) {
            throw Exception(
              'Sale payload must contain at least one valid item',
            );
          }

          final primaryDiscountPct =
              ((data['discountPercentage'] as num?)?.toDouble() ?? 0.0).clamp(
                0.0,
                100.0,
              );
          final additionalDiscountPct =
              ((data['additionalDiscountPercentage'] as num?)?.toDouble() ??
                      0.0)
                  .clamp(0.0, 100.0);
          final normalizedGstType = _normalizeGstType(
            data['gstType']?.toString() ?? 'None',
          );
          final gstPercentage = normalizedGstType == 'None'
              ? 0.0
              : ((data['gstPercentage'] as num?)?.toDouble() ?? 0.0).clamp(
                  0.0,
                  100.0,
                );
          final calcItems = validatedItems
              .map(
                (item) => SaleItemForUI(
                  productId: item['productId']?.toString() ?? '',
                  name: item['name']?.toString() ?? '',
                  quantity: (item['quantity'] as num?)?.toInt() ?? 0,
                  price: (item['price'] as num?)?.toDouble() ?? 0.0,
                  isFree: item['isFree'] == true,
                  discount: (item['discount'] as num?)?.toDouble() ?? 0.0,
                  secondaryPrice: (item['secondaryPrice'] as num?)?.toDouble(),
                  conversionFactor: (item['conversionFactor'] as num?)
                      ?.toDouble(),
                  baseUnit: item['baseUnit']?.toString() ?? '',
                  secondaryUnit: item['secondaryUnit']?.toString(),
                  stock: 0,
                ),
              )
              .toList(growable: false);
          final calc = _calculateSale(
            items: calcItems,
            discountPercentage: primaryDiscountPct,
            additionalDiscountPercentage: additionalDiscountPct,
            gstPercentage: gstPercentage,
            gstType: normalizedGstType,
          );
          final authoritativeItems = calc.lines
              .asMap()
              .entries
              .map((entry) {
                final line = entry.value;
                final original = validatedItems[entry.key];
                return {
                  ...line.toPersistedMap(),
                  'movementId': _resolveSaleMovementId(
                    saleId: saleId,
                    item: original,
                    itemIndex: entry.key,
                  ),
                };
              })
              .toList(growable: false);

          final salePayload = Map<String, dynamic>.from(data);
          salePayload.remove('isSynced');
          salePayload['status'] = salePayload['status'] == 'pending_sync'
              ? 'completed'
              : salePayload['status'];
          salePayload['items'] = authoritativeItems;
          salePayload['itemProductIds'] = authoritativeItems
              .map((item) => item['productId']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toList(growable: false);
          salePayload['discountPercentage'] = primaryDiscountPct;
          salePayload['additionalDiscountPercentage'] = additionalDiscountPct;
          salePayload['gstType'] = normalizedGstType;
          salePayload['gstPercentage'] = gstPercentage;
          salePayload['subtotal'] = calc.subtotal;
          salePayload['itemDiscountAmount'] = calc.itemDiscountTotal;
          salePayload['discountAmount'] = calc.discountAmount;
          salePayload['additionalDiscountAmount'] =
              calc.additionalDiscountAmount;
          salePayload['taxableAmount'] = calc.taxableAmount;
          salePayload.remove('cgstAmount');
          salePayload.remove('sgstAmount');
          salePayload.remove('igstAmount');
          if (calc.cgstAmount > 0) salePayload['cgstAmount'] = calc.cgstAmount;
          if (calc.sgstAmount > 0) salePayload['sgstAmount'] = calc.sgstAmount;
          if (calc.igstAmount > 0) salePayload['igstAmount'] = calc.igstAmount;
          salePayload['totalAmount'] = calc.totalAmount;
          salePayload['roundOff'] = _round2(
            calc.totalAmount - (calc.taxableAmount + calc.totalGstAmount),
          );

          DocumentReference? customerRef;
          if (recipientType == 'customer') {
            final recipientId =
                salePayload['recipientId']?.toString().trim() ?? '';
            if (recipientId.isEmpty) {
              throw Exception(
                'Customer recipient ID is missing in sync payload',
              );
            }
            customerRef = firestore.collection('customers').doc(recipientId);
            final customerSnap = await transaction.get(customerRef);
            if (!customerSnap.exists) {
              throw Exception('Customer $recipientId not found');
            }
          }

          if (seriesData != null) {
            final sData = seriesData;
            final current = sData['current'] ?? 0;
            final next = current + 1;
            transaction.update(seriesRef, {'current': next});
            salePayload['humanReadableId'] =
                '${sData['prefix'] ?? "INV"}-$next';
          }

          transaction.set(saleRef, salePayload);

          await _ensureSaleInventoryAppliedIfNeeded(
            saleId: saleId,
            recipientType: recipientType.toString(),
            salesmanUid: salesmanId,
            items: authoritativeItems,
            recipientSalesmanUid: data['recipientId']?.toString(),
            actorUid: salesmanId,
            actorLegacyAppUserId: data['editedBy']?.toString(),
          );

          // 4. Stock operations
          // T9-P2 REMOVED: direct Firestore stock writes replaced by
          // InventoryMovementEngine sale_complete / dispatch_create.
          // if (recipientType == 'customer') {
          //   final allocated =
          //       salesmanData['allocatedStock'] as Map<String, dynamic>? ?? {};
          //   for (var item in validatedItems) {
          //     final pId = item['productId'];
          //     final qty = (item['quantity'] as num).toDouble();
          //     final isFree = item['isFree'] == true;
          //     final stockItem = allocated[pId] as Map<String, dynamic>? ?? {};
          //     final available = isFree
          //         ? (stockItem['freeQuantity'] as num? ?? 0).toDouble()
          //         : (stockItem['quantity'] as num? ?? 0).toDouble();
          //     if (available < qty) {
          //       throw Exception(
          //         'Insufficient allocated stock for $pId. Available: $available, Required: $qty',
          //       );
          //     }
          //     final field = isFree
          //         ? 'allocatedStock.$pId.freeQuantity'
          //         : 'allocatedStock.$pId.quantity';
          //     transaction.update(salesmanRef, {
          //       field: FieldValue.increment(-qty),
          //     });
          //   }
          // } else if (recipientType == 'dealer' || recipientType == 'salesman') {
          //   DocumentReference? recipientRef;
          //   if (recipientType == 'salesman') {
          //     recipientRef = firestore.collection('users').doc(data['recipientId']);
          //     final recipientSnap = await transaction.get(recipientRef);
          //     if (!recipientSnap.exists) {
          //       throw Exception(
          //         'Recipient Salesman ${data['recipientId']} not found',
          //       );
          //     }
          //   }
          //   for (var item in validatedItems) {
          //     final pRef = firestore.collection('products').doc(item['productId']);
          //     final pSnap = await transaction.get(pRef);
          //     if (!pSnap.exists) {
          //       throw Exception('Product ${item['productId']} not found');
          //     }
          //     final pData = pSnap.data() as Map<String, dynamic>;
          //     final currentStock = (pData['stock'] as num? ?? 0).toDouble();
          //     final qty = (item['quantity'] as num).toDouble();
          //     if (currentStock < qty) {
          //       throw Exception(
          //         'Insufficient main stock for ${item['productId']}. Available: $currentStock',
          //       );
          //     }
          //     transaction.update(pRef, {'stock': FieldValue.increment(-qty)});
          //     if (recipientType == 'salesman' && recipientRef != null) {
          //       transaction.set(recipientRef, {
          //         'allocatedStock': {
          //           item['productId']: {
          //             'quantity': FieldValue.increment(qty),
          //             'name': pData['name'],
          //             'baseUnit': pData['baseUnit'],
          //             'secondaryUnit': pData['secondaryUnit'],
          //             'conversionFactor': pData['conversionFactor'],
          //             'price': pData['price'],
          //           },
          //         },
          //       }, SetOptions(merge: true));
          //     }
          //   }
          // }

          // 5. Stock movement logs (deterministic IDs)
          final movementSource = (data['saleType'] == 'DIRECT_DEALER')
              ? 'sale'
              : 'dispatch';
          for (var i = 0; i < authoritativeItems.length; i++) {
            final item = authoritativeItems[i];
            final movementId = _resolveSaleMovementId(
              saleId: saleId,
              item: item,
              itemIndex: i,
            );
            final movementRef = firestore
                .collection('stock_movements')
                .doc(movementId);
            transaction.set(movementRef, {
              'id': movementId,
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
            }, SetOptions(merge: true));
          }

          // 6. Customer balance adjustment
          if (recipientType == 'customer') {
            final totalAmt = calc.totalAmount;
            if (totalAmt > 0 && customerRef != null) {
              transaction.update(customerRef, {
                'balance': FieldValue.increment(totalAmt),
              });
            }
          }

          final auditRef = firestore.collection('audit_logs').doc();
          transaction.set(auditRef, {
            'collectionName': 'sales',
            'docId': data['id'],
            'action': 'create_sync',
            'userId': salesmanId,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      } catch (e) {
        AppLogger.error(
          'SalesService.performSync FAILED inside try-catch block for add',
          tag: 'Sync',
          error: e,
        );
        rethrow;
      }
      return;
    }

    if (action == 'edit' && collection == salesCollection) {
      final saleId = data['id']?.toString().trim();
      if (saleId == null || saleId.isEmpty) {
        throw Exception('Sale ID is required for edit sync');
      }

      final saleRef = firestore.collection(salesCollection).doc(saleId);
      final precheck = await saleRef.get();
      if (!precheck.exists) {
        final createPayload = _stripEditSyncMetadata(data);
        await performSync('add', salesCollection, createPayload);
        return;
      }
      final commandKey = _buildSaleEditCommandKey(data);
      final commandRef = firestore
          .collection('audit_logs')
          .doc(_buildCommandAuditDocId(commandKey));
      try {
        final isWindows = Platform.isWindows;
        if (isWindows) {
          await _performSalesEditSyncWindows(
            firestore: firestore,
            data: data,
            saleId: saleId,
            saleRef: saleRef,
            commandKey: commandKey,
            commandRef: commandRef,
          );
          return;
        }
        await firestore.runTransaction((transaction) async {
          final processedCommand = await transaction.get(commandRef);
          if (processedCommand.exists) {
            return;
          }

          final saleSnap = await transaction.get(saleRef);
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
              (data['recipientType'] ?? currentData['recipientType'] ?? '')
                  .toString();
          final recipientId =
              (data['recipientId'] ?? currentData['recipientId'] ?? '')
                  .toString();
          final previousRecipientType =
              (data['previousRecipientType'] ??
                      currentData['recipientType'] ??
                      '')
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
              (data['totalAmount'] as num? ??
                      currentData['totalAmount'] as num? ??
                      0)
                  .toDouble();
          final totalDelta =
              (data['totalDelta'] as num?)?.toDouble() ??
              _round2(newTotalAmount - oldTotalAmount);
          final salesmanId =
              (data['salesmanId'] ?? currentData['salesmanId'] ?? '')
                  .toString();

          final previousItems = (currentData['items'] is List)
              ? (currentData['items'] as List)
                    .whereType<Map>()
                    .map(
                      (item) => Map<String, dynamic>.from(
                        item.map(
                          (key, value) => MapEntry(key.toString(), value),
                        ),
                      ),
                    )
                    .toList(growable: false)
              : const <Map<String, dynamic>>[];
          final nextItems = (data['items'] is List)
              ? (data['items'] as List)
                    .whereType<Map>()
                    .map(
                      (item) => Map<String, dynamic>.from(
                        item.map(
                          (key, value) => MapEntry(key.toString(), value),
                        ),
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
            // T9-P2 REMOVED: direct Firestore allocatedStock edits replaced by
            // InventoryMovementEngine sale_reversal -> sale_complete.
            final normalizedRecipientId = recipientId.trim();
            final normalizedPreviousRecipientId = previousRecipientId.trim();
            final recipientChanged =
                normalizedPreviousRecipientId.isNotEmpty &&
                normalizedRecipientId.isNotEmpty &&
                normalizedPreviousRecipientId != normalizedRecipientId;

            if (recipientChanged &&
                previousRecipientType.trim().toLowerCase() == 'customer') {
              if (oldTotalAmount.abs() >= 1e-9) {
                final previousCustomerRef = firestore
                    .collection('customers')
                    .doc(normalizedPreviousRecipientId);
                transaction.update(previousCustomerRef, {
                  'balance': FieldValue.increment(-oldTotalAmount),
                });
              }
              if (newTotalAmount.abs() >= 1e-9) {
                final nextCustomerRef = firestore
                    .collection('customers')
                    .doc(normalizedRecipientId);
                transaction.update(nextCustomerRef, {
                  'balance': FieldValue.increment(newTotalAmount),
                });
              }
            } else if (normalizedRecipientId.isNotEmpty &&
                totalDelta.abs() >= 1e-9) {
              final customerRef = firestore
                  .collection('customers')
                  .doc(normalizedRecipientId);
              transaction.update(customerRef, {
                'balance': FieldValue.increment(totalDelta),
              });
            }
          } else if (recipientType == 'dealer' || recipientType == 'salesman') {
            // T9-P2 REMOVED: direct Firestore product stock edits replaced by
            // InventoryMovementEngine sale_reversal -> sale_complete.
          }

          final salePatch =
              _stripEditSyncMetadata(Map<String, dynamic>.from(data))
                ..remove('id')
                ..['updatedAt'] = DateTime.now().toIso8601String()
                ..['lastEditCommandKey'] = commandKey;
          transaction.set(saleRef, salePatch, SetOptions(merge: true));

          transaction.set(commandRef, {
            'collectionName': 'sales',
            'docId': saleId,
            'action': 'edit_sync_command',
            'commandKey': commandKey,
            'userId': data['editedBy'] ?? salesmanId,
            'timestamp': DateTime.now().toIso8601String(),
          });

          final auditRef = firestore.collection('audit_logs').doc();
          transaction.set(auditRef, {
            'collectionName': 'sales',
            'docId': saleId,
            'action': 'edit_sync',
            'commandKey': commandKey,
            'userId': data['editedBy'] ?? salesmanId,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      } catch (e) {
        AppLogger.error('Sales edit sync batch failed', error: e, tag: 'Sync');
        rethrow;
      }
      return;
    }

    // Default behavior
    await super.performSync(action, collection, data);
  }

  Future<void> _performSalesAddSyncWindows({
    required FirebaseFirestore firestore,
    required Map<String, dynamic> data,
    required String recipientType,
    required String seriesType,
    required String salesmanId,
    required String saleId,
    required List<Map<String, dynamic>> items,
  }) async {
    // Windows Desktop: use batch path to avoid runTransaction native crash.
    final batch = firestore.batch();

    // 1. Salesman Data (User)
    final salesmanRef = firestore.collection('users').doc(salesmanId);
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

    // 2. Transaction Series (admin-only by rules)
    final seriesRef = firestore
        .collection('transaction_series')
        .doc(seriesType);
    Map<String, dynamic>? seriesData;
    if (canWriteTransactionSeries) {
      final seriesSnap = await seriesRef.get();
      if (seriesSnap.exists) {
        seriesData = seriesSnap.data();
      }
    } else {
      AppLogger.debug(
        'performSync Tx: skipping transaction_series update for role=$salesmanRole',
        tag: 'Sync',
      );
    }

    // 3. Create Sale Document (idempotent on saleId)
    final saleRef = firestore.collection(salesCollection).doc(saleId);
    final existingSaleSnap = await saleRef.get();
    if (existingSaleSnap.exists) {
      AppLogger.debug('performSync Tx: ABORT due to idempotency', tag: 'Sync');
      return;
    }

    final validatedItems = <Map<String, dynamic>>[];
    for (final rawItem in items) {
      final item = Map<String, dynamic>.from(rawItem);
      final productId = item['productId']?.toString().trim() ?? '';
      if (productId.isEmpty) {
        throw Exception('Sale item payload missing productId');
      }

      final productRef = firestore.collection('products').doc(productId);
      final productSnap = await productRef.get();
      if (!productSnap.exists) {
        throw Exception('Product $productId not found');
      }

      final productData = productSnap.data() ?? const <String, dynamic>{};
      final payloadPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
      final authoritativePrice =
          (productData['price'] as num?)?.toDouble() ?? 0.0;
      final isFreeItem = item['isFree'] == true;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      if (quantity <= 0) {
        throw Exception('Invalid quantity for $productId');
      }

      if (!isFreeItem && authoritativePrice > 0) {
        if ((payloadPrice - authoritativePrice).abs() > 0.009) {
          throw Exception(
            'Price mismatch for $productId. Expected: $authoritativePrice, Received: $payloadPrice',
          );
        }
      }
      item['price'] = authoritativePrice;

      if (item['secondaryPrice'] != null &&
          productData['secondaryPrice'] != null) {
        final payloadSecondary =
            (item['secondaryPrice'] as num?)?.toDouble() ?? 0.0;
        final authoritativeSecondary =
            (productData['secondaryPrice'] as num?)?.toDouble() ?? 0.0;
        if ((payloadSecondary - authoritativeSecondary).abs() > 0.009) {
          throw Exception(
            'Secondary price mismatch for $productId. Expected: $authoritativeSecondary, Received: $payloadSecondary',
          );
        }
      }
      if (productData['secondaryPrice'] != null) {
        item['secondaryPrice'] = (productData['secondaryPrice'] as num?)
            ?.toDouble();
      }
      if (productData['conversionFactor'] != null) {
        item['conversionFactor'] = (productData['conversionFactor'] as num?)
            ?.toDouble();
      }
      if (productData['baseUnit'] != null) {
        item['baseUnit'] = productData['baseUnit'];
      }
      if (productData.containsKey('secondaryUnit')) {
        item['secondaryUnit'] = productData['secondaryUnit'];
      }
      if (productData['name'] != null &&
          productData['name'].toString().trim().isNotEmpty) {
        item['name'] = productData['name'];
      }
      item['discount'] = ((item['discount'] as num?)?.toDouble() ?? 0.0).clamp(
        0.0,
        100.0,
      );

      validatedItems.add(item);
    }
    if (validatedItems.isEmpty) {
      throw Exception('Sale payload must contain at least one valid item');
    }

    final primaryDiscountPct =
        ((data['discountPercentage'] as num?)?.toDouble() ?? 0.0).clamp(
          0.0,
          100.0,
        );
    final additionalDiscountPct =
        ((data['additionalDiscountPercentage'] as num?)?.toDouble() ?? 0.0)
            .clamp(0.0, 100.0);
    final normalizedGstType = _normalizeGstType(
      data['gstType']?.toString() ?? 'None',
    );
    final gstPercentage = normalizedGstType == 'None'
        ? 0.0
        : ((data['gstPercentage'] as num?)?.toDouble() ?? 0.0).clamp(
            0.0,
            100.0,
          );
    final calcItems = validatedItems
        .map(
          (item) => SaleItemForUI(
            productId: item['productId']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
            quantity: (item['quantity'] as num?)?.toInt() ?? 0,
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
            isFree: item['isFree'] == true,
            discount: (item['discount'] as num?)?.toDouble() ?? 0.0,
            secondaryPrice: (item['secondaryPrice'] as num?)?.toDouble(),
            conversionFactor: (item['conversionFactor'] as num?)?.toDouble(),
            baseUnit: item['baseUnit']?.toString() ?? '',
            secondaryUnit: item['secondaryUnit']?.toString(),
            stock: 0,
          ),
        )
        .toList(growable: false);
    final calc = _calculateSale(
      items: calcItems,
      discountPercentage: primaryDiscountPct,
      additionalDiscountPercentage: additionalDiscountPct,
      gstPercentage: gstPercentage,
      gstType: normalizedGstType,
    );
    final authoritativeItems = calc.lines
        .asMap()
        .entries
        .map((entry) {
          final line = entry.value;
          final original = validatedItems[entry.key];
          return {
            ...line.toPersistedMap(),
            'movementId': _resolveSaleMovementId(
              saleId: saleId,
              item: original,
              itemIndex: entry.key,
            ),
          };
        })
        .toList(growable: false);

    final salePayload = Map<String, dynamic>.from(data);
    salePayload.remove('isSynced');
    salePayload['status'] = salePayload['status'] == 'pending_sync'
        ? 'completed'
        : salePayload['status'];
    salePayload['items'] = authoritativeItems;
    salePayload['itemProductIds'] = authoritativeItems
        .map((item) => item['productId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    salePayload['discountPercentage'] = primaryDiscountPct;
    salePayload['additionalDiscountPercentage'] = additionalDiscountPct;
    salePayload['gstType'] = normalizedGstType;
    salePayload['gstPercentage'] = gstPercentage;
    salePayload['subtotal'] = calc.subtotal;
    salePayload['itemDiscountAmount'] = calc.itemDiscountTotal;
    salePayload['discountAmount'] = calc.discountAmount;
    salePayload['additionalDiscountAmount'] = calc.additionalDiscountAmount;
    salePayload['taxableAmount'] = calc.taxableAmount;
    salePayload.remove('cgstAmount');
    salePayload.remove('sgstAmount');
    salePayload.remove('igstAmount');
    if (calc.cgstAmount > 0) salePayload['cgstAmount'] = calc.cgstAmount;
    if (calc.sgstAmount > 0) salePayload['sgstAmount'] = calc.sgstAmount;
    if (calc.igstAmount > 0) salePayload['igstAmount'] = calc.igstAmount;
    salePayload['totalAmount'] = calc.totalAmount;
    salePayload['roundOff'] = _round2(
      calc.totalAmount - (calc.taxableAmount + calc.totalGstAmount),
    );

    DocumentReference? customerRef;
    if (recipientType == 'customer') {
      final recipientId = salePayload['recipientId']?.toString().trim() ?? '';
      if (recipientId.isEmpty) {
        throw Exception('Customer recipient ID is missing in sync payload');
      }
      customerRef = firestore.collection('customers').doc(recipientId);
      final customerSnap = await customerRef.get();
      if (!customerSnap.exists) {
        throw Exception('Customer $recipientId not found');
      }
    }

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
      items: authoritativeItems,
      recipientSalesmanUid: data['recipientId']?.toString(),
      actorUid: salesmanId,
      actorLegacyAppUserId: data['editedBy']?.toString(),
    );

    // 4. Stock operations
    // T9-P2 REMOVED: direct Firestore stock writes replaced by
    // InventoryMovementEngine sale_complete / dispatch_create.
    // if (recipientType == 'customer') {
    //   final allocated =
    //       salesmanData['allocatedStock'] as Map<String, dynamic>? ?? {};
    //   for (var item in validatedItems) {
    //     final pId = item['productId'];
    //     final qty = (item['quantity'] as num).toDouble();
    //     final isFree = item['isFree'] == true;
    //     final stockItem = allocated[pId] as Map<String, dynamic>? ?? {};
    //     final available = isFree
    //         ? (stockItem['freeQuantity'] as num? ?? 0).toDouble()
    //         : (stockItem['quantity'] as num? ?? 0).toDouble();
    //     if (available < qty) {
    //       throw Exception(
    //         'Insufficient allocated stock for $pId. Available: $available, Required: $qty',
    //       );
    //     }
    //     final field = isFree
    //         ? 'allocatedStock.$pId.freeQuantity'
    //         : 'allocatedStock.$pId.quantity';
    //     batch.update(salesmanRef, {field: FieldValue.increment(-qty)});
    //   }
    // } else if (recipientType == 'dealer' || recipientType == 'salesman') {
    //   DocumentReference? recipientRef;
    //   if (recipientType == 'salesman') {
    //     recipientRef = firestore.collection('users').doc(data['recipientId']);
    //     final recipientSnap = await recipientRef.get();
    //     if (!recipientSnap.exists) {
    //       throw Exception(
    //         'Recipient Salesman ${data['recipientId']} not found',
    //       );
    //     }
    //   }
    //   for (var item in validatedItems) {
    //     final pRef = firestore.collection('products').doc(item['productId']);
    //     final pSnap = await pRef.get();
    //     if (!pSnap.exists) {
    //       throw Exception('Product ${item['productId']} not found');
    //     }
    //     final pData = pSnap.data() as Map<String, dynamic>;
    //     final currentStock = (pData['stock'] as num? ?? 0).toDouble();
    //     final qty = (item['quantity'] as num).toDouble();
    //     if (currentStock < qty) {
    //       throw Exception(
    //         'Insufficient main stock for ${item['productId']}. Available: $currentStock',
    //       );
    //     }
    //     batch.update(pRef, {'stock': FieldValue.increment(-qty)});
    //     if (recipientType == 'salesman' && recipientRef != null) {
    //       batch.set(recipientRef, {
    //         'allocatedStock': {
    //           item['productId']: {
    //             'quantity': FieldValue.increment(qty),
    //             'name': pData['name'],
    //             'baseUnit': pData['baseUnit'],
    //             'secondaryUnit': pData['secondaryUnit'],
    //             'conversionFactor': pData['conversionFactor'],
    //             'price': pData['price'],
    //           },
    //         },
    //       }, SetOptions(merge: true));
    //     }
    //   }
    // }

    // 5. Stock movement logs (deterministic IDs)
    final movementSource = (data['saleType'] == 'DIRECT_DEALER')
        ? 'sale'
        : 'dispatch';
    for (var i = 0; i < authoritativeItems.length; i++) {
      final item = authoritativeItems[i];
      final movementId = _resolveSaleMovementId(
        saleId: saleId,
        item: item,
        itemIndex: i,
      );
      final movementRef = firestore
          .collection('stock_movements')
          .doc(movementId);
      batch.set(movementRef, {
        'id': movementId,
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
      }, SetOptions(merge: true));
    }

    // 6. Customer balance adjustment
    if (recipientType == 'customer') {
      final totalAmt = calc.totalAmount;
      if (totalAmt > 0 && customerRef != null) {
        batch.update(customerRef, {'balance': FieldValue.increment(totalAmt)});
      }
    }

    final auditRef = firestore.collection('audit_logs').doc();
    batch.set(auditRef, {
      'collectionName': 'sales',
      'docId': data['id'],
      'action': 'create_sync',
      'userId': salesmanId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  Future<void> _performSalesEditSyncWindows({
    required FirebaseFirestore firestore,
    required Map<String, dynamic> data,
    required String saleId,
    required DocumentReference<Map<String, dynamic>> saleRef,
    required String commandKey,
    required DocumentReference<Map<String, dynamic>> commandRef,
  }) async {
    final batch = firestore.batch();

    final processedCommand = await commandRef.get();
    if (processedCommand.exists) {
      return;
    }

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
        (data['recipientType'] ?? currentData['recipientType'] ?? '')
            .toString();
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
        _round2(newTotalAmount - oldTotalAmount);
    final salesmanId = (data['salesmanId'] ?? currentData['salesmanId'] ?? '')
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
      // T9-P2 REMOVED: direct Firestore allocatedStock edits replaced by
      // InventoryMovementEngine sale_reversal -> sale_complete.
      final normalizedRecipientId = recipientId.trim();
      final normalizedPreviousRecipientId = previousRecipientId.trim();
      final recipientChanged =
          normalizedPreviousRecipientId.isNotEmpty &&
          normalizedRecipientId.isNotEmpty &&
          normalizedPreviousRecipientId != normalizedRecipientId;

      if (recipientChanged &&
          previousRecipientType.trim().toLowerCase() == 'customer') {
        if (oldTotalAmount.abs() >= 1e-9) {
          final previousCustomerRef = firestore
              .collection('customers')
              .doc(normalizedPreviousRecipientId);
          batch.update(previousCustomerRef, {
            'balance': FieldValue.increment(-oldTotalAmount),
          });
        }
        if (newTotalAmount.abs() >= 1e-9) {
          final nextCustomerRef = firestore
              .collection('customers')
              .doc(normalizedRecipientId);
          batch.update(nextCustomerRef, {
            'balance': FieldValue.increment(newTotalAmount),
          });
        }
      } else if (normalizedRecipientId.isNotEmpty && totalDelta.abs() >= 1e-9) {
        final customerRef = firestore
            .collection('customers')
            .doc(normalizedRecipientId);
        batch.update(customerRef, {
          'balance': FieldValue.increment(totalDelta),
        });
      }
    } else if (recipientType == 'dealer' || recipientType == 'salesman') {
      // T9-P2 REMOVED: direct Firestore product stock edits replaced by
      // InventoryMovementEngine sale_reversal -> sale_complete.
    }

    final salePatch = _stripEditSyncMetadata(Map<String, dynamic>.from(data))
      ..remove('id')
      ..['updatedAt'] = DateTime.now().toIso8601String()
      ..['lastEditCommandKey'] = commandKey;
    batch.set(saleRef, salePatch, SetOptions(merge: true));

    batch.set(commandRef, {
      'collectionName': 'sales',
      'docId': saleId,
      'action': 'edit_sync_command',
      'commandKey': commandKey,
      'userId': data['editedBy'] ?? salesmanId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final auditRef = firestore.collection('audit_logs').doc();
    batch.set(auditRef, {
      'collectionName': 'sales',
      'docId': saleId,
      'action': 'edit_sync',
      'commandKey': commandKey,
      'userId': data['editedBy'] ?? salesmanId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  Future<void> _updateSaleItemReturnedQtyRemoteWindows({
    required FirebaseFirestore firestore,
    required DocumentReference<Map<String, dynamic>> saleRef,
    required String saleId,
    required String productId,
    required int additionalReturnedQty,
  }) async {
    final docSnap = await saleRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data();
    if (data == null) {
      AppLogger.warning(
        'Skipping returned qty sync for sale=$saleId (remote payload missing)',
        tag: 'Sales',
      );
      return;
    }

    final rawItems = data['items'];
    if (rawItems is! List) {
      AppLogger.warning(
        'Skipping returned qty sync for sale=$saleId (items is not a list)',
        tag: 'Sales',
      );
      return;
    }

    final parsedItems = <Map<String, dynamic>>[];
    var hasMalformedItem = false;
    for (final raw in rawItems) {
      if (raw is! Map) {
        hasMalformedItem = true;
        continue;
      }
      parsedItems.add(
        Map<String, dynamic>.from(
          raw.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }
    if (parsedItems.isEmpty) {
      AppLogger.warning(
        'Skipping returned qty sync for sale=$saleId (no valid sale items)',
        tag: 'Sales',
      );
      return;
    }

    var matchedProduct = false;
    for (final item in parsedItems) {
      if (item['productId']?.toString() == productId) {
        final currentReturned =
            (item['returnedQuantity'] as num?)?.toInt() ?? 0;
        item['returnedQuantity'] = currentReturned + additionalReturnedQty;
        matchedProduct = true;
        break;
      }
    }
    if (!matchedProduct) {
      AppLogger.warning(
        'Skipping returned qty sync for sale=$saleId (product not found: $productId)',
        tag: 'Sales',
      );
      return;
    }

    if (hasMalformedItem) {
      AppLogger.warning(
        'Sale $saleId contains malformed remote items; applied safe partial parse for returned qty update',
        tag: 'Sales',
      );
    }

    final batch = firestore.batch();
    batch.update(saleRef, {'items': parsedItems});
    await batch.commit();
  }

  Future<void> _cancelSaleRemoteWindows({
    required FirebaseFirestore firestore,
    required String saleId,
    required String reason,
    required String userId,
    required String nowIso,
  }) async {
    final saleRef = firestore.collection(salesCollection).doc(saleId);
    final saleSnap = await saleRef.get();
    if (!saleSnap.exists) return;

    final batch = firestore.batch();
    batch.update(saleRef, {
      'status': 'cancelled',
      'cancelReason': reason,
      'cancelledBy': userId,
      'cancelledAt': nowIso,
      'paidAmount': 0,
      'paymentStatus': 'cancelled',
      'commissionAmount': 0,
      'updatedAt': nowIso,
    });

    final saleData = saleSnap.data() as Map<String, dynamic>;
    if ((saleData['recipientType'] as String?) == 'customer') {
      final customerId = saleData['recipientId']?.toString();
      if (customerId != null && customerId.isNotEmpty) {
        final totalRemote =
            (saleData['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final custRef = firestore.collection('customers').doc(customerId);
        batch.update(custRef, {'balance': FieldValue.increment(-totalRemote)});
      }
    }

    await batch.commit();
  }

  Future<Map<String, String>> _resolveSalesmanIdentity() async {
    final actor = await _requireSalesMutationActor(
      'resolve sale actor identity',
    );
    final firebaseUid = auth?.currentUser?.uid;
    final normalizedFirebaseUid = firebaseUid?.trim();
    if (normalizedFirebaseUid == null || normalizedFirebaseUid.isEmpty) {
      throw StateError(
        'Authenticated Firebase UID is required to resolve sale actor identity.',
      );
    }
    final resolvedName = actor.name.trim().isNotEmpty
        ? actor.name.trim()
        : actor.email.trim();
    return {'id': normalizedFirebaseUid, 'name': resolvedName};
  }

  String _buildOfflineInvoiceId(String saleId, {int attempt = 0}) {
    final compactId = _sanitizeDeterministicToken(
      saleId,
    ).replaceAll('_', '').toUpperCase();
    final suffix = compactId.length >= 10
        ? compactId.substring(compactId.length - 10)
        : compactId.padLeft(10, 'X');
    final base = 'OFF-$suffix';
    return attempt == 0 ? base : '$base-$attempt';
  }

  Future<bool> _isInvoiceIdInUse(
    String invoiceId, {
    String? excludeSaleId,
  }) async {
    final existing = await _dbService.sales
        .filter()
        .humanReadableIdEqualTo(invoiceId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (existing == null) return false;
    if (excludeSaleId != null && existing.id == excludeSaleId) return false;
    return true;
  }

  Future<String> _generateUniqueOfflineInvoiceId(String saleId) async {
    var attempt = 0;
    while (attempt < 100) {
      final candidate = _buildOfflineInvoiceId(saleId, attempt: attempt);
      if (!await _isInvoiceIdInUse(candidate)) {
        return candidate;
      }
      attempt++;
    }
    throw Exception('Unable to generate unique offline invoice ID');
  }

  Future<String> createSale({
    required String recipientType,
    required String recipientId,
    required String recipientName,
    required List<SaleItemForUI> items,
    required double discountPercentage,
    double additionalDiscountPercentage = 0,
    String? route,
    String? vehicleNumber,
    String? driverName,
    String? saleType,
    String? createdByRole,
    String? status,
    bool? dispatchRequired,
    String? tripId,
    double gstPercentage = 0,
    String gstType = 'None',
  }) async {
    _ensureSalesmanAllocationUsesDispatch(recipientType);
    final actor = await _requireSalesMutationActor('create sale');
    final identity = await _resolveSalesmanIdentity();
    final salesmanId = identity['id'] ?? actor.id;
    final salesmanName =
        identity['name'] ??
        (actor.name.trim().isNotEmpty ? actor.name.trim() : actor.email.trim());

    return await _createSaleLocal(
      recipientType: recipientType,
      recipientId: recipientId,
      recipientName: recipientName,
      items: items,
      discountPercentage: discountPercentage,
      additionalDiscountPercentage: additionalDiscountPercentage,
      route: route,
      vehicleNumber: vehicleNumber,
      driverName: driverName,
      saleType: saleType,
      createdByRole: createdByRole,
      status: status,
      dispatchRequired: dispatchRequired,
      tripId: tripId,
      gstPercentage: gstPercentage,
      gstType: gstType,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
    );
  }

  Future<String> _createSaleLocal({
    required String recipientType,
    required String recipientId,
    required String recipientName,
    required List<SaleItemForUI> items,
    required double discountPercentage,
    double additionalDiscountPercentage = 0,
    String? route,
    String? vehicleNumber,
    String? driverName,
    String? saleType,
    String? createdByRole,
    String? status,
    bool? dispatchRequired,
    String? tripId,
    double gstPercentage = 0,
    String gstType = 'None',
    required String salesmanId,
    required String salesmanName,
  }) async {
    _ensureSalesmanAllocationUsesDispatch(recipientType);
    final saleId = generateId();
    final now = getCurrentTimestamp();
    final saleDate = DateTime.now();

    _validationDelegate.validateCreateSaleParams(
      recipientType: recipientType,
      recipientId: recipientId,
      recipientName: recipientName,
      items: items,
      discountPercentage: discountPercentage,
      additionalDiscountPercentage: additionalDiscountPercentage,
      gstPercentage: gstPercentage,
    );

    final humanReadableId = await _generateUniqueOfflineInvoiceId(saleId);

    final primaryDiscountPct = discountPercentage.clamp(0.0, 100.0);
    final additionalDiscountPct = additionalDiscountPercentage.clamp(
      0.0,
      100.0,
    );
    final calc = _calculateSale(
      items: items,
      discountPercentage: primaryDiscountPct,
      additionalDiscountPercentage: additionalDiscountPct,
      gstPercentage: gstPercentage,
      gstType: gstType,
    );
    final accountingDimensions = await _accountingDelegate
        .resolveAccountingDimensions(
          recipientType: recipientType,
          recipientId: recipientId,
          recipientName: recipientName,
          salesmanId: salesmanId,
          salesmanName: salesmanName,
          saleDate: saleDate,
          explicitRoute: route,
        );

    // Commission Calculation (Snapshot)
    double commissionAmount = 0;
    String commissionTypeSnapshot = 'percentage';
    try {
      final reportPrefs = await _settingsService.getReportsPreferences();
      commissionTypeSnapshot = reportPrefs.commissionType;
      // ... (Use existing logic if complex, or simplified snapshot)
      if (reportPrefs.commissionType == 'percentage') {
        commissionAmount = _round2(
          calc.totalAmount * (reportPrefs.baseCommissionPercentage / 100),
        );
      } else if (reportPrefs.commissionType == 'slab') {
        double remaining = calc.totalAmount;
        for (var slab in reportPrefs.commissionSlabs) {
          if (remaining <= 0) break;
          double slabTotal = slab.maxAmount - slab.minAmount;
          if (slabTotal <= 0) slabTotal = 99999999;
          double taxableInSlab = (remaining > slabTotal)
              ? slabTotal
              : remaining;
          commissionAmount += taxableInSlab * (slab.percentage / 100);
          remaining -= taxableInSlab;
        }
        commissionAmount = _round2(commissionAmount);
      } else if (reportPrefs.commissionType == 'target_based') {
        commissionAmount = _round2(
          calc.totalAmount * (reportPrefs.baseCommissionPercentage / 100),
        );
      }
    } catch (e) {
      // Ignore
    }

    final saleData = {
      'id': saleId,
      'recipientType': recipientType,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'items': calc.lines.asMap().entries.map((entry) {
        final line = entry.value;
        final itemMap = line.toPersistedMap();
        itemMap['movementId'] = _buildSaleMovementId(
          saleId: saleId,
          productId: line.item.productId,
          itemIndex: entry.key,
          isFree: line.item.isFree,
        );
        return itemMap;
      }).toList(),
      'subtotal': calc.subtotal,
      'itemDiscountAmount': calc.itemDiscountTotal,
      'discountPercentage': primaryDiscountPct,
      'discountAmount': calc.discountAmount,
      'additionalDiscountPercentage': additionalDiscountPct,
      'additionalDiscountAmount': calc.additionalDiscountAmount,
      'taxableAmount': calc.taxableAmount,
      'gstType': gstType,
      'gstPercentage': gstPercentage,
      if (calc.cgstAmount > 0) 'cgstAmount': calc.cgstAmount,
      if (calc.sgstAmount > 0) 'sgstAmount': calc.sgstAmount,
      if (calc.igstAmount > 0) 'igstAmount': calc.igstAmount,
      'totalAmount': calc.totalAmount,
      'roundOff': _round2(
        calc.totalAmount - (calc.taxableAmount + calc.totalGstAmount),
      ),
      'commissionAmount': commissionAmount,
      'commissionType': commissionTypeSnapshot,
      'humanReadableId': humanReadableId,
      'createdAt': now,
      'month': saleDate.month,
      'year': saleDate.year,
      'salesmanId': accountingDimensions['salesmanId'] ?? salesmanId,
      'salesmanName': accountingDimensions['salesmanName'] ?? salesmanName,
      if ((accountingDimensions['route'] ?? '').toString().isNotEmpty)
        'route': accountingDimensions['route']
      else if ((route ?? '').trim().isNotEmpty)
        'route': route,
      if ((accountingDimensions['district'] ?? '').toString().isNotEmpty)
        'district': accountingDimensions['district'],
      if ((accountingDimensions['division'] ?? '').toString().isNotEmpty)
        'division': accountingDimensions['division'],
      if ((accountingDimensions['dealerId'] ?? '').toString().isNotEmpty)
        'dealerId': accountingDimensions['dealerId'],
      if ((accountingDimensions['dealerName'] ?? '').toString().isNotEmpty)
        'dealerName': accountingDimensions['dealerName'],
      'saleDate': accountingDimensions['saleDate'],
      'accountingDimensions': accountingDimensions,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'status': status ?? ((vehicleNumber != null) ? 'delivered' : 'completed'),
      'itemProductIds': items.map((i) => i.productId).toList(),
      if (saleType != null) 'saleType': saleType,
      if (createdByRole != null) 'createdByRole': createdByRole,
      if (dispatchRequired != null) 'dispatchRequired': dispatchRequired,
      if (tripId != null) 'tripId': tripId,
      'isSynced': false,
    };

    final saleEntity = _buildSaleEntityFromMap(
      saleData,
      syncStatus: SyncStatus.pending,
    );

    // 2. ATOMIC TRANSACTION: Stocks + Ledger + Balance + Sale Persist
    await _dbService.db.writeTxn(() async {
      final duplicateInvoice = await _dbService.sales
          .filter()
          .humanReadableIdEqualTo(humanReadableId)
          .and()
          .isDeletedEqualTo(false)
          .findFirst();
      if (duplicateInvoice != null) {
        throw Exception('Duplicate invoice ID detected: $humanReadableId');
      }

      final saleCommandItems = items
          .map(
            (item) => InventoryCommandItem(
              productId: item.productId,
              quantityBase: item.finalBaseQuantity.toDouble(),
            ),
          )
          .toList(growable: false);
      final inventoryActorUid = _resolveInventoryActorUid(
        explicitActorUid: salesmanId,
        fallbackSalesmanUid: salesmanId,
      );
      final inventoryActorLegacyId = _resolveInventoryActorLegacyId(salesmanId);

      if (saleCommandItems.isNotEmpty) {
        await _applySaleCompleteInTxn(
          saleIdToken: saleId,
          recipientType: recipientType,
          salesmanUid: salesmanId,
          items: saleCommandItems,
          actorUid: inventoryActorUid,
          actorLegacyAppUserId: inventoryActorLegacyId,
          occurredAt: DateTime.parse(now),
        );
      }

      // T9-P2 REMOVED: direct local customer/warehouse stock mutations now go
      // through InventoryMovementEngine sale_complete.
      // if (recipientType == 'customer') {
      //   final user = await _findLocalSalesmanUser(salesmanId);
      //   if (user == null) {
      //     throw Exception(
      //       'Salesman profile not found locally for stock deduction ($salesmanId)',
      //     );
      //   }
      //   final allocatedMap = user.getAllocatedStock();
      //   for (var item in items) {
      //     final stockItem = allocatedMap[item.productId];
      //     if (stockItem == null) {
      //       throw Exception('Not allocated: ${item.name}');
      //     }
      //     final currentQty = item.isFree
      //         ? (stockItem.freeQuantity ?? 0)
      //         : stockItem.quantity;
      //     if (currentQty < item.quantity) {
      //       throw Exception('Insufficient Stock: ${item.name}');
      //     }
      //     if (item.isFree) {
      //       final newFreeQty =
      //           (stockItem.freeQuantity ?? 0) - item.quantity.toInt();
      //       allocatedMap[item.productId] = stockItem.copyWith(
      //         freeQuantity: newFreeQty,
      //       );
      //     } else {
      //       final newQty = stockItem.quantity - item.quantity.toInt();
      //       allocatedMap[item.productId] = stockItem.copyWith(
      //         quantity: newQty,
      //       );
      //     }
      //   }
      //   user.setAllocatedStock(allocatedMap);
      //   user.syncStatus = SyncStatus.pending;
      //   user.updatedAt = DateTime.now();
      //   await _dbService.users.put(user);
      // } else if (recipientType == 'dealer' || recipientType == 'salesman') {
      //   for (var item in items) {
      //     final product = await _dbService.products.get(
      //       fastHash(item.productId),
      //     );
      //     if (product == null) {
      //       throw Exception('Product not found: ${item.name}');
      //     }
      //     final currentStock = (product.stock ?? 0).toDouble();
      //     if (currentStock < item.quantity) {
      //       throw Exception('Insufficient Warehouse Stock: ${item.name}');
      //     }
      //     final updatedStock = currentStock - item.quantity;
      //     await _inventoryService.applyProductStockChangeInTxn(
      //       productId: item.productId,
      //       quantityChange: -item.quantity.toDouble(),
      //       updatedAt: DateTime.now(),
      //       markSyncPending: true,
      //     );
      //     final ledger = StockLedgerEntity()
      //       ..id = generateId()
      //       ..productId = item.productId
      //       ..warehouseId = 'Main'
      //       ..transactionDate = DateTime.parse(now)
      //       ..transactionType = 'SALE_OUT'
      //       ..quantityChange = -item.quantity.toDouble()
      //       ..runningBalance = updatedStock
      //       ..unit = item.baseUnit
      //       ..performedBy = salesmanId
      //       ..notes = 'Direct Sale to $recipientName'
      //       ..referenceId = saleId
      //       ..syncStatus = SyncStatus.pending
      //       ..updatedAt = DateTime.parse(now);
      //     await _dbService.stockLedger.put(ledger);
      //   }
      // }

      if (_normalizeRecipientType(recipientType) == 'dealer') {
        for (final item in items) {
          final product = await _dbService.products.getById(item.productId);
          if (product == null) {
            continue;
          }
          final ledger = StockLedgerEntity()
            ..id = generateId()
            ..productId = item.productId
            ..warehouseId = 'Main'
            ..transactionDate = DateTime.parse(now)
            ..transactionType = 'SALE_OUT'
            ..quantityChange = -item.finalBaseQuantity.toDouble()
            ..runningBalance = product.stock ?? 0.0
            ..unit = item.baseUnit
            ..performedBy = salesmanId
            ..notes = 'Direct Sale to $recipientName'
            ..referenceId = saleId
            ..syncStatus = SyncStatus.pending
            ..updatedAt = DateTime.parse(now);
          await _dbService.stockLedger.put(ledger);
        }
      }

      // B. Customer Balance (Atomic)
      if (recipientType == 'customer') {
        final customer = await _dbService.customers
            .filter()
            .idEqualTo(recipientId)
            .findFirst();

        if (customer != null) {
          customer.balance = (customer.balance) + calc.totalAmount;
          customer.updatedAt = DateTime.now();
          customer.syncStatus = SyncStatus.pending;
          await _dbService.customers.put(customer);
        }
      }

      // C. Sale Record (same transaction to avoid split-brain local state)
      await _dbService.sales.put(saleEntity);
    });

    final strictMode = await _postingService.isStrictAccountingModeEnabled();
    if (strictMode) {
      try {
        await _postSaleVoucherAfterSuccess(
          saleData: saleData,
          salesmanId: salesmanId,
          salesmanName: salesmanName,
          strictModeOverride: true,
          strictBusinessWrite: StrictBusinessWrite(
            collection: salesCollection,
            docId: saleId,
            data: saleData,
            merge: true,
          ),
        );
      } catch (e) {
        await _compensateStrictModeSaleFailure(
          saleData: saleData,
          items: items,
          salesmanId: salesmanId,
          salesmanName: salesmanName,
          reason: e.toString(),
        );
        rethrow;
      }
    }

    // 4. Sync (Immediate if possible, otherwise enqueue)
    final synced = await _queueAndSyncSale(saleData);

    if (synced) {
      await _dbService.db.writeTxn(() async {
        final existing = await _dbService.sales.getById(saleId);
        if (existing != null) {
          existing.syncStatus = SyncStatus.synced;
          existing.updatedAt = DateTime.now();
          await _dbService.sales.put(existing);
        }
      });
    }

    if (!strictMode) {
      if (synced) {
        await _postSaleVoucherAfterSuccess(
          saleData: saleData,
          salesmanId: salesmanId,
          salesmanName: salesmanName,
          strictModeOverride: false,
        );
      } else {
        AppLogger.warning(
          'Skipping immediate sales voucher post because sale sync is pending (saleId=$saleId)',
          tag: 'Accounting',
        );
        if (await _canQueueSalesVoucherRetry(salesmanId)) {
          await _enqueueSalesVoucherPostRetry(
            saleData: saleData,
            salesmanId: salesmanId,
            salesmanName: salesmanName,
            reason: 'Sale sync pending; voucher posting deferred',
          );
        }
      }
    }

    return saleId;
  }

  Future<void> _postSaleVoucherAfterSuccess({
    required Map<String, dynamic> saleData,
    required String salesmanId,
    required String salesmanName,
    bool? strictModeOverride,
    StrictBusinessWrite? strictBusinessWrite,
    bool requireSuccess = false,
    bool enqueueRetryOnFailure = true,
  }) async {
    final strictMode =
        strictModeOverride ??
        await _postingService.isStrictAccountingModeEnabled();
    final canQueueVoucherRetry = await _canQueueSalesVoucherRetry(salesmanId);
    try {
      final result = await _postingService.postSalesVoucher(
        saleData: saleData,
        postedByUserId: salesmanId,
        postedByName: salesmanName,
        strictModeOverride: strictMode,
        strictBusinessWrite: strictBusinessWrite,
      );
      if (!result.success) {
        final message = result.errorMessage ?? 'Voucher posting failed';
        if (strictMode || requireSuccess) {
          throw Exception(message);
        }
        AppLogger.warning(message, tag: 'Accounting');
        if (enqueueRetryOnFailure) {
          if (canQueueVoucherRetry) {
            await _enqueueSalesVoucherPostRetry(
              saleData: saleData,
              salesmanId: salesmanId,
              salesmanName: salesmanName,
              reason: message,
            );
          } else {
            AppLogger.warning(
              _isPermissionDeniedError(message)
                  ? 'Skipping voucher retry queue due to permission rules for role/user: $salesmanId'
                  : 'Skipping voucher retry queue because current role is not allowed to post accounting entries.',
              tag: 'Accounting',
            );
          }
        }
      }
    } catch (e) {
      if (strictMode || requireSuccess) {
        rethrow;
      }
      AppLogger.warning(
        'Sales posted without voucher in Phase-1 safe mode: $e',
        tag: 'Accounting',
      );
      if (enqueueRetryOnFailure) {
        if (canQueueVoucherRetry) {
          await _enqueueSalesVoucherPostRetry(
            saleData: saleData,
            salesmanId: salesmanId,
            salesmanName: salesmanName,
            reason: e.toString(),
          );
        } else {
          AppLogger.warning(
            _isPermissionDeniedError(e)
                ? 'Voucher retry queue skipped due to permission-denied for role/user: $salesmanId'
                : 'Voucher retry queue skipped because current role cannot write accounting vouchers.',
            tag: 'Accounting',
          );
        }
      }
    }
  }

  Future<bool> _canQueueSalesVoucherRetry(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return false;
    try {
      final user = await _dbService.users
          .filter()
          .idEqualTo(normalizedUserId)
          .findFirst();
      final role = (user?.role ?? '').trim().toLowerCase();
      return role == 'admin' || role == 'owner' || role == 'accountant';
    } catch (_) {
      return false;
    }
  }

  bool _isPermissionDeniedError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('permission-denied') ||
        text.contains('missing or insufficient permissions');
  }

  Future<void> _enqueueSalesVoucherPostRetry({
    required Map<String, dynamic> saleData,
    required String salesmanId,
    required String salesmanName,
    String? reason,
  }) async {
    final saleId = _accountingDelegate.sanitizeDimensionValue(saleData['id']);
    if (saleId.isEmpty) return;

    final queueId = '${salesVoucherPostRetryCollection}_$saleId';
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final payload = <String, dynamic>{
      'id': saleId,
      'saleData': saleData,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      if (reason != null && reason.trim().isNotEmpty) 'lastError': reason,
      'updatedAt': now.toIso8601String(),
    };

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = salesVoucherPostRetryCollection
      ..action = 'set'
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: false,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(entity);
    });

    AppLogger.warning(
      'Queued sales voucher retry for sale $saleId',
      tag: 'Accounting',
    );
  }

  Future<void> processQueuedSalesVoucherPost(
    Map<String, dynamic> queuePayload,
  ) async {
    await _capabilityGuard.requireCapabilityOrRole(
      operation: 'process queued sales voucher post',
      capability: null,
      allowedRoles: _accountingMutationRoleOverrides,
    );
    final saleDataRaw = queuePayload['saleData'];
    if (saleDataRaw is! Map) {
      throw StateError(
        'Invalid sales voucher retry payload: saleData is missing',
      );
    }
    final saleData = Map<String, dynamic>.from(
      saleDataRaw.map((key, value) => MapEntry(key.toString(), value)),
    );

    final fallbackSalesmanId = _accountingDelegate.sanitizeDimensionValue(
      saleData['salesmanId'],
    );
    final fallbackSalesmanName = _accountingDelegate.sanitizeDimensionValue(
      saleData['salesmanName'],
    );
    final salesmanId = _accountingDelegate.firstNonEmpty([
      queuePayload['salesmanId'],
      fallbackSalesmanId,
    ]);
    final salesmanName = _accountingDelegate.firstNonEmpty([
      queuePayload['salesmanName'],
      fallbackSalesmanName,
    ]);
    if (salesmanId.isEmpty) {
      throw StateError('Sales voucher retry payload missing salesmanId');
    }

    final strictMode = await _postingService.isStrictAccountingModeEnabled();
    await _postSaleVoucherAfterSuccess(
      saleData: saleData,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
      strictModeOverride: strictMode,
      requireSuccess: true,
      enqueueRetryOnFailure: false,
    );
  }

  Future<void> _compensateStrictModeSaleFailure({
    required Map<String, dynamic> saleData,
    required List<SaleItemForUI> items,
    required String salesmanId,
    required String salesmanName,
    required String reason,
  }) async {
    final saleId = (saleData['id'] ?? '').toString();
    final recipientType = (saleData['recipientType'] ?? '').toString();
    final recipientId = (saleData['recipientId'] ?? '').toString();
    final recipientName = (saleData['recipientName'] ?? '').toString();
    final totalAmount = _toDouble(saleData['totalAmount']) ?? 0;
    final now = DateTime.now();
    final rollbackPlan = CompensationStrategy.salesRollbackPlan(
      saleData: saleData,
      itemLines: items
          .map(
            (item) => {
              'productId': item.productId,
              'quantity': item.quantity,
              'isFree': item.isFree,
            },
          )
          .toList(),
    );

    try {
      await _dbService.db.writeTxn(() async {
        final localSale = await _dbService.sales.getById(saleId);
        if (localSale != null) {
          await _dbService.sales.delete(localSale.isarId);
        }

        if (recipientType == 'customer') {
          final user = await _findLocalSalesmanUser(salesmanId);
          if (user != null) {
            final allocatedMap = user.getAllocatedStock();
            for (final item in items) {
              final stockItem = allocatedMap[item.productId];
              if (stockItem == null) continue;
              if (item.isFree) {
                final restoredFree =
                    (stockItem.freeQuantity ?? 0) + item.quantity;
                allocatedMap[item.productId] = stockItem.copyWith(
                  freeQuantity: restoredFree,
                );
              } else {
                final restored = stockItem.quantity + item.quantity;
                allocatedMap[item.productId] = stockItem.copyWith(
                  quantity: restored,
                );
              }
            }
            user.setAllocatedStock(allocatedMap);
            user.syncStatus = SyncStatus.pending;
            user.updatedAt = now;
            await _dbService.users.put(user);
          }

          final customer = await _dbService.customers
              .filter()
              .idEqualTo(recipientId)
              .findFirst();
          if (customer != null) {
            customer.balance = customer.balance - totalAmount;
            customer.syncStatus = SyncStatus.pending;
            customer.updatedAt = now;
            await _dbService.customers.put(customer);
          }
        } else if (recipientType == 'dealer' || recipientType == 'salesman') {
          for (final item in items) {
            await _inventoryService.applyProductStockChangeInTxn(
              productId: item.productId,
              quantityChange: item.quantity.toDouble(),
              updatedAt: now,
              markSyncPending: true,
              createLedger: true,
              transactionType: 'SALE_COMPENSATION_IN',
              performedBy: salesmanId,
              reason: 'Strict mode compensation',
              referenceId: saleId,
              notes: 'Compensation rollback for strict accounting failure',
            );
          }
        }
      });

      final compensationToken = jsonEncode(<String, dynamic>{
        'saleId': saleId,
        'reason': reason,
        'operations': rollbackPlan.operations,
      });
      final compensationId = 'comp_sale_${fastHash(compensationToken)}';
      final payload = <String, dynamic>{
        'id': compensationId,
        'module': 'sales',
        'transactionRefId': saleId,
        'transactionType': 'sales',
        'status': 'compensated',
        'reason': reason,
        'recipientType': recipientType,
        'recipientId': recipientId,
        'recipientName': recipientName,
        'totalAmount': totalAmount,
        'compensatedAt': now.toIso8601String(),
        'performedBy': salesmanId,
        'operations': rollbackPlan.operations,
      };
      await syncToFirebase(
        'set',
        payload,
        collectionName: accountingCompensationLogCollection,
        syncImmediately: false,
      );
      await createAuditLog(
        collectionName: accountingCompensationLogCollection,
        docId: compensationId,
        action: 'create',
        changes: payload,
        userId: salesmanId,
        userName: salesmanName,
      );
    } catch (e) {
      AppLogger.error(
        'Failed strict sale compensation',
        error: e,
        tag: 'Accounting',
      );
      rethrow;
    }
  }

  Future<void> compensatePermanentAddFailure(
    Map<String, dynamic> failedPayload, {
    Object? error,
  }) async {
    final saleId = failedPayload['id']?.toString().trim() ?? '';
    if (saleId.isEmpty) return;
    final now = DateTime.now();
    await _dbService.db.writeTxn(() async {
      final saleEntity = await _dbService.sales.getById(saleId);
      if (saleEntity == null) return;

      final alreadyCompensated =
          (saleEntity.status ?? '').trim().toLowerCase() == 'conflict' &&
          saleEntity.syncStatus == SyncStatus.conflict;
      if (alreadyCompensated) return;

      final recipientType = saleEntity.recipientType.trim().toLowerCase();
      final saleItems = saleEntity.items ?? const <SaleItemEntity>[];
      final totalAmount = saleEntity.totalAmount ?? 0.0;

      if (recipientType == 'customer') {
        final user = await _findLocalSalesmanUser(saleEntity.salesmanId);
        if (user != null) {
          final allocatedMap = user.getAllocatedStock();
          for (final item in saleItems) {
            final productId = item.productId?.trim() ?? '';
            final qty = item.quantity ?? 0;
            if (productId.isEmpty || qty <= 0) continue;
            final itemName = (item.name?.trim().isNotEmpty ?? false)
                ? item.name!.trim()
                : productId;
            final itemPrice = item.price ?? 0.0;
            final baseUnit = (item.baseUnit?.trim().isNotEmpty ?? false)
                ? item.baseUnit!.trim()
                : 'unit';
            final conversionFactor = item.conversionFactor ?? 1.0;
            final isFreeItem = item.isFree == true;
            final existing =
                allocatedMap[productId] ??
                AllocatedStockItem(
                  name: itemName,
                  quantity: 0,
                  productId: productId,
                  price: itemPrice,
                  baseUnit: baseUnit,
                  conversionFactor: conversionFactor,
                  freeQuantity: 0,
                );
            if (isFreeItem) {
              final restoredFree = (existing.freeQuantity ?? 0) + qty;
              allocatedMap[productId] = existing.copyWith(
                freeQuantity: restoredFree,
              );
            } else {
              allocatedMap[productId] = existing.copyWith(
                quantity: existing.quantity + qty,
              );
            }
          }
          user.setAllocatedStock(allocatedMap);
          user.syncStatus = SyncStatus.pending;
          user.updatedAt = now;
          await _dbService.users.put(user);
        }

        final customer = await _dbService.customers
            .filter()
            .idEqualTo(saleEntity.recipientId)
            .findFirst();
        if (customer != null) {
          customer.balance = _round2(customer.balance - totalAmount);
          customer.syncStatus = SyncStatus.pending;
          customer.updatedAt = now;
          await _dbService.customers.put(customer);
        }
      } else if (recipientType == 'dealer' || recipientType == 'salesman') {
        for (final item in saleItems) {
          final productId = item.productId?.trim() ?? '';
          if (productId.isEmpty) continue;
          final qty = (item.quantity ?? 0).toDouble();
          if (qty <= 0) continue;
          await _inventoryService.applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: qty,
            unit: item.baseUnit ?? '',
            enforceNonNegative: false,
            updatedAt: now,
            markSyncPending: true,
            createLedger: true,
            transactionType: 'SALE_SYNC_CONFLICT_ROLLBACK_IN',
            performedBy: saleEntity.salesmanId,
            reason: 'Permanent sale sync failure rollback',
            referenceId: saleId,
            notes: 'Rollback after permanent add sync failure',
          );
        }
      }

      saleEntity
        ..status = 'conflict'
        ..syncStatus = SyncStatus.conflict
        ..updatedAt = now;
      await _dbService.sales.put(saleEntity);
    });
    AppLogger.warning(
      'Applied local compensation for permanent sale add failure: $saleId (${error ?? 'unknown error'})',
      tag: 'Sync',
    );
  }

  // Helper to check for generic stub mode (on Windows)
  bool isStubMode() {
    return Platform.isWindows; // Simple check or can use FirebaseConfig
  }

  Future<bool> dispatchSaleClient(String saleId, String vehicleNumber) async {
    try {
      await _requireSalesMutationActor('dispatch sale');
      final firestore = db;
      if (firestore == null) throw Exception('Offline');

      final docRef = firestore.collection(salesCollection).doc(saleId);
      await docRef.update({
        'vehicleNumber': vehicleNumber,
        'status': 'inTransit',
      });

      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();
      if (data == null) throw Exception('Sale data not found');
      final userId = data['salesmanId']; // fixed null check

      await createAuditLog(
        collectionName: salesCollection,
        docId: saleId,
        action: 'dispatch',
        changes: {'vehicleNumber': vehicleNumber},
        userId: userId ?? '',
      );

      return true;
    } catch (e) {
      throw handleError(e, 'dispatchSaleClient');
    }
  }

  Future<void> syncOfflineSales() async {
    await _syncOfflineSalesLegacy();
  }

  Future<void> _syncOfflineSalesLegacy() async {
    await _migrateLegacySalesIfNeeded();
    final pendingSales = await _dbService.sales
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    for (final sale in pendingSales) {
      await _enqueueSaleForSync(sale.toDomain().toJson());
    }
    if (_centralQueueSync != null) {
      await _centralQueueSync!.call();
    }
  }

  Future<List<Sale>> getSalesClient({
    String? salesmanId,
    String? customerId,
    int? limit,
    List<String>? orderBy,
    DateTime? startDate,
    DateTime? endDate,
    String? recipientType,
    int offset = 0,
    String? searchQuery,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      await _migrateLegacySalesIfNeeded();

      // 1. Build Isar Query
      // We start with a baseline filter so we can chain dynamically.
      var query = _dbService.sales.filter().createdAtIsNotEmpty();

      if (salesmanId != null && salesmanId.isNotEmpty) {
        query = query.and().salesmanIdEqualTo(salesmanId);
      }

      if (customerId != null && customerId.isNotEmpty) {
        query = query.and().recipientIdEqualTo(customerId);
      }

      if (recipientType != null && recipientType.isNotEmpty) {
        query = query.and().recipientTypeEqualTo(recipientType);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.and().recipientNameContains(
          searchQuery.trim(),
          caseSensitive: false,
        );
      }

      if (startDate != null) {
        final startOfDay = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        ).toIso8601String();
        query = query.and().createdAtGreaterThan(startOfDay, include: true);
      }

      if (endDate != null) {
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        ).toIso8601String();
        query = query.and().createdAtLessThan(endOfDay, include: true);
      }

      // Query local Isar with sorting and limits
      List<SaleEntity> entities;
      if (orderBy != null && orderBy.length == 2 && orderBy[1] == 'desc') {
        // Fallback for custom sorts (rare in this app) is memory sort, but we limit fetching based on default
        entities = await query
            .sortByCreatedAtDesc()
            .offset(offset)
            .limit(limit ?? 200)
            .findAll();
      } else {
        entities = await query
            .sortByCreatedAtDesc()
            .offset(offset)
            .limit(limit ?? 200)
            .findAll();
      }

      // 2. BOOTSTRAP: If local empty at offset 0, try sync ONCE (best effort)
      if (entities.isEmpty && offset == 0) {
        final firestoreInstance = db;
        if (firestoreInstance != null) {
          try {
            Query fbQuery = firestoreInstance.collection(salesCollection);
            if (salesmanId != null && salesmanId.isNotEmpty) {
              fbQuery = fbQuery.where('salesmanId', isEqualTo: salesmanId);
            }
            if (customerId != null && customerId.isNotEmpty) {
              fbQuery = fbQuery.where('recipientId', isEqualTo: customerId);
            }

            fbQuery = fbQuery.orderBy('createdAt', descending: true);

            if (limit != null) {
              fbQuery = fbQuery.limit(limit);
            } else {
              fbQuery = fbQuery.limit(50);
            }

            if (lastDoc != null) {
              fbQuery = fbQuery.startAfterDocument(lastDoc);
            }

            final snapshot = await fbQuery.get().timeout(
              const Duration(seconds: 3),
            );

            final fetchedItems = snapshot.docs
                .map(
                  (doc) => {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  },
                )
                .toList();

            if (fetchedItems.isNotEmpty) {
              await _dbService.db.writeTxn(() async {
                for (final item in fetchedItems) {
                  final entity = _buildSaleEntityFromMap(
                    item,
                    syncStatus: SyncStatus.synced,
                  );
                  await _dbService.sales.put(entity);
                }
              });

              // Re-run Isar query
              entities = await query
                  .sortByCreatedAtDesc()
                  .offset(offset)
                  .limit(limit ?? 200)
                  .findAll();
            }
          } catch (_) {
            // Ignore sync errors
          }
        }
      }

      // 3. Convert to domain and apply custom memory sort if necessary
      var sales = entities.map((e) => e.toDomain()).toList();

      if (orderBy != null && orderBy.length == 2 && orderBy[0] != 'createdAt') {
        final key = orderBy[0];
        final desc = orderBy[1] == 'desc';
        sales.sort((a, b) {
          final va = a.toJson()[key]?.toString() ?? '';
          final vb = b.toJson()[key]?.toString() ?? '';
          return desc ? vb.compareTo(va) : va.compareTo(vb);
        });
      }

      return deduplicate(sales, (s) => s.id);
    } catch (e) {
      throw handleError(e, 'getSalesClient');
    }
  }

  Future<double> getAggregateSalesTotal({
    required String salesmanId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final firestoreDb = db;
      if (firestoreDb == null) return 0.0;

      final startIso = startDate.toIso8601String();
      final endIso = endDate.toIso8601String();

      final query = firestoreDb
          .collection(salesCollection)
          .where('salesmanId', isEqualTo: salesmanId)
          .where('createdAt', isGreaterThanOrEqualTo: startIso)
          .where('createdAt', isLessThanOrEqualTo: endIso);

      final snapshot = await query.aggregate(sum('totalAmount')).get();

      final sumVal = snapshot.getSum('totalAmount');
      return (sumVal as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      handleError(e, 'getAggregateSalesTotal');
      return 0.0;
    }
  }

  Future<List<Sale>> getSalesByCustomerClient(
    String customerId,
    String salesmanId,
  ) async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      final query = firestore
          .collection(salesCollection)
          .where('recipientId', isEqualTo: customerId)
          .where('salesmanId', isEqualTo: salesmanId)
          .where('recipientType', isEqualTo: 'customer')
          .orderBy('createdAt', descending: true)
          .limit(50);

      final snapshot = await query.get().timeout(const Duration(seconds: 3));
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Sale.fromJson(data);
      }).toList();
    } catch (e) {
      throw handleError(e, 'getSalesByCustomerClient');
    }
  }

  Future<List<Sale>> getSalesByIds(List<String> saleIds) async {
    if (saleIds.isEmpty) return [];
    try {
      // Firestore 'whereIn' supports up to 10-30 items depending on version. 10 is safe.
      // For larger lists, we'd need to chunk.
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(salesCollection)
          .where(FieldPath.documentId, whereIn: saleIds)
          .get()
          .timeout(const Duration(seconds: 3));

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Sale.fromJson(data);
      }).toList();
    } catch (e) {
      throw handleError(e, 'getSalesByIds');
    }
  }

  // Backward compatibility methods
  Future<List<Sale>> getSales({
    String? salesmanId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return getSalesClient(
      salesmanId: salesmanId,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Sale?> getSale(String saleId) async {
    try {
      final firestore = db;
      if (firestore == null) return null;

      final docSnap = await firestore
          .collection(salesCollection)
          .doc(saleId)
          .get()
          .timeout(const Duration(seconds: 3));
      if (!docSnap.exists) return null;
      final data = Map<String, dynamic>.from(docSnap.data() as Map);
      data['id'] = docSnap.id;
      return Sale.fromJson(data);
    } catch (e) {
      throw handleError(e, 'getSale');
    }
  }

  /// Update returned quantity for a specific item in a sale
  Future<void> updateSaleItemReturnedQty({
    required String saleId,
    required String productId,
    required int additionalReturnedQty,
  }) async {
    try {
      await _requireSalesMutationActor('update sale returned quantity');
      await _migrateLegacySalesIfNeeded();
      // 1. Update Locally (Isar)
      await _dbService.db.writeTxn(() async {
        final saleEntity = await _dbService.sales.get(fastHash(saleId));
        if (saleEntity == null) return;

        final items = saleEntity.items ?? [];
        for (var i = 0; i < items.length; i++) {
          if (items[i].productId == productId) {
            items[i].returnedQuantity =
                (items[i].returnedQuantity ?? 0) + additionalReturnedQty;
            break;
          }
        }

        saleEntity.items = items;
        saleEntity.syncStatus = SyncStatus.pending;
        saleEntity.updatedAt = DateTime.now();
        await _dbService.sales.put(saleEntity);
      });

      // 2. Sync to Firebase (via Transaction on server)
      final firestore = db;
      if (firestore != null) {
        final saleRef = firestore.collection(salesCollection).doc(saleId);
        final isWindows = Platform.isWindows;
        if (isWindows) {
          await _updateSaleItemReturnedQtyRemoteWindows(
            firestore: firestore,
            saleRef: saleRef,
            saleId: saleId,
            productId: productId,
            additionalReturnedQty: additionalReturnedQty,
          );
        } else {
          await firestore.runTransaction((transaction) async {
            final docSnap = await transaction.get(saleRef);
            if (!docSnap.exists) return;

            final data = docSnap.data();
            if (data == null) {
              AppLogger.warning(
                'Skipping returned qty sync for sale=$saleId (remote payload missing)',
                tag: 'Sales',
              );
              return;
            }

            final rawItems = data['items'];
            if (rawItems is! List) {
              AppLogger.warning(
                'Skipping returned qty sync for sale=$saleId (items is not a list)',
                tag: 'Sales',
              );
              return;
            }

            final parsedItems = <Map<String, dynamic>>[];
            var hasMalformedItem = false;
            for (final raw in rawItems) {
              if (raw is! Map) {
                hasMalformedItem = true;
                continue;
              }
              parsedItems.add(
                Map<String, dynamic>.from(
                  raw.map((key, value) => MapEntry(key.toString(), value)),
                ),
              );
            }
            if (parsedItems.isEmpty) {
              AppLogger.warning(
                'Skipping returned qty sync for sale=$saleId (no valid sale items)',
                tag: 'Sales',
              );
              return;
            }

            var matchedProduct = false;
            for (final item in parsedItems) {
              if (item['productId']?.toString() == productId) {
                final currentReturned =
                    (item['returnedQuantity'] as num?)?.toInt() ?? 0;
                item['returnedQuantity'] =
                    currentReturned + additionalReturnedQty;
                matchedProduct = true;
                break;
              }
            }
            if (!matchedProduct) {
              AppLogger.warning(
                'Skipping returned qty sync for sale=$saleId (product not found: $productId)',
                tag: 'Sales',
              );
              return;
            }

            if (hasMalformedItem) {
              AppLogger.warning(
                'Sale $saleId contains malformed remote items; applied safe partial parse for returned qty update',
                tag: 'Sales',
              );
            }

            transaction.update(saleRef, {'items': parsedItems});
          });
        }
      }
    } catch (e) {
      handleError(e, 'updateSaleItemReturnedQty');
      AppLogger.warning(
        'Gracefully skipped returned qty sync update for sale=$saleId: $e',
        tag: 'Sales',
      );
    }
  }

  /// Edits an existing sale and applies stock/customer balance deltas atomically.
  Future<void> editSale({
    required String saleId,
    required List<SaleItemForUI> items,
    required double discountPercentage,
    double? additionalDiscountPercentage,
    double? gstPercentage,
    String? gstType,
    String? recipientId,
    String? recipientName,
    String? route,
    String editedBy = 'system',
  }) async {
    try {
      await _requireSalesMutationActor('edit sale');
      await _migrateLegacySalesIfNeeded();
      if (items.isEmpty) {
        throw Exception('Sale must contain at least one item');
      }
      for (final item in items) {
        if (item.productId.trim().isEmpty) {
          throw Exception('Invalid product in sale items');
        }
        if (item.quantity <= 0) {
          throw Exception(
            'Quantity must be greater than zero for ${item.name}',
          );
        }
      }

      final trimmedEditedBy = editedBy.trim().isEmpty
          ? 'system'
          : editedBy.trim();
      Map<String, dynamic>? syncPayload;

      await _dbService.db.writeTxn(() async {
        final saleEntity = await _dbService.sales.get(fastHash(saleId));
        if (saleEntity == null) throw Exception('Sale not found');

        final saleStatus = (saleEntity.status ?? '').trim().toLowerCase();
        if (saleStatus == 'cancelled') {
          throw Exception('Cancelled sale cannot be edited');
        }

        final previousRecipientType = saleEntity.recipientType;
        final previousRecipientId = saleEntity.recipientId;
        final previousRecipientName = saleEntity.recipientName;
        final previousRoute = saleEntity.route;

        final effectiveRecipientId = (recipientId ?? previousRecipientId)
            .trim();
        final effectiveRecipientName = (recipientName ?? previousRecipientName)
            .trim();
        if (effectiveRecipientId.isEmpty) {
          throw Exception('Recipient is required');
        }
        if (effectiveRecipientName.isEmpty) {
          throw Exception('Recipient name is required');
        }

        final incomingRoute = route?.trim();
        String? effectiveRoute;
        if (incomingRoute != null) {
          effectiveRoute = incomingRoute.isEmpty ? null : incomingRoute;
        } else {
          final existingRoute = saleEntity.route?.trim();
          effectiveRoute = (existingRoute == null || existingRoute.isEmpty)
              ? null
              : existingRoute;
        }

        final primaryDiscountPct = discountPercentage.clamp(0.0, 100.0);
        final additionalDiscountPct =
            (additionalDiscountPercentage ??
                    saleEntity.additionalDiscountPercentage ??
                    0.0)
                .clamp(0.0, 100.0);
        final effectiveGstType =
            ((gstType ?? saleEntity.gstType ?? 'None').toString().trim().isEmpty
            ? 'None'
            : (gstType ?? saleEntity.gstType ?? 'None').toString().trim());
        final effectiveGstPct =
            (gstPercentage ?? saleEntity.gstPercentage ?? 0.0).clamp(
              0.0,
              100.0,
            );

        final calc = _calculateSale(
          items: items,
          discountPercentage: primaryDiscountPct,
          additionalDiscountPercentage: additionalDiscountPct,
          gstPercentage: effectiveGstPct,
          gstType: effectiveGstType,
        );

        final stockDeltas = _stockDelegate.calculateSaleStockDeltas(
          previousItems: saleEntity.items ?? const <SaleItemEntity>[],
          nextItems: items,
        );
        final oldTotalAmount = saleEntity.totalAmount ?? 0.0;
        final totalDelta = _round2(calc.totalAmount - oldTotalAmount);
        final now = DateTime.now();
        final nowIso = now.toIso8601String();
        final previousSaleItems = List<SaleItemEntity>.from(
          saleEntity.items ?? const <SaleItemEntity>[],
        );
        final inventoryEditCommandKey =
            'sales_edit_${fastHash('$saleId|$nowIso|$effectiveRecipientId|${jsonEncode(items.map((item) => item.toJson()).toList(growable: false))}')}';
        final inventoryActorUid = _resolveInventoryActorUid(
          explicitActorUid: saleEntity.salesmanId,
          fallbackSalesmanUid: saleEntity.salesmanId,
        );
        final inventoryActorLegacyId = _resolveInventoryActorLegacyId(
          trimmedEditedBy,
        );

        await _applySaleEditInventoryInTxn(
          saleId: saleId,
          previousRecipientType: saleEntity.recipientType,
          nextRecipientType: saleEntity.recipientType,
          salesmanUid: saleEntity.salesmanId,
          previousItems: _commandItemsFromSaleEntities(previousSaleItems),
          nextItems: items
              .map(
                (item) => InventoryCommandItem(
                  productId: item.productId,
                  quantityBase: item.finalBaseQuantity.toDouble(),
                ),
              )
              .toList(growable: false),
          actorUid: inventoryActorUid,
          actorLegacyAppUserId: inventoryActorLegacyId,
          commandKey: inventoryEditCommandKey,
          occurredAt: now,
        );

        // T9-P2 REMOVED: sale edit stock deltas now flow through
        // InventoryMovementEngine sale_reversal -> sale_complete.
        // if (saleEntity.recipientType == 'customer') {
        //   final user = await _findLocalSalesmanUser(saleEntity.salesmanId);
        //   if (user == null) {
        //     throw Exception(
        //       'Salesman profile not found locally for sale edit (${saleEntity.salesmanId})',
        //     );
        //   }
        //   final allocatedMap = user.getAllocatedStock();
        //   for (final delta in stockDeltas) {
        //     var stockItem = allocatedMap[delta.productId];
        //     if (stockItem == null) {
        //       if (delta.quantityDelta > 0) {
        //         throw Exception('Not allocated: ${delta.name}');
        //       }
        //       stockItem = AllocatedStockItem(
        //         name: delta.name,
        //         quantity: 0,
        //         productId: delta.productId,
        //         price: 0,
        //         baseUnit: delta.baseUnit,
        //         conversionFactor: 1,
        //         freeQuantity: 0,
        //       );
        //     }
        //     final currentQty = delta.isFree
        //         ? (stockItem.freeQuantity ?? 0)
        //         : stockItem.quantity;
        //     final nextQty = currentQty - delta.quantityDelta;
        //     if (nextQty < 0) {
        //       throw Exception(
        //         'Insufficient ${delta.isFree ? 'free ' : ''}stock for ${delta.name}',
        //       );
        //     }
        //     if (delta.isFree) {
        //       allocatedMap[delta.productId] = stockItem.copyWith(
        //         freeQuantity: nextQty,
        //       );
        //     } else {
        //       allocatedMap[delta.productId] = stockItem.copyWith(
        //         quantity: nextQty,
        //       );
        //     }
        //   }
        //   user.setAllocatedStock(allocatedMap);
        //   user.syncStatus = SyncStatus.pending;
        //   user.updatedAt = now;
        //   await _dbService.users.put(user);
        // } else if (saleEntity.recipientType == 'dealer' ||
        //     saleEntity.recipientType == 'salesman') {
        //   for (final delta in stockDeltas) {
        //     final stockChange = -delta.quantityDelta.toDouble();
        //     if (stockChange.abs() < 1e-9) continue;
        //     await _inventoryService.applyProductStockChangeInTxn(
        //       productId: delta.productId,
        //       quantityChange: stockChange,
        //       unit: delta.baseUnit,
        //       enforceNonNegative: true,
        //       updatedAt: now,
        //       markSyncPending: true,
        //       createLedger: true,
        //       transactionType: stockChange < 0
        //           ? 'SALE_EDIT_OUT'
        //           : 'SALE_EDIT_IN',
        //       performedBy: trimmedEditedBy,
        //       reason: 'Sale Edit',
        //       referenceId: saleId,
        //       notes: 'Sale edit adjustment for ${delta.name}',
        //     );
        //   }
        // }

        if (saleEntity.recipientType == 'dealer' ||
            saleEntity.recipientType == 'salesman') {
          for (final delta in stockDeltas) {
            final stockChange = -delta.quantityDelta.toDouble();
            if (stockChange.abs() < 1e-9) continue;
            final product = await _dbService.products.getById(delta.productId);
            if (product == null) continue;
            final ledger = StockLedgerEntity()
              ..id = generateId()
              ..productId = delta.productId
              ..warehouseId = 'Main'
              ..transactionDate = now
              ..transactionType = stockChange < 0
                  ? 'SALE_EDIT_OUT'
                  : 'SALE_EDIT_IN'
              ..quantityChange = stockChange
              ..runningBalance = product.stock ?? 0.0
              ..unit = delta.baseUnit
              ..performedBy = trimmedEditedBy
              ..referenceId = saleId
              ..notes = 'Sale edit adjustment for ${delta.name}'
              ..syncStatus = SyncStatus.pending
              ..updatedAt = now;
            await _dbService.stockLedger.put(ledger);
          }
        }

        if (saleEntity.recipientType == 'customer') {
          final recipientChanged =
              previousRecipientId.trim() != effectiveRecipientId;
          if (recipientChanged) {
            if (previousRecipientId.trim().isNotEmpty) {
              final previousCustomer = await _dbService.customers
                  .filter()
                  .idEqualTo(previousRecipientId)
                  .findFirst();
              if (previousCustomer != null) {
                previousCustomer.balance = _round2(
                  previousCustomer.balance - oldTotalAmount,
                );
                previousCustomer.syncStatus = SyncStatus.pending;
                previousCustomer.updatedAt = now;
                await _dbService.customers.put(previousCustomer);
              }
            }

            final nextCustomer = await _dbService.customers
                .filter()
                .idEqualTo(effectiveRecipientId)
                .findFirst();
            if (nextCustomer == null) {
              throw Exception('Selected customer not found');
            }
            nextCustomer.balance = _round2(
              nextCustomer.balance + calc.totalAmount,
            );
            nextCustomer.syncStatus = SyncStatus.pending;
            nextCustomer.updatedAt = now;
            await _dbService.customers.put(nextCustomer);
          } else if (totalDelta.abs() >= 1e-9) {
            final customer = await _dbService.customers
                .filter()
                .idEqualTo(effectiveRecipientId)
                .findFirst();
            if (customer != null) {
              customer.balance = _round2(customer.balance + totalDelta);
              customer.syncStatus = SyncStatus.pending;
              customer.updatedAt = now;
              await _dbService.customers.put(customer);
            }
          }
        }

        saleEntity
          ..recipientId = effectiveRecipientId
          ..recipientName = effectiveRecipientName
          ..route = effectiveRoute
          ..items = _toSaleItemEntities(calc.lines)
          ..itemProductIds = items
              .map((e) => e.productId)
              .toList(growable: false)
          ..subtotal = calc.subtotal
          ..itemDiscountAmount = calc.itemDiscountTotal
          ..discountPercentage = primaryDiscountPct
          ..discountAmount = calc.discountAmount
          ..additionalDiscountPercentage = additionalDiscountPct
          ..additionalDiscountAmount = calc.additionalDiscountAmount
          ..taxableAmount = calc.taxableAmount
          ..gstType = effectiveGstType
          ..gstPercentage = effectiveGstPct
          ..cgstAmount = calc.cgstAmount
          ..sgstAmount = calc.sgstAmount
          ..igstAmount = calc.igstAmount
          ..totalAmount = calc.totalAmount
          ..roundOff = _round2(
            calc.totalAmount - (calc.taxableAmount + calc.totalGstAmount),
          )
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;
        await _dbService.sales.put(saleEntity);

        final payload = saleEntity.toDomain().toJson();
        payload['updatedAt'] = nowIso;
        payload['stockDeltas'] = stockDeltas
            .map((entry) => entry.toJson())
            .toList(growable: false);
        payload['totalDelta'] = totalDelta;
        payload['oldTotalAmount'] = oldTotalAmount;
        payload['previousRecipientType'] = previousRecipientType;
        payload['previousRecipientId'] = previousRecipientId;
        payload['previousRecipientName'] = previousRecipientName;
        payload['previousRoute'] = previousRoute;
        payload['editedBy'] = trimmedEditedBy;
        payload['editedAt'] = nowIso;
        payload[OutboxCodec.idempotencyKeyField] = inventoryEditCommandKey;
        syncPayload = payload;
      });

      if (syncPayload == null) return;
      final synced = await _queueAndSyncSale(syncPayload!, action: 'edit');
      if (synced) {
        await _dbService.db.writeTxn(() async {
          final existing = await _dbService.sales.getById(saleId);
          if (existing != null) {
            existing.syncStatus = SyncStatus.synced;
            existing.updatedAt = DateTime.now();
            await _dbService.sales.put(existing);
          }
        });
      }
    } catch (e) {
      handleError(e, 'editSale');
      rethrow;
    }
  }

  /// Cancels a sale and reverts stock changes.
  /// ARCHITECTURE LOCK: Must revert stock via InventoryService
  Future<void> cancelSale({
    required String saleId,
    required String reason,
    required String userId,
  }) async {
    try {
      await _requireSalesMutationActor('cancel sale');
      await _migrateLegacySalesIfNeeded();
      await _dbService.db.writeTxn(() async {
        final saleEntity = await _dbService.sales.get(fastHash(saleId));
        if (saleEntity == null) throw Exception('Sale not found');

        final alreadyCancelled = saleEntity.status == 'cancelled';
        final totalAmount = saleEntity.totalAmount ?? 0.0;

        // 1. Update Sale Status
        saleEntity.status = 'cancelled';
        saleEntity.cancelReason = reason;
        saleEntity.cancelledBy = userId;
        saleEntity.cancelledAt = DateTime.now().toIso8601String();
        saleEntity.commissionAmount = 0;
        // Financial reversal once
        if (saleEntity.paymentStatus != 'cancelled') {
          saleEntity.paidAmount = 0;
          saleEntity.paymentStatus = 'cancelled';

          if (saleEntity.recipientType == 'customer') {
            final customer = await _dbService.customers
                .filter()
                .idEqualTo(saleEntity.recipientId)
                .findFirst();
            if (customer != null) {
              customer.balance = _round2(customer.balance - totalAmount);
              customer.syncStatus = SyncStatus.pending;
              customer.updatedAt = DateTime.now();
              await _dbService.customers.put(customer);
            }
          }
        }
        saleEntity.syncStatus = SyncStatus.pending;

        await _dbService.sales.put(saleEntity);

        // 2. Revert Stock (Delegated to InventoryService) - only first time
        if (!alreadyCancelled) {
          final items = saleEntity.items ?? [];
          if (items.isNotEmpty) {
            await _inventoryService.revertSaleStock(
              saleId: saleId,
              items: items,
              recipientType: saleEntity.recipientType,
              salesmanId: saleEntity.salesmanId,
              performedBy: userId,
              inTransaction: true,
            );
          }
        }
      });

      // 3. Sync Update to Firestore (Best Effort)
      final firestore = db;
      if (firestore != null) {
        final nowIso = DateTime.now().toIso8601String();
        final isWindows = Platform.isWindows;
        if (isWindows) {
          await _cancelSaleRemoteWindows(
            firestore: firestore,
            saleId: saleId,
            reason: reason,
            userId: userId,
            nowIso: nowIso,
          );
        } else {
          await firestore.runTransaction((transaction) async {
            final saleRef = firestore.collection(salesCollection).doc(saleId);
            final saleSnap = await transaction.get(saleRef);
            if (saleSnap.exists) {
              transaction.update(saleRef, {
                'status': 'cancelled',
                'cancelReason': reason,
                'cancelledBy': userId,
                'cancelledAt': nowIso,
                'paidAmount': 0,
                'paymentStatus': 'cancelled',
                'commissionAmount': 0,
                'updatedAt': nowIso,
              });

              final saleData = saleSnap.data() as Map<String, dynamic>;
              if ((saleData['recipientType'] as String?) == 'customer') {
                final customerId = saleData['recipientId']?.toString();
                if (customerId != null && customerId.isNotEmpty) {
                  final totalRemote =
                      (saleData['totalAmount'] as num?)?.toDouble() ?? 0.0;
                  final custRef = firestore
                      .collection('customers')
                      .doc(customerId);
                  transaction.update(custRef, {
                    'balance': FieldValue.increment(-totalRemote),
                  });
                }
              }
            }
          });
        }
      }
    } catch (e) {
      handleError(e, 'cancelSale');
      rethrow;
    }
  }
}

class _SaleInventoryCommandContext {
  const _SaleInventoryCommandContext({
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

  _SaleInventoryCommandContext copyWith({
    String? commandId,
    String? sourceLocationId,
    int? sequence,
    DateTime? createdAt,
    String? editCommandKey,
  }) {
    return _SaleInventoryCommandContext(
      commandId: commandId ?? this.commandId,
      sourceLocationId: sourceLocationId ?? this.sourceLocationId,
      sequence: sequence ?? this.sequence,
      createdAt: createdAt ?? this.createdAt,
      editCommandKey: editCommandKey ?? this.editCommandKey,
    );
  }
}
