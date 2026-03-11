import 'package:flutter/material.dart';
import '../services/master_data_service.dart';
import '../utils/app_logger.dart';

/// Quick verification widget to check display unit changes
/// Add this temporarily to any screen to verify saves
class DisplayUnitVerifier extends StatelessWidget {
  final MasterDataService masterDataService;

  const DisplayUnitVerifier({
    super.key,
    required this.masterDataService,
  });

  Future<void> _verifyDisplayUnit(BuildContext context) async {
    try {
      // 1. Get current product types
      final types = await masterDataService.getProductTypes();
      
      // 2. Find Semi-Finished Good
      final semiType = types.firstWhere(
        (t) => t.name == 'Semi-Finished Good',
        orElse: () => throw Exception('Semi-Finished Good not found'),
      );

      // 3. Show current display unit
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Current Display Unit: ${semiType.displayUnit ?? "null (using baseUnit)"}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // 4. Print to console
      AppLogger.info('=== Display Unit Verification ===', tag: 'Verifier');
      AppLogger.info('Product Type: ${semiType.name}', tag: 'Verifier');
      AppLogger.info('Display Unit: ${semiType.displayUnit}', tag: 'Verifier');
      AppLogger.info('Default UOM: ${semiType.defaultUom}', tag: 'Verifier');
      AppLogger.info('ID: ${semiType.id}', tag: 'Verifier');
      AppLogger.info('================================', tag: 'Verifier');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      AppLogger.error('Verification Error: $e', tag: 'Verifier');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _verifyDisplayUnit(context),
      icon: const Icon(Icons.verified),
      label: const Text('Verify Display Unit'),
      backgroundColor: Colors.blue,
    );
  }
}

/// Usage in any screen:
/// 
/// ```dart
/// // Add to your screen's build method
/// floatingActionButton: DisplayUnitVerifier(
///   masterDataService: context.read<MasterDataService>(),
/// ),
/// ```
