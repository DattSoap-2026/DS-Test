import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../widgets/ui/glass_container.dart'; // GlassContainer
import '../../widgets/ui/animated_card.dart'; // AnimatedCard
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class TransactionSeriesScreen extends StatefulWidget {
  final bool showHeader;

  const TransactionSeriesScreen({super.key, this.showHeader = true});

  @override
  State<TransactionSeriesScreen> createState() =>
      _TransactionSeriesScreenState();
}

class _TransactionSeriesScreenState extends State<TransactionSeriesScreen> {
  late final SettingsService _settingsService;
  bool _isLoading = true;
  bool _isSaving = false;
  List<TransactionSeries> _allSeries = [];
  String? _editingType;

  // Form State
  final _formKey = GlobalKey<FormState>();
  final _prefixController = TextEditingController();
  final _suffixController = TextEditingController();
  final _nextNumberController = TextEditingController(text: '1');
  final _paddingController = TextEditingController(text: '4');
  String _selectedFormat = '{PREFIX}-{YEAR}-{MONTH}-{NUMBER}';
  String _selectedReset = 'never';

  final List<Map<String, dynamic>> _transactionTypes = [
    {
      'id': 'Sale',
      'name': 'Sales Invoice',
      'icon': Icons.description,
      'color': AppColors.info,
    },
    {
      'id': 'Dispatch',
      'name': 'Dispatch Challan',
      'icon': Icons.local_shipping,
      'color': AppColors.success,
    },
    {
      'id': 'Purchase Order',
      'name': 'Purchase Order',
      'icon': Icons.shopping_cart,
      'color': AppColors.info,
    },
    {
      'id': 'Return Request',
      'name': 'Return Request',
      'icon': Icons.keyboard_return,
      'color': AppColors.warning,
    },
  ];

  final List<Map<String, String>> _formatOptions = [
    {
      'value': '{PREFIX}{NUMBER}',
      'label': 'Prefix + Number',
      'example': 'INV0127',
    },
    {
      'value': '{PREFIX}-{NUMBER}',
      'label': 'Prefix - Number',
      'example': 'INV-0127',
    },
    {
      'value': '{PREFIX}-{YEAR}-{NUMBER}',
      'label': 'Prefix - Year - Number',
      'example': 'INV-2025-0127',
    },
    {
      'value': '{PREFIX}-{YEAR}-{MONTH}-{NUMBER}',
      'label': 'Prefix - Year - Month - Number',
      'example': 'INV-2025-11-0127',
    },
    {
      'value': '{PREFIX}/{YEAR}/{NUMBER}',
      'label': 'Prefix / Year / Number',
      'example': 'INV/2025/0127',
    },
    {
      'value': '{PREFIX}{YEAR}{MONTH}{NUMBER}',
      'label': 'Compact (No separator)',
      'example': 'INV20251127',
    },
  ];

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _loadSeries();
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _suffixController.dispose();
    _nextNumberController.dispose();
    _paddingController.dispose();
    super.dispose();
  }

  Future<void> _loadSeries() async {
    setState(() => _isLoading = true);
    final data = await _settingsService.getTransactionSeries();
    if (mounted) {
      setState(() {
        _allSeries = data;
        _isLoading = false;
      });
    }
  }

  void _handleEdit(String type) {
    final existing = _allSeries.firstWhere(
      (s) => s.type == type,
      orElse: () => TransactionSeries(
        id: type,
        type: type,
        prefix: type == 'Sale'
            ? 'INV'
            : type == 'Dispatch'
            ? 'DSP'
            : type == 'Purchase Order'
            ? 'PO'
            : 'RTN',
        nextNumber: 1,
        padding: 4,
        format: '{PREFIX}-{YEAR}-{MONTH}-{NUMBER}',
        resetOn: 'never',
      ),
    );

    setState(() {
      _editingType = type;
      _prefixController.text = existing.prefix;
      _suffixController.text = existing.suffix ?? '';
      _nextNumberController.text = existing.nextNumber.toString();
      _paddingController.text = existing.padding.toString();
      _selectedFormat = existing.format;
      _selectedReset = existing.resetOn;
    });
  }

  String _generatePreview({
    required String prefix,
    String? suffix,
    required int nextNumber,
    required int padding,
    required String format,
  }) {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final number = nextNumber.toString().padLeft(padding, '0');

    String preview = format;
    preview = preview.replaceAll('{PREFIX}', prefix);
    preview = preview.replaceAll('{YEAR}', year);
    preview = preview.replaceAll('{MONTH}', month);
    preview = preview.replaceAll('{NUMBER}', number);

    if (suffix != null && suffix.isNotEmpty) {
      preview += suffix;
    }

    return preview;
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSaving = true);

    final isNew = !_allSeries.any((s) => s.type == _editingType);
    final series = TransactionSeries(
      id: _editingType!,
      type: _editingType!,
      prefix: _prefixController.text,
      suffix: _suffixController.text.isEmpty ? null : _suffixController.text,
      nextNumber: int.tryParse(_nextNumberController.text) ?? 1,
      padding: int.tryParse(_paddingController.text) ?? 4,
      format: _selectedFormat,
      resetOn: _selectedReset,
      lastResetDate: DateTime.now().toIso8601String(),
    );

    final success = await _settingsService.updateTransactionSeries(
      series,
      isNew,
      user.id,
      user.name,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        setState(() => _editingType = null);
        _loadSeries();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Configuration saved')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save configuration')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: widget.showHeader
          ? AppBar(
              title: const Text('Transaction Series'),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GlassContainer(
                    color: AppColors.info.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Configure automatic numbering for different document types. Each can have its own prefix, format, and reset rules.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._transactionTypes.map((type) => _buildTypeBlock(type)),
                  _buildHelpSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeBlock(Map<String, dynamic> typeData) {
    final typeId = typeData['id'] as String;
    final series = _allSeries.firstWhere(
      (s) => s.type == typeId,
      orElse: () => TransactionSeries(
        id: '',
        type: typeId,
        prefix: '',
        nextNumber: 1,
        padding: 4,
        format: '',
        resetOn: 'never',
      ),
    );
    final isConfigured = series.id.isNotEmpty;
    final isEditing = _editingType == typeId;

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (typeData['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                typeData['icon'] as IconData,
                color: typeData['color'] as Color,
              ),
            ),
            title: Text(
              typeData['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              isConfigured ? 'Configured' : 'Not configured',
              style: TextStyle(
                fontSize: 12,
                color: isConfigured
                    ? AppColors.success
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: isConfigured && !isEditing
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _generatePreview(
                        prefix: series.prefix,
                        suffix: series.suffix,
                        nextNumber: series.nextNumber,
                        padding: series.padding,
                        format: series.format,
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          if (!isEditing)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CustomButton(
                label: isConfigured ? 'Edit Configuration' : 'Configure Series',
                variant: isConfigured
                    ? ButtonVariant.outlined
                    : ButtonVariant.filled,
                icon: Icons.settings,
                onPressed: () => _handleEdit(typeId),
              ),
            )
          else
            _buildEditor(typeId),
        ],
      ),
    );
  }

  Widget _buildEditor(String typeId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedFormat,
              isExpanded: true,
              itemHeight: null,
              selectedItemBuilder: (context) => _formatOptions
                  .map(
                    (opt) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        opt['label']!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Number Format',
                border: OutlineInputBorder(),
              ),
              items: _formatOptions
                  .map(
                    (opt) => DropdownMenuItem(
                      value: opt['value'],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              opt['label']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              opt['example']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedFormat = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _prefixController,
                    label: 'Prefix',
                    hintText: 'e.g., INV',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _suffixController,
                    label: 'Suffix (Optional)',
                    hintText: 'e.g., /FY25',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _nextNumberController,
                    label: 'Next Number',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        int.tryParse(v!) == null ? 'Must be a number' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _paddingController,
                    label: 'Padding (Digits)',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final p = int.tryParse(v!);
                      if (p == null) return 'Must be a number';
                      if (p < 2 || p > 8) return '2 to 8';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedReset,
              decoration: const InputDecoration(
                labelText: 'Auto Reset',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'never',
                  child: Text('Never (Continuous)'),
                ),
                DropdownMenuItem(
                  value: 'year',
                  child: Text('Yearly (Jan 1st)'),
                ),
                DropdownMenuItem(
                  value: 'month',
                  child: Text('Monthly (1st of month)'),
                ),
              ],
              onChanged: (val) => setState(() => _selectedReset = val!),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.infoBg, AppColors.infoBg],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Live Preview',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatePreview(
                      prefix: _prefixController.text,
                      suffix: _suffixController.text,
                      nextNumber: int.tryParse(_nextNumberController.text) ?? 1,
                      padding: int.tryParse(_paddingController.text) ?? 4,
                      format: _selectedFormat,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Cancel',
                    variant: ButtonVariant.outlined,
                    onPressed: () => setState(() => _editingType = null),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: 'Save Changes',
                    onPressed: _saveConfiguration,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'HOW IT WORKS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpItem('{PREFIX}', 'Your custom prefix (e.g., INV, PO)'),
            _buildHelpItem('{YEAR}', 'Current year (e.g., 2025)'),
            _buildHelpItem('{MONTH}', 'Current month (01-12)'),
            _buildHelpItem('{NUMBER}', 'Auto-incrementing padded number'),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String code, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
