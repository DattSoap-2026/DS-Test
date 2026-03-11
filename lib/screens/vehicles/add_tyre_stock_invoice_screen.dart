import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/vehicles_service.dart';

class AddTyreStockInvoiceScreen extends StatefulWidget {
  const AddTyreStockInvoiceScreen({super.key});

  @override
  State<AddTyreStockInvoiceScreen> createState() =>
      _AddTyreStockInvoiceScreenState();
}

class _AddTyreStockInvoiceScreenState extends State<AddTyreStockInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final VehiclesService _vehiclesService;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs ',
    decimalDigits: 2,
  );

  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  bool _isSaving = false;

  List<String> _brandOptions = ['MRF'];
  List<String> _sizeOptions = ['100/20'];
  final List<_TyreInvoiceLineForm> _lines = [];

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _lines.add(_createLineForm());
    _loadDropdownOptions();
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _invoiceNumberController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  _TyreInvoiceLineForm _createLineForm() {
    return _TyreInvoiceLineForm(
      initialBrand: _brandOptions.first,
      initialSize: _sizeOptions.first,
    );
  }

  List<String> _normalizeOptions(
    List<String> values, {
    required String fallback,
  }) {
    final cleaned =
        values
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (cleaned.isEmpty) {
      return [fallback];
    }
    return cleaned;
  }

  Future<void> _loadDropdownOptions() async {
    try {
      final lists = await Future.wait<List<String>>([
        _vehiclesService.getTyreBrands(),
        _vehiclesService.getTyreSizes(),
      ]);
      if (!mounted) return;
      final brandOptions = _normalizeOptions(lists[0], fallback: 'MRF');
      final sizeOptions = _normalizeOptions(lists[1], fallback: '100/20');
      setState(() {
        _brandOptions = brandOptions;
        _sizeOptions = sizeOptions;
        for (final line in _lines) {
          if (!_brandOptions.contains(line.brand)) {
            line.brand = _brandOptions.first;
          }
          if (!_sizeOptions.contains(line.size)) {
            line.size = _sizeOptions.first;
          }
        }
      });
    } catch (_) {
      // Keep fallback values if lookup fails.
    }
  }

  void _addLine() {
    setState(() {
      _lines.add(_createLineForm());
    });
  }

  void _removeLine(int index) {
    if (_lines.length <= 1) return;
    setState(() {
      final removed = _lines.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _pickInvoiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _invoiceDate = picked;
    });
  }

  int _parseQty(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  double _parsePrice(String value) {
    return double.tryParse(value.trim()) ?? 0.0;
  }

  double _lineTotal(_TyreInvoiceLineForm line) {
    return _parseQty(line.qtyController.text) *
        _parsePrice(line.priceController.text);
  }

  int get _invoiceQty {
    return _lines.fold<int>(
      0,
      (sum, line) => sum + _parseQty(line.qtyController.text),
    );
  }

  double get _invoiceTotal {
    return _lines.fold<double>(0, (sum, line) => sum + _lineTotal(line));
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final lines = <TyreStockInvoiceLine>[];
    for (final item in _lines) {
      final qty = _parseQty(item.qtyController.text);
      final price = _parsePrice(item.priceController.text);
      lines.add(
        TyreStockInvoiceLine(
          brand: item.brand,
          type: item.tyreType,
          size: item.size,
          serialNumberInput: item.serialController.text.trim(),
          quantity: qty,
          unitPrice: price,
        ),
      );
    }

    setState(() => _isSaving = true);
    try {
      final added = await _vehiclesService.addTyreStockInvoice(
        vendorName: _vendorController.text.trim(),
        invoiceNumber: _invoiceNumberController.text.trim(),
        invoiceDate: _invoiceDate,
        lines: lines,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$added tyre(s) added from invoice')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add tyre stock: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Tyre Stock Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Vendor name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _invoiceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice No',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Invoice number is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _isSaving ? null : _pickInvoiceDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_invoiceDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Tyre Items',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ..._lines.asMap().entries.map((entry) {
                return _buildLineCard(index: entry.key, item: entry.value);
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _addLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildSummaryRow('Line Items', _lines.length.toString()),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Total Qty', _invoiceQty.toString()),
                      const Divider(height: 20),
                      _buildSummaryRow(
                        'Invoice Total',
                        _currencyFormat.format(_invoiceTotal),
                        isEmphasized: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save Invoice Stock'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isEmphasized = false,
  }) {
    final style = isEmphasized
        ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)
        : const TextStyle(fontWeight: FontWeight.w500);
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }

  Widget _buildLineCard({
    required int index,
    required _TyreInvoiceLineForm item,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Item #${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (_lines.length > 1)
                  IconButton(
                    onPressed: _isSaving ? null : () => _removeLine(index),
                    tooltip: 'Remove item',
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: item.brand,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                    ),
                    items: _brandOptions
                        .map(
                          (brand) => DropdownMenuItem(
                            value: brand,
                            child: Text(brand),
                          ),
                        )
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              item.brand = value;
                            });
                          },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: item.tyreType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'New', child: Text('New')),
                      DropdownMenuItem(value: 'Remold', child: Text('Remold')),
                    ],
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              item.tyreType = value ?? 'New';
                            });
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: item.size,
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(),
                    ),
                    items: _sizeOptions
                        .map(
                          (size) =>
                              DropdownMenuItem(value: size, child: Text(size)),
                        )
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              item.size = value;
                            });
                          },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: item.qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final qty = int.tryParse((value ?? '').trim()) ?? 0;
                      if (qty <= 0) return 'Invalid qty';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final price = double.tryParse((value ?? '').trim());
                      if (price == null || price < 0) return 'Invalid price';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _currencyFormat.format(_lineTotal(item)),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: item.serialController,
              decoration: const InputDecoration(
                labelText: 'Tyre No / Serial Number',
                helperText:
                    'Qty > 1: single base serial or comma-separated serials',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Serial number required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TyreInvoiceLineForm {
  _TyreInvoiceLineForm({
    required String initialBrand,
    required String initialSize,
  }) : brand = initialBrand,
       size = initialSize;

  String brand;
  String size;
  String tyreType = 'New';

  final TextEditingController serialController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController(
    text: '0',
  );

  void dispose() {
    serialController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }
}
