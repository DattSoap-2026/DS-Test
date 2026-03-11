import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:flutter_app/data/repositories/dealer_repository.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/data/local/entities/dealer_entity.dart';
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
  late DealerRepository repo;
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});

    // Create temp directory for this test suite
    tempDir = await Directory.systemTemp.createTemp('dealer_test_');

    // Create and init DB Service with temp dir
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    repo = DealerRepository(dbService);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    // Clear data before each test
    await dbService.db.writeTxn(() async {
      await dbService.dealers.clear();
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
    'saveDealer adds dealer and marks as pending',
    () async {
    final dealer = DealerEntity()
      ..id = const Uuid().v4()
      ..name = 'Test Dealer'
      ..contactPerson = 'John Doe'
      ..mobile = '1234567890'
      ..address = 'Test Address'
      ..status = 'active';

    await repo.saveDealer(dealer);

    final saved = await repo.getDealerById(dealer.id);
    expect(saved, isNotNull);
    expect(saved!.name, 'Test Dealer');
    expect(saved.syncStatus, SyncStatus.pending);
    expect(saved.updatedAt, isNotNull);
  },
    skip: _dbSkipReason ?? false,
  );

  test(
    'getAllDealers returns all dealers',
    () async {
    final d1 = DealerEntity()
      ..id = const Uuid().v4()
      ..name = 'Dealer 1'
      ..mobile = '1'
      ..address = 'a'
      ..contactPerson = 'c';
    final d2 = DealerEntity()
      ..id = const Uuid().v4()
      ..name = 'Dealer 2'
      ..mobile = '2'
      ..address = 'b'
      ..contactPerson = 'c';

    await repo.saveDealer(d1);
    await repo.saveDealer(d2);

    final all = await repo.getAllDealers();
    expect(all.length, 2);
  },
    skip: _dbSkipReason ?? false,
  );

  test(
    'deleteDealer (soft delete) marks as deleted',
    () async {
    final d1 = DealerEntity()
      ..id = const Uuid().v4()
      ..name = 'Delete Me'
      ..mobile = '1'
      ..address = 'a'
      ..contactPerson = 'c';
    await repo.saveDealer(d1);

    await repo.deleteDealer(d1.id);

    // Should NOT be returned by standard getters if they filter !isDeleted
    final all = await repo.getAllDealers();
    expect(all.isEmpty, true);

    // But should exist in DB with isDeleted = true
    final fromDb = await dbService.dealers
        .filter()
        .idEqualTo(d1.id)
        .findFirst();
    expect(fromDb, isNotNull);
    expect(fromDb!.isDeleted, true);
    expect(fromDb.syncStatus, SyncStatus.pending); // Should trigger sync
  },
    skip: _dbSkipReason ?? false,
  );
}
