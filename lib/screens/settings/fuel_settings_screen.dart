import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class FuelSettingsScreen extends StatefulWidget {
  final bool showHeader;

  const FuelSettingsScreen({super.key, this.showHeader = true});

  @override
  State<FuelSettingsScreen> createState() => _FuelSettingsScreenState();
}
class _FuelSettingsScreenState extends State<FuelSettingsScreen> {
  late final SettingsService _settingsService;
  late final VehiclesService _vehiclesService;
  bool _isLoading = true;
  bool _isSaving = false;

  // Data
  FuelSettings _settings = FuelSettings(
    globalMinMileage: 10,
    globalPenaltyRate: 5,
    vehicleOverrides: {},
  );
  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;

  // Controllers
  final _globalMinMileageController = TextEditingController();
  final _globalPenaltyRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _vehiclesService = context.read<VehiclesService>();
    _loadAll();
  }

  @override
  void dispose() {
    _globalMinMileageController.dispose();
    _globalPenaltyRateController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _settingsService.getFuelSettings();
      final vehicles = await _vehiclesService
          .getVehiclesOnce(); // Assuming this method exists or similar

      if (mounted) {
        setState(() {
          if (settings != null) {
            _settings = settings;
            _globalMinMileageController.text = _settings.globalMinMileage
                .toString();
            _globalPenaltyRateController.text = _settings.globalPenaltyRate
                .toString();
          }
          _vehicles = vehicles.where((v) => v.status == 'active').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleSave() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSaving = true);

    final finalSettings = FuelSettings(
      globalMinMileage:
          double.tryParse(_globalMinMileageController.text) ??
          _settings.globalMinMileage,
      globalPenaltyRate:
          double.tryParse(_globalPenaltyRateController.text) ??
          _settings.globalPenaltyRate,
      vehicleOverrides: _settings.vehicleOverrides,
    );

    final success = await _settingsService.updateFuelSettings(
      finalSettings,
      user.id,
      user.name,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fuel settings saved')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings')),
        );
      }
    }
  }

  void _handleAddOverride() {
    if (_selectedVehicleId == null) return;
    if (_settings.vehicleOverrides.containsKey(_selectedVehicleId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Override already exists for this vehicle'),
        ),
      );
      return;
    }

    setState(() {
      _settings.vehicleOverrides[_selectedVehicleId!] = VehicleFuelOverride(
        minMileage: _settings.globalMinMileage,
        penaltyRate: _settings.globalPenaltyRate,
      );
      _selectedVehicleId = null;
    });
  }

  void _handleRemoveOverride(String vehicleId) {
    setState(() {
      _settings.vehicleOverrides.remove(vehicleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: widget.showHeader
          ? AppBar(
              title: const Text('Fuel Settings'),
              backgroundColor: const Color(0xFF4f46e5),
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlobalCard(),
                  const SizedBox(height: 24),
                  _buildOverridesCard(),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Save Fuel Settings',
                    icon: Icons.save,
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGlobalCard() {
    final colors = Theme.of(context).colorScheme;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Global Defaults',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'These settings apply to all vehicles unless overridden.',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;

              final minMileageField = CustomTextField(
                controller: _globalMinMileageController,
                label: 'Min Mileage (km/l)',
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null) {
                    _settings = FuelSettings(
                      globalMinMileage: val,
                      globalPenaltyRate: _settings.globalPenaltyRate,
                      vehicleOverrides: _settings.vehicleOverrides,
                    );
                  }
                },
              );

              final penaltyField = CustomTextField(
                controller: _globalPenaltyRateController,
                label: 'Penalty Rate (\u20B9/deficit)',
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null) {
                    _settings = FuelSettings(
                      globalMinMileage: _settings.globalMinMileage,
                      globalPenaltyRate: val,
                      vehicleOverrides: _settings.vehicleOverrides,
                    );
                  }
                },
              );

              if (isNarrow) {
                return Column(
                  children: [
                    minMileageField,
                    const SizedBox(height: 12),
                    penaltyField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: minMileageField),
                  const SizedBox(width: 16),
                  Expanded(child: penaltyField),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverridesCard() {
    final colors = Theme.of(context).colorScheme;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Overrides',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Set targets for specific vehicles (trucks vs vans).',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;
              final dropdown = DropdownButtonFormField<String>(
                initialValue: _selectedVehicleId,
                decoration: const InputDecoration(
                  labelText: 'Select Vehicle',
                  border: OutlineInputBorder(),
                ),
                items: _vehicles
                    .map(
                      (v) => DropdownMenuItem(
                        value: v.id,
                        child: Text('${v.name} (${v.number})'),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedVehicleId = val),
              );

              final addButton = CustomButton(
                label: 'Add',
                icon: Icons.add,
                onPressed: _handleAddOverride,
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    dropdown,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: addButton),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: dropdown),
                  const SizedBox(width: 12),
                  addButton,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          if (_settings.vehicleOverrides.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No overrides configured',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            )
          else
            ..._settings.vehicleOverrides.entries.map(
              (entry) => _buildOverrideRow(entry.key, entry.value),
            ),
        ],
      ),
    );
  }

  Widget _buildOverrideRow(String vehicleId, VehicleFuelOverride override) {
    final colors = Theme.of(context).colorScheme;
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => Vehicle(
        id: vehicleId,
        name: 'Unknown',
        number: '',
        status: '',
        type: 'Unknown',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      vehicle.number.isEmpty ? vehicleId : vehicle.number,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _handleRemoveOverride(vehicleId),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;

              final minMileageInput = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Min Mileage',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  TextFormField(
                    initialValue: override.minMileage.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null) {
                        setState(() {
                          _settings.vehicleOverrides[vehicleId] =
                              VehicleFuelOverride(
                                minMileage: val,
                                penaltyRate: override.penaltyRate,
                              );
                        });
                      }
                    },
                  ),
                ],
              );

              final penaltyInput = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penalty Rate',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  TextFormField(
                    initialValue: override.penaltyRate.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null) {
                        setState(() {
                          _settings.vehicleOverrides[vehicleId] =
                              VehicleFuelOverride(
                                minMileage: override.minMileage,
                                penaltyRate: val,
                              );
                        });
                      }
                    },
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  children: [
                    minMileageInput,
                    const SizedBox(height: 12),
                    penaltyInput,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: minMileageInput),
                  const SizedBox(width: 16),
                  Expanded(child: penaltyInput),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


