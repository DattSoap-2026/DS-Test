import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../services/vehicles_service.dart';
import '../../../services/vehicle_bulk_operations.dart';
import '../../../utils/responsive.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class BulkOperationsDialog extends StatefulWidget {
  final List<Vehicle> vehicles;

  const BulkOperationsDialog({super.key, required this.vehicles});

  @override
  State<BulkOperationsDialog> createState() => _BulkOperationsDialogState();
}

class _BulkOperationsDialogState extends State<BulkOperationsDialog> {
  bool _isProcessing = false;
  String? _resultMessage;

  @override
  Widget build(BuildContext context) {
    final constraints = Responsive.dialogConstraints(
      context,
      maxWidth: 520,
      maxHeightFactor: 0.9,
    );
    return AlertDialog(
      title: const Text('Bulk Operations'),
      content: SizedBox(
        width: constraints.maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_resultMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_resultMessage!, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export to CSV'),
              subtitle: const Text('Export all vehicles to CSV file'),
              onTap: _isProcessing ? null : _exportToCSV,
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Import from CSV'),
              subtitle: const Text('Import vehicles from CSV file'),
              onTap: _isProcessing ? null : _importFromCSV,
            ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _exportToCSV() async {
    setState(() => _isProcessing = true);
    try {
      final bulkOps = VehicleBulkOperations(context.read<VehiclesService>());
      final csv = await bulkOps.exportVehiclesToCSV(widget.vehicles);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Vehicles CSV',
        fileName: 'vehicles_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );

      if (path != null) {
        await File(path).writeAsString(csv);
        setState(() {
          _resultMessage = 'Exported ${widget.vehicles.length} vehicles successfully!';
          _isProcessing = false;
        });
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Export failed: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _importFromCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;
    if (!mounted) return;

    setState(() => _isProcessing = true);
    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      if (!mounted) return;
      final bulkOps = VehicleBulkOperations(context.read<VehiclesService>());
      final importResult = await bulkOps.importVehiclesFromCSV(content);

      if (!mounted) return;
      setState(() {
        _resultMessage = 'Import complete!\nSuccess: ${importResult['success']}\nErrors: ${importResult['errors']}';
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultMessage = 'Import failed: $e';
        _isProcessing = false;
      });
    }
  }
}
