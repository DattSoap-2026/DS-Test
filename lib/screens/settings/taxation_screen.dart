import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../services/master_data_service.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class TaxationScreen extends StatefulWidget {
  final bool showHeader;

  const TaxationScreen({super.key, this.showHeader = true});

  @override
  State<TaxationScreen> createState() => _TaxationScreenState();
}

class _TaxationScreenState extends State<TaxationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = ThemedTabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'General GST Config'),
        Tab(text: 'Product Tax Rates'),
      ],
    );

    if (widget.showHeader) {
      return Scaffold(
        appBar: AppBar(title: const Text('Taxation Management'), bottom: tabBar),
        body: TabBarView(
          controller: _tabController,
          children: const [_GstConfigurationTab(), _ProductTaxRatesTab()],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardTheme.color,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: tabBar,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_GstConfigurationTab(), _ProductTaxRatesTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// --- TAB 1: General GST Configuration (From GstSettingsScreen) ---

class _GstConfigurationTab extends StatefulWidget {
  const _GstConfigurationTab();

  @override
  State<_GstConfigurationTab> createState() => _GstConfigurationTabState();
}

class _GstConfigurationTabState extends State<_GstConfigurationTab> {
  late final SettingsService _settingsService;
  bool _isLoading = true;
  bool _isSaving = false;

  bool _isEnabled = false;
  String _defaultGstType = 'none';
  double _defaultGstPercentage = 0;
  String _gstin = '';

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final settings = await _settingsService.getGstSettings();
      if (mounted && settings != null) {
        setState(() {
          _isEnabled = settings.isEnabled;
          _defaultGstType = settings.defaultGstType.toLowerCase();
          _defaultGstPercentage = settings.defaultGstPercentage;
          _gstin = settings.gstin;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
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
    final settings = GstSettings(
      isEnabled: _isEnabled,
      defaultGstType: _defaultGstType,
      defaultGstPercentage: _defaultGstPercentage,
      gstin: _gstin,
    );

    final success = await _settingsService.updateGstSettings(
      settings,
      user.id,
      user.name,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('GST settings saved')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Global GST Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Enable GST system-wide and configure your company GSTIN.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                SwitchListTile(
                  title: const Text('Enable GST Calculation'),
                  subtitle: const Text(
                    'Turn this on to calculate taxes on invoices',
                  ),
                  value: _isEnabled,
                  onChanged: (v) => setState(() => _isEnabled = v),
                ),
                const Divider(height: 32),

                CustomTextField(
                  label: 'Company GSTIN',
                  initialValue: _gstin,
                  hintText: 'e.g. 27ABCDE1234F1Z5',
                  onChanged: (v) => _gstin = v,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Default Values',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _defaultGstType,
                        decoration: const InputDecoration(
                          labelText: 'Default Tax Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text('None (No Tax)'),
                          ),
                          DropdownMenuItem(
                            value: 'cgstSgst',
                            child: Text('CGST + SGST'),
                          ),
                          DropdownMenuItem(value: 'igst', child: Text('IGST')),
                        ],
                        onChanged: _isEnabled
                            ? (v) => setState(() => _defaultGstType = v!)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Standard Rate (%)',
                        initialValue: _defaultGstPercentage.toString(),
                        keyboardType: TextInputType.number,
                        readOnly: !_isEnabled,
                        onChanged: (v) =>
                            _defaultGstPercentage = double.tryParse(v) ?? 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Save Configuration',
            icon: Icons.save,
            isLoading: _isSaving,
            onPressed: _handleSave,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

// --- TAB 2: Product Tax Rates (From TaxSettingsScreen) ---

class _ProductTaxRatesTab extends StatefulWidget {
  const _ProductTaxRatesTab();

  @override
  State<_ProductTaxRatesTab> createState() => _ProductTaxRatesTabState();
}

class _ProductTaxRatesTabState extends State<_ProductTaxRatesTab> {
  late final MasterDataService _masterDataService;
  List<DynamicProductType> _productTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _masterDataService = context.read<MasterDataService>();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final types = await _masterDataService.getProductTypes();
    if (mounted) {
      setState(() {
        _productTypes = types;
        _isLoading = false;
      });
    }
  }

  void _editGst(DynamicProductType type) {
    final controller = TextEditingController(text: type.defaultGst.toString());
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Text('Edit Tax Rate: ${type.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set the default GST percentage for all ${type.name} products.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'GST Percent',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newGst = double.tryParse(controller.text);
              if (newGst != null) {
                final success = await _masterDataService.updateProductType(
                  type.id,
                  {'defaultGst': newGst},
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Updated rate successfully'
                            : 'Failed to update',
                      ),
                    ),
                  );
                  if (success) _loadData();
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Category Tax Rates',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Define specific tax rates for each product category. These override the global default if set.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          if (_productTypes.isEmpty)
            const Center(child: Text("No product categories found.")),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _productTypes.length,
            itemBuilder: (context, index) {
              final type = _productTypes[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.info.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.category_outlined,
                      color: AppColors.info,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    type.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('SKU Prefix: ${type.skuPrefix}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '${type.defaultGst}% GST',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit Rate',
                        onPressed: () => _editGst(type),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

