import 'package:flutter/material.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_button.dart';

class PrintingSettingsScreen extends StatefulWidget {
  const PrintingSettingsScreen({super.key});

  @override
  State<PrintingSettingsScreen> createState() => _PrintingSettingsScreenState();
}

class _PrintingSettingsScreenState extends State<PrintingSettingsScreen> {
  String _pageSize = 'A4';
  bool _printLogo = true;
  bool _printHeader = true;
  bool _printFooter = true;
  int _copies = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Printing Preferences',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Configure how invoices and reports are printed.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Page Configuration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _pageSize,
                    decoration: const InputDecoration(
                      labelText: 'Default Paper Size',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A4', child: Text('Standard A4')),
                      DropdownMenuItem(value: 'A5', child: Text('Small A5')),
                      DropdownMenuItem(
                        value: '80mm',
                        child: Text('Thermal Receipt (80mm)'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _pageSize = v!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Default Copies: '),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () =>
                            setState(() => _copies > 1 ? _copies-- : null),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_copies',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _copies++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Elements to Include',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Include Company Logo'),
                    value: _printLogo,
                    onChanged: (v) => setState(() => _printLogo = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Include Standard Header'),
                    value: _printHeader,
                    onChanged: (v) => setState(() => _printHeader = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Include Terms & Conditions'),
                    value: _printFooter,
                    onChanged: (v) => setState(() => _printFooter = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Save Preferences',
              icon: Icons.save,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Printing preferences saved for this device.',
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
}
