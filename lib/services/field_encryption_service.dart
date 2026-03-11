import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';
import 'database_service.dart';

class FieldEncryptionService {
  static final FieldEncryptionService instance =
      FieldEncryptionService._internal();

  static const String _flagKey = 'field_encryption_enabled';
  static const String _migrationFlagKey = 'field_encryption_migrated_v1';
  static const String _migrationPayrollKey =
      'field_encryption_migrated_v1_payroll';
  static const String _migrationAttendanceKey =
      'field_encryption_migrated_v1_attendance';
  static const String _migrationCustomersKey =
      'field_encryption_migrated_v1_customers';
  static const String _migrationProductsKey =
      'field_encryption_migrated_v1_products';
  static const String _keyStorageKey = 'field_encryption_key_v1';
  static const String _cipherPrefix = 'enc:v1:';
  static const int _keyLength = 32;
  static const int _nonceLength = 16;
  static const int _macLength = 32;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Random _random = Random.secure();

  bool _initialized = false;
  bool _enabled = false;
  Uint8List? _key;
  bool _migrationInProgress = false;

  FieldEncryptionService._internal();

  bool get isEnabled => _enabled;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final existingFlag = prefs.getBool(_flagKey);
      if (existingFlag != null) {
        _enabled = existingFlag;
      } else {
        final hasExistingDb = await _hasExistingDb();
        _enabled = !hasExistingDb;
        await prefs.setBool(_flagKey, _enabled);
      }

      _key = await _loadOrCreateKey();
      _initialized = true;
    } catch (e) {
      AppLogger.error('Field encryption init failed', error: e);
      _enabled = false;
      _initialized = true;
    }
  }

  Future<void> scheduleMigration(DatabaseService dbService) async {
    if (!_initialized) return;
    if (!_enabled) return;

    // Run migration asynchronously to avoid blocking cold start.
    Future<void>(() async {
      await _migrateIfNeeded(dbService);
    });
  }

  Future<void> _migrateIfNeeded(DatabaseService dbService) async {
    if (_migrationInProgress) return;
    _migrationInProgress = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final migratedAll = prefs.getBool(_migrationFlagKey) ?? false;
      if (migratedAll) return;

      await _runMigration(
        prefs,
        _migrationPayrollKey,
        () => _migratePayroll(dbService),
      );
      await _runMigration(
        prefs,
        _migrationAttendanceKey,
        () => _migrateAttendance(dbService),
      );
      await _runMigration(
        prefs,
        _migrationCustomersKey,
        () => _migrateCustomers(dbService),
      );
      await _runMigration(
        prefs,
        _migrationProductsKey,
        () => _migrateProducts(dbService),
      );

      final allDone =
          (prefs.getBool(_migrationPayrollKey) ?? false) &&
          (prefs.getBool(_migrationAttendanceKey) ?? false) &&
          (prefs.getBool(_migrationCustomersKey) ?? false) &&
          (prefs.getBool(_migrationProductsKey) ?? false);
      if (allDone) {
        await prefs.setBool(_migrationFlagKey, true);
        AppLogger.success('Field encryption migration complete');
      }
    } catch (e) {
      AppLogger.error('Field encryption migration failed', error: e);
    } finally {
      _migrationInProgress = false;
    }
  }

  Future<void> _runMigration(
    SharedPreferences prefs,
    String key,
    Future<void> Function() action,
  ) async {
    final done = prefs.getBool(key) ?? false;
    if (done) return;
    try {
      await action();
      await prefs.setBool(key, true);
    } catch (e) {
      AppLogger.error('Field encryption migration failed: $key', error: e);
    }
  }

  Future<void> _migratePayroll(DatabaseService dbService) async {
    final records = await dbService.payrollRecords.where().findAll();
    if (records.isEmpty) return;

    await dbService.db.writeTxn(() async {
      for (final record in records) {
        record.baseSalary = encryptDouble(
          record.baseSalary,
          _ctx('payroll', record.employeeId, record.month, 'baseSalary'),
          magnitude: 1e5,
        );
        record.totalHours = encryptDouble(
          record.totalHours,
          _ctx('payroll', record.employeeId, record.month, 'totalHours'),
          magnitude: 1e3,
        );
        record.totalOvertimeHours = encryptDouble(
          record.totalOvertimeHours,
          _ctx('payroll', record.employeeId, record.month, 'totalOvertimeHours'),
          magnitude: 1e3,
        );
        record.bonuses = encryptDouble(
          record.bonuses,
          _ctx('payroll', record.employeeId, record.month, 'bonuses'),
          magnitude: 1e5,
        );
        record.deductions = encryptDouble(
          record.deductions,
          _ctx('payroll', record.employeeId, record.month, 'deductions'),
          magnitude: 1e5,
        );
        record.netSalary = encryptDouble(
          record.netSalary,
          _ctx('payroll', record.employeeId, record.month, 'netSalary'),
          magnitude: 1e5,
        );
        if (record.paymentReference != null) {
          record.paymentReference = encryptString(
            record.paymentReference!,
            _ctx('payroll', record.employeeId, record.month, 'paymentRef'),
          );
        }
        await dbService.payrollRecords.put(record);
      }
    });
  }

  Future<void> _migrateAttendance(DatabaseService dbService) async {
    final records = await dbService.attendances.where().findAll();
    if (records.isEmpty) return;

    await dbService.db.writeTxn(() async {
      for (final record in records) {
        if (record.checkInLatitude != null) {
          record.checkInLatitude = encryptDouble(
            record.checkInLatitude!,
            _ctx('attendance', record.id, record.date, 'checkInLat'),
            magnitude: 1.0,
          );
        }
        if (record.checkInLongitude != null) {
          record.checkInLongitude = encryptDouble(
            record.checkInLongitude!,
            _ctx('attendance', record.id, record.date, 'checkInLng'),
            magnitude: 1.0,
          );
        }
        if (record.checkOutLatitude != null) {
          record.checkOutLatitude = encryptDouble(
            record.checkOutLatitude!,
            _ctx('attendance', record.id, record.date, 'checkOutLat'),
            magnitude: 1.0,
          );
        }
        if (record.checkOutLongitude != null) {
          record.checkOutLongitude = encryptDouble(
            record.checkOutLongitude!,
            _ctx('attendance', record.id, record.date, 'checkOutLng'),
            magnitude: 1.0,
          );
        }
        if (record.remarks != null) {
          record.remarks = encryptString(
            record.remarks!,
            _ctx('attendance', record.id, record.date, 'remarks'),
          );
        }
        await dbService.attendances.put(record);
      }
    });
  }

  Future<void> _migrateCustomers(DatabaseService dbService) async {
    final records = await dbService.customers.where().findAll();
    if (records.isEmpty) return;

    await dbService.db.writeTxn(() async {
      for (final record in records) {
        record.mobile = encryptString(
          record.mobile,
          _ctx('customer', record.id, null, 'mobile'),
        );
        if (record.alternateMobile != null) {
          record.alternateMobile = encryptString(
            record.alternateMobile!,
            _ctx('customer', record.id, null, 'altMobile'),
          );
        }
        if (record.email != null) {
          record.email = encryptString(
            record.email!,
            _ctx('customer', record.id, null, 'email'),
          );
        }
        record.address = encryptString(
          record.address,
          _ctx('customer', record.id, null, 'address'),
        );
        if (record.addressLine2 != null) {
          record.addressLine2 = encryptString(
            record.addressLine2!,
            _ctx('customer', record.id, null, 'address2'),
          );
        }
        if (record.city != null) {
          record.city = encryptString(
            record.city!,
            _ctx('customer', record.id, null, 'city'),
          );
        }
        if (record.state != null) {
          record.state = encryptString(
            record.state!,
            _ctx('customer', record.id, null, 'state'),
          );
        }
        if (record.pincode != null) {
          record.pincode = encryptString(
            record.pincode!,
            _ctx('customer', record.id, null, 'pincode'),
          );
        }
        if (record.gstin != null) {
          record.gstin = encryptString(
            record.gstin!,
            _ctx('customer', record.id, null, 'gstin'),
          );
        }
        if (record.pan != null) {
          record.pan = encryptString(
            record.pan!,
            _ctx('customer', record.id, null, 'pan'),
          );
        }
        await dbService.customers.put(record);
      }
    });
  }

  Future<void> _migrateProducts(DatabaseService dbService) async {
    final records = await dbService.products.where().findAll();
    if (records.isEmpty) return;

    await dbService.db.writeTxn(() async {
      for (final record in records) {
        if (record.price != null) {
          record.price = encryptDouble(
            record.price!,
            _ctx('product', record.id, null, 'price'),
            magnitude: 1e5,
          );
        }
        if (record.secondaryPrice != null) {
          record.secondaryPrice = encryptDouble(
            record.secondaryPrice!,
            _ctx('product', record.id, null, 'secondaryPrice'),
            magnitude: 1e5,
          );
        }
        if (record.mrp != null) {
          record.mrp = encryptDouble(
            record.mrp!,
            _ctx('product', record.id, null, 'mrp'),
            magnitude: 1e5,
          );
        }
        if (record.purchasePrice != null) {
          record.purchasePrice = encryptDouble(
            record.purchasePrice!,
            _ctx('product', record.id, null, 'purchasePrice'),
            magnitude: 1e5,
          );
        }
        if (record.averageCost != null) {
          record.averageCost = encryptDouble(
            record.averageCost!,
            _ctx('product', record.id, null, 'averageCost'),
            magnitude: 1e5,
          );
        }
        if (record.lastCost != null) {
          record.lastCost = encryptDouble(
            record.lastCost!,
            _ctx('product', record.id, null, 'lastCost'),
            magnitude: 1e5,
          );
        }
        if (record.internalCost != null) {
          record.internalCost = encryptDouble(
            record.internalCost!,
            _ctx('product', record.id, null, 'internalCost'),
            magnitude: 1e5,
          );
        }
        await dbService.products.put(record);
      }
    });
  }

  String encryptString(String value, String context) {
    if (!_enabled) return value;
    if (value.isEmpty) return value;
    if (!_initialized || _key == null) return value;
    if (_isEncrypted(value)) return value;

    final nonce = _randomBytes(_nonceLength);
    final plaintext = utf8.encode(value);
    final keystream = _keystream(context, nonce, plaintext.length);
    final cipher = _xorBytes(plaintext, keystream);
    final mac = _hmacSha256(_key!, _macData(context, nonce, cipher));

    final payload = BytesBuilder()
      ..add(nonce)
      ..add(cipher)
      ..add(mac);
    return '$_cipherPrefix${base64UrlEncode(payload.toBytes())}';
  }

  String decryptString(String value, String context) {
    if (!_enabled) return value;
    if (!_initialized || _key == null) return value;
    if (!_isEncrypted(value)) return value;

    try {
      final encoded = value.substring(_cipherPrefix.length);
      final payload = base64Url.decode(encoded);
      if (payload.length <= _nonceLength + _macLength) {
        return value;
      }
      final nonce = payload.sublist(0, _nonceLength);
      final mac = payload.sublist(payload.length - _macLength);
      final cipher = payload.sublist(_nonceLength, payload.length - _macLength);

      final expectedMac = _hmacSha256(_key!, _macData(context, nonce, cipher));
      if (!_constantTimeEquals(mac, expectedMac)) {
        return value;
      }

      final keystream = _keystream(context, nonce, cipher.length);
      final plaintext = _xorBytes(cipher, keystream);
      return utf8.decode(plaintext, allowMalformed: true);
    } catch (_) {
      return value;
    }
  }

  double encryptDouble(
    double value,
    String context, {
    double magnitude = 1e5,
  }) {
    if (!_enabled) return value;
    if (!_initialized || _key == null) return value;
    final mask = _doubleMask(context, magnitude);
    return value + mask;
  }

  double decryptDouble(
    double value,
    String context, {
    double magnitude = 1e5,
  }) {
    if (!_enabled) return value;
    if (!_initialized || _key == null) return value;
    final mask = _doubleMask(context, magnitude);
    return value - mask;
  }

  Future<bool> _hasExistingDb() async {
    final dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) return false;
    final entries = dir.listSync();
    for (final entry in entries) {
      final base = entry.uri.pathSegments.last;
      if (base.startsWith('dattsoap') || base.startsWith('isar')) {
        return true;
      }
    }
    final file = File('${dir.path}${Platform.pathSeparator}dattsoap.isar');
    return file.existsSync();
  }

  Future<Uint8List> _loadOrCreateKey() async {
    final existing = await _secureStorage.read(key: _keyStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Url.decode(existing));
    }

    final bytes = List<int>.generate(
      _keyLength,
      (_) => _random.nextInt(256),
    );
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64UrlEncode(bytes),
    );
    return Uint8List.fromList(bytes);
  }

  Uint8List _hmacSha256(Uint8List key, List<int> data) {
    final hmac = Hmac(sha256, key);
    return Uint8List.fromList(hmac.convert(data).bytes);
  }

  List<int> _macData(String context, List<int> nonce, List<int> cipher) {
    final contextBytes = utf8.encode(context);
    return <int>[...contextBytes, ...nonce, ...cipher];
  }

  Uint8List _keystream(String context, List<int> nonce, int length) {
    final contextBytes = utf8.encode(context);
    final output = BytesBuilder();
    var counter = 0;
    while (output.length < length) {
      final counterBytes = ByteData(4)
        ..setUint32(0, counter, Endian.little);
      final block = _hmacSha256(
        _key!,
        <int>[
          ...contextBytes,
          ...nonce,
          ...counterBytes.buffer.asUint8List(),
        ],
      );
      output.add(block);
      counter += 1;
    }
    final bytes = output.toBytes();
    return bytes.length == length ? bytes : bytes.sublist(0, length);
  }

  Uint8List _xorBytes(List<int> a, List<int> b) {
    final len = a.length;
    final out = Uint8List(len);
    for (var i = 0; i < len; i++) {
      out[i] = a[i] ^ b[i];
    }
    return out;
  }

  Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  double _doubleMask(String context, double magnitude) {
    final bytes = _hmacSha256(_key!, utf8.encode('mask:$context'));
    final bd = ByteData.sublistView(bytes);
    final int64 = bd.getInt64(0, Endian.little);
    final normalized = int64 / 0x7FFFFFFFFFFFFFFF;
    return normalized * magnitude;
  }

  bool _isEncrypted(String value) => value.startsWith(_cipherPrefix);

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  String _ctx(String domain, String id, String? scope, String field) {
    if (scope == null || scope.isEmpty) {
      return '$domain:$id:$field';
    }
    return '$domain:$id:$scope:$field';
  }
}
