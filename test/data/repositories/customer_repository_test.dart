import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:flutter_app/data/repositories/customer_repository.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:ffi';

const bool _runDbTests = bool.fromEnvironment(
  'RUN_DB_TESTS',
  defaultValue: false,
);

String? _detectDbSkipReason() {
  if (!_runDbTests) {
    return 'Requires Isar native library. Run with --dart-define=RUN_DB_TESTS=true';
  }

  if (Platform.isWindows) {
    final dllPath = '${Directory.current.path}${Platform.pathSeparator}isar.dll';
    try {
      DynamicLibrary.open(dllPath);
    } catch (e) {
      return 'RUN_DB_TESTS=true but Isar native library is unavailable: $e';
    }
  }

  return null;
}

final String? _dbSkipReason = _detectDbSkipReason();
bool get _shouldSkipDbTests => _dbSkipReason != null;

void main() {
  late DatabaseService dbService;
  late CustomerRepository repo;
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});

    // Create temp directory for this test suite
    tempDir = await Directory.systemTemp.createTemp('customer_test_');

    // Create and init DB Service with temp dir
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    repo = CustomerRepository(dbService);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    // Clear data before each test
    await dbService.db.writeTxn(() async {
      await dbService.customers.clear();
    });
  });

  tearDownAll(() async {
    if (_shouldSkipDbTests) return;
    await dbService.db.close();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  test(
    'saveCustomer adds customer and marks as pending',
    () async {
    final customer = CustomerEntity()
      ..id = const Uuid().v4()
      ..shopName = 'Test Shop'
      ..ownerName = 'Test Owner'
      ..mobile = '1234567890'
      ..address = 'Test Address'
      ..route = 'Test Route'
      ..status = 'active';

    await repo.saveCustomer(customer);

    final saved = await repo.getCustomerById(customer.id);
    expect(saved, isNotNull);
    expect(saved!.shopName, 'Test Shop');
    expect(saved.syncStatus, SyncStatus.pending);
    expect(saved.updatedAt, isNotNull);
  },
    skip: _dbSkipReason ?? false,
  );

  test(
    'getAllCustomers returns all customers',
    () async {
    final c1 = CustomerEntity()
      ..id = const Uuid().v4()
      ..shopName = 'Shop 1'
      ..mobile = '1'
      ..address = 'a'
      ..route = 'r'
      ..ownerName = 'o';
    final c2 = CustomerEntity()
      ..id = const Uuid().v4()
      ..shopName = 'Shop 2'
      ..mobile = '2'
      ..address = 'b'
      ..route = 'r'
      ..ownerName = 'o';

    await repo.saveCustomer(c1);
    await repo.saveCustomer(c2);

    final all = await repo.getAllCustomers();
    expect(all.length, 2);
  },
    skip: _dbSkipReason ?? false,
  );

  test(
    'searchCustomers filters by name',
    () async {
    final c1 = CustomerEntity()
      ..id = const Uuid().v4()
      ..shopName = 'Alpha Shop'
      ..mobile = '1'
      ..address = 'a'
      ..route = 'r'
      ..ownerName = 'o';
    final c2 = CustomerEntity()
      ..id = const Uuid().v4()
      ..shopName = 'Beta Store'
      ..mobile = '2'
      ..address = 'b'
      ..route = 'r'
      ..ownerName = 'o';

    await repo.saveCustomer(c1);
    await repo.saveCustomer(c2);

    final results = await repo.searchCustomers('Alpha');
    expect(results.length, 1);
    expect(results.first.shopName, 'Alpha Shop');
  },
    skip: _dbSkipReason ?? false,
  );

  test(
    'deleteCustomer (soft delete) marks as deleted',
    () async {
    final c1 = CustomerEntity()
      ..id = const Uuid().v4()
      ..shopName = 'Delete Me'
      ..mobile = '1'
      ..address = 'a'
      ..route = 'r'
      ..ownerName = 'o';
    await repo.saveCustomer(c1);

    await repo.deleteCustomer(c1.id);

    // Should NOT be returned by standard getters if they filter !isDeleted
    final all = await repo.getAllCustomers();
    expect(all.isEmpty, true);

    // But should exist in DB with isDeleted = true
    final fromDb = await dbService.customers
        .filter()
        .idEqualTo(c1.id)
        .findFirst();
    expect(fromDb, isNotNull);
    expect(fromDb!.isDeleted, true);
    expect(fromDb.syncStatus, SyncStatus.pending); // Should trigger sync
  },
    skip: _dbSkipReason ?? false,
  );
}
