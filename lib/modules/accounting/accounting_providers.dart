import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/firebase/firebase_config.dart';
import 'voucher_repository.dart';
import 'accounts_repository.dart';

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return VoucherRepository(firebaseServices);
});

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(firebaseServices);
});

class AccountingDashboardData {
  final double cashBalance;
  final double bankBalance;
  final double outstandingReceivables;
  final double outstandingPayables;
  final double outputGst;
  final double inputGst;
  final List<Map<String, dynamic>> accounts;

  const AccountingDashboardData({
    required this.cashBalance,
    required this.bankBalance,
    required this.outstandingReceivables,
    required this.outstandingPayables,
    required this.outputGst,
    required this.inputGst,
    required this.accounts,
  });

  factory AccountingDashboardData.empty() {
    return const AccountingDashboardData(
      cashBalance: 0,
      bankBalance: 0,
      outstandingReceivables: 0,
      outstandingPayables: 0,
      outputGst: 0,
      inputGst: 0,
      accounts: [],
    );
  }
}

final accountingDashboardDataProvider = FutureProvider<AccountingDashboardData>(
  (ref) async {
    final voucherRepo = ref.watch(voucherRepositoryProvider);
    final accountsRepo = ref.watch(accountsRepositoryProvider);

    // On Windows, skip ensureDefaultAccounts to prevent concurrent Firestore
    // C++ SDK operations that crash the native process. SyncManager handles
    // the initial data pull; default accounts are created post-sync.
    final isWindows =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    if (!isWindows) {
      await accountsRepo.ensureDefaultAccounts();
    }

    // Fetch metrics efficiently
    final metrics = await voucherRepo.getDashboardMetrics();
    final accounts = await accountsRepo.getAccounts();

    return AccountingDashboardData(
      cashBalance: (metrics['cash'] as num?)?.toDouble() ?? 0.0,
      bankBalance: (metrics['bank'] as num?)?.toDouble() ?? 0.0,
      outstandingReceivables:
          (metrics['receivables'] as num?)?.toDouble() ?? 0.0,
      outstandingPayables: (metrics['payables'] as num?)?.toDouble() ?? 0.0,
      outputGst: (metrics['outputGst'] as num?)?.toDouble() ?? 0.0,
      inputGst: (metrics['inputGst'] as num?)?.toDouble() ?? 0.0,
      accounts: accounts,
    );
  },
);
