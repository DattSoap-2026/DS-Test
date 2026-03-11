import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final String message;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction,
    this.color,
    this.message =
        'This screen is under development. Full implementation coming soon.',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = color ?? colorScheme.primary;
    final appBarColor =
        color ?? colorScheme.surfaceContainerHighest;
    final appBarForeground =
        color == null ? colorScheme.onSurface : colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appBarColor,
        foregroundColor: appBarForeground,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: accentColor),
            ),
            const SizedBox(height: 24),
            Text(
              '$title Screen',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
