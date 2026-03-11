import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';

import '../../services/customers_service.dart';
import '../../services/dealers_service.dart';
import '../../services/suppliers_service.dart';
import '../../services/vehicles_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/dealer_repository.dart';
import '../../data/local/entities/customer_entity.dart';
import '../../data/local/entities/dealer_entity.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../services/settings_service.dart'; // For routes
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';

enum PartnerType { customer, dealer, supplier, vendor }

class BusinessPartnerFormDialog extends StatefulWidget {
  final PartnerType? initialType;
  final dynamic existingPartner; // Customer, Dealer, or Supplier
  final VoidCallback onSaved;
  final String? saleType;
  final bool fullScreen;

  const BusinessPartnerFormDialog({
    super.key,
    this.initialType,
    this.existingPartner,
    required this.onSaved,
    this.saleType,
    this.fullScreen = false,
  });

  @override
  State<BusinessPartnerFormDialog> createState() =>
      _BusinessPartnerFormDialogState();
}

class _BusinessPartnerFormDialogState extends State<BusinessPartnerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // Shop Name / Company Name
  final _contactPersonController = TextEditingController(); // Owner Name / POC
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _commissionController = TextEditingController(); // Dealer
  final _territoryController = TextEditingController(); // Dealer

  PartnerType _selectedType = PartnerType.customer;
  String _status = 'active';
  String? _selectedRoute;
  String? _selectedDealerRouteId;
  String? _selectedDealerRouteName;
  double? _latitude;
  double? _longitude;

  bool _isSaving = false;
  bool _isCapturingLocation = false;
  List<String> _allRoutes = [];
  List<Map<String, String>> _dealerRouteOptions = [];
  late final SettingsService _settingsService;
  late final VehiclesService _vehiclesService;

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _vehiclesService = context.read<VehiclesService>();
    _loadRoutes();

    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }

    if (widget.existingPartner != null) {
      _populateForm(widget.existingPartner);
    }
  }

  Future<void> _loadRoutes() async {
    try {
      final routeData = await _vehiclesService.getRoutes(refreshRemote: true);
      final activeRoutes =
          routeData
              .where((r) => r['status'] == 'active' || r['isActive'] == true)
              .map((r) {
                final id = (r['id'] ?? '').toString().trim();
                final name = (r['name'] ?? '').toString().trim();
                return {'id': id, 'name': name};
              })
              .where((r) => r['id']!.isNotEmpty && r['name']!.isNotEmpty)
              .toList()
            ..sort(
              (a, b) =>
                  a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()),
            );

      final uniqueActiveRoutes = <Map<String, String>>[];
      final seenRouteIds = <String>{};
      for (final route in activeRoutes) {
        final token = _normalizeRouteToken(route['id']);
        if (token == null) continue;
        if (!seenRouteIds.add(token)) continue;
        uniqueActiveRoutes.add(route);
      }

      if (uniqueActiveRoutes.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _dealerRouteOptions = uniqueActiveRoutes;
          _allRoutes = _dedupeRouteNames(
            uniqueActiveRoutes.map((r) => r['name']!).toList(),
          );
          _syncDealerRouteSelectionWithOptions();
        });
        return;
      }

      final settingsRoutes = await _settingsService.getRoutes();
      if (settingsRoutes.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _allRoutes = _dedupeRouteNames(settingsRoutes);
          _dealerRouteOptions = _buildRouteOptionsFromNames(_allRoutes);
          _syncDealerRouteSelectionWithOptions();
        });
        return;
      }

      if (!mounted) return;
      final customerRepo = context.read<CustomerRepository>();
      final customers = await customerRepo.getAllCustomers();
      final customerRoutes =
          customers
              .map((c) => c.route)
              .whereType<String>()
              .map((r) => r.trim())
              .where((r) => r.isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (mounted) {
        setState(() {
          _allRoutes = _dedupeRouteNames(customerRoutes);
          _dealerRouteOptions = _buildRouteOptionsFromNames(customerRoutes);
          _syncDealerRouteSelectionWithOptions();
        });
      }
    } catch (e) {
      debugPrint('Error loading routes: $e');
      // Try to load from customers as final fallback
      try {
        if (!mounted) return;
        final customerRepo = context.read<CustomerRepository>();
        final customers = await customerRepo.getAllCustomers();
        final customerRoutes =
            customers
                .map((c) => c.route)
                .whereType<String>()
                .map((r) => r.trim())
                .where((r) => r.isNotEmpty)
                .toSet()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        if (mounted) {
          setState(() {
            _allRoutes = _dedupeRouteNames(customerRoutes);
            _dealerRouteOptions = _buildRouteOptionsFromNames(customerRoutes);
            _syncDealerRouteSelectionWithOptions();
          });
        }
      } catch (e2) {
        debugPrint('Error loading routes from customers: $e2');
      }
    }
  }

  List<Map<String, String>> _buildRouteOptionsFromNames(List<String> names) {
    final options = <Map<String, String>>[];
    final seenIds = <String>{};
    for (final rawName in names) {
      final name = rawName.trim();
      if (name.isEmpty) continue;
      final syntheticId = name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
      if (!seenIds.add(syntheticId)) continue;
      options.add({'id': syntheticId, 'name': name});
    }
    return options;
  }

  List<String> _dedupeRouteNames(List<String> names) {
    final unique = <String>[];
    final seen = <String>{};
    for (final rawName in names) {
      final name = rawName.trim();
      if (name.isEmpty) continue;
      final token = _normalizeRouteToken(name);
      if (token == null) continue;
      if (!seen.add(token)) continue;
      unique.add(name);
    }
    unique.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return unique;
  }

  String? _normalizeRouteToken(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return normalized.isEmpty ? null : normalized;
  }

  void _syncDealerRouteSelectionWithOptions() {
    if (_dealerRouteOptions.isEmpty) return;

    final byId = <String, Map<String, String>>{};
    final byName = <String, Map<String, String>>{};
    for (final option in _dealerRouteOptions) {
      final idToken = _normalizeRouteToken(option['id']);
      final nameToken = _normalizeRouteToken(option['name']);
      if (idToken != null) {
        byId[idToken] = option;
      }
      if (nameToken != null) {
        byName[nameToken] = option;
      }
    }

    Map<String, String>? matched;
    final selectedIdToken = _normalizeRouteToken(_selectedDealerRouteId);
    final selectedNameToken = _normalizeRouteToken(_selectedDealerRouteName);
    final territoryToken = _normalizeRouteToken(_territoryController.text);

    if (selectedIdToken != null) {
      matched = byId[selectedIdToken];
    }
    if (matched == null && selectedNameToken != null) {
      matched = byName[selectedNameToken];
    }
    if (matched == null && territoryToken != null) {
      matched = byName[territoryToken] ?? byId[territoryToken];
    }

    if (matched == null) return;
    _selectedDealerRouteId = matched['id'];
    _selectedDealerRouteName = matched['name'];
  }

  void _populateForm(dynamic partner) {
    if (partner is Customer) {
      _selectedType = PartnerType.customer;
      _nameController.text = partner.shopName;
      _contactPersonController.text = partner.ownerName;
      _mobileController.text = partner.mobile;
      _altMobileController.text = partner.alternateMobile ?? '';
      _emailController.text = partner.email ?? '';
      _addressController.text = partner.address;
      _addressLine2Controller.text = partner.addressLine2 ?? '';
      _cityController.text = partner.city ?? '';
      _stateController.text = partner.state ?? '';
      _pincodeController.text = partner.pincode ?? '';
      _selectedRoute = partner.route;
      _creditLimitController.text = partner.creditLimit?.toString() ?? '';
      _gstinController.text = partner.gstin ?? '';
      _panController.text = partner.pan ?? '';
      _paymentTermsController.text = partner.paymentTerms ?? '';
      _status = partner.status;
      _latitude = partner.latitude;
      _longitude = partner.longitude;
    } else if (partner is Dealer) {
      _selectedType = PartnerType.dealer;
      _nameController.text = partner.name;
      _contactPersonController.text = partner.contactPerson;
      _mobileController.text = partner.mobile;
      _altMobileController.text = partner.alternateMobile ?? '';
      _emailController.text = partner.email ?? '';
      _addressController.text = partner.address;
      _addressLine2Controller.text = partner.addressLine2 ?? '';
      _cityController.text = partner.city ?? '';
      _stateController.text = partner.state ?? '';
      _pincodeController.text = partner.pincode ?? '';
      _status = partner.status ?? 'active';
      _gstinController.text = partner.gstin ?? '';
      _panController.text = partner.pan ?? '';
      _commissionController.text =
          partner.commissionPercentage?.toString() ?? '';
      _paymentTermsController.text = partner.paymentTerms ?? '';
      _territoryController.text = partner.territory ?? '';
      _selectedDealerRouteId = partner.assignedRouteId;
      _selectedDealerRouteName = partner.assignedRouteName;
      _latitude = partner.latitude;
      _longitude = partner.longitude;
      _syncDealerRouteSelectionWithOptions();
    } else if (partner is Supplier) {
      if (partner.type == 'vendor') {
        _selectedType = PartnerType.vendor;
      } else {
        _selectedType = PartnerType.supplier;
      }
      _nameController.text = partner.name;
      _contactPersonController.text = partner.contactPerson;
      _mobileController.text = partner.mobile;
      _emailController.text = partner.email ?? '';
      _addressController.text = partner.address;
      _gstinController.text = partner.gstin ?? '';
      _status = partner.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _creditLimitController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _paymentTermsController.dispose();
    _commissionController.dispose();
    _territoryController.dispose();
    super.dispose();
  }

  String _trim(String value) => value.trim();

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizePincode(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 6) {
      return digits.substring(0, 6);
    }
    return null;
  }

  bool _isAddressSectionComplete() {
    return _trim(_addressController.text).isNotEmpty &&
        _trim(_cityController.text).isNotEmpty &&
        _trim(_stateController.text).isNotEmpty &&
        _normalizePincode(_pincodeController.text) != null;
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value == null) continue;
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  String _joinNonEmpty(List<String?> values, {String separator = ', '}) {
    final parts = values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return parts.join(separator);
  }

  String? _extractPincode(dynamic rawPostCode) {
    if (rawPostCode is! String) return null;
    return _normalizePincode(rawPostCode);
  }

  Future<Map<String, String?>> _reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'addressdetails': '1',
      'zoom': '18',
    });

    final response = await http
        .get(uri, headers: const {'User-Agent': 'DattSoap Flutter App/1.0'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Reverse geocode failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Reverse geocode returned invalid response');
    }

    final address = decoded['address'];
    if (address is! Map) {
      throw Exception('Address details unavailable');
    }
    final addressMap = Map<String, dynamic>.from(address);
    final displayName = (decoded['display_name'] as String?)?.trim();

    final houseNumber = addressMap['house_number'] as String?;
    final road = _firstNonEmpty([
      addressMap['road'] as String?,
      addressMap['pedestrian'] as String?,
      addressMap['residential'] as String?,
      addressMap['footway'] as String?,
    ]);
    final locality = _firstNonEmpty([
      addressMap['neighbourhood'] as String?,
      addressMap['suburb'] as String?,
      addressMap['city_district'] as String?,
      addressMap['quarter'] as String?,
      addressMap['hamlet'] as String?,
    ]);

    String? line1;
    final houseRoad = _joinNonEmpty([houseNumber, road], separator: ' ');
    if (houseRoad.isNotEmpty) {
      line1 = houseRoad;
    } else {
      final fallbackLine = _joinNonEmpty([
        addressMap['building'] as String?,
        locality,
      ]);
      if (fallbackLine.isNotEmpty) {
        line1 = fallbackLine;
      }
    }

    if ((line1 == null || line1.isEmpty) &&
        displayName != null &&
        displayName.isNotEmpty) {
      line1 = displayName
          .split(',')
          .map((part) => part.trim())
          .firstWhere((part) => part.isNotEmpty, orElse: () => displayName);
    }

    final city = _firstNonEmpty([
      addressMap['city'] as String?,
      addressMap['town'] as String?,
      addressMap['village'] as String?,
      addressMap['municipality'] as String?,
      addressMap['county'] as String?,
      locality,
    ]);

    final state = _firstNonEmpty([
      addressMap['state'] as String?,
      addressMap['state_district'] as String?,
      addressMap['region'] as String?,
    ]);

    final pincode = _extractPincode(addressMap['postcode']);

    return {
      'line1': line1,
      'line2': locality,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  Future<bool> _autofillAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final parsed = await _reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
      if (!mounted) return false;

      var didAutofill = false;

      void setIfEmpty(TextEditingController controller, String? value) {
        if (value == null || value.trim().isEmpty) return;
        if (controller.text.trim().isNotEmpty) return;
        controller.text = value.trim();
        didAutofill = true;
      }

      setIfEmpty(_addressController, parsed['line1']);

      // Fill line2 from locality only if line2 is still blank and different from line1.
      final line2 = parsed['line2'];
      if ((line2 ?? '').trim().isNotEmpty &&
          _addressLine2Controller.text.trim().isEmpty &&
          _addressController.text.trim().toLowerCase() !=
              line2!.trim().toLowerCase()) {
        _addressLine2Controller.text = line2.trim();
        didAutofill = true;
      }

      setIfEmpty(_cityController, parsed['city']);
      setIfEmpty(_stateController, parsed['state']);
      setIfEmpty(_pincodeController, parsed['pincode']);

      if (didAutofill) {
        _formKey.currentState?.validate();
      }

      return didAutofill;
    } catch (_) {
      return false;
    }
  }

  Future<void> _captureLocation() async {
    if (_isCapturingLocation) return;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location service is off. Enable GPS and try again.',
              ),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission denied. Please allow location access.',
              ),
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() => _isCapturingLocation = true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Capturing GPS...')));

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      final didAutofill = await _autofillAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      final missingFields = <String>[];
      if (_trim(_addressController.text).isEmpty) {
        missingFields.add('Address Line 1');
      }
      if (_trim(_cityController.text).isEmpty) {
        missingFields.add('City');
      }
      if (_trim(_stateController.text).isEmpty) {
        missingFields.add('State');
      }
      if (_normalizePincode(_pincodeController.text) == null) {
        missingFields.add('Pincode');
      }

      final message = missingFields.isEmpty
          ? (didAutofill
                ? 'Location locked and address auto-filled.'
                : 'Location locked successfully.')
          : 'Location locked. Fill: ${missingFields.join(', ')}';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturingLocation = false);
      }
    }
  }

  Future<void> _save() async {
    _pincodeController.text =
        _normalizePincode(_pincodeController.text) ??
        _trim(_pincodeController.text);

    if (!_formKey.currentState!.validate()) return;

    // Custom Validations
    if (_selectedType == PartnerType.customer &&
        (_selectedRoute == null || _selectedRoute!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a route for customer')),
      );
      return;
    }

    if (_selectedType == PartnerType.dealer &&
        _status == 'active' &&
        (_selectedDealerRouteId == null || _selectedDealerRouteId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign a dispatch route for active dealer'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_selectedType == PartnerType.customer) {
        await _saveCustomer();
      } else if (_selectedType == PartnerType.dealer) {
        await _saveDealer();
      } else if (_selectedType == PartnerType.supplier ||
          _selectedType == PartnerType.vendor) {
        await _saveSupplier();
      }

      widget.onSaved();
      if (mounted) {
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving partner: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveCustomer() async {
    final customerRepo = context.read<CustomerRepository>();
    CustomerEntity entity;

    if (widget.existingPartner != null && widget.existingPartner is Customer) {
      final existing = widget.existingPartner as Customer;
      entity = CustomerEntity.fromDomain(existing);
    } else {
      entity = CustomerEntity()
        ..id = const Uuid().v4()
        ..createdAt = DateTime.now().toIso8601String()
        ..balance = 0.0
        ..isDeleted = false;
    }

    entity.shopName = _trim(_nameController.text);
    entity.ownerName = _trim(_contactPersonController.text);
    entity.mobile = _trim(_mobileController.text);
    entity.alternateMobile = _trimOrNull(_altMobileController.text);
    entity.email = _trimOrNull(_emailController.text);
    entity.address = _trim(_addressController.text);
    entity.addressLine2 = _trimOrNull(_addressLine2Controller.text);
    entity.city = _trimOrNull(_cityController.text);
    entity.state = _trimOrNull(_stateController.text);
    entity.pincode = _normalizePincode(_pincodeController.text);
    entity.route = _selectedRoute!;
    entity.creditLimit = double.tryParse(_trim(_creditLimitController.text));
    entity.gstin = _trimOrNull(_gstinController.text);
    entity.pan = _trimOrNull(_panController.text);
    entity.paymentTerms = _trimOrNull(_paymentTermsController.text);
    entity.status = _status;
    entity.latitude = _latitude;
    entity.longitude = _longitude;

    await customerRepo.saveCustomer(entity);
  }

  Future<void> _saveDealer() async {
    final dealerRepo = context.read<DealerRepository>();
    DealerEntity entity;

    if (widget.existingPartner != null && widget.existingPartner is Dealer) {
      final existing = widget.existingPartner as Dealer;
      entity = DealerEntity.fromDomain(existing);
    } else {
      entity = DealerEntity()
        ..id = const Uuid().v4()
        ..createdAt = DateTime.now().toIso8601String()
        ..isDeleted = false;
    }

    entity.name = _trim(_nameController.text);
    entity.contactPerson = _trim(_contactPersonController.text);
    entity.mobile = _trim(_mobileController.text);
    entity.alternateMobile = _trimOrNull(_altMobileController.text);
    entity.email = _trimOrNull(_emailController.text);
    entity.address = _trim(_addressController.text);
    entity.addressLine2 = _trimOrNull(_addressLine2Controller.text);
    entity.city = _trimOrNull(_cityController.text);
    entity.state = _trimOrNull(_stateController.text);
    entity.pincode = _normalizePincode(_pincodeController.text);
    entity.gstin = _trimOrNull(_gstinController.text);
    entity.pan = _trimOrNull(_panController.text);
    entity.commissionPercentage = double.tryParse(
      _trim(_commissionController.text),
    );
    entity.paymentTerms = _trimOrNull(_paymentTermsController.text);
    final territoryText = _trim(_territoryController.text);
    final routeNameText = _selectedDealerRouteName?.trim();
    entity.territory = territoryText.isNotEmpty
        ? territoryText
        : (routeNameText != null && routeNameText.isNotEmpty
              ? routeNameText
              : null);
    entity.assignedRouteId = _selectedDealerRouteId;
    entity.assignedRouteName = _selectedDealerRouteName;
    entity.status = _status;
    entity.latitude = _latitude;
    entity.longitude = _longitude;

    await dealerRepo.saveDealer(entity);
  }

  Future<void> _saveSupplier() async {
    final suppliersService = context.read<SuppliersService>();

    final isVendor = _selectedType == PartnerType.vendor;
    final typeStr = isVendor ? 'vendor' : 'supplier';

    if (widget.existingPartner != null && widget.existingPartner is Supplier) {
      final existing = widget.existingPartner as Supplier;
      await suppliersService.updateSupplier(
        id: existing.id,
        name: _trim(_nameController.text),
        contactPerson: _trim(_contactPersonController.text),
        mobile: _trim(_mobileController.text),
        email: _trimOrNull(_emailController.text),
        address: _trim(_addressController.text),
        addressLine2: _trimOrNull(_addressLine2Controller.text),
        city: _trimOrNull(_cityController.text),
        state: _trimOrNull(_stateController.text),
        pincode: _normalizePincode(_pincodeController.text),
        gstin: _trimOrNull(_gstinController.text),
        pan: _trimOrNull(_panController.text),
        paymentTerms: _trimOrNull(_paymentTermsController.text),
        type: typeStr, // Update type if changed
      );
    } else {
      await suppliersService.addSupplier(
        name: _trim(_nameController.text),
        contactPerson: _trim(_contactPersonController.text),
        mobile: _trim(_mobileController.text),
        email: _trimOrNull(_emailController.text),
        address: _trim(_addressController.text),
        addressLine2: _trimOrNull(_addressLine2Controller.text),
        city: _trimOrNull(_cityController.text),
        state: _trimOrNull(_stateController.text),
        pincode: _normalizePincode(_pincodeController.text),
        gstin: _trimOrNull(_gstinController.text),
        pan: _trimOrNull(_panController.text),
        paymentTerms: _trimOrNull(_paymentTermsController.text),
        type: typeStr,
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Fetch user for role-based logic (listen: false as role unlikely to change while dialog is open)
    final user = Provider.of<AuthProvider>(context, listen: false).state.user;
    final isEditing = widget.existingPartner != null;
    final isSalesman = user?.role == UserRole.salesman;
    final isStoreIncharge = user?.role == UserRole.storeIncharge;
    final title = isEditing ? 'Edit Partner' : 'Add Partner';

    return DefaultTabController(
      length: 4,
      animationDuration: const Duration(milliseconds: 200),
      child: widget.fullScreen
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(title),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    ThemedTabBar(
                      tabs: const [
                        Tab(icon: Icon(Icons.info_outline), text: 'General'),
                        Tab(
                          icon: Icon(Icons.contact_phone_outlined),
                          text: 'Contact',
                        ),
                        Tab(
                          icon: Icon(Icons.business_outlined),
                          text: 'Business',
                        ),
                        Tab(
                          icon: Icon(Icons.location_on_outlined),
                          text: 'Address',
                        ),
                      ],
                    ),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TabBarView(
                          children: [
                            _buildGeneralTab(
                              isEditing,
                              isSalesman,
                              isStoreIncharge,
                            ),
                            _buildContactTab(),
                            _buildBusinessTab(),
                            _buildAddressTab(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text(
                                    'Save Partner',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Dialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: Responsive.width(context) * 0.9,
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 800,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business_center_rounded,
                            color: theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            title,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ThemedTabBar(
                      tabs: const [
                        Tab(icon: Icon(Icons.info_outline), text: 'General'),
                        Tab(
                          icon: Icon(Icons.contact_phone_outlined),
                          text: 'Contact',
                        ),
                        Tab(
                          icon: Icon(Icons.business_outlined),
                          text: 'Business',
                        ),
                        Tab(
                          icon: Icon(Icons.location_on_outlined),
                          text: 'Address',
                        ),
                      ],
                    ),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TabBarView(
                          children: [
                            _buildGeneralTab(
                              isEditing,
                              isSalesman,
                              isStoreIncharge,
                            ),
                            _buildContactTab(),
                            _buildBusinessTab(),
                            _buildAddressTab(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text(
                                    'Save Partner',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGeneralTab(
    bool isEditing,
    bool isSalesman,
    bool isStoreIncharge,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Information', Icons.badge_outlined),
          if (!isSalesman && !isStoreIncharge) ...[
            DropdownButtonFormField<PartnerType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Partner Type',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: PartnerType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: isEditing
                  ? null
                  : (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
            ),
            const SizedBox(height: 16),
          ],
          CustomTextField(
            label: _selectedType == PartnerType.customer
                ? 'Shop Name'
                : (_selectedType == PartnerType.vendor
                      ? 'Vendor / Service Center Name'
                      : 'Company Name'),
            controller: _nameController,
            prefixIcon: Icons.store_outlined,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: _selectedType == PartnerType.customer
                ? 'Owner Name'
                : 'Contact Person',
            controller: _contactPersonController,
            prefixIcon: Icons.person_outline,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          if (_selectedType != PartnerType.supplier &&
              _selectedType != PartnerType.vendor)
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(
                labelText: 'Account Status',
                prefixIcon: const Icon(Icons.toggle_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSectionHeader('Contact Details', Icons.contact_mail_outlined),
          CustomTextField(
            label: 'Primary Mobile',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (v) => v?.length != 10 ? 'Enter 10 digits' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Alternate Mobile (Optional)',
            controller: _altMobileController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_iphone_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v != null && v.isNotEmpty) {
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Invalid email';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSectionHeader(
            'Business Verification',
            Icons.verified_user_outlined,
          ),
          CustomTextField(
            label: 'GSTIN',
            controller: _gstinController,
            textCapitalization: TextCapitalization.characters,
            prefixIcon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'PAN Number',
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            prefixIcon: Icons.credit_card_outlined,
          ),
          if (_selectedType == PartnerType.customer) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Sales Configuration', Icons.route_outlined),
            Builder(
              builder: (context) {
                final customerRoutes = _dedupeRouteNames(_allRoutes);
                final selectedRoute = customerRoutes.contains(_selectedRoute)
                    ? _selectedRoute
                    : null;
                return DropdownButtonFormField<String>(
                  key: ValueKey(
                    'customer_route_${selectedRoute ?? 'none'}_${customerRoutes.length}',
                  ),
                  initialValue: selectedRoute,
                  decoration: InputDecoration(
                    labelText: 'Assigned Route',
                    prefixIcon: const Icon(Icons.map_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: customerRoutes
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRoute = val),
                  validator: (v) => v == null ? 'Required' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Credit Limit (\u20B9)',
              controller: _creditLimitController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.account_balance_wallet_outlined,
            ),
          ],
          if (_selectedType == PartnerType.dealer) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Dispatch Configuration', Icons.route_outlined),
            DropdownButtonFormField<String>(
              key: ValueKey(
                'dealer_route_${_selectedDealerRouteId ?? 'none'}_${_dealerRouteOptions.length}',
              ),
              initialValue: _selectedDealerRouteId,
              decoration: InputDecoration(
                labelText: 'Assigned Dispatch Route',
                prefixIcon: const Icon(Icons.map_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _dealerRouteOptions
                  .map(
                    (r) => DropdownMenuItem(
                      value: r['id'],
                      child: Text(r['name'] ?? ''),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedDealerRouteId = val;
                  final selected = _dealerRouteOptions.firstWhere(
                    (option) => option['id'] == val,
                    orElse: () => const {'id': '', 'name': ''},
                  );
                  _selectedDealerRouteName = selected['name'];
                  if (_territoryController.text.trim().isEmpty &&
                      _selectedDealerRouteName != null &&
                      _selectedDealerRouteName!.isNotEmpty) {
                    _territoryController.text = _selectedDealerRouteName!;
                  }
                });
              },
              validator: _status == 'active'
                  ? (v) => v == null || v.isEmpty ? 'Required' : null
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Commission (%)',
              controller: _commissionController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Territory',
              controller: _territoryController,
              prefixIcon: Icons.public_outlined,
            ),
          ],
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Payment Terms',
            controller: _paymentTermsController,
            prefixIcon: Icons.payment_outlined,
            hintText: 'e.g. Net 30, Cash on Delivery',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSectionHeader('Location Details', Icons.pin_drop_outlined),
          CustomTextField(
            label: 'Address Line 1',
            controller: _addressController,
            maxLines: 2,
            prefixIcon: Icons.location_on_outlined,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Address Line 2 (Optional)',
            controller: _addressLine2Controller,
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'City',
                  controller: _cityController,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'State',
                  controller: _stateController,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Pincode',
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (v) =>
                _normalizePincode(v ?? '') == null ? 'Enter 6 digits' : null,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('GPS Verification', Icons.my_location_outlined),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                if (_latitude != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Location Locked: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (_latitude != null && _longitude != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAddressSectionComplete()
                            ? Icons.verified_outlined
                            : Icons.info_outline,
                        size: 16,
                        color: _isAddressSectionComplete()
                            ? AppColors.success
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isAddressSectionComplete()
                              ? 'Address fields are ready for save.'
                              : 'Address partially filled. Complete required fields.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isAddressSectionComplete()
                                ? AppColors.success
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton.icon(
                  onPressed: _isCapturingLocation ? null : _captureLocation,
                  icon: _isCapturingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _isCapturingLocation
                        ? 'Capturing...'
                        : (_latitude == null
                              ? 'Capture Current Location'
                              : 'Update Location'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
