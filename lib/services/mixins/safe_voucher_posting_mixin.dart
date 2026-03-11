import '../../modules/accounting/posting_service.dart';

/// Mixin providing safe voucher posting with automatic error handling.
/// 
/// Voucher posting failures are silently caught to prevent blocking
/// primary business operations when accounting integration is optional.
mixin SafeVoucherPostingMixin {
  PostingService? get postingService;

  /// Safely posts a voucher, catching and suppressing any errors.
  /// 
  /// This allows accounting integration to be optional - if posting fails,
  /// the primary operation (payroll, advance, etc.) still succeeds.
  Future<void> safePostVoucher(
    Future<void> Function(PostingService service) postingFn,
  ) async {
    final service = postingService;
    if (service == null) return;
    
    try {
      await postingFn(service);
    } catch (_) {
      // Silent fail - voucher posting is optional
    }
  }
}
