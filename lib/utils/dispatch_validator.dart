import '../models/types/sales_types.dart';
import '../models/types/user_types.dart';

/// Validates dispatch operations to prevent crashes and ensure business rules
class DispatchValidator {
  /// Validates dispatch items before processing
  static String? validateDispatchItems(List<SaleItem> items) {
    if (items.isEmpty) {
      return 'Dispatch must include at least one item';
    }
    
    for (final item in items) {
      if (item.productId.trim().isEmpty) {
        return 'All items must have valid product IDs';
      }
      
      if (item.quantity <= 0) {
        return 'All items must have quantity greater than zero';
      }
      
      if (item.name.trim().isEmpty) {
        return 'All items must have valid product names';
      }
    }
    
    return null; // Valid
  }
  
  /// Validates salesman for dispatch
  static String? validateSalesman(AppUser? salesman) {
    if (salesman == null) {
      return 'Salesman is required for dispatch';
    }
    
    if (salesman.id.trim().isEmpty) {
      return 'Salesman must have valid ID';
    }
    
    if (salesman.name.trim().isEmpty) {
      return 'Salesman must have valid name';
    }
    
    return null; // Valid
  }
  
  /// Validates vehicle for dispatch
  static String? validateVehicle(String? vehicleId, String? vehicleNumber) {
    if (vehicleId == null || vehicleId.trim().isEmpty) {
      return 'Vehicle ID is required';
    }
    
    if (vehicleNumber == null || vehicleNumber.trim().isEmpty) {
      return 'Vehicle number is required';
    }
    
    return null; // Valid
  }
  
  /// Validates route information
  static String? validateRoute(String? route) {
    if (route == null || route.trim().isEmpty) {
      return 'Dispatch route is required';
    }
    
    return null; // Valid
  }
  
  /// Comprehensive dispatch validation
  static String? validateDispatch({
    required List<SaleItem> items,
    required AppUser? salesman,
    required String? vehicleId,
    required String? vehicleNumber,
    required String? dispatchRoute,
  }) {
    String? error;
    
    error = validateDispatchItems(items);
    if (error != null) return error;
    
    error = validateSalesman(salesman);
    if (error != null) return error;
    
    error = validateVehicle(vehicleId, vehicleNumber);
    if (error != null) return error;
    
    error = validateRoute(dispatchRoute);
    if (error != null) return error;
    
    return null; // All validations passed
  }
}