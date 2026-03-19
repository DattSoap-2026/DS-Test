import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/customer_entity.dart';
import '../../../data/local/entities/dealer_entity.dart';
import '../../../data/local/entities/sale_entity.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/dealer_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/returns_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../services/database_service.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final returnsRepositoryProvider = Provider<ReturnsRepository>((ref) {
  return ReturnsRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final dealerRepositoryProvider = Provider<DealerRepository>((ref) {
  return DealerRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final allSalesProvider = StreamProvider<List<SaleEntity>>((ref) {
  return ref.watch(salesRepositoryProvider).watchAllSales();
});

final allCustomersProvider = StreamProvider<List<CustomerEntity>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAllCustomers();
});

final allDealersProvider = StreamProvider<List<DealerEntity>>((ref) {
  return ref.watch(dealerRepositoryProvider).watchAllDealers();
});

final pendingSalesSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.sales,
    CollectionRegistry.returns,
    CollectionRegistry.payments,
    CollectionRegistry.customers,
    CollectionRegistry.dealers,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
