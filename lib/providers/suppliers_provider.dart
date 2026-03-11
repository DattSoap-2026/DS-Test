import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/suppliers_service.dart';
import 'service_providers.dart';

final suppliersFutureProvider = FutureProvider<List<Supplier>>((ref) async {
  final service = ref.watch(suppliersServiceProvider);
  return service.getSuppliers(status: 'active');
});
