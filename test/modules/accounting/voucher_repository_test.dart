import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/modules/accounting/voucher_repository.dart';

class _InMemoryVoucherRepository extends VoucherRepository {
  _InMemoryVoucherRepository() : super(FirebaseServices());

  final List<Map<String, dynamic>> _localVouchers = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> loadFromLocal() async {
    return _localVouchers
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  @override
  Future<void> saveToLocal(List<Map<String, dynamic>> items) async {
    _localVouchers
      ..clear()
      ..addAll(items.map((item) => Map<String, dynamic>.from(item)));
  }

  @override
  Future<List<Map<String, dynamic>>> bootstrapFromFirebase({
    required String collectionName,
  }) async {
    return [];
  }

  @override
  Future<void> syncToFirebase(
    String action,
    Map<String, dynamic> data, {
    String? collectionName,
    bool syncImmediately = true,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'prevents duplicate vouchers for same transactionRefId + transactionType',
    () async {
      final repo = _InMemoryVoucherRepository();
      final entries = [
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
      ];

      final firstId = await repo.createVoucherBundle(
        voucher: {
          'transactionRefId': 'TX-1',
          'transactionType': 'sales',
          'voucherType': 'sales',
          'date': DateTime(2026, 2, 1).toIso8601String(),
        },
        entries: entries,
        strictMode: false,
      );

      final secondId = await repo.createVoucherBundle(
        voucher: {
          'transactionRefId': 'TX-1',
          'transactionType': 'sales',
          'voucherType': 'sales',
          'date': DateTime(2026, 2, 1).toIso8601String(),
        },
        entries: entries,
        strictMode: false,
      );

      final vouchers = await repo.getVouchers();
      final savedEntries = await repo.getVoucherEntries();

      expect(firstId, 'TX-1');
      expect(secondId, 'TX-1');
      expect(vouchers.length, 1);
      expect(savedEntries.length, 2);
    },
  );

  test(
    'throws on conflicting transactionType for same transactionRefId',
    () async {
      final repo = _InMemoryVoucherRepository();
      final entries = [
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
      ];

      await repo.createVoucherBundle(
        voucher: {
          'transactionRefId': 'TX-2',
          'transactionType': 'sales',
          'voucherType': 'sales',
          'date': DateTime(2026, 2, 1).toIso8601String(),
        },
        entries: entries,
        strictMode: false,
      );

      expect(
        () => repo.createVoucherBundle(
          voucher: {
            'transactionRefId': 'TX-2',
            'transactionType': 'purchase',
            'voucherType': 'purchase',
            'date': DateTime(2026, 2, 1).toIso8601String(),
          },
          entries: entries,
          strictMode: false,
        ),
        throwsA(isA<StateError>()),
      );
    },
  );
}
