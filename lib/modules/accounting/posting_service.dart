import '../../core/firebase/firebase_config.dart';
import '../../services/settings_service.dart';
import '../../utils/app_logger.dart';
import 'accounts_repository.dart';
import 'financial_year_service.dart';
import 'voucher_repository.dart';

class PostingResult {
  final bool success;
  final String? voucherId;
  final String? errorMessage;
  final bool strictMode;

  const PostingResult({
    required this.success,
    required this.strictMode,
    this.voucherId,
    this.errorMessage,
  });
}

class PostingService {
  final SettingsService _settingsService;
  final AccountsRepository _accountsRepository;
  final VoucherRepository _voucherRepository;
  final FinancialYearService _financialYearService;

  PostingService(
    FirebaseServices firebase, {
    SettingsService? settingsService,
    AccountsRepository? accountsRepository,
    VoucherRepository? voucherRepository,
    FinancialYearService? financialYearService,
  }) : _settingsService = settingsService ?? SettingsService(firebase),
       _accountsRepository = accountsRepository ?? AccountsRepository(firebase),
       _voucherRepository = voucherRepository ?? VoucherRepository(firebase),
       _financialYearService =
           financialYearService ?? FinancialYearService(firebase);

  Future<bool> isStrictAccountingModeEnabled() async {
    try {
      final settings = await _settingsService.getGeneralSettings();
      return settings?.strictAccountingMode ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _ensureFinancialYearOpen({
    required DateTime date,
    required String createdBy,
  }) async {
    final isLocked = await _financialYearService.isDateLocked(date);
    if (isLocked) {
      throw StateError(
        'Financial year ${FinancialYearService.financialYearIdForDate(date)} is locked.',
      );
    }
    return _financialYearService.ensureFinancialYearForDate(
      date,
      createdBy: createdBy,
    );
  }

  Future<PostingResult> postSalesVoucher({
    required Map<String, dynamic> saleData,
    required String postedByUserId,
    String? postedByName,
    bool? strictModeOverride,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    final strictMode =
        strictModeOverride ?? await isStrictAccountingModeEnabled();

    try {
      await _accountsRepository.ensureDefaultAccounts();

      final postingDate = _parseDate(saleData['createdAt']?.toString());
      final year = await _ensureFinancialYearOpen(
        date: postingDate,
        createdBy: postedByUserId,
      );
      final yearId = (year['id'] ?? '').toString();

      final totalAmount = _toDouble(saleData['totalAmount']);
      final cgstAmount = _toDouble(saleData['cgstAmount']);
      final sgstAmount = _toDouble(saleData['sgstAmount']);
      final igstAmount = _toDouble(saleData['igstAmount']);
      final gstTotal = cgstAmount + sgstAmount + igstAmount;
      final taxableAmount = _toDouble(saleData['taxableAmount']);
      final salesAmount = taxableAmount > 0
          ? taxableAmount
          : (totalAmount - gstTotal);
      final roundOff = _toDouble(saleData['roundOff']);

      final recipientType = (saleData['recipientType'] ?? '').toString();
      final recipientName = (saleData['recipientName'] ?? 'Sale').toString();
      final recipientId = (saleData['recipientId'] ?? 'NA').toString();
      final sourceId = (saleData['id'] ?? '').toString();
      final salesDimensions = _buildSalesDimensions(
        saleData: saleData,
        postingDate: postingDate,
        postedByUserId: postedByUserId,
        postedByName: postedByName,
      );
      final voucherNarration = _buildSalesVoucherNarration(
        recipientName: recipientName,
        dimensions: salesDimensions,
      );
      final voucherNumber = await _nextVoucherNumber(
        voucherType: 'sales',
        date: postingDate,
        userId: postedByUserId,
        userName: postedByName,
      );

      final partyCode = recipientType.toLowerCase() == 'customer'
          ? 'SUNDRY_DEBTORS'
          : 'SUNDRY_DEBTORS';
      final partyName = recipientType.toLowerCase() == 'customer'
          ? 'Sundry Debtors'
          : 'Sales Receivable';

      final entries = <Map<String, dynamic>>[
        _entry(
          accountCode: partyCode,
          accountName: partyName,
          debit: totalAmount,
          credit: 0,
          dimensions: salesDimensions,
          narration: _buildEntryNarration(
            accountName: partyName,
            recipientName: recipientName,
            dimensions: salesDimensions,
          ),
        ),
      ];

      if (salesAmount > 0) {
        entries.add(
          _entry(
            accountCode: 'SALES',
            accountName: 'Sales Account',
            debit: 0,
            credit: salesAmount,
            dimensions: salesDimensions,
            narration: _buildEntryNarration(
              accountName: 'Sales Account',
              recipientName: recipientName,
              dimensions: salesDimensions,
            ),
          ),
        );
      }

      if (cgstAmount > 0) {
        entries.add(
          _entry(
            accountCode: gstLedgerCodeForComponent(
              component: 'CGST',
              isOutputTax: true,
            ),
            accountName: 'Output CGST',
            debit: 0,
            credit: cgstAmount,
            gstComponent: 'CGST',
            dimensions: salesDimensions,
            narration: _buildEntryNarration(
              accountName: 'Output CGST',
              recipientName: recipientName,
              dimensions: salesDimensions,
            ),
          ),
        );
      }
      if (sgstAmount > 0) {
        entries.add(
          _entry(
            accountCode: gstLedgerCodeForComponent(
              component: 'SGST',
              isOutputTax: true,
            ),
            accountName: 'Output SGST',
            debit: 0,
            credit: sgstAmount,
            gstComponent: 'SGST',
            dimensions: salesDimensions,
            narration: _buildEntryNarration(
              accountName: 'Output SGST',
              recipientName: recipientName,
              dimensions: salesDimensions,
            ),
          ),
        );
      }
      if (igstAmount > 0) {
        entries.add(
          _entry(
            accountCode: gstLedgerCodeForComponent(
              component: 'IGST',
              isOutputTax: true,
            ),
            accountName: 'Output IGST',
            debit: 0,
            credit: igstAmount,
            gstComponent: 'IGST',
            dimensions: salesDimensions,
            narration: _buildEntryNarration(
              accountName: 'Output IGST',
              recipientName: recipientName,
              dimensions: salesDimensions,
            ),
          ),
        );
      }

      if (roundOff.abs() > 0.0001) {
        if (roundOff > 0) {
          entries.add(
            _entry(
              accountCode: 'ROUND_OFF',
              accountName: 'Round Off',
              debit: 0,
              credit: roundOff,
              dimensions: salesDimensions,
              narration: _buildEntryNarration(
                accountName: 'Round Off',
                recipientName: recipientName,
                dimensions: salesDimensions,
              ),
            ),
          );
        } else {
          entries.add(
            _entry(
              accountCode: 'ROUND_OFF',
              accountName: 'Round Off',
              debit: roundOff.abs(),
              credit: 0,
              dimensions: salesDimensions,
              narration: _buildEntryNarration(
                accountName: 'Round Off',
                recipientName: recipientName,
                dimensions: salesDimensions,
              ),
            ),
          );
        }
      }

      final voucherId = await _voucherRepository.createVoucherBundle(
        voucher: {
          'transactionRefId': sourceId,
          'transactionType': 'sales',
          'voucherNumber': voucherNumber,
          'voucherType': 'sales',
          'sourceModule': 'sales',
          'sourceId': sourceId,
          'sourceNumber': saleData['humanReadableId'],
          'financialYearId': yearId,
          'date': postingDate.toIso8601String(),
          'partyId': recipientId,
          'partyName': recipientName,
          'narration': voucherNarration,
          ..._flattenDimensions(salesDimensions),
          if (salesDimensions.isNotEmpty)
            'accountingDimensions': salesDimensions,
          'dimensionVersion': 1,
          'createdBy': postedByUserId,
          'createdByName': postedByName,
        },
        entries: entries,
        strictMode: strictMode,
        strictBusinessWrite: strictBusinessWrite,
      );

      return PostingResult(
        success: true,
        strictMode: strictMode,
        voucherId: voucherId,
      );
    } catch (e) {
      if (strictMode) {
        rethrow;
      }
      AppLogger.warning('Sales voucher posting skipped: $e', tag: 'Accounting');
      return PostingResult(
        success: false,
        strictMode: strictMode,
        errorMessage: e.toString(),
      );
    }
  }

  Future<PostingResult> postPurchaseVoucher({
    required Map<String, dynamic> purchaseData,
    required String postedByUserId,
    String? postedByName,
    bool? strictModeOverride,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    final strictMode =
        strictModeOverride ?? await isStrictAccountingModeEnabled();

    try {
      await _accountsRepository.ensureDefaultAccounts();

      final postingDate = _parseDate(
        purchaseData['createdAt']?.toString() ??
            purchaseData['receivedAt']?.toString(),
      );
      final year = await _ensureFinancialYearOpen(
        date: postingDate,
        createdBy: postedByUserId,
      );
      final yearId = (year['id'] ?? '').toString();

      final totalAmount = _toDouble(purchaseData['totalAmount']);
      final cgstAmount = _toDouble(purchaseData['cgstAmount']);
      final sgstAmount = _toDouble(purchaseData['sgstAmount']);
      final igstAmount = _toDouble(purchaseData['igstAmount']);
      final gstTotal = cgstAmount + sgstAmount + igstAmount;
      final taxableAmount = _toDouble(purchaseData['subtotal']);
      final purchaseAmount = taxableAmount > 0
          ? taxableAmount
          : (totalAmount - gstTotal);
      final roundOff = _toDouble(purchaseData['roundOff']);

      final supplierName = (purchaseData['supplierName'] ?? 'Supplier')
          .toString();
      final supplierId = (purchaseData['supplierId'] ?? 'NA').toString();
      final sourceId = (purchaseData['id'] ?? '').toString();
      final voucherNumber = await _nextVoucherNumber(
        voucherType: 'purchase',
        date: postingDate,
        userId: postedByUserId,
        userName: postedByName,
      );

      final entries = <Map<String, dynamic>>[];
      if (purchaseAmount > 0) {
        entries.add(
          _entry(
            accountCode: 'PURCHASES',
            accountName: 'Purchase Account',
            debit: purchaseAmount,
            credit: 0,
          ),
        );
      }

      if (cgstAmount > 0) {
        entries.add(
          _entry(
            accountCode: gstLedgerCodeForComponent(
              component: 'CGST',
              isOutputTax: false,
            ),
            accountName: 'Input CGST',
            debit: cgstAmount,
            credit: 0,
            gstComponent: 'CGST',
          ),
        );
      }
      if (sgstAmount > 0) {
        entries.add(
          _entry(
            accountCode: gstLedgerCodeForComponent(
              component: 'SGST',
              isOutputTax: false,
            ),
            accountName: 'Input SGST',
            debit: sgstAmount,
            credit: 0,
            gstComponent: 'SGST',
          ),
        );
      }
      if (igstAmount > 0) {
        entries.add(
          _entry(
            accountCode: gstLedgerCodeForComponent(
              component: 'IGST',
              isOutputTax: false,
            ),
            accountName: 'Input IGST',
            debit: igstAmount,
            credit: 0,
            gstComponent: 'IGST',
          ),
        );
      }

      if (roundOff.abs() > 0.0001) {
        if (roundOff > 0) {
          entries.add(
            _entry(
              accountCode: 'ROUND_OFF',
              accountName: 'Round Off',
              debit: roundOff,
              credit: 0,
            ),
          );
        } else {
          entries.add(
            _entry(
              accountCode: 'ROUND_OFF',
              accountName: 'Round Off',
              debit: 0,
              credit: roundOff.abs(),
            ),
          );
        }
      }

      entries.add(
        _entry(
          accountCode: 'SUNDRY_CREDITORS',
          accountName: 'Sundry Creditors',
          debit: 0,
          credit: totalAmount,
        ),
      );

      final voucherId = await _voucherRepository.createVoucherBundle(
        voucher: {
          'transactionRefId': sourceId,
          'transactionType': 'purchase',
          'voucherNumber': voucherNumber,
          'voucherType': 'purchase',
          'sourceModule': 'purchase_orders',
          'sourceId': sourceId,
          'sourceNumber': purchaseData['poNumber'],
          'financialYearId': yearId,
          'date': postingDate.toIso8601String(),
          'partyId': supplierId,
          'partyName': supplierName,
          'narration': 'Auto-posted purchase voucher for $supplierName',
          'createdBy': postedByUserId,
          'createdByName': postedByName,
        },
        entries: entries,
        strictMode: strictMode,
        strictBusinessWrite: strictBusinessWrite,
      );

      return PostingResult(
        success: true,
        strictMode: strictMode,
        voucherId: voucherId,
      );
    } catch (e) {
      if (strictMode) {
        rethrow;
      }
      AppLogger.warning(
        'Purchase voucher posting skipped: $e',
        tag: 'Accounting',
      );
      return PostingResult(
        success: false,
        strictMode: strictMode,
        errorMessage: e.toString(),
      );
    }
  }

  Future<PostingResult> createOpeningBalanceVoucher({
    required String openingRefId,
    required DateTime date,
    required List<Map<String, dynamic>> entries,
    required String postedByUserId,
    String? postedByName,
    bool? strictModeOverride,
  }) async {
    final strictMode =
        strictModeOverride ?? await isStrictAccountingModeEnabled();
    try {
      await _accountsRepository.ensureDefaultAccounts();
      final year = await _ensureFinancialYearOpen(
        date: date,
        createdBy: postedByUserId,
      );
      final voucherNumber = await _nextVoucherNumber(
        voucherType: 'opening_balance',
        date: date,
        userId: postedByUserId,
        userName: postedByName,
      );

      final voucherId = await _voucherRepository.createVoucherBundle(
        voucher: {
          'transactionRefId': openingRefId,
          'transactionType': 'opening_balance',
          'voucherNumber': voucherNumber,
          'voucherType': 'opening_balance',
          'sourceModule': 'migration',
          'sourceId': openingRefId,
          'financialYearId': year['id'],
          'date': date.toIso8601String(),
          'narration': 'Opening balance migration voucher',
          'createdBy': postedByUserId,
          'createdByName': postedByName,
        },
        entries: entries,
        strictMode: strictMode,
      );

      return PostingResult(
        success: true,
        strictMode: strictMode,
        voucherId: voucherId,
      );
    } catch (e) {
      if (strictMode) {
        rethrow;
      }
      return PostingResult(
        success: false,
        strictMode: strictMode,
        errorMessage: e.toString(),
      );
    }
  }

  Future<PostingResult> createManualVoucher({
    required String voucherType,
    required String transactionRefId,
    required DateTime date,
    required List<Map<String, dynamic>> entries,
    required String postedByUserId,
    String? postedByName,
    String? narration,
    String? partyId,
    String? partyName,
    bool? strictModeOverride,
  }) async {
    final strictMode =
        strictModeOverride ?? await isStrictAccountingModeEnabled();
    final normalizedVoucherType = voucherType.trim().toLowerCase();
    if (normalizedVoucherType.isEmpty) {
      throw ArgumentError('voucherType is required');
    }

    try {
      await _accountsRepository.ensureDefaultAccounts();
      final year = await _ensureFinancialYearOpen(
        date: date,
        createdBy: postedByUserId,
      );
      final voucherNumber = await _nextVoucherNumber(
        voucherType: normalizedVoucherType,
        date: date,
        userId: postedByUserId,
        userName: postedByName,
      );

      final voucherId = await _voucherRepository.createVoucherBundle(
        voucher: {
          'transactionRefId': transactionRefId,
          'transactionType': normalizedVoucherType,
          'voucherNumber': voucherNumber,
          'voucherType': normalizedVoucherType,
          'sourceModule': 'accounting_manual',
          'sourceId': transactionRefId,
          'financialYearId': year['id'],
          'date': date.toIso8601String(),
          'narration': narration ?? 'Manual $normalizedVoucherType voucher',
          if (partyId != null && partyId.isNotEmpty) 'partyId': partyId,
          if (partyName != null && partyName.isNotEmpty) 'partyName': partyName,
          'createdBy': postedByUserId,
          'createdByName': postedByName,
        },
        entries: entries,
        strictMode: strictMode,
      );

      return PostingResult(
        success: true,
        strictMode: strictMode,
        voucherId: voucherId,
      );
    } catch (e) {
      if (strictMode) {
        rethrow;
      }
      return PostingResult(
        success: false,
        strictMode: strictMode,
        errorMessage: e.toString(),
      );
    }
  }

  Future<PostingResult> createVoucherReversal({
    required String originalVoucherId,
    required String reason,
    required String postedByUserId,
    String? postedByName,
    DateTime? reversalDate,
    bool? strictModeOverride,
  }) async {
    final strictMode =
        strictModeOverride ?? await isStrictAccountingModeEnabled();
    final effectiveDate = reversalDate ?? DateTime.now();
    try {
      await _accountsRepository.ensureDefaultAccounts();
      final year = await _ensureFinancialYearOpen(
        date: effectiveDate,
        createdBy: postedByUserId,
      );
      final voucherNumber = await _nextVoucherNumber(
        voucherType: 'reversal',
        date: effectiveDate,
        userId: postedByUserId,
        userName: postedByName,
      );

      final voucherId = await _voucherRepository.createReversalVoucherBundle(
        originalVoucherId: originalVoucherId,
        reason: reason,
        postedByUserId: postedByUserId,
        postedByName: postedByName,
        strictMode: strictMode,
        reversalDate: effectiveDate,
        voucherNumber: voucherNumber,
        financialYearId: (year['id'] ?? '').toString(),
      );

      return PostingResult(
        success: true,
        strictMode: strictMode,
        voucherId: voucherId,
      );
    } catch (e) {
      if (strictMode) {
        rethrow;
      }
      return PostingResult(
        success: false,
        strictMode: strictMode,
        errorMessage: e.toString(),
      );
    }
  }

  static String gstLedgerCodeForComponent({
    required String component,
    required bool isOutputTax,
  }) {
    final upper = component.toUpperCase().trim();
    final valid = {'CGST', 'SGST', 'IGST'};
    if (!valid.contains(upper)) {
      throw ArgumentError('Unsupported GST component: $component');
    }
    return '${isOutputTax ? 'OUTPUT' : 'INPUT'}_$upper';
  }

  Map<String, dynamic> _entry({
    required String accountCode,
    required String accountName,
    required double debit,
    required double credit,
    String? gstComponent,
    String? narration,
    Map<String, dynamic>? dimensions,
  }) {
    final safeDimensions = _flattenDimensions(
      dimensions ?? const <String, dynamic>{},
    );
    return {
      'accountCode': accountCode,
      'accountName': accountName,
      'debit': debit,
      'credit': credit,
      if (gstComponent != null) 'gstComponent': gstComponent,
      if (narration != null && narration.trim().isNotEmpty)
        'narration': narration.trim(),
      ...safeDimensions,
      if (safeDimensions.isNotEmpty) 'accountingDimensions': safeDimensions,
    };
  }

  Map<String, dynamic> _buildSalesDimensions({
    required Map<String, dynamic> saleData,
    required DateTime postingDate,
    required String postedByUserId,
    String? postedByName,
  }) {
    final nestedRaw = saleData['accountingDimensions'];
    final nested = nestedRaw is Map
        ? nestedRaw.map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : const <String, dynamic>{};

    final recipientType = (saleData['recipientType'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final recipientId = _sanitizeDimensionValue(saleData['recipientId']);
    final recipientName = _sanitizeDimensionValue(saleData['recipientName']);

    final route = _firstNonEmpty([saleData['route'], nested['route']]);
    final district = _firstNonEmpty([saleData['district'], nested['district']]);
    final division = _firstNonEmpty(
      [saleData['division'], saleData['zone'], nested['division'], nested['zone']],
    );
    final salesmanId = _firstNonEmpty(
      [saleData['salesmanId'], nested['salesmanId'], postedByUserId],
    );
    final salesmanName = _firstNonEmpty(
      [saleData['salesmanName'], nested['salesmanName'], postedByName],
    );
    final saleDate = _firstNonEmpty(
      [saleData['saleDate'], nested['saleDate'], _formatDateOnly(postingDate)],
    );

    final dealerId = _firstNonEmpty([
      saleData['dealerId'],
      nested['dealerId'],
      if (recipientType == 'dealer') recipientId,
    ]);
    final dealerName = _firstNonEmpty([
      saleData['dealerName'],
      nested['dealerName'],
      if (recipientType == 'dealer') recipientName,
    ]);

    return {
      if (route.isNotEmpty) 'route': route,
      if (district.isNotEmpty) 'district': district,
      if (division.isNotEmpty) 'division': division,
      if (salesmanId.isNotEmpty) 'salesmanId': salesmanId,
      if (salesmanName.isNotEmpty) 'salesmanName': salesmanName,
      if (saleDate.isNotEmpty) 'saleDate': saleDate,
      if (dealerId.isNotEmpty) 'dealerId': dealerId,
      if (dealerName.isNotEmpty) 'dealerName': dealerName,
    };
  }

  Map<String, dynamic> _flattenDimensions(Map<String, dynamic> dimensions) {
    final route = _sanitizeDimensionValue(dimensions['route']);
    final district = _sanitizeDimensionValue(dimensions['district']);
    final division = _sanitizeDimensionValue(dimensions['division']);
    final salesmanId = _sanitizeDimensionValue(dimensions['salesmanId']);
    final salesmanName = _sanitizeDimensionValue(dimensions['salesmanName']);
    final saleDate = _sanitizeDimensionValue(dimensions['saleDate']);
    final dealerId = _sanitizeDimensionValue(dimensions['dealerId']);
    final dealerName = _sanitizeDimensionValue(dimensions['dealerName']);

    return {
      if (route.isNotEmpty) 'route': route,
      if (district.isNotEmpty) 'district': district,
      if (division.isNotEmpty) 'division': division,
      if (salesmanId.isNotEmpty) 'salesmanId': salesmanId,
      if (salesmanName.isNotEmpty) 'salesmanName': salesmanName,
      if (saleDate.isNotEmpty) 'saleDate': saleDate,
      if (dealerId.isNotEmpty) 'dealerId': dealerId,
      if (dealerName.isNotEmpty) 'dealerName': dealerName,
    };
  }

  String _buildSalesVoucherNarration({
    required String recipientName,
    required Map<String, dynamic> dimensions,
  }) {
    final safeRecipient = _sanitizeDimensionValue(recipientName, maxLength: 80);
    final base = safeRecipient.isEmpty
        ? 'Auto-posted sale voucher'
        : 'Auto-posted sale voucher for $safeRecipient';
    final dimensionTag = _dimensionNarrationTag(dimensions);
    if (dimensionTag.isEmpty) return base;
    return '$base [$dimensionTag]';
  }

  String _buildEntryNarration({
    required String accountName,
    required String recipientName,
    required Map<String, dynamic> dimensions,
  }) {
    final safeAccount = _sanitizeDimensionValue(accountName, maxLength: 80);
    final safeRecipient = _sanitizeDimensionValue(recipientName, maxLength: 80);
    final base = safeRecipient.isEmpty
        ? 'Auto Sales Entry - $safeAccount'
        : 'Auto Sales Entry - $safeAccount for $safeRecipient';
    final dimensionTag = _dimensionNarrationTag(dimensions);
    if (dimensionTag.isEmpty) return base;
    return '$base [$dimensionTag]';
  }

  String _dimensionNarrationTag(Map<String, dynamic> dimensions) {
    final flat = _flattenDimensions(dimensions);
    final tags = <String>[];

    void append(String key, String label) {
      final value = _sanitizeDimensionValue(flat[key], maxLength: 64);
      if (value.isNotEmpty) {
        tags.add('$label:$value');
      }
    }

    append('route', 'Route');
    append('district', 'District');
    append('division', 'Division');
    append('salesmanName', 'Salesman');
    append('saleDate', 'Date');
    append('dealerName', 'Dealer');

    return tags.join(' | ');
  }

  String _formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _sanitizeDimensionValue(dynamic value, {int maxLength = 96}) {
    if (value == null) return '';
    var text = value.toString().trim();
    if (text.isEmpty) return '';

    text = text
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r'[<>&|]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return '';
    if (text.length > maxLength) {
      return text.substring(0, maxLength);
    }
    return text;
  }

  String _firstNonEmpty(List<dynamic> values, {int maxLength = 96}) {
    for (final value in values) {
      final sanitized = _sanitizeDimensionValue(value, maxLength: maxLength);
      if (sanitized.isNotEmpty) {
        return sanitized;
      }
    }
    return '';
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  DateTime _parseDate(String? input) {
    if (input == null || input.trim().isEmpty) return DateTime.now();
    return DateTime.tryParse(input) ?? DateTime.now();
  }

  Future<String> _nextVoucherNumber({
    required String voucherType,
    required DateTime date,
    required String userId,
    String? userName,
  }) async {
    final typeCode = _voucherTypeCode(voucherType);
    final seriesId = 'voucher_${voucherType.toLowerCase()}';
    final fy = FinancialYearService.financialYearIdForDate(date);
    final allSeries = await _settingsService.getTransactionSeries();

    TransactionSeries? series;
    for (final candidate in allSeries) {
      final candidateType = candidate.type.toLowerCase();
      if (candidate.id == seriesId ||
          candidateType == seriesId ||
          candidateType == voucherType.toLowerCase()) {
        series = candidate;
        break;
      }
    }

    final isNew = series == null;
    series ??= TransactionSeries(
      id: seriesId,
      type: voucherType.toLowerCase(),
      prefix: typeCode,
      suffix: null,
      nextNumber: 1,
      padding: 4,
      format: '{FY}/{TYPE}/{NUMBER}',
      resetOn: 'year',
      lastResetDate: null,
    );

    var number = series.nextNumber <= 0 ? 1 : series.nextNumber;
    String candidateNumber = '';
    while (true) {
      candidateNumber =
          '$fy/$typeCode/${number.toString().padLeft(series.padding, '0')}';
      final exists = await _voucherRepository.voucherNumberExists(
        candidateNumber,
      );
      if (!exists) break;
      number++;
    }

    final updatedSeries = TransactionSeries(
      id: series.id,
      type: series.type,
      prefix: typeCode,
      suffix: series.suffix,
      nextNumber: number + 1,
      padding: series.padding,
      format: series.format,
      resetOn: series.resetOn,
      lastResetDate: date.toIso8601String(),
    );
    final updated = await _settingsService.updateTransactionSeries(
      updatedSeries,
      isNew,
      userId,
      userName,
    );
    if (!updated) {
      throw StateError('Unable to update voucher series for $voucherType');
    }
    return candidateNumber;
  }

  String _voucherTypeCode(String voucherType) {
    switch (voucherType.trim().toLowerCase()) {
      case 'contra':
        return 'CONTRA';
      case 'payment':
        return 'PAYMENT';
      case 'receipt':
        return 'RECEIPT';
      case 'journal':
        return 'JOURNAL';
      case 'sales':
        return 'SALES';
      case 'purchase':
        return 'PURCHASE';
      case 'opening_balance':
        return 'OPENING';
      case 'reversal':
        return 'REV';
      default:
        final cleaned = voucherType.trim().toUpperCase();
        if (cleaned.isEmpty) return 'VOUCHER';
        return cleaned;
    }
  }
}
