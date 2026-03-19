import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_config.dart';
import '../../core/providers/core_providers.dart';
import '../../core/sync/collection_registry.dart';
import '../../data/local/entities/account_entity.dart';
import '../../data/local/entities/voucher_entity.dart';
import '../../providers/service_providers.dart';
import 'accounts_repository.dart';
import 'voucher_repository.dart';

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return VoucherRepository(
    firebaseServices,
    dbService: ref.read(databaseServiceProvider),
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(
    firebaseServices,
    dbService: ref.read(databaseServiceProvider),
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final allAccountsProvider = StreamProvider<List<AccountEntity>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAllAccounts();
});

final allVouchersProvider = StreamProvider<List<VoucherEntity>>((ref) {
  return ref.watch(voucherRepositoryProvider).watchAllVouchers();
});

final vouchersByTypeProvider =
    FutureProvider.family<List<VoucherEntity>, String>((ref, type) {
      return ref.watch(voucherRepositoryProvider).getVouchersByType(type);
    });

final pendingAccountingSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.accounts,
    CollectionRegistry.vouchers,
    CollectionRegistry.voucherEntries,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
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

    final isWindows =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    if (!isWindows) {
      await accountsRepo.ensureDefaultAccounts();
    }

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
