import '../../models/types/sales_types.dart';

/// Delegate responsible for enforcing strict domain-driven validation guards
/// before processing sales. This ensures that no invalid, negative, or
/// malicious data makes its way into the local database.
class SalesValidationDelegate {
  /// Validates the parameters for creating a new sale.
  /// Throws an [ArgumentError] if any parameter is invalid.
  void validateCreateSaleParams({
    required String recipientType,
    required String recipientId,
    required String recipientName,
    required List<SaleItemForUI> items,
    required double discountPercentage,
    required double additionalDiscountPercentage,
    required double gstPercentage,
  }) {
    if (recipientType.trim().isEmpty) {
      throw ArgumentError('Recipient type cannot be empty.');
    }
    if (recipientId.trim().isEmpty) {
      throw ArgumentError('Recipient ID cannot be empty.');
    }
    if (items.isEmpty) {
      throw ArgumentError('Cannot create a sale with zero items.');
    }

    if (discountPercentage < 0 || discountPercentage > 100) {
      throw ArgumentError('Discount percentage must be between 0 and 100.');
    }
    if (additionalDiscountPercentage < 0 ||
        additionalDiscountPercentage > 100) {
      throw ArgumentError(
        'Additional discount percentage must be between 0 and 100.',
      );
    }
    if (gstPercentage < 0 || gstPercentage > 100) {
      throw ArgumentError('GST percentage must be between 0 and 100.');
    }

    for (final item in items) {
      validateSaleItem(item);
    }
  }

  /// Validates a single sale item.
  /// Throws an [ArgumentError] if the item has invalid properties.
  void validateSaleItem(SaleItemForUI item) {
    if (item.productId.trim().isEmpty) {
      throw ArgumentError('Sale item must have a valid productId.');
    }
    if (item.quantity <= 0) {
      throw ArgumentError('Sale item quantity must be greater than zero.');
    }
    if (item.price < 0) {
      throw ArgumentError('Sale item price cannot be negative.');
    }
    if (item.discount < 0 || item.discount > 100) {
      throw ArgumentError('Sale item discount must be between 0 and 100.');
    }
    if (item.secondaryPrice != null && item.secondaryPrice! < 0) {
      throw ArgumentError('Sale item secondary price cannot be negative.');
    }
    if (item.returnedQuantity < 0) {
      throw ArgumentError('Sale item returned quantity cannot be negative.');
    }
  }
}
