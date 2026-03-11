import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/master_data_service.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class TaxSettingsScreen extends StatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  State<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends State<TaxSettingsScreen> {
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
    setState(() => _isLoading = true);
    final types = await _masterDataService.getProductTypes();
    if (mounted) {
      setState(() {
        _productTypes = types;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tax Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Configure default GST rates for different product categories',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _productTypes.length,
              itemBuilder: (context, index) {
                final type = _productTypes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      type.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('SKU Prefix: ${type.skuPrefix}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Default GST: ',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${type.defaultGst}%',
                            style: const TextStyle(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
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
      ),
    );
  }

  void _editGst(DynamicProductType type) {
    final controller = TextEditingController(text: type.defaultGst.toString());
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Text('Edit GST for ${type.name}'),
        content: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'GST Percent',
            suffixText: '%',
          ),
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
                    SnackBar(content: Text(success ? 'Updated' : 'Failed')),
                  );
                  if (success) _loadData();
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

