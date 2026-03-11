import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/vehicles_provider.dart';
import '../../../services/vehicles_service.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/dialogs/responsive_alert_dialog.dart';

class VehicleIssueReportDialog extends ConsumerStatefulWidget {
  final Vehicle? initialVehicle;

  const VehicleIssueReportDialog({super.key, this.initialVehicle});

  @override
  ConsumerState<VehicleIssueReportDialog> createState() =>
      _VehicleIssueReportDialogState();
}

class _VehicleIssueReportDialogState
    extends ConsumerState<VehicleIssueReportDialog> {
  final _formKey = GlobalKey<FormState>();
  Vehicle? _selectedVehicle;
  String? _description;
  String _priority = 'Medium';
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.initialVehicle;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
      return;
    }

    setState(() => _isSaving = true);
    _formKey.currentState!.save();

    try {
      final reportedByUser = ref.read(authProviderProvider).currentUser;
      final issue = VehicleIssue(
        id: '', // Service will generate ID
        vehicleId: _selectedVehicle!.id,
        vehicleNumber: _selectedVehicle!.number,
        reportedBy: reportedByUser?.name ?? reportedByUser?.id ?? 'Unknown',
        reportedDate: _date.toIso8601String(),
        description: _description!,
        priority: _priority,
        status: 'Open',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await ref.read(vehiclesServiceProvider).addVehicleIssue(issue);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error reporting issue: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no initial vehicle, we need to fetch list.
    // Assuming parent passes list or we use Consumer<VehiclesService> if needed.
    // For simplicity, let's assume we can get vehicles from provider.

    return ResponsiveAlertDialog(
      title: const Text('Report Issue'),
      content: SizedBox(
        width: Responsive.clamp(context, min: 280, max: 480, ratio: 0.45),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.initialVehicle != null)
                TextFormField(
                  initialValue:
                      '${widget.initialVehicle!.name} (${widget.initialVehicle!.number})',
                  decoration: const InputDecoration(
                    labelText: 'Vehicle',
                    filled: true,
                    enabled: false,
                  ),
                )
              else
                ref
                    .watch(vehiclesFutureProvider)
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) =>
                          Text('Error loading vehicles: $err'),
                      data: (vehiclesList) {
                        // Keep one stable entry per vehicle id to prevent duplicate-value
                        // assertions in DropdownButtonFormField.
                        final seenIds = <String>{};
                        final vehicles = <Vehicle>[];
                        for (final vehicle in vehiclesList) {
                          if (seenIds.add(vehicle.id)) {
                            vehicles.add(vehicle);
                          }
                        }

                        Vehicle? selectedFromList;
                        final selectedId = _selectedVehicle?.id;
                        if (selectedId != null) {
                          for (final vehicle in vehicles) {
                            if (vehicle.id == selectedId) {
                              selectedFromList = vehicle;
                              break;
                            }
                          }
                        }

                        return DropdownButtonFormField<Vehicle>(
                          key: ValueKey(selectedFromList?.id ?? 'no_vehicle'),
                          initialValue: selectedFromList,
                          decoration: const InputDecoration(
                            labelText: 'Select Vehicle',
                            filled: true,
                            border: OutlineInputBorder(),
                          ),
                          items: vehicles
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text('${v.name} (${v.number})'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedVehicle = v),
                          validator: (v) => v == null ? 'Required' : null,
                        );
                      },
                    ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                items: ['Low', 'Medium', 'High', 'Critical']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  border: OutlineInputBorder(),
                  hintText: 'Describe the issue...',
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_date)),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
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
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Report Issue'),
        ),
      ],
    );
  }
}
