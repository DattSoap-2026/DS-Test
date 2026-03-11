import '../../core/firebase/firebase_config.dart';
import '../../providers/auth/auth_provider.dart';
import 'posting_service.dart';
import 'voucher_repository.dart';
import '../../services/accounting_audit_service.dart';

class AuditedPostingService {
  final PostingService _postingService;
  final AccountingAuditService _auditService;
  final AuthProvider _authProvider;

  AuditedPostingService(
    FirebaseServices firebase,
    AuthProvider authProvider, {
    PostingService? postingService,
    AccountingAuditService? auditService,
  })  : _postingService = postingService ?? PostingService(firebase),
        _auditService = auditService ?? AccountingAuditService(firebase),
        _authProvider = authProvider;

  Future<PostingResult> postSalesVoucher({
    required Map<String, dynamic> saleData,
    required String postedByUserId,
    String? postedByName,
    bool? strictModeOverride,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    final result = await _postingService.postSalesVoucher(
      saleData: saleData,
      postedByUserId: postedByUserId,
      postedByName: postedByName,
      strictModeOverride: strictModeOverride,
      strictBusinessWrite: strictBusinessWrite,
    );

    if (result.success && _isAccountant()) {
      await _auditService.logAction(
        userId: postedByUserId,
        userName: postedByName ?? 'Unknown',
        action: 'create',
        collectionName: 'vouchers',
        documentId: result.voucherId ?? 'unknown',
        changes: {'type': 'sales', 'amount': saleData['totalAmount']},
        notes: 'Sales voucher posted',
      );
    }

    return result;
  }

  Future<PostingResult> postPurchaseVoucher({
    required Map<String, dynamic> purchaseData,
    required String postedByUserId,
    String? postedByName,
    bool? strictModeOverride,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    final result = await _postingService.postPurchaseVoucher(
      purchaseData: purchaseData,
      postedByUserId: postedByUserId,
      postedByName: postedByName,
      strictModeOverride: strictModeOverride,
      strictBusinessWrite: strictBusinessWrite,
    );

    if (result.success && _isAccountant()) {
      await _auditService.logAction(
        userId: postedByUserId,
        userName: postedByName ?? 'Unknown',
        action: 'create',
        collectionName: 'vouchers',
        documentId: result.voucherId ?? 'unknown',
        changes: {'type': 'purchase', 'amount': purchaseData['totalAmount']},
        notes: 'Purchase voucher posted',
      );
    }

    return result;
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
    final result = await _postingService.createManualVoucher(
      voucherType: voucherType,
      transactionRefId: transactionRefId,
      date: date,
      entries: entries,
      postedByUserId: postedByUserId,
      postedByName: postedByName,
      narration: narration,
      partyId: partyId,
      partyName: partyName,
      strictModeOverride: strictModeOverride,
    );

    if (result.success && _isAccountant()) {
      final totalDebit = entries.fold<double>(
        0,
        (sum, e) => sum + (e['debit'] as num? ?? 0).toDouble(),
      );
      await _auditService.logAction(
        userId: postedByUserId,
        userName: postedByName ?? 'Unknown',
        action: 'create',
        collectionName: 'vouchers',
        documentId: result.voucherId ?? 'unknown',
        changes: {
          'type': voucherType,
          'amount': totalDebit,
          'entries': entries.length,
        },
        notes: narration ?? 'Manual voucher created',
      );
    }

    return result;
  }

  Future<PostingResult> createVoucherReversal({
    required String originalVoucherId,
    required String reason,
    required String postedByUserId,
    String? postedByName,
    DateTime? reversalDate,
    bool? strictModeOverride,
  }) async {
    final result = await _postingService.createVoucherReversal(
      originalVoucherId: originalVoucherId,
      reason: reason,
      postedByUserId: postedByUserId,
      postedByName: postedByName,
      reversalDate: reversalDate,
      strictModeOverride: strictModeOverride,
    );

    if (result.success && _isAccountant()) {
      await _auditService.logAction(
        userId: postedByUserId,
        userName: postedByName ?? 'Unknown',
        action: 'create',
        collectionName: 'vouchers',
        documentId: result.voucherId ?? 'unknown',
        changes: {'type': 'reversal', 'originalVoucherId': originalVoucherId},
        notes: 'Reversal: $reason',
      );
    }

    return result;
  }

  bool _isAccountant() {
    final user = _authProvider.currentUser;
    return user?.role.name.toLowerCase() == 'accountant';
  }
}
