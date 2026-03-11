import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/modules/accounting/accounts_repository.dart';
import 'package:flutter_app/modules/accounting/financial_year_service.dart';
import 'package:flutter_app/modules/accounting/posting_service.dart';
import 'package:flutter_app/modules/accounting/trial_balance_service.dart';
import 'package:flutter_app/modules/accounting/voucher_repository.dart';
import 'package:flutter_app/services/settings_service.dart';

class _FakeAccountsRepository extends AccountsRepository {
  _FakeAccountsRepository() : super(FirebaseServices());

  int ensureCalls = 0;

  @override
  Future<void> ensureDefaultAccounts() async {
    ensureCalls++;
  }
}

class _FakeVoucherRepository extends VoucherRepository {
  _FakeVoucherRepository() : super(FirebaseServices());

  bool throwOnCreate = false;
  bool strictFlag = false;
  int createCalls = 0;
  Map<String, dynamic>? capturedVoucher;
  List<Map<String, dynamic>> capturedEntries = [];
  final Set<String> _voucherNumbers = <String>{};

  @override
  Future<String> createVoucherBundle({
    required Map<String, dynamic> voucher,
    required List<Map<String, dynamic>> entries,
    required bool strictMode,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    strictFlag = strictMode;
    createCalls++;
    if (throwOnCreate) {
      throw Exception('forced voucher failure');
    }
    capturedVoucher = Map<String, dynamic>.from(voucher);
    final number = voucher['voucherNumber']?.toString();
    if (number != null && number.isNotEmpty) {
      _voucherNumbers.add(number);
    }
    capturedEntries = entries
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
    return (voucher['transactionRefId'] ?? voucher['id'] ?? 'VCH-TEST')
        .toString();
  }

  @override
  Future<bool> voucherNumberExists(
    String voucherNumber, {
    bool includeRemote = true,
  }) async {
    return _voucherNumbers.contains(voucherNumber);
  }
}

class _FakeFinancialYearService extends FinancialYearService {
  _FakeFinancialYearService({this.locked = false}) : super(FirebaseServices());

  bool locked;

  @override
  Future<bool> isDateLocked(DateTime date) async => locked;

  @override
  Future<Map<String, dynamic>> ensureFinancialYearForDate(
    DateTime date, {
    String? createdBy,
  }) async {
    return {'id': FinancialYearService.financialYearIdForDate(date)};
  }
}

class _FakeSettingsService extends SettingsService {
  _FakeSettingsService(this.strictMode) : super(FirebaseServices());

  bool strictMode;
  final List<TransactionSeries> _series = [];

  @override
  Future<GeneralSettingsData?> getGeneralSettings({
    bool forceRefresh = false,
  }) async {
    return GeneralSettingsData(strictAccountingMode: strictMode);
  }

  @override
  Future<List<TransactionSeries>> getTransactionSeries() async {
    return List<TransactionSeries>.from(_series);
  }

  @override
  Future<bool> updateTransactionSeries(
    TransactionSeries series,
    bool isNew,
    String userId,
    String? userName,
  ) async {
    final index = _series.indexWhere((item) => item.id == series.id);
    if (index >= 0) {
      _series[index] = series;
    } else {
      _series.add(series);
    }
    return true;
  }
}

double _sumDebit(List<Map<String, dynamic>> entries) {
  return entries.fold<double>(0, (sum, row) {
    final value = row['debit'];
    if (value is num) return sum + value.toDouble();
    return sum + (double.tryParse(value.toString()) ?? 0);
  });
}

double _sumCredit(List<Map<String, dynamic>> entries) {
  return entries.fold<double>(0, (sum, row) {
    final value = row['credit'];
    if (value is num) return sum + value.toDouble();
    return sum + (double.tryParse(value.toString()) ?? 0);
  });
}

PostingService _buildPostingService({
  required _FakeAccountsRepository accountsRepository,
  required _FakeVoucherRepository voucherRepository,
  required _FakeFinancialYearService financialYearService,
  required _FakeSettingsService settingsService,
}) {
  return PostingService(
    FirebaseServices(),
    accountsRepository: accountsRepository,
    voucherRepository: voucherRepository,
    financialYearService: financialYearService,
    settingsService: settingsService,
  );
}

void main() {
  group('Sales Auto Posting', () {
    test('creates balanced sales voucher', () async {
      final accounts = _FakeAccountsRepository();
      final vouchers = _FakeVoucherRepository();
      final years = _FakeFinancialYearService();
      final settings = _FakeSettingsService(false);
      final posting = _buildPostingService(
        accountsRepository: accounts,
        voucherRepository: vouchers,
        financialYearService: years,
        settingsService: settings,
      );

      final result = await posting.postSalesVoucher(
        saleData: {
          'id': 'S1',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Alpha Traders',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 1180.0,
          'taxableAmount': 1000.0,
          'cgstAmount': 90.0,
          'sgstAmount': 90.0,
          'roundOff': 0.0,
        },
        postedByUserId: 'U1',
        postedByName: 'Admin',
      );

      expect(result.success, isTrue);
      expect(vouchers.capturedVoucher?['voucherType'], 'sales');
      expect(vouchers.capturedVoucher?['transactionRefId'], 'S1');
      expect(vouchers.capturedVoucher?['transactionType'], 'sales');
      expect(
        (vouchers.capturedVoucher?['voucherNumber'] ?? '').toString(),
        isNotEmpty,
      );
      expect(
        (_sumDebit(vouchers.capturedEntries) -
                _sumCredit(vouchers.capturedEntries))
            .abs(),
        lessThanOrEqualTo(0.01),
      );
    });

    test('propagates route/division/district/dealer/salesman dimensions', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'S1-DIM',
          'recipientType': 'dealer',
          'recipientId': 'D-10',
          'recipientName': 'Dealer Ten',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 100.0,
          'taxableAmount': 100.0,
          'route': 'Route-8',
          'district': 'Pune',
          'division': 'Pune Division',
          'salesmanId': 'SM-8',
          'salesmanName': 'Ravi',
          'saleDate': '2026-02-10',
        },
        postedByUserId: 'U1',
      );

      expect(vouchers.capturedVoucher?['route'], 'Route-8');
      expect(vouchers.capturedVoucher?['district'], 'Pune');
      expect(vouchers.capturedVoucher?['division'], 'Pune Division');
      expect(vouchers.capturedVoucher?['salesmanId'], 'SM-8');
      expect(vouchers.capturedVoucher?['salesmanName'], 'Ravi');
      expect(vouchers.capturedVoucher?['saleDate'], '2026-02-10');
      expect(vouchers.capturedVoucher?['dealerId'], 'D-10');
      expect(vouchers.capturedVoucher?['dealerName'], 'Dealer Ten');
      expect(vouchers.capturedVoucher?['accountingDimensions'], isA<Map>());
      expect(vouchers.capturedEntries, isNotEmpty);
      expect(
        vouchers.capturedEntries.every((row) => row['route'] == 'Route-8'),
        isTrue,
      );
      expect(
        vouchers.capturedEntries.every((row) => row['district'] == 'Pune'),
        isTrue,
      );
      expect(
        vouchers.capturedEntries.every((row) => row['division'] == 'Pune Division'),
        isTrue,
      );
      expect(
        vouchers.capturedEntries.every((row) => row['salesmanName'] == 'Ravi'),
        isTrue,
      );
      expect(
        vouchers.capturedEntries.every((row) => row['dealerName'] == 'Dealer Ten'),
        isTrue,
      );
    });

    test('includes customer debit line', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'S2',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Customer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 100.0,
          'taxableAmount': 100.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) =>
              row['accountCode'] == 'SUNDRY_DEBTORS' && row['debit'] == 100.0,
        ),
        isTrue,
      );
    });

    test('maps output CGST and SGST ledgers', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'S3',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Customer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 118.0,
          'taxableAmount': 100.0,
          'cgstAmount': 9.0,
          'sgstAmount': 9.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'OUTPUT_CGST',
        ),
        isTrue,
      );
      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'OUTPUT_SGST',
        ),
        isTrue,
      );
    });

    test('maps output IGST ledger', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'S4',
          'recipientType': 'dealer',
          'recipientId': 'D1',
          'recipientName': 'Dealer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 118.0,
          'taxableAmount': 100.0,
          'igstAmount': 18.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'OUTPUT_IGST',
        ),
        isTrue,
      );
    });

    test('posts positive round-off as credit', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'S5',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Customer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 101.0,
          'taxableAmount': 100.0,
          'roundOff': 1.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'ROUND_OFF' && row['credit'] == 1.0,
        ),
        isTrue,
      );
    });

    test('posts negative round-off as debit', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'S6',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Customer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 99.0,
          'taxableAmount': 100.0,
          'roundOff': -1.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'ROUND_OFF' && row['debit'] == 1.0,
        ),
        isTrue,
      );
    });

    test(
      'non-strict mode returns failure without throw on voucher error',
      () async {
        final vouchers = _FakeVoucherRepository()..throwOnCreate = true;
        final posting = _buildPostingService(
          accountsRepository: _FakeAccountsRepository(),
          voucherRepository: vouchers,
          financialYearService: _FakeFinancialYearService(),
          settingsService: _FakeSettingsService(false),
        );

        final result = await posting.postSalesVoucher(
          saleData: {
            'id': 'S7',
            'recipientType': 'customer',
            'recipientId': 'C1',
            'recipientName': 'Customer',
            'createdAt': '2026-02-10T10:00:00.000',
            'totalAmount': 100.0,
            'taxableAmount': 100.0,
          },
          postedByUserId: 'U1',
        );

        expect(result.success, isFalse);
      },
    );

    test('strict mode propagates to voucher repository', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(true),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'S8',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Customer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 100.0,
          'taxableAmount': 100.0,
        },
        postedByUserId: 'U1',
      );

      expect(vouchers.strictFlag, isTrue);
    });

    test('throws in strict mode when financial year is locked', () async {
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: _FakeVoucherRepository(),
        financialYearService: _FakeFinancialYearService(locked: true),
        settingsService: _FakeSettingsService(true),
      );

      expect(
        () => posting.postSalesVoucher(
          saleData: {
            'id': 'S9',
            'recipientType': 'customer',
            'recipientId': 'C1',
            'recipientName': 'Customer',
            'createdAt': '2026-02-10T10:00:00.000',
            'totalAmount': 100.0,
            'taxableAmount': 100.0,
          },
          postedByUserId: 'U1',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Purchase Auto Posting', () {
    test('creates purchase voucher with creditors credit', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      final result = await posting.postPurchaseVoucher(
        purchaseData: {
          'id': 'P1',
          'supplierId': 'SUP1',
          'supplierName': 'Supplier',
          'createdAt': '2026-02-10T10:00:00.000',
          'subtotal': 1000.0,
          'cgstAmount': 90.0,
          'sgstAmount': 90.0,
          'totalAmount': 1180.0,
        },
        postedByUserId: 'U1',
      );

      expect(result.success, isTrue);
      expect(vouchers.capturedVoucher?['transactionRefId'], 'P1');
      expect(vouchers.capturedVoucher?['transactionType'], 'purchase');
      expect(
        vouchers.capturedEntries.any(
          (row) =>
              row['accountCode'] == 'SUNDRY_CREDITORS' &&
              row['credit'] == 1180.0,
        ),
        isTrue,
      );
    });

    test('maps input CGST and SGST ledgers', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postPurchaseVoucher(
        purchaseData: {
          'id': 'P2',
          'supplierId': 'SUP1',
          'supplierName': 'Supplier',
          'createdAt': '2026-02-10T10:00:00.000',
          'subtotal': 100.0,
          'cgstAmount': 9.0,
          'sgstAmount': 9.0,
          'totalAmount': 118.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'INPUT_CGST',
        ),
        isTrue,
      );
      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'INPUT_SGST',
        ),
        isTrue,
      );
    });

    test('maps input IGST ledger', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postPurchaseVoucher(
        purchaseData: {
          'id': 'P3',
          'supplierId': 'SUP1',
          'supplierName': 'Supplier',
          'createdAt': '2026-02-10T10:00:00.000',
          'subtotal': 100.0,
          'igstAmount': 18.0,
          'totalAmount': 118.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'INPUT_IGST',
        ),
        isTrue,
      );
    });

    test('posts positive round-off as debit', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postPurchaseVoucher(
        purchaseData: {
          'id': 'P4',
          'supplierId': 'SUP1',
          'supplierName': 'Supplier',
          'createdAt': '2026-02-10T10:00:00.000',
          'subtotal': 100.0,
          'totalAmount': 101.0,
          'roundOff': 1.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'ROUND_OFF' && row['debit'] == 1.0,
        ),
        isTrue,
      );
    });

    test('posts negative round-off as credit', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postPurchaseVoucher(
        purchaseData: {
          'id': 'P5',
          'supplierId': 'SUP1',
          'supplierName': 'Supplier',
          'createdAt': '2026-02-10T10:00:00.000',
          'subtotal': 100.0,
          'totalAmount': 99.0,
          'roundOff': -1.0,
        },
        postedByUserId: 'U1',
      );

      expect(
        vouchers.capturedEntries.any(
          (row) => row['accountCode'] == 'ROUND_OFF' && row['credit'] == 1.0,
        ),
        isTrue,
      );
    });

    test('throws in strict mode when year is locked', () async {
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: _FakeVoucherRepository(),
        financialYearService: _FakeFinancialYearService(locked: true),
        settingsService: _FakeSettingsService(true),
      );

      expect(
        () => posting.postPurchaseVoucher(
          purchaseData: {
            'id': 'P6',
            'supplierId': 'SUP1',
            'supplierName': 'Supplier',
            'createdAt': '2026-02-10T10:00:00.000',
            'subtotal': 100.0,
            'totalAmount': 100.0,
          },
          postedByUserId: 'U1',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('GST Ledger Mapping', () {
    test('maps output CGST code', () {
      expect(
        PostingService.gstLedgerCodeForComponent(
          component: 'cgst',
          isOutputTax: true,
        ),
        'OUTPUT_CGST',
      );
    });

    test('maps input IGST code', () {
      expect(
        PostingService.gstLedgerCodeForComponent(
          component: 'IGST',
          isOutputTax: false,
        ),
        'INPUT_IGST',
      );
    });

    test('throws for unsupported component', () {
      expect(
        () => PostingService.gstLedgerCodeForComponent(
          component: 'VAT',
          isOutputTax: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Trial Balance', () {
    test('is balanced when debits equal credits', () {
      final result = TrialBalanceService.calculateFromEntries([
        {
          'accountCode': 'A1',
          'accountName': 'Cash',
          'debit': 100.0,
          'credit': 0.0,
        },
        {
          'accountCode': 'A2',
          'accountName': 'Sales',
          'debit': 0.0,
          'credit': 100.0,
        },
      ]);

      expect(result.isBalanced, isTrue);
      expect(result.totalDebit, 100.0);
      expect(result.totalCredit, 100.0);
    });

    test('detects imbalance', () {
      final result = TrialBalanceService.calculateFromEntries([
        {
          'accountCode': 'A1',
          'accountName': 'Cash',
          'debit': 100.0,
          'credit': 0.0,
        },
        {
          'accountCode': 'A2',
          'accountName': 'Sales',
          'debit': 0.0,
          'credit': 99.0,
        },
      ]);

      expect(result.isBalanced, isFalse);
    });

    test('aggregates multiple rows by account', () {
      final result = TrialBalanceService.calculateFromEntries([
        {
          'accountCode': 'A1',
          'accountName': 'Cash',
          'debit': 50.0,
          'credit': 0.0,
        },
        {
          'accountCode': 'A1',
          'accountName': 'Cash',
          'debit': 70.0,
          'credit': 0.0,
        },
        {
          'accountCode': 'A2',
          'accountName': 'Sales',
          'debit': 0.0,
          'credit': 120.0,
        },
      ]);

      final cash = result.lines.firstWhere((row) => row.accountCode == 'A1');
      expect(cash.totalDebit, 120.0);
    });

    test('respects date range filters', () {
      final result = TrialBalanceService.calculateFromEntries(
        [
          {
            'accountCode': 'A1',
            'accountName': 'Cash',
            'debit': 100.0,
            'credit': 0.0,
            'postingDate': '2026-02-01T00:00:00.000',
          },
          {
            'accountCode': 'A2',
            'accountName': 'Sales',
            'debit': 0.0,
            'credit': 100.0,
            'postingDate': '2026-03-01T00:00:00.000',
          },
        ],
        fromDate: DateTime.parse('2026-02-15T00:00:00.000'),
        toDate: DateTime.parse('2026-03-15T00:00:00.000'),
      );

      expect(result.totalDebit, 0.0);
      expect(result.totalCredit, 100.0);
    });

    test('ignores deleted voucher entries', () {
      final result = TrialBalanceService.calculateFromEntries([
        {
          'accountCode': 'A1',
          'accountName': 'Cash',
          'debit': 100.0,
          'credit': 0.0,
          'isDeleted': true,
        },
        {
          'accountCode': 'A2',
          'accountName': 'Sales',
          'debit': 0.0,
          'credit': 100.0,
        },
      ]);

      expect(result.totalDebit, 0.0);
      expect(result.totalCredit, 100.0);
    });
  });

  group('Financial Year Helpers', () {
    test('returns previous-year start for March date', () {
      expect(
        FinancialYearService.financialYearIdForDate(DateTime(2026, 3, 31)),
        '2025-2026',
      );
    });

    test('returns current-year start for April date', () {
      expect(
        FinancialYearService.financialYearIdForDate(DateTime(2026, 4, 1)),
        '2026-2027',
      );
    });
  });

  group('Voucher Numbering', () {
    test('increments voucher numbers across transactions', () async {
      final vouchers = _FakeVoucherRepository();
      final posting = _buildPostingService(
        accountsRepository: _FakeAccountsRepository(),
        voucherRepository: vouchers,
        financialYearService: _FakeFinancialYearService(),
        settingsService: _FakeSettingsService(false),
      );

      await posting.postSalesVoucher(
        saleData: {
          'id': 'SX1',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Customer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 100.0,
          'taxableAmount': 100.0,
        },
        postedByUserId: 'U1',
      );
      final firstNumber = (vouchers.capturedVoucher?['voucherNumber'] ?? '')
          .toString();

      await posting.postSalesVoucher(
        saleData: {
          'id': 'SX2',
          'recipientType': 'customer',
          'recipientId': 'C1',
          'recipientName': 'Customer',
          'createdAt': '2026-02-10T10:00:00.000',
          'totalAmount': 100.0,
          'taxableAmount': 100.0,
        },
        postedByUserId: 'U1',
      );
      final secondNumber = (vouchers.capturedVoucher?['voucherNumber'] ?? '')
          .toString();

      expect(firstNumber, isNotEmpty);
      expect(secondNumber, isNotEmpty);
      expect(secondNumber, isNot(firstNumber));
    });
  });
}
