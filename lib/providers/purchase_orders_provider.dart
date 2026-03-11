import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/types/purchase_order_types.dart';
import 'service_providers.dart';

final purchaseOrdersFutureProvider = FutureProvider<List<PurchaseOrder>>((
  ref,
) async {
  final service = ref.watch(purchaseOrderServiceProvider);
  return service.getAllPurchaseOrders();
});
