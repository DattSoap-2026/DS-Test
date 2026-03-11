import 'package:flutter/material.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_button.dart';

class UnitsManagementScreen extends StatefulWidget {
  const UnitsManagementScreen({super.key});

  @override
  State<UnitsManagementScreen> createState() => _UnitsManagementScreenState();
}

class _UnitsManagementScreenState extends State<UnitsManagementScreen> {
  final List<Map<String, String>> _units = [
    {'name': 'Kilogram', 'code': 'KG', 'base': '1000g'},
    {'name': 'Gram', 'code': 'G', 'base': '1g'},
    {'name': 'Piece', 'code': 'PCS', 'base': '1 unit'},
    {'name': 'Box', 'code': 'BOX', 'base': 'Multiple items'},
    {'name': 'Packet', 'code': 'PKT', 'base': 'Retail pack'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Units of Measurement', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(
              'Manage mass, volume, and count units used across the system.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _units.length,
              itemBuilder: (context, index) {
                final unit = _units[index];
                return CustomCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4f46e5).withValues(alpha: 0.1),
                      child: Text(unit['code']!, style: const TextStyle(color: Color(0xFF4f46e5), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    title: Text(unit['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Base conversion: ${unit['base']}'),
                    trailing: const Icon(Icons.more_vert),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Add New Unit',
              icon: Icons.add,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Standard units are predefined for this version.')));
              },
              variant: ButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}
