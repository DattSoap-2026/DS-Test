import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../services/offline_first_service.dart';
import '../../../services/database_service.dart';
import '../../../services/duty_service.dart';
import '../../../core/firebase/firebase_config.dart';
import '../../../modules/accounting/posting_service.dart';
import '../../../services/mixins/safe_voucher_posting_mixin.dart';
import 'hr_service.dart';
import 'advance_service.dart';
import '../models/employee_model.dart';
import '../models/payroll_record_model.dart';
import '../models/attendance_model.dart';
import '../../../data/local/entities/advance_entity.dart';
import '../../../data/local/entities/attendance_entity.dart';
import '../../../data/local/entities/duty_session_entity.dart';
import '../../../data/local/entities/payroll_record_entity.dart';
import '../../../data/local/base_entity.dart';
import '../../../modules/hr/services/payroll_calculator.dart';
import '../../../services/field_encryption_service.dart';
import './holiday_service.dart';

class PayrollService extends OfflineFirstService with ChangeNotifier, SafeVoucherPostingMixin {
  final HrService _hrService;
  final DatabaseService _dbService;
  final AdvanceService _advanceService;
  final FieldEncryptionService _fieldEncryption =
      FieldEncryptionService.instance;
  late final PostingService _postingService;

  @override
  PostingService? get postingService => _postingService;

  static const double _salaryMagnitude = 1e5;
  static const double _hoursMagnitude = 1e3;

  PayrollService(
    super.firebaseServices,
    DutyService _unusedDutyService,
    this._hrService,
    this._dbService,
    this._advanceService,
  ) {
    _postingService = PostingService(firebaseServices);
  }

  @override
  String get localStorageKey => 'local_payroll';

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final firestore = db;
    if (firestore == null) return;

    // Use default impl for now, unless we need transactions (e.g. updating budget?)
    // Default impl handles add/set/update/delete basic CRUD
    await super.performSync(action, collection, data);
  }

  /// Generates (or updates) payroll records for a specific month.
  /// [month] should be a DateTime representing the month (e.g., 2024-02-01).
  Future<void> generatePayrollForMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final totalDaysInMonth = lastDay.day;
      final endOfMonth = DateTime(
        lastDay.year,
        lastDay.month,
        lastDay.day,
        23,
        59,
        59,
      );

      final monthStr =
          "${month.year}-${month.month.toString().padLeft(2, '0')}";
      final startStr =
          '${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-01';
      final endStr =
          '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';

      // 1. Fetch All Employees
      final rawEmployees = await _hrService.getAllEmployees();
      final employees = _dedupeEmployees(rawEmployees)
          .where((emp) => _isEmployeeActiveForMonth(emp, startOfMonth, endOfMonth))
          .toList();
      if (employees.isEmpty) {
        notifyListeners();
        return;
      }

      final linkedUserIds = employees
          .map((e) => e.linkedUserId?.trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final holidayService = HolidayService(firebaseServices, _dbService);
      final holidays = await holidayService.getHolidaysForMonth(
        startOfMonth.year,
        startOfMonth.month,
      );

      final dutySessionEntities = await _dbService.dutySessions
          .filter()
          .statusEqualTo('completed')
          .and()
          .loginTimeBetween(
            startOfMonth.toIso8601String(),
            endOfMonth.toIso8601String(),
            includeLower: true,
            includeUpper: true,
          )
          .findAll();

      final sessionsByUserId = <String, List<DutySession>>{};
      for (final entity in dutySessionEntities) {
        final userId = entity.userId.trim();
        if (!linkedUserIds.contains(userId)) continue;
        sessionsByUserId.putIfAbsent(userId, () => <DutySession>[]).add(
          entity.toDomain(),
        );
      }

      final monthAttendances = await _dbService.attendances
          .filter()
          .dateBetween(startStr, endStr)
          .findAll();
      final attendancesByEmployee = <String, List<AttendanceEntity>>{};
      for (final entry in monthAttendances) {
        final employeeId = entry.employeeId.trim();
        if (employeeId.isEmpty) continue;
        attendancesByEmployee.putIfAbsent(employeeId, () => <AttendanceEntity>[])
            .add(entry);
      }

      final monthAdvances = await _dbService.advances.where().findAll();
      final advancesByEmployee = <String, List<AdvanceEntity>>{};
      for (final advance in monthAdvances) {
        if (advance.isDeleted) continue;
        final employeeId = advance.employeeId.trim();
        if (employeeId.isEmpty) continue;
        advancesByEmployee.putIfAbsent(employeeId, () => <AdvanceEntity>[])
            .add(advance);
      }

      final existingRecords = await _dbService.payrollRecords
          .filter()
          .monthEqualTo(monthStr)
          .and()
          .isDeletedEqualTo(false)
          .findAll();
      final existingByEmployee = _pickLatestRecordPerEmployee(existingRecords);

      for (var emp in employees) {
        // 2. Fetch Sessions if user is linked (Drivers/Salesmen)
        final linkedUserId = emp.linkedUserId?.trim() ?? '';
        final sessions = linkedUserId.isEmpty
            ? const <DutySession>[]
            : (sessionsByUserId[linkedUserId] ?? const <DutySession>[]);

        // 3. Fetch Attendance Records for this employee/month
        final attendanceEntities =
            attendancesByEmployee[emp.employeeId] ?? const <AttendanceEntity>[];

        // Convert attendance entities to domain models for calculator
        // Use a dummy AttendanceService internal mapper if needed,
        // or just map manually for speed (calculator needs domain model).
        final attendances = attendanceEntities.map((e) {
          // Decrypt sensitive fields for calculation
          return Attendance(
            id: e.id,
            employeeId: e.employeeId,
            date: DateTime.parse(e.date),
            status: e.status,
            checkInTime: e.checkInTime != null ? DateTime.parse(e.checkInTime!) : null,
            checkOutTime: e.checkOutTime != null ? DateTime.parse(e.checkOutTime!) : null,
            isOvertime: e.isOvertime,
            overtimeHours: e.overtimeHours,
            updatedAt: e.updatedAt,
          );
        }).toList();

        // 4. Calculate using helper
        final result = await PayrollCalculator.calculate(
          employee: emp,
          sessions: sessions,
          attendances: attendances,
          totalDaysInMonth: totalDaysInMonth,
          month: startOfMonth,
          holidays: holidays,
          advanceService: _advanceService,
        );

        final totalHours = result.totalHours;
        final totalOvertimeHours = result.totalOvertimeHours;
        final baseSalarySnapshot = result.baseSalarySnapshot;
        final emiDeduction = result.emiDeduction;
        final tdsDeduction = result.tdsDeduction;
        final netSalary = result.netSalary;

        Map<String, dynamic> syncData = {};
        String action = '';
        String recordId = '';

        // 5. Create or update record
        final existing = existingByEmployee[emp.employeeId];

        if (existing != null) {
          _decryptPayrollEntity(existing);
          if (existing.status == 'Draft') {
            final now = DateTime.now();
            existing.totalHours = totalHours;
            existing.totalOvertimeHours = totalOvertimeHours;
            existing.baseSalary = baseSalarySnapshot;
            existing.generatedAt = now;
            existing.updatedAt = now;
            existing.syncStatus = SyncStatus.pending;
            existing.deductions = emiDeduction + tdsDeduction;
            existing.netSalary = netSalary + existing.bonuses;

            final syncNetSalary = existing.netSalary;
            _encryptPayrollEntity(existing);
            await _dbService.db.writeTxn(() async {
              await _dbService.payrollRecords.put(existing);
            });

            recordId = existing.id;
            action = 'update';
            syncData = {
              'id': recordId,
              'employeeId': emp.employeeId,
              'month': monthStr,
              'generatedAt': existing.generatedAt.toIso8601String(),
              'totalHours': totalHours,
              'totalOvertimeHours': totalOvertimeHours,
              'baseSalary': baseSalarySnapshot,
              'bonuses': existing.bonuses,
              'deductions': emiDeduction + tdsDeduction,
              'netSalary': syncNetSalary,
              'status': existing.status,
            };
          }
        } else {
          final now = DateTime.now();
          final record = PayrollRecordEntity()
            ..id = _recordId(emp.employeeId, monthStr)
            ..employeeId = emp.employeeId
            ..month = monthStr
            ..generatedAt = now
            ..totalHours = totalHours
            ..baseSalary = baseSalarySnapshot
            ..totalOvertimeHours = totalOvertimeHours
            ..bonuses = 0.0
            ..deductions = emiDeduction + tdsDeduction
            ..netSalary = netSalary
            ..status = 'Draft'
            ..updatedAt = now
            ..syncStatus = SyncStatus.pending;

          _encryptPayrollEntity(record);
          await _dbService.db.writeTxn(() async {
            await _dbService.payrollRecords.put(record);
          });

          recordId = record.id;
          action = 'set';
          syncData = {
            'id': recordId,
            'employeeId': emp.employeeId,
            'month': monthStr,
            'generatedAt': record.generatedAt.toIso8601String(),
            'totalHours': totalHours,
            'totalOvertimeHours': totalOvertimeHours,
            'baseSalary': baseSalarySnapshot,
            'bonuses': 0.0,
            'deductions': emiDeduction + tdsDeduction,
            'netSalary': netSalary,
            'status': 'Draft',
          };
        }

        if (action.isNotEmpty) {
          syncToFirebase(
            action,
            syncData,
            collectionName: 'payroll_records',
            syncImmediately: false,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      handleError(e, 'generatePayrollForMonth');
      rethrow;
    }
  }

  Future<List<PayrollRecord>> getPayrolls(DateTime month) async {
    try {
      final monthStr =
          "${month.year}-${month.month.toString().padLeft(2, '0')}";

      final entities = await _dbService.payrollRecords
          .filter()
          .monthEqualTo(monthStr)
          .and()
          .isDeletedEqualTo(false)
          .findAll();

      final employees = _dedupeEmployees(await _hrService.getAllEmployees());
      final employeeNameById = <String, String>{
        for (final emp in employees)
          emp.employeeId: emp.name,
      };

      final latestByEmployee = _pickLatestRecordPerEmployee(entities);

      // Hydrate names
      final records = <PayrollRecord>[];
      for (final e in latestByEmployee.values) {
        final domain = _toDomain(e);
        final employeeName = employeeNameById[e.employeeId];
        if (employeeName != null && employeeName.trim().isNotEmpty) {
          domain.setEmployeeName(employeeName);
        }
        records.add(domain);
      }
      records.sort((a, b) => a.employeeName.compareTo(b.employeeName));
      return records;
    } catch (e) {
      handleError(e, 'getPayrolls');
      return [];
    }
  }

  Future<void> updateStatus(String id, String newStatus, {String? ref}) async {
    DateTime? paidAt;
    var found = false;
    String employeeId = '';
    String employeeName = '';
    double netSalary = 0.0;
    String month = '';

    await _dbService.db.writeTxn(() async {
      final record = await _dbService.payrollRecords
          .filter()
          .idEqualTo(id)
          .findFirst();

      if (record != null) {
        found = true;
        _decryptPayrollEntity(record);
        record.updatedAt = DateTime.now();
        record.syncStatus = SyncStatus.pending;
        record.status = newStatus;
        if (newStatus == 'Paid') {
          paidAt = DateTime.now();
          record.paidAt = paidAt;
          record.paymentReference = ref ?? '';
          
          // Store for voucher posting
          employeeId = record.employeeId;
          netSalary = record.netSalary;
          month = record.month;
        } else if (newStatus != 'Paid') {
          record.paidAt = null;
          record.paymentReference = null;
        }
        _encryptPayrollEntity(record);
        await _dbService.payrollRecords.put(record);

        final updates = {
          'id': id,
          'status': newStatus,
          if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
          if (ref != null) 'paymentReference': ref,
        };

        syncToFirebase('update', updates, collectionName: 'payroll_records');
      }
    });
    if (!found) {
      throw Exception('Payroll record not found');
    }

    // Auto-post salary payment voucher
    if (newStatus == 'Paid' && employeeId.isNotEmpty && netSalary > 0) {
      final employee = await _hrService.getEmployee(employeeId);
      employeeName = employee?.name ?? 'Employee';
      await _postSalaryPaymentVoucher(
        payrollRecordId: id,
        employeeId: employeeId,
        employeeName: employeeName,
        netSalary: netSalary,
        month: month,
        paymentReference: ref,
        paidAt: paidAt!,
      );
    }

    notifyListeners();
  }

  Future<void> _postSalaryPaymentVoucher({
    required String payrollRecordId,
    required String employeeId,
    required String employeeName,
    required double netSalary,
    required String month,
    String? paymentReference,
    required DateTime paidAt,
  }) async {
    await safePostVoucher((service) async {
      final auth = firebaseServices.auth;
      if (auth == null) return;
      final currentUser = auth.currentUser;
      if (currentUser == null) return;
      
      await service.createManualVoucher(
        voucherType: 'payment',
        transactionRefId: payrollRecordId,
        date: paidAt,
        entries: [
          {
            'accountCode': 'SALARY_EXPENSE',
            'accountName': 'Salary Expense',
            'debit': netSalary,
            'credit': 0,
            'narration': 'Salary payment for $employeeName - $month',
          },
          {
            'accountCode': 'CASH_IN_HAND',
            'accountName': 'Cash in Hand',
            'debit': 0,
            'credit': netSalary,
            'narration': 'Payment to $employeeName${paymentReference != null ? " (Ref: $paymentReference)" : ""}',
          },
        ],
        postedByUserId: currentUser.uid,
        narration: 'Salary Payment - $employeeName ($month)',
        partyName: employeeName,
      );
    });
  }

  PayrollRecord _toDomain(PayrollRecordEntity e) {
    return PayrollRecord(
      id: e.id.toString(),
      employeeId: e.employeeId,
      month: e.month,
      generatedAt: e.generatedAt,
      totalHours: _decryptPayrollDouble(
        e,
        'totalHours',
        e.totalHours,
        magnitude: _hoursMagnitude,
      ),
      baseSalary: _decryptPayrollDouble(
        e,
        'baseSalary',
        e.baseSalary,
        magnitude: _salaryMagnitude,
      ),
      totalOvertimeHours: _decryptPayrollDouble(
        e,
        'totalOvertimeHours',
        e.totalOvertimeHours,
        magnitude: _hoursMagnitude,
      ),
      bonuses: _decryptPayrollDouble(
        e,
        'bonuses',
        e.bonuses,
        magnitude: _salaryMagnitude,
      ),
      deductions: _decryptPayrollDouble(
        e,
        'deductions',
        e.deductions,
        magnitude: _salaryMagnitude,
      ),
      emiDeduction: 0.0,
      tdsDeduction: 0.0,
      grossSalary: _decryptPayrollDouble(
        e,
        'netSalary',
        e.netSalary,
        magnitude: _salaryMagnitude,
      ),
      netSalary: _decryptPayrollDouble(
        e,
        'netSalary',
        e.netSalary,
        magnitude: _salaryMagnitude,
      ),
      status: e.status,
      paymentReference: e.paymentReference == null
          ? null
          : _fieldEncryption.decryptString(
              e.paymentReference!,
              _payrollCtx(e, 'paymentRef'),
            ),
      paidAt: e.paidAt,
    );
  }

  String _payrollCtx(PayrollRecordEntity e, String field) {
    return 'payroll:${e.employeeId}:${e.month}:$field';
  }

  String _recordId(String employeeId, String month) => '${employeeId}_$month';

  double _decryptPayrollDouble(
    PayrollRecordEntity e,
    String field,
    double value, {
    double magnitude = _salaryMagnitude,
  }) {
    if (!_fieldEncryption.isEnabled) return value;
    return _fieldEncryption.decryptDouble(
      value,
      _payrollCtx(e, field),
      magnitude: magnitude,
    );
  }

  void _decryptPayrollEntity(PayrollRecordEntity e) {
    if (!_fieldEncryption.isEnabled) return;
    e.totalHours = _decryptPayrollDouble(
      e,
      'totalHours',
      e.totalHours,
      magnitude: _hoursMagnitude,
    );
    e.baseSalary = _decryptPayrollDouble(
      e,
      'baseSalary',
      e.baseSalary,
      magnitude: _salaryMagnitude,
    );
    e.totalOvertimeHours = _decryptPayrollDouble(
      e,
      'totalOvertimeHours',
      e.totalOvertimeHours,
      magnitude: _hoursMagnitude,
    );
    e.bonuses = _decryptPayrollDouble(
      e,
      'bonuses',
      e.bonuses,
      magnitude: _salaryMagnitude,
    );
    e.deductions = _decryptPayrollDouble(
      e,
      'deductions',
      e.deductions,
      magnitude: _salaryMagnitude,
    );
    e.netSalary = _decryptPayrollDouble(
      e,
      'netSalary',
      e.netSalary,
      magnitude: _salaryMagnitude,
    );
    if (e.paymentReference != null) {
      e.paymentReference = _fieldEncryption.decryptString(
        e.paymentReference!,
        _payrollCtx(e, 'paymentRef'),
      );
    }
  }

  void _encryptPayrollEntity(PayrollRecordEntity e) {
    if (!_fieldEncryption.isEnabled) return;
    e.totalHours = _fieldEncryption.encryptDouble(
      e.totalHours,
      _payrollCtx(e, 'totalHours'),
      magnitude: _hoursMagnitude,
    );
    e.baseSalary = _fieldEncryption.encryptDouble(
      e.baseSalary,
      _payrollCtx(e, 'baseSalary'),
      magnitude: _salaryMagnitude,
    );
    e.totalOvertimeHours = _fieldEncryption.encryptDouble(
      e.totalOvertimeHours,
      _payrollCtx(e, 'totalOvertimeHours'),
      magnitude: _hoursMagnitude,
    );
    e.bonuses = _fieldEncryption.encryptDouble(
      e.bonuses,
      _payrollCtx(e, 'bonuses'),
      magnitude: _salaryMagnitude,
    );
    e.deductions = _fieldEncryption.encryptDouble(
      e.deductions,
      _payrollCtx(e, 'deductions'),
      magnitude: _salaryMagnitude,
    );
    e.netSalary = _fieldEncryption.encryptDouble(
      e.netSalary,
      _payrollCtx(e, 'netSalary'),
      magnitude: _salaryMagnitude,
    );
    if (e.paymentReference != null) {
      e.paymentReference = _fieldEncryption.encryptString(
        e.paymentReference!,
        _payrollCtx(e, 'paymentRef'),
      );
    }
  }

  List<Employee> _dedupeEmployees(List<Employee> employees) {
    final byId = <String, Employee>{};
    for (final employee in employees) {
      final employeeId = employee.employeeId.trim();
      if (employeeId.isEmpty) continue;
      final existing = byId[employeeId];
      if (existing == null) {
        byId[employeeId] = employee;
        continue;
      }
      final existingTs = existing.updatedAt ?? existing.createdAt;
      final incomingTs = employee.updatedAt ?? employee.createdAt;
      if (incomingTs.isAfter(existingTs)) {
        byId[employeeId] = employee;
      }
    }
    return byId.values.toList(growable: false);
  }

  bool _isEmployeeActiveForMonth(
    Employee employee,
    DateTime startOfMonth,
    DateTime endOfMonth,
  ) {
    final joiningDate = DateTime(
      employee.joiningDate.year,
      employee.joiningDate.month,
      employee.joiningDate.day,
    );
    if (joiningDate.isAfter(endOfMonth)) {
      return false;
    }

    final exitDate = employee.exitDate;
    if (exitDate != null) {
      final normalizedExit = DateTime(exitDate.year, exitDate.month, exitDate.day);
      if (normalizedExit.isBefore(startOfMonth)) {
        return false;
      }
    } else if (!employee.isActive) {
      // Inactive employee without explicit exit date should not receive payroll.
      return false;
    }

    return true;
  }

  Map<String, PayrollRecordEntity> _pickLatestRecordPerEmployee(
    List<PayrollRecordEntity> records,
  ) {
    final latestByEmployee = <String, PayrollRecordEntity>{};
    for (final record in records) {
      final employeeId = record.employeeId.trim();
      if (employeeId.isEmpty) continue;
      final existing = latestByEmployee[employeeId];
      if (existing == null || record.updatedAt.isAfter(existing.updatedAt)) {
        latestByEmployee[employeeId] = record;
      }
    }
    return latestByEmployee;
  }
}
