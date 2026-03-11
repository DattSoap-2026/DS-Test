import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/sales_targets_service.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_text_field.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class RouteTargetsScreen extends StatefulWidget {
  const RouteTargetsScreen({super.key});

  @override
  State<RouteTargetsScreen> createState() => _RouteTargetsScreenState();
}

class _RouteTargetsScreenState extends State<RouteTargetsScreen> {
  late final SalesTargetsService _targetsService;
  late final UsersService _usersService;

  bool _isLoading = true;
  bool _isSaving = false;

  List<AppUser> _salesmen = [];
  String? _selectedSalesmanId;
  DateTime _selectedDate = DateTime.now();

  final Map<String, TextEditingController> _controllers = {};
  final List<String> _routes = [];
  SalesTarget? _prevTarget;

  @override
  void initState() {
    super.initState();
    _targetsService = context.read<SalesTargetsService>();
    _usersService = context.read<UsersService>();
    _init();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      final salesmen = await _usersService.getUsers(role: UserRole.salesman);
      if (mounted) {
        setState(() {
          _salesmen = salesmen;
          if (salesmen.isNotEmpty) {
            _selectedSalesmanId = salesmen[0].id;
          }
          _isLoading = false;
        });
        if (_selectedSalesmanId != null) await _loadTargets();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _loadTargets() async {
    if (_selectedSalesmanId == null) return;

    setState(() => _isLoading = true);
    try {
      final targets = await _targetsService.getSalesTargets(_selectedSalesmanId);
      
      final current = targets.cast<SalesTarget?>().firstWhere(
        (t) => t!.month == _selectedDate.month && t.year == _selectedDate.year,
        orElse: () => null,
      );

      final prevDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      final prev = targets.cast<SalesTarget?>().firstWhere(
        (t) => t!.month == prevDate.month && t.year == prevDate.year,
        orElse: () => null,
      );

      _routes.clear();
      _controllers.clear();

      if (current?.routeTargets != null) {
        _routes.addAll(current!.routeTargets!.keys);
      }
      if (prev?.routeTargets != null) {
        for (var route in prev!.routeTargets!.keys) {
          if (!_routes.contains(route)) _routes.add(route);
        }
      }
      _routes.sort();

      for (var route in _routes) {
        final value = current?.routeTargets?[route] ?? 0;
        _controllers[route] = TextEditingController(
          text: value > 0 ? value.toString() : '',
        );
      }

      if (mounted) {
        setState(() {
          _prevTarget = prev;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _autoCalculateTargets() {
    if (_prevTarget?.routeTargets == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous month data to calculate from')),
      );
      return;
    }

    setState(() {
      for (var route in _routes) {
        final prevValue = (_prevTarget!.routeTargets![route] as num?)?.toDouble() ?? 0;
        final newValue = prevValue * 1.02; // +2%
        _controllers[route]?.text = newValue.round().toString();
      }
    });
  }

  Future<void> _saveTargets() async {
    if (_selectedSalesmanId == null) return;

    final routeTargets = <String, dynamic>{};
    double totalTarget = 0;

    for (var route in _routes) {
      final value = double.tryParse(_controllers[route]?.text ?? '0') ?? 0;
      if (value > 0) {
        routeTargets[route] = value;
        totalTarget += value;
      }
    }

    if (routeTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set at least one route target')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final salesman = _salesmen.firstWhere((s) => s.id == _selectedSalesmanId);
      final success = await _targetsService.setSalesTarget(
        AddSalesTargetPayload(
          salesmanId: _selectedSalesmanId!,
          salesmanName: salesman.name,
          month: _selectedDate.month,
          year: _selectedDate.year,
          targetAmount: totalTarget,
          routeTargets: routeTargets,
        ),
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Targets saved successfully')),
          );
          await _loadTargets();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save targets')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Targets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _isLoading ? null : _autoCalculateTargets,
            tooltip: 'Auto Calculate (+2%)',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSalesmanId,
                        decoration: const InputDecoration(
                          labelText: 'Salesman',
                          border: OutlineInputBorder(),
                        ),
                        items: _salesmen.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedSalesmanId = val);
                          _loadTargets();
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                            _loadTargets();
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('MMMM yyyy').format(_selectedDate)),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _routes.isEmpty
                      ? Center(
                          child: Text(
                            'No routes found. Add routes in previous month first.',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _routes.length,
                          itemBuilder: (context, index) {
                            final route = _routes[index];
                            final prevValue = (_prevTarget?.routeTargets?[route] as num?)?.toDouble() ?? 0;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            route,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (prevValue > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.info.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Prev: ₹${NumberFormat('#,##,###').format(prevValue.round())}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.info,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      label: 'Target Amount',
                                      hintText: '0',
                                      controller: _controllers[route],
                                      keyboardType: TextInputType.number,
                                      prefixText: '₹ ',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            label: 'Save Targets',
            icon: Icons.save,
            isLoading: _isSaving,
            onPressed: _saveTargets,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
