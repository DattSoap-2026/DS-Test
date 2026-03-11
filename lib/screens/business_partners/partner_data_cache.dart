import '../../services/customers_service.dart';
import '../../services/dealers_service.dart';
import '../../services/suppliers_service.dart';

class CustomersTabCacheSnapshot {
  final List<Customer> customers;
  final Map<String, String> routeIdByName;
  final Map<String, String> routeNameById;
  final List<Map<String, dynamic>> routeReferences;
  final List<String> salesmanRouteOptions;

  CustomersTabCacheSnapshot({
    required this.customers,
    required this.routeIdByName,
    required this.routeNameById,
    required this.routeReferences,
    required this.salesmanRouteOptions,
  });

  CustomersTabCacheSnapshot copy() {
    return CustomersTabCacheSnapshot(
      customers: List<Customer>.from(customers),
      routeIdByName: Map<String, String>.from(routeIdByName),
      routeNameById: Map<String, String>.from(routeNameById),
      routeReferences: routeReferences
          .map((route) => Map<String, dynamic>.from(route))
          .toList(),
      salesmanRouteOptions: List<String>.from(salesmanRouteOptions),
    );
  }
}

class BusinessPartnersDataCache {
  static CustomersTabCacheSnapshot? _customers;
  static List<Dealer>? _dealers;
  static final Map<String, List<Supplier>> _suppliersByType = {};

  static CustomersTabCacheSnapshot? get customers => _customers?.copy();

  static set customers(CustomersTabCacheSnapshot? value) {
    _customers = value?.copy();
  }

  static List<Dealer>? get dealers {
    final value = _dealers;
    return value == null ? null : List<Dealer>.from(value);
  }

  static set dealers(List<Dealer>? value) {
    _dealers = value == null ? null : List<Dealer>.from(value);
  }

  static List<Supplier>? suppliersByType(String type) {
    final value = _suppliersByType[type];
    return value == null ? null : List<Supplier>.from(value);
  }

  static void setSuppliersByType(String type, List<Supplier> suppliers) {
    _suppliersByType[type] = List<Supplier>.from(suppliers);
  }
}

