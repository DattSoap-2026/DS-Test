import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/incentives_service.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

// DEPRECATED: replaced by IncentivesScreen
class IncentivesManagementScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool showHeader;
  const IncentivesManagementScreen({
    super.key,
    this.onBack,
    this.showHeader = true,
  });

  @override
  State<IncentivesManagementScreen> createState() =>
      _IncentivesManagementScreenState();
}

class _IncentivesManagementScreenState
    extends State<IncentivesManagementScreen> {
  late final IncentivesService _incentivesService;
  bool _isLoading = true;
  late IncentiveSettings _settings;

  @override
  void initState() {
    super.initState();
    _incentivesService = context.read<IncentivesService>();
    _loadIncentives();
  }

  Future<void> _loadIncentives() async {
    setState(() => _isLoading = true);
    final settings = await _incentivesService.getIncentives();
    if (mounted) {
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveIncentives() async {
    setState(() => _isLoading = true);
    final success = await _incentivesService.saveIncentives(_settings);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Settings updated' : 'Save failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.showHeader)
                  _buildScreenHeader()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.save_outlined,
                            size: 24,
                          ),
                          onPressed: _saveIncentives,
                          tooltip: 'Save Settings',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.info),
                          onPressed: _loadIncentives,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('Attendance & Targets'),
                        _buildInput(
                          'Required Monthly Work Days',
                          _settings.requiredMonthlyWorkDays,
                          Icons.calendar_today,
                          (val) {
                            _settings = IncentiveSettings.fromJson({
                              ..._settings.toJson(),
                              'requiredMonthlyWorkDays': int.tryParse(val) ?? 0,
                            });
                          },
                        ),
                        _buildInput(
                          'Daily Counter Target (Shops)',
                          _settings.dailyCounterTarget,
                          Icons.store,
                          (val) {
                            _settings = IncentiveSettings.fromJson({
                              ..._settings.toJson(),
                              'dailyCounterTarget': int.tryParse(val) ?? 0,
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        _sectionHeader('Incentive Rates'),
                        _buildInput(
                          'Daily Incentive Amount (₹)',
                          _settings.dailyIncentiveAmount,
                          Icons.currency_rupee,
                          (val) {
                            _settings = IncentiveSettings.fromJson({
                              ..._settings.toJson(),
                              'dailyIncentiveAmount': double.tryParse(val) ?? 0,
                            });
                          },
                          isDecimal: true,
                        ),
                        _buildInput(
                          'New Customer Incentive (₹)',
                          _settings.newCustomerIncentive,
                          Icons.person_add,
                          (val) {
                            _settings = IncentiveSettings.fromJson({
                              ..._settings.toJson(),
                              'newCustomerIncentive': double.tryParse(val) ?? 0,
                            });
                          },
                          isDecimal: true,
                        ),
                        const SizedBox(height: 32),
                        _sectionHeader('Penalties'),
                        _buildInput(
                          'Mileage Penalty Rate (₹ per KM diff)',
                          _settings.mileagePenaltyAmount,
                          Icons.trending_down,
                          (val) {
                            _settings = IncentiveSettings.fromJson({
                              ..._settings.toJson(),
                              'mileagePenaltyAmount': double.tryParse(val) ?? 0,
                            });
                          },
                          isDecimal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildScreenHeader() {
    return MasterScreenHeader(
      title: 'Incentives',
      subtitle: 'Sales incentive rules',
      helperText:
          'Incentives are calculated automatically during sales. Manual edits are not allowed later.',
      color: AppColors.success,
      icon: Icons.monetization_on,
      onBack: widget.onBack,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.save_outlined,
            size: 28,
          ),
          onPressed: _saveIncentives,
          tooltip: 'Save Settings',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.info),
          onPressed: _loadIncentives,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    dynamic initialValue,
    IconData icon,
    Function(String) onChanged, {
    bool isDecimal = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue.toString(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
        ),
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }
}
