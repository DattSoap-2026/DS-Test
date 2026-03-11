import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/custom_button.dart';
import '../../utils/responsive.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class PdfTemplatesScreen extends StatefulWidget {
  final bool showHeader;

  const PdfTemplatesScreen({super.key, this.showHeader = true});

  @override
  State<PdfTemplatesScreen> createState() => _PdfTemplatesScreenState();
}

class _PdfTemplatesScreenState extends State<PdfTemplatesScreen> {
  late final SettingsService _settingsService;

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, PdfTemplate> _templates = {};

  // Settings extracted from HTML or defaults
  String _primaryColor = '#2563eb';
  String _secondaryColor = '#4b5563';
  String _headerBgColor = '#f3f4f6';
  String _fontFamily = "'Helvetica', 'Arial', sans-serif";

  final List<Map<String, String>> _fontOptions = [
    {
      'label': 'Helvetica (Default)',
      'value': "'Helvetica', 'Arial', sans-serif",
    },
    {'label': 'Georgia', 'value': "'Georgia', serif"},
    {'label': 'Times New Roman', 'value': "'Times New Roman', serif"},
    {'label': 'Courier New', 'value': "'Courier New', monospace"},
    {'label': 'Arial', 'value': "'Arial', sans-serif"},
  ];

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _templates = await _settingsService.getPdfTemplates();
      final invoice = _templates['invoice'];
      if (invoice != null) {
        _extractSettingsFromHtml(invoice.htmlContent);
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _extractSettingsFromHtml(String html) {
    final primaryMatch = RegExp(
      r'--primary-color:\s*([^;]+);',
    ).firstMatch(html);
    final secondaryMatch = RegExp(
      r'--secondary-color:\s*([^;]+);',
    ).firstMatch(html);
    final fontMatch = RegExp(r'--font-family:\s*([^;]+);').firstMatch(html);
    final headerBgMatch = RegExp(
      r'--header-bg-color:\s*([^;]+);',
    ).firstMatch(html);

    setState(() {
      if (primaryMatch != null) {
        _primaryColor = primaryMatch.group(1)!.trim();
      }
      if (secondaryMatch != null) {
        _secondaryColor = secondaryMatch.group(1)!.trim();
      }
      if (fontMatch != null) {
        _fontFamily = fontMatch.group(1)!.trim();
      }
      if (headerBgMatch != null) {
        _headerBgColor = headerBgMatch.group(1)!.trim();
      }
    });
  }

  String _generateHtml() {
    return '''<!DOCTYPE html>
<html>
<head>
    <title>Invoice</title>
    <style>
        /* --- EASY EDIT AREA --- */
        :root {
            --primary-color: $_primaryColor;
            --secondary-color: $_secondaryColor;
            --font-family: $_fontFamily;
            --header-bg-color: $_headerBgColor;
        }
        /* --- END EASY EDIT AREA --- */

        body { font-family: var(--font-family); margin: 0; padding: 2rem; color: #333; }
        .header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #eee; padding-bottom: 1rem; }
        .company-details { font-size: 0.9rem; color: #555; }
        .invoice-details { text-align: right; }
        .invoice-details h2 { color: var(--primary-color); }
        table { width: 100%; border-collapse: collapse; margin-top: 2rem; font-size: 0.9rem; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: var(--header-bg-color); color: var(--secondary-color); font-weight: 600; }
        .totals { float: right; width: 40%; margin-top: 2rem; }
        .text-right { text-align: right; }
        .font-bold { font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1 style="color: var(--primary-color);">DattSoap Company</h1>
            <p class="company-details">123 Business Street, City</p>
        </div>
        <div class="invoice-details">
            <h2>INVOICE</h2>
            <p><strong>Invoice #:</strong> INV-001</p>
            <p><strong>Date:</strong> ${DateTime.now().toIso8601String().split('T')[0]}</p>
        </div>
    </div>
    
    <div style="margin-top: 2rem;">
        <strong>Billed To:</strong>
        <p>Customer Name</p>
    </div>

    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Item</th>
                <th class="text-right">Quantity</th>
                <th class="text-right">Rate</th>
                <th class="text-right">Amount</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1</td>
                <td>Neem Soap (1kg)</td>
                <td class="text-right">10</td>
                <td class="text-right">₹50.00</td>
                <td class="text-right">₹500.00</td>
            </tr>
            <tr>
                <td>2</td>
                <td>Herbal Soap (500g)</td>
                <td class="text-right">5</td>
                <td class="text-right">₹30.00</td>
                <td class="text-right">₹150.00</td>
            </tr>
        </tbody>
    </table>

    <div class="totals">
        <table style="width: 100%;">
            <tr>
                <th>Subtotal</th>
                <td class="text-right">₹650.00</td>
            </tr>
            <tr>
                <th>Discount (0%)</th>
                <td class="text-right">-₹0.00</td>
            </tr>
            <tr class="font-bold" style="font-size: 1.2rem; color: var(--primary-color);">
                <th>Total</th>
                <td class="text-right">₹650.00</td>
            </tr>
        </table>
    </div>
</body>
</html>''';
  }

  Future<void> _handleSave() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final html = _generateHtml();
      final template = PdfTemplate(
        id: 'invoice',
        name: 'Sales Invoice',
        type: 'invoice',
        htmlContent: html,
      );

      final success = await _settingsService.savePdfTemplate(
        template,
        user.id,
        user.name,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template saved successfully')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save template')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          if (widget.showHeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'PDF Templates',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: Responsive.screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_outlined,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Template Customization',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Customize the appearance of your generated PDFs.',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 1100;

                      final controls = Column(
                        children: [
                          _buildColorCard(
                            'Primary Color',
                            'Used for headings and totals',
                            _primaryColor,
                            (c) => setState(() => _primaryColor = c),
                          ),
                          const SizedBox(height: 16),
                          _buildColorCard(
                            'Secondary Color',
                            'Used for text and borders',
                            _secondaryColor,
                            (c) => setState(() => _secondaryColor = c),
                          ),
                          const SizedBox(height: 16),
                          _buildColorCard(
                            'Header Background',
                            'Table header color',
                            _headerBgColor,
                            (c) => setState(() => _headerBgColor = c),
                          ),
                          const SizedBox(height: 16),
                          _buildFontCard(),
                          const SizedBox(height: 32),
                          CustomButton(
                            label: 'Save Changes',
                            icon: Icons.save,
                            isLoading: _isSaving,
                            onPressed: _handleSave,
                          ),
                        ],
                      );

                      final preview = GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Live Preview (Conceptual)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(height: 1),
                            AspectRatio(
                              aspectRatio: isNarrow ? 1.2 : 1.7,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf,
                                        size: 64,
                                        color: _hexToColor(_primaryColor),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'PDF Preview Styles',
                                        style: TextStyle(
                                          color: _hexToColor(_primaryColor),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        'Secondary: $_secondaryColor',
                                        style: TextStyle(
                                          color: _hexToColor(_secondaryColor),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        color: _hexToColor(_headerBgColor),
                                        child: Text(
                                          'Table Header Sample',
                                          style: TextStyle(
                                            color: _hexToColor(_secondaryColor),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          children: [
                            controls,
                            const SizedBox(height: 24),
                            preview,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: controls),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: preview),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(
    String title,
    String subtitle,
    String hex,
    Function(String) onChanged,
  ) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _hexToColor(hex),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: hex,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    if (v.startsWith('#') && (v.length == 7 || v.length == 4)) {
                      onChanged(v);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontCard() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Font Style',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _fontFamily,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: _fontOptions
                .map(
                  (f) => DropdownMenuItem(
                    value: f['value'],
                    child: Text(f['label']!),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _fontFamily = v!),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((c) => c + c).join('');
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Theme.of(context).colorScheme.onSurface;
    }
  }
}

