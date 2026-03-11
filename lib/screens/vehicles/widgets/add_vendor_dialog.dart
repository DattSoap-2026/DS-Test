import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/suppliers_service.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class AddVendorDialog extends StatefulWidget {
  const AddVendorDialog({super.key});

  @override
  State<AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<AddVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController(); // Added
  final _addressController = TextEditingController(); // Added
  bool _isSaving = false; // Added

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        // Use SuppliersService to save with type = 'vendor'
        final service = context.read<SuppliersService>();
        // Clean and prepare data
        final name = _nameController.text.trim();
        final mobile = _mobileController.text.trim();
        final address = _addressController.text.trim();

        await service.addSupplier(
          name: name,
          contactPerson: 'Manager', // Defaulting as this is a quick add
          mobile: mobile.isEmpty
              ? 'N/A'
              : mobile, // Handle optionality by default
          address: address.isEmpty ? 'N/A' : address,
          type: 'vendor',
        );

        if (mounted) {
          Navigator.pop(context, name);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding vendor: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple dark-themed dialog matching the app style
    return ResponsiveAlertDialog(
      title: const Text('Add New Vendor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vendor / Workshop Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Location / Address (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),

      actions: [
        if (_isSaving)
          const Center(child: CircularProgressIndicator())
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _save, child: const Text('Add Vendor')),
        ],
      ],
    );
  }
}

