import '../services/master_data_service.dart';
import '../utils/app_logger.dart';

/// Helper to update display unit for a product type
/// 
/// Usage:
/// ```dart
/// final helper = UpdateDisplayUnitHelper(masterDataService);
/// await helper.updateDisplayUnit(
///   typeName: 'Semi-Finished Good',
///   newDisplayUnit: 'Batch', // or 'Kg', 'Pcs', etc.
/// );
/// ```
class UpdateDisplayUnitHelper {
  final MasterDataService _masterDataService;

  UpdateDisplayUnitHelper(this._masterDataService);

  /// Update display unit for a specific product type
  Future<bool> updateDisplayUnit({
    required String typeName,
    required String newDisplayUnit,
  }) async {
    try {
      // 1. Get all product types
      final types = await _masterDataService.getProductTypes();
      
      // 2. Find the target type
      final targetType = types.firstWhere(
        (t) => t.name.toLowerCase() == typeName.toLowerCase(),
        orElse: () => throw Exception('Product type "$typeName" not found'),
      );

      // 3. Update the display unit
      final success = await _masterDataService.updateProductType(
        targetType.id,
        {'displayUnit': newDisplayUnit},
      );

      if (success) {
        AppLogger.info('Display unit updated: $typeName → $newDisplayUnit', tag: 'DisplayUnit');
      } else {
        AppLogger.error('Failed to update display unit', tag: 'DisplayUnit');
      }

      return success;
    } catch (e) {
      AppLogger.error('Error updating display unit: $e', tag: 'DisplayUnit');
      return false;
    }
  }

  /// Batch update multiple product types
  Future<Map<String, bool>> updateMultipleDisplayUnits(
    Map<String, String> updates,
  ) async {
    final results = <String, bool>{};
    
    for (final entry in updates.entries) {
      final typeName = entry.key;
      final newUnit = entry.value;
      results[typeName] = await updateDisplayUnit(
        typeName: typeName,
        newDisplayUnit: newUnit,
      );
    }
    
    return results;
  }
}

/// Example usage in a screen or service:
/// 
/// ```dart
/// // In your screen/service
/// final masterDataService = context.read<MasterDataService>();
/// final helper = UpdateDisplayUnitHelper(masterDataService);
/// 
/// // Single update
/// await helper.updateDisplayUnit(
///   typeName: 'Semi-Finished Good',
///   newDisplayUnit: 'Batch',
/// );
/// 
/// // Multiple updates
/// await helper.updateMultipleDisplayUnits({
///   'Semi-Finished Good': 'Batch',
///   'Raw Material': 'Kg',
///   'Finished Good': 'Pcs',
/// });
/// ```
