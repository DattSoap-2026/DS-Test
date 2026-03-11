// ⚠️ CRITICAL FILE - DO NOT MODIFY WITHOUT PERMISSION
// Schemes management screen with searchable product dropdowns.
// Modified: Replaced standard dropdowns with SearchableDropdown, fixed overflow in scheme cards
// Contact: Developer before making changes

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/schemes_service.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart';
import '../../utils/normalized_number_input_formatter.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import '../../widgets/searchable_dropdown.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  late final SchemesService _schemesService;
  late final ProductsService _productsService;

  bool _isLoading = true;
  List<Scheme> _schemes = [];
  List<Product> _products = [];
  String _searchTerm = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _schemesService = context.read<SchemesService>();
    _productsService = context.read<ProductsService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _schemesService.getSchemes(),
        _productsService.getProducts(),
      ]);

      if (mounted) {
        setState(() {
          _schemes = results[0] as List<Scheme>;
          _products = (results[1] as List<Product>)
              .where((p) => p.status == 'active')
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Map<String, int> get _stats {
    final now = DateTime.now();
    int active = 0;
    int expiringSoon = 0;
    for (var s in _schemes) {
      if (s.status == 'active') {
        active++;
        final to = DateTime.tryParse(s.validTo);
        if (to != null &&
            to.isAfter(now) &&
            to.difference(now).inDays <= 7) {
          expiringSoon++;
        }
      }
    }
    return {
      'total': _schemes.length,
      'active': active,
      'expiring': expiringSoon,
    };
  }

  List<Scheme> get _filteredSchemes {
    return _schemes.where((s) {
      final matchesSearch =
          s.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchTerm.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || s.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _getSchemeOfferText(Scheme scheme) {
    final buyProduct = _products.firstWhere(
      (p) => p.id == scheme.buyProductId,
      orElse: () => Product(
        id: '',
        name: 'Unknown',
        sku: 'UNKNOWN',
        itemType: ProductType.rawMaterial,
        type: ProductTypeEnum.raw,
        category: 'Unknown',
        stock: 0,
        baseUnit: 'kg',
        conversionFactor: 1,
        price: 0,
        status: 'active',
        createdAt: '',
        unitWeightGrams: 0,
      ),
    );
    final getProduct = _products.firstWhere(
      (p) => p.id == scheme.getProductId,
      orElse: () => Product(
        id: '',
        name: 'Unknown',
        sku: 'UNKNOWN',
        itemType: ProductType.rawMaterial,
        type: ProductTypeEnum.raw,
        category: 'Unknown',
        stock: 0,
        baseUnit: 'kg',
        conversionFactor: 1,
        price: 0,
        status: 'active',
        createdAt: '',
        unitWeightGrams: 0,
      ),
    );
    return 'Buy ${scheme.buyQuantity} of ${buyProduct.name}, Get ${scheme.getQuantity} of ${getProduct.name} FREE';
  }

  bool _isExpired(String validTo) {
    final parsed = DateTime.tryParse(validTo);
    if (parsed == null) return false;
    return parsed.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading && _schemes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildScreenHeader(),
                _buildStatsBar(),
                _buildFilterBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: _filteredSchemes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredSchemes.length,
                            itemBuilder: (context, index) =>
                                _buildSchemeCard(_filteredSchemes[index]),
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'schemes_fab',
        onPressed: () => _showForm(),
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
    );
  }

  Widget _buildScreenHeader() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      color: theme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Promotions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Manage schemes, offers and loyalty rewards',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.info),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final s = _stats;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Schemes',
              '${s['total']}',
              Icons.local_offer,
              AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Active',
              '${s['active']}',
              Icons.check_circle,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Expiring Soon',
              '${s['expiring']}',
              Icons.timer,
              AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search schemes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchTerm = v),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _statusFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            onChanged: (v) => setState(() => _statusFilter = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    final expired = _isExpired(scheme.validTo);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration,
                    color: colors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        scheme.description,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(scheme.status, expired),
              ],
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: colors.secondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSchemeOfferText(scheme),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${scheme.validFrom} - ${scheme.validTo}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.info,
                      ),
                      onPressed: () => _showForm(scheme),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      onPressed: () => _handleDelete(scheme),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool expired) {
    final color = expired
        ? AppColors.error
        : (status == 'active'
              ? AppColors.success
              : Theme.of(context).colorScheme.onSurfaceVariant);
    final label = expired ? 'EXPIRED' : status.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No schemes found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showForm([Scheme? scheme]) {
    showDialog(
      context: context,
      builder: (context) => SchemeFormDialog(
        scheme: scheme,
        products: _products,
        onSave: (payload) async {
          bool success;
          if (scheme == null) {
            success = await _schemesService.addScheme(payload);
          } else {
            success = await _schemesService.updateScheme(scheme.id, payload);
          }
          if (success) _loadData();
        },
      ),
    );
  }

  Future<void> _handleDelete(Scheme scheme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Scheme'),
        content: Text('Are you sure you want to delete "${scheme.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _schemesService.deleteScheme(scheme.id);
      if (success) _loadData();
    }
  }
}

// Reuse the SchemeFormDialog but with better styling
class SchemeFormDialog extends StatefulWidget {
  final Scheme? scheme;
  final List<Product> products;
  final Function(AddSchemePayload) onSave;

  const SchemeFormDialog({
    super.key,
    this.scheme,
    required this.products,
    required this.onSave,
  });

  @override
  State<SchemeFormDialog> createState() => _SchemeFormDialogState();
}

class _SchemeFormDialogState extends State<SchemeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _status;
  late String _validFrom;
  late String _validTo;
  late Product? _buyProduct;
  late Product? _getProduct;

  late int _buyQuantity;
  late int _getQuantity;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.scheme?.name ?? '');
    _descController = TextEditingController(
      text: widget.scheme?.description ?? '',
    );
    _status = widget.scheme?.status ?? 'active';
    _validFrom =
        widget.scheme?.validFrom ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _validTo =
        widget.scheme?.validTo ??
        DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now().add(const Duration(days: 30)));
    
    if (widget.scheme != null) {
      _buyProduct = widget.products.firstWhere(
        (p) => p.id == widget.scheme!.buyProductId,
        orElse: () => widget.products.first,
      );
      _getProduct = widget.products.firstWhere(
        (p) => p.id == widget.scheme!.getProductId,
        orElse: () => widget.products.first,
      );
    } else {
      _buyProduct = widget.products.isNotEmpty ? widget.products.first : null;
      _getProduct = widget.products.isNotEmpty ? widget.products.first : null;
    }
    _buyQuantity = widget.scheme?.buyQuantity ?? 0;
    _getQuantity = widget.scheme?.getQuantity ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAlertDialog(
      title: Text(widget.scheme == null ? 'Create Offer' : 'Edit Offer'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.clamp(context, min: 320, max: 500, ratio: 0.85),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Scheme Name *',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.tryParse(_validFrom) ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(
                              () => _validFrom = DateFormat(
                                'yyyy-MM-dd',
                              ).format(date),
                            );
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Starts',
                          ),
                          child: Text(_validFrom),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.tryParse(_validTo) ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(
                              () => _validTo = DateFormat(
                                'yyyy-MM-dd',
                              ).format(date),
                            );
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Ends'),
                          child: Text(_validTo),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 24),
                Text(
                  'Offer Details (Buy X Get Y)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                SearchableDropdown<Product>(
                  label: 'On Buying',
                  value: _buyProduct,
                  items: widget.products,
                  itemLabel: (p) => p.name,
                  onChanged: (v) => setState(() => _buyProduct = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _buyQuantity.toString(),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.integer(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                  onChanged: (v) => _buyQuantity = int.tryParse(v) ?? 0,
                  validator: (v) {
                    final qty = int.tryParse(v ?? '') ?? 0;
                    return qty > 0 ? null : 'Enter quantity > 0';
                  },
                ),
                const SizedBox(height: 16),
                SearchableDropdown<Product>(
                  label: 'Get Free',
                  value: _getProduct,
                  items: widget.products,
                  itemLabel: (p) => p.name,
                  onChanged: (v) => setState(() => _getProduct = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _getQuantity.toString(),
                  decoration: const InputDecoration(labelText: 'Free Quantity'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.integer(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                  onChanged: (v) => _getQuantity = int.tryParse(v) ?? 0,
                  validator: (v) {
                    final qty = int.tryParse(v ?? '') ?? 0;
                    return qty > 0 ? null : 'Enter quantity > 0';
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && 
                  _buyProduct != null && 
                  _getProduct != null) {
              widget.onSave(
                AddSchemePayload(
                  name: _nameController.text.trim(),
                  description: _descController.text.trim(),
                  type: 'buy_x_get_y_free',
                  status: _status,
                  validFrom: _validFrom,
                  validTo: _validTo,
                  buyProductId: _buyProduct!.id,
                  buyQuantity: _buyQuantity,
                  getProductId: _getProduct!.id,
                  getQuantity: _getQuantity,
                ),
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Save Scheme'),
        ),
      ],
    );
  }
}


