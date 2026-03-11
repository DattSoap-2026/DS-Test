import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../core/constants/currencies.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class CurrenciesScreen extends StatefulWidget {
  final bool showHeader;

  const CurrenciesScreen({super.key, this.showHeader = true});

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  late final SettingsService _settingsService;
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<AppCurrency> _currencies = [];

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() => _isLoading = true);
    try {
      final currs = await _settingsService.getCurrencies();
      if (mounted) {
        setState(() {
          _currencies = currs;
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

  void _showCurrencyDialog([AppCurrency? currency]) {
    WorldCurrency? selectedWorldCurrency;
    if (currency != null) {
      selectedWorldCurrency = worldCurrencies.firstWhere(
        (c) => c.code == currency.code,
        orElse: () => WorldCurrency(
          code: currency.code,
          name: currency.name,
          symbol: currency.symbol,
        ),
      );
    }

    final rateController = TextEditingController(
      text: currency?.exchangeRate.toString() ?? '1.0',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ResponsiveAlertDialog(
          title: Text(currency == null ? 'Add Currency' : 'Edit Currency'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currency == null)
                  DropdownButtonFormField<WorldCurrency>(
                    initialValue: selectedWorldCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Select Currency',
                    ),
                    items: worldCurrencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.name} (${c.code})'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedWorldCurrency = val),
                  )
                else
                  ListTile(
                    title: Text('${currency.name} (${currency.code})'),
                    subtitle: Text('Symbol: ${currency.symbol}'),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Exchange Rate (to Base)',
                    helperText: '1 Base = X this currency',
                  ),
                  enabled: !(currency?.isBaseCurrency ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (selectedWorldCurrency == null) return;

                      final user = context.read<AuthProvider>().state.user;
                      if (user == null) return;

                      final rate = double.tryParse(rateController.text) ?? 1.0;

                      final data = {
                        'name': selectedWorldCurrency!.name,
                        'code': selectedWorldCurrency!.code,
                        'symbol': selectedWorldCurrency!.symbol,
                        'exchangeRate': rate,
                        'isBaseCurrency': currency?.isBaseCurrency ?? false,
                      };

                      setState(() => _isSubmitting = true);
                      bool success;
                      if (currency == null) {
                        // Check if already exists
                        if (_currencies.any(
                          (c) => c.code == selectedWorldCurrency!.code,
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Currency already added'),
                            ),
                          );
                          setState(() => _isSubmitting = false);
                          return;
                        }
                        success = await _settingsService.addCurrency(
                          data,
                          user.id,
                          user.name,
                        );
                      } else {
                        success = await _settingsService.updateCurrency(
                          currency.id,
                          data,
                          user.id,
                          user.name,
                        );
                      }

                      if (context.mounted) {
                        setState(() => _isSubmitting = false);
                        if (success) {
                          Navigator.pop(context);
                          _loadCurrencies();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save currency'),
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteCurrency(AppCurrency currency) async {
    if (currency.isBaseCurrency) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete base currency')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Currency'),
        content: Text('Are you sure you want to delete ${currency.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().state.user;
      if (user == null) return;
      await _settingsService.deleteCurrency(currency.id, user.id, user.name);
      _loadCurrencies();
    }
  }

  Future<void> _handleSetBaseCurrency(AppCurrency currency) async {
    if (currency.isBaseCurrency) return;

    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    final success = await _settingsService.setBaseCurrency(
      currency.id,
      _currencies,
      user.id,
      user.name,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _loadCurrencies();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set base currency')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseCurrency = _currencies.firstWhere(
      (c) => c.isBaseCurrency,
      orElse: () => AppCurrency(
        id: '',
        name: 'None',
        code: 'NONE',
        symbol: '',
        exchangeRate: 1.0,
      ),
    );
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: widget.showHeader
          ? AppBar(
              title: const Text('Currencies'),
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
              foregroundColor: colors.onPrimary,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCurrencies,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GlassContainer(
                    color: AppColors.info.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Base Currency',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The base currency is the primary currency for your ERP. All other exchange rates are relative to this.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.info,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${baseCurrency.name} (${baseCurrency.code})',
                                  style: TextStyle(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currencies.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.money_off,
                            size: 64,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          const Text('No currencies added'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _showCurrencyDialog(),
                            child: const Text('Add First Currency'),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._currencies.map((curr) => _buildCurrencyCard(curr)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_currency_fab',
        onPressed: () => _showCurrencyDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrencyCard(AppCurrency currency) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Text(
              currency.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '(${currency.code})',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
            if (currency.isBaseCurrency)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'BASE',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          'Rate: ${currency.exchangeRate} · Symbol: ${currency.symbol}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!currency.isBaseCurrency)
              IconButton(
                icon: const Icon(Icons.star_border, color: AppColors.warning),
                tooltip: 'Set as Base',
                onPressed: () => _handleSetBaseCurrency(currency),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showCurrencyDialog(currency),
            ),
            if (!currency.isBaseCurrency)
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => _handleDeleteCurrency(currency),
              ),
          ],
        ),
      ),
    );
  }
}


