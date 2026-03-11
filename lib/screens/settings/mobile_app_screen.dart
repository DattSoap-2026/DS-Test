import 'package:flutter/material.dart';
import 'dart:io';

class MobileAppScreen extends StatelessWidget {
  const MobileAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildVersionCard(context),
            const SizedBox(height: 24),
            _buildInfoCard(
              context,
              'Installation & Updates',
              'Keep your application updated for the latest features and security patches.',
              [
                _buildInfoTile(
                  context,
                  Icons.cloud_download,
                  'Download Latest APK',
                  'Available on company portal',
                ),
                _buildInfoTile(
                  context,
                  Icons.update,
                  'Auto-updates',
                  'Enabled for next release',
                ),
                _buildInfoTile(
                  context,
                  Icons.security,
                  'Security',
                  'End-to-end encrypted sync',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFeaturesCard(context),
            const SizedBox(height: 32),
            _buildSupportFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.smartphone,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DattSoap Mobile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Enterprise Edition',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildVersionRow(context, 'App Version', '1.0.0'),
            const Divider(height: 24),
            _buildVersionRow(context, 'Build Number', '1'),
            const Divider(height: 24),
            _buildVersionRow(
              context,
              'Platform',
              Platform.isAndroid
                  ? 'Android'
                  : (Platform.isIOS ? 'iOS' : 'Web/Desktop'),
            ),
            const Divider(height: 24),
            _buildVersionRow(context, 'Environment', 'Production'),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Tooltip(
      message: 'Informational item only.',
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4f46e5)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.info_outline, size: 16),
        onTap: null,
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Core Features',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFeatureChip(context, 'Offline Sync'),
            _buildFeatureChip(context, 'Real-time Tracking'),
            _buildFeatureChip(context, 'Inventory Management'),
            _buildFeatureChip(context, 'Sales Reporting'),
            _buildFeatureChip(context, 'Push Notifications'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSupportFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Need support?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showContactSupportDialog(context),
            child: const Text(
              'Contact IT Department',
              style: TextStyle(
                color: Color(0xFF4f46e5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '(c) 2024 DattSoap. All rights reserved.',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Contact IT Department'),
          content: const Text(
            'Please contact your IT administrator through the internal support channel for APK updates and access issues.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
