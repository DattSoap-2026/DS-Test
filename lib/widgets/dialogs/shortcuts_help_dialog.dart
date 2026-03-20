import 'package:flutter/material.dart';
import '../../core/shortcuts/key_tip_controller.dart';
import '../../utils/responsive.dart';

class ShortcutsHelpDialog extends StatelessWidget {
  const ShortcutsHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final dialogHeight = Responsive.clamp(
      context,
      min: 420,
      max: 620,
      ratio: 0.75,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: Responsive.dialogInsetPadding(context),
      child: ConstrainedBox(
        constraints: Responsive.dialogConstraints(
          context,
          maxWidth: 800,
          maxHeightFactor: 0.9,
        ),
        child: SizedBox(
          height: dialogHeight,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: isDark ? 0.5 : 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.keyboard, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    'Keyboard Shortcuts',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.hintColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (KeyTipController.instance.registry.isNotEmpty) ...[
                    _buildSection(
                      context,
                      'Active Context Shortcuts',
                      KeyTipController.instance.registry.entries.map((e) {
                        return _buildShortcut(
                          context,
                          'Alt + ${e.key}',
                          e.value.description,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildSection(context, 'Essentials', [
                    _buildShortcut(
                      context,
                      'Ctrl + K',
                      'Command Palette / Search',
                    ),
                    _buildShortcut(
                      context,
                      'Ctrl + /',
                      'Show Keyboard Shortcuts',
                    ),
                    _buildShortcut(context, 'Ctrl + S', 'Save Current Form'),
                    _buildShortcut(context, 'Esc', 'Close Dialog / Cancel'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Navigation', [
                    _buildShortcut(
                      context,
                      'Ctrl + T',
                      'New Tab (Coming Soon)',
                    ),
                    _buildShortcut(context, 'Ctrl + W', 'Close Active Tab'),
                    _buildShortcut(
                      context,
                      'Ctrl + \\',
                      'Split View (Coming Soon)',
                    ),
                    _buildShortcut(context, 'Ctrl + Shift + N', 'New Window'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Actions', [
                    _buildShortcut(
                      context,
                      'Ctrl + N',
                      'New Item (Context Sensitive)',
                    ),
                  ]),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> shortcuts,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 5, // Adjust for width/height ratio
          crossAxisSpacing: 32,
          mainAxisSpacing: 12,
          children: shortcuts,
        ),
      ],
    );
  }

  Widget _buildShortcut(BuildContext context, String keys, String description) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: keys.split('+').map((key) {
            final cleanKey = key.trim();
            return Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                cleanKey,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
