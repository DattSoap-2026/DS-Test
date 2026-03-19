import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/sync/sync_queue_service.dart';
import '../../../services/database_service.dart';
import '../../../data/local/entities/advance_entity.dart';
import '../../../data/local/base_entity.dart';
import '../../../core/firebase/firebase_config.dart';
import '../../../modules/accounting/posting_service.dart';
import '../../../services/mixins/safe_voucher_posting_mixin.dart';
import '../models/advance_model.dart';
import 'hr_service.dart';

class AdvanceService with ChangeNotifier, SafeVoucherPostingMixin {
  final DatabaseService _dbService;
  final HrService _hrService;
  final FirebaseServices? _firebaseServices;
  late final PostingService? _postingService;
  static const String _collection = 'advances';

  @override
  PostingService? get postingService => _postingService;

  AdvanceService(this._dbService, this._hrService, [this._firebaseServices]) {
    if (_firebaseServices != null) {
      _postingService = PostingService(_firebaseServices);
    } else {
      _postingService = null;
    }
  }

  Future<void> _enqueueOutbox(
    Map<String, dynamic> payload, {
    String action = 'set',
  }) async {
    final documentId = payload['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) {
      return;
    }
    await SyncQueueService.instance.addToQueue(
      collectionName: _collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
  }

  Map<String, dynamic> _toSyncPayload(AdvanceEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'type': entity.type,
      'amount': entity.amount,
      'paidAmount': entity.paidAmount,
      'status': entity.status,
      'requestDate': entity.requestDate,
      'approvedDate': entity.approvedDate,
      'approvedBy': entity.approvedBy,
      'rejectionReason': entity.rejectionReason,
      'purpose': entity.purpose,
      'emiMonths': entity.emiMonths,
      'emiAmount': entity.emiAmount,
      'remarks': entity.remarks,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  /// Request a new advance or loan for an employee.
  ///
  /// Creates a pending advance/loan request that requires approval.
  ///
  /// Parameters:
  /// - [employeeId]: ID of the employee requesting advance
  /// - [type]: 'Advance' or 'Loan'
  /// - [amount]: Amount requested (must be > 0)
  /// - [purpose]: Optional reason for the advance
  /// - [emiMonths]: Number of months for EMI (required for loans)
  ///
  /// Returns: The created [Advance] object
  ///
  /// Throws: [ArgumentError] if amount <= 0 or employeeId is empty
  Future<Advance> requestAdvance({
    required String employeeId,
    required String type, // 'Advance' or 'Loan'
    required double amount,
    String? purpose,
    int? emiMonths,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Advance amount must be greater than zero');
    }
    if (employeeId.trim().isEmpty) {
      throw ArgumentError('Employee ID is required');
    }

    final id = const Uuid().v4();
    final now = DateTime.now();

    double? emiAmount;
    if (type == 'Loan' && emiMonths != null && emiMonths > 0) {
      emiAmount = amount / emiMonths;
    }

    final entity = AdvanceEntity()
      ..id = id
      ..employeeId = employeeId
      ..type = type
      ..amount = amount
      ..paidAmount = 0
      ..status = 'Pending'
      ..requestDate = now.toIso8601String()
      ..purpose = purpose
      ..emiMonths = emiMonths
      ..emiAmount = emiAmount
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.advances.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'set');

    notifyListeners();
    return _toDomain(entity);
  }

  /// Approve an advance/loan request.
  ///
  /// Changes status to 'Active' and optionally posts accounting voucher.
  ///
  /// Parameters:
  /// - [id]: Advance ID to approve
  /// - [approvedBy]: User ID of approver
  ///
  /// Throws: [Exception] if advance not found
  Future<void> approveAdvance(String id, String approvedBy) async {
    final entity = await _dbService.advances.filter().idEqualTo(id).findFirst();
    if (entity == null) throw Exception('Advance not found');

    entity
      ..status = 'Active'
      ..approvedBy = approvedBy
      ..approvedDate = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.advances.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'update');

    // Auto-post advance payment voucher
    final employee = await _hrService.getEmployee(entity.employeeId);
    await _postAdvancePaymentVoucher(
      advanceId: id,
      employeeId: entity.employeeId,
      employeeName: employee?.name ?? 'Employee',
      amount: entity.amount,
      type: entity.type,
      userId: approvedBy,
    );

    notifyListeners();
  }

  /// Reject an advance/loan request
  Future<void> rejectAdvance(
    String id,
    String rejectedBy,
    String reason,
  ) async {
    final entity = await _dbService.advances.filter().idEqualTo(id).findFirst();
    if (entity == null) throw Exception('Advance not found');

    entity
      ..status = 'Rejected'
      ..approvedBy = rejectedBy
      ..rejectionReason = reason
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.advances.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'update');

    notifyListeners();
  }

  /// Record a repayment
  Future<void> recordRepayment(String id, double amount) async {
    final entity = await _dbService.advances.filter().idEqualTo(id).findFirst();
    if (entity == null) throw Exception('Advance not found');

    final remaining = entity.amount - entity.paidAmount;
    if (amount > remaining) {
      throw Exception(
          'Overpayment detected! Amount $amount exceeds remaining balance $remaining.');
    }

    entity.paidAmount += amount;
    if (entity.paidAmount >= entity.amount) {
      entity.status = 'Cleared';
    }
    entity
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.advances.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'update');

    notifyListeners();
  }

  /// Get pending requests (for approval)
  Future<List<Advance>> getPendingRequests() async {
    final entities = await _dbService.advances
        .filter()
        .statusEqualTo('Pending')
        .findAll();
    return _hydrateList(entities.where((e) => !e.isDeleted).toList());
  }

  /// Get active advances/loans for an employee
  Future<List<Advance>> getActiveAdvances(String employeeId) async {
    final entities = await _dbService.advances
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();
    final active = entities
        .where(
          (e) => !e.isDeleted && (e.status == 'Active' || e.status == 'Approved'),
        )
        .toList();
    return _hydrateList(active);
  }

  /// Get all advances for an employee (history)
  Future<List<Advance>> getAdvanceHistory(String employeeId) async {
    final entities = await _dbService.advances
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();
    return _hydrateList(entities.where((e) => !e.isDeleted).toList());
  }

  /// Get summary for an employee
  Future<AdvanceSummary> getAdvanceSummary(String employeeId) async {
    final entities = await _dbService.advances
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();
    final activeEntities = entities
        .where(
          (e) => !e.isDeleted && (e.status == 'Active' || e.status == 'Approved'),
        )
        .toList();

    double totalAdvances = 0;
    double totalLoans = 0;
    double outstanding = 0;
    int activeAdvances = 0;
    int activeLoans = 0;

    for (var e in activeEntities) {
      final remaining = e.amount - e.paidAmount;
      outstanding += remaining;

      if (e.type == 'Advance') {
        totalAdvances += e.amount;
        activeAdvances++;
      } else {
        totalLoans += e.amount;
        activeLoans++;
      }
    }

    return AdvanceSummary(
      employeeId: employeeId,
      totalAdvances: totalAdvances,
      totalLoans: totalLoans,
      totalOutstanding: outstanding,
      activeAdvances: activeAdvances,
      activeLoans: activeLoans,
    );
  }

  /// Get total EMI deduction for payroll
  Future<double> getMonthlyEmiDeduction(String employeeId) async {
    final entities = await _dbService.advances
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();
    final active = entities.where(
      (e) =>
          !e.isDeleted &&
          (e.status == 'Active' || e.status == 'Approved') &&
          e.paidAmount < e.amount,
    );

    double total = 0;
    for (var a in active) {
      final remaining = a.amount - a.paidAmount;
      final emi = a.emiAmount ?? 0;
      if (emi > 0 && remaining > 0) {
        total += emi.clamp(0, remaining);
      }
    }
    return total;
  }

  Future<List<Advance>> _hydrateList(List<AdvanceEntity> entities) async {
    final results = <Advance>[];
    for (final e in entities) {
      final advance = _toDomain(e);
      final employee = await _hrService.getEmployee(e.employeeId);
      advance.employeeName = employee?.name;
      results.add(advance);
    }
    return results;
  }

  Advance _toDomain(AdvanceEntity e) {
    return Advance(
      id: e.id,
      employeeId: e.employeeId,
      type: e.type,
      amount: e.amount,
      paidAmount: e.paidAmount,
      status: e.status,
      requestDate: DateTime.parse(e.requestDate),
      approvedDate: e.approvedDate != null
          ? DateTime.parse(e.approvedDate!)
          : null,
      approvedBy: e.approvedBy,
      rejectionReason: e.rejectionReason,
      purpose: e.purpose,
      emiMonths: e.emiMonths,
      emiAmount: e.emiAmount,
      remarks: e.remarks,
    );
  }

  Future<void> _postAdvancePaymentVoucher({
    required String advanceId,
    required String employeeId,
    required String employeeName,
    required double amount,
    required String type,
    required String userId,
  }) async {
    await safePostVoucher((service) async {
      await service.createManualVoucher(
        voucherType: 'payment',
        transactionRefId: advanceId,
        date: DateTime.now(),
        entries: [
          {
            'accountCode': type == 'Loan' ? 'LOAN_TO_EMPLOYEES' : 'ADVANCE_TO_EMPLOYEES',
            'accountName': type == 'Loan' ? 'Loan to Employees' : 'Advance to Employees',
            'debit': amount,
            'credit': 0,
            'narration': '$type payment to $employeeName',
          },
          {
            'accountCode': 'CASH_IN_HAND',
            'accountName': 'Cash in Hand',
            'debit': 0,
            'credit': amount,
            'narration': 'Payment to $employeeName for $type',
          },
        ],
        postedByUserId: userId,
        narration: '$type Payment - $employeeName (₹${amount.toStringAsFixed(2)})',
        partyName: employeeName,
      );
    });
  }
}
