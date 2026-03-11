import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/customers_service.dart'; // For Customer domain model
import '../../data/repositories/customer_repository.dart';
import '../../data/local/entities/customer_entity.dart';
import '../../widgets/ui/custom_text_field.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class CustomerFormDialog extends StatefulWidget {
  final Customer? customer;
  final VoidCallback onSaved;
  final List<String> allRoutes;

  const CustomerFormDialog({
    super.key,
    this.customer,
    required this.onSaved,
    required this.allRoutes,
  });

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  // final _routeController = TextEditingController(); // Replaced by _selectedRoute
  String? _selectedRoute;
  final _creditLimitController = TextEditingController();
  final _gstinController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _shopNameController.text = widget.customer!.shopName;
      _ownerNameController.text = widget.customer!.ownerName;
      _mobileController.text = widget.customer!.mobile;
      _altMobileController.text = widget.customer!.alternateMobile ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address;
      _cityController.text = widget.customer!.city ?? '';
      // _routeController.text = widget.customer!.route;
      _selectedRoute = widget.customer!.route;
      _creditLimitController.text =
          widget.customer!.creditLimit?.toString() ?? '';
      _gstinController.text = widget.customer!.gstin ?? '';
      _status = widget.customer!.status;
      if (widget.customer!.latitude != null) {
        _latitudeController.text = widget.customer!.latitude!.toString();
      }
      if (widget.customer!.longitude != null) {
        _longitudeController.text = widget.customer!.longitude!.toString();
      }
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _creditLimitController.dispose();
    _gstinController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Capturing GPS...')));
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        if (!mounted) return;
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Location captured!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final customerRepo = context.read<CustomerRepository>();
      final double? lat = double.tryParse(_latitudeController.text);
      final double? long = double.tryParse(_longitudeController.text);

      CustomerEntity entity;
      if (widget.customer != null) {
        // Edit existing
        entity = CustomerEntity.fromDomain(widget.customer!);
        // Update fields
        entity.shopName = _shopNameController.text;
        entity.ownerName = _ownerNameController.text;
        entity.mobile = _mobileController.text;
        entity.alternateMobile = _altMobileController.text.isNotEmpty
            ? _altMobileController.text
            : null;
        entity.email = _emailController.text.isNotEmpty
            ? _emailController.text
            : null;
        entity.address = _addressController.text;
        entity.city = _cityController.text.isNotEmpty
            ? _cityController.text
            : null;
        entity.route = _selectedRoute!;
        entity.creditLimit = double.tryParse(_creditLimitController.text);
        entity.gstin = _gstinController.text.isNotEmpty
            ? _gstinController.text
            : null;
        entity.status = _status;
        entity.latitude = lat;
        entity.longitude = long;
      } else {
        // Create new
        final newId = const Uuid().v4();
        entity = CustomerEntity()
          ..id = newId
          ..shopName = _shopNameController.text
          ..ownerName = _ownerNameController.text
          ..mobile = _mobileController.text
          ..alternateMobile = _altMobileController.text.isNotEmpty
              ? _altMobileController.text
              : null
          ..email = _emailController.text.isNotEmpty
              ? _emailController.text
              : null
          ..address = _addressController.text
          ..city = _cityController.text.isNotEmpty ? _cityController.text : null
          ..route = _selectedRoute!
          ..creditLimit = double.tryParse(_creditLimitController.text)
          ..gstin = _gstinController.text.isNotEmpty
              ? _gstinController.text
              : null
          ..status = _status
          ..latitude = lat
          ..longitude = long
          ..createdAt = DateTime.now().toIso8601String()
          ..balance = 0.0
          // syncStatus & updatedAt handled by saveCustomer
          ..isDeleted = false;
      }

      await customerRepo.saveCustomer(entity);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ResponsiveAlertDialog(
      title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Shop Name',
                controller: _shopNameController,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Owner Name',
                controller: _ownerNameController,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Mobile Number',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: (v) => v?.length != 10 ? 'Enter 10 digits' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedRoute),
                initialValue: _selectedRoute,
                decoration: const InputDecoration(
                  labelText: 'Route',
                  prefixIcon: Icon(Icons.route),
                  border: OutlineInputBorder(),
                ),
                items: widget.allRoutes
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRoute = v),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              // Location Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _captureLocation,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text('Capture GPS'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Latitude',
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          label: 'Longitude',
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Credit Limit (\u20B9)',
                controller: _creditLimitController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: colorScheme.onPrimary,
          ),
          child: _isSaving
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}



