import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/core/theme/theme_builder.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/models/theme/theme_settings.dart';
import 'package:flutter_app/providers/theme_settings_provider.dart';
import 'package:flutter_app/widgets/settings/theme_preview_panel.dart';
import 'package:flutter_app/widgets/ui/master_screen_header.dart';
import 'package:flutter_app/widgets/ui/themed_segment_control.dart';
import 'package:flutter_app/utils/contrast_checker.dart';
import 'package:flutter_app/utils/responsive.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  final bool showHeader;

  const ThemeSettingsScreen({super.key, this.showHeader = true});

  static const List<Color> _primaryPalette = [
    AppColors.lightPrimary,
    AppColors.darkPrimary,
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    AppColors.lightAccent,
    AppColors.darkAccent,
  ];

  static const List<Color> _surfacePalette = [
    AppColors.lightBackground,
    AppColors.lightSurface,
    AppColors.darkBackground,
    AppColors.darkSurface,
    AppColors.darkCard,
  ];

  static const List<Color> _accentPalette = [
    AppColors.lightAccent,
    AppColors.darkAccent,
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(themeSettingsProvider);
    final settings = state.settings;
    final isWide = Responsive.isDesktop(context);

    final previewBrightness = settings.themeMode == ThemeMode.system
        ? theme.brightness
        : (settings.themeMode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light);

    final previewBase = previewBrightness == Brightness.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;

    final previewTheme = ThemeBuilder.build(
      previewBase,
      settings,
      previewBrightness,
    );
    final contrastPrimary = ContrastChecker.evaluate(
      settings.primaryColor,
      settings.surfaceColor,
    );
    final contrastText = ContrastChecker.evaluate(
      previewTheme.colorScheme.onSurface,
      settings.surfaceColor,
    );

    final leftPane = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          const MasterScreenHeader(
            title: 'Theme & Appearance',
            subtitle: 'Control visual style, theme mode and branding colors',
            icon: Icons.palette_outlined,
          ),
          const SizedBox(height: 16),
        ],
        _SectionCard(
          title: 'Theme Mode',
          subtitle: 'Choose how the UI adapts to light or dark environments.',
          child: ThemedSegmentControl<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.auto_awesome_outlined),
                label: Text('System'),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (value) {
              if (value.isEmpty) return;
              ref
                  .read(themeSettingsProvider.notifier)
                  .setThemeMode(value.first);
            },
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Custom Theme',
          subtitle: 'Override primary, surface and accent colors.',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Custom Theme'),
                subtitle: Text(
                  'Use company branding colors across the ERP UI.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: settings.customThemeEnabled,
                onChanged: (value) => ref
                    .read(themeSettingsProvider.notifier)
                    .setCustomThemeEnabled(value),
              ),
              const SizedBox(height: 12),
              _ColorPickerRow(
                label: 'Primary Color',
                color: settings.primaryColor,
                options: _primaryPalette,
                recentColors: state.recentColors,
                enabled: settings.customThemeEnabled,
                onPick: (color) {
                  final notifier =
                      ref.read(themeSettingsProvider.notifier);
                  notifier.setPrimaryColor(color);
                  notifier.addRecentColor(color);
                },
              ),
              const SizedBox(height: 12),
              _ColorPickerRow(
                label: 'Surface / Background',
                color: settings.surfaceColor,
                options: _surfacePalette,
                recentColors: state.recentColors,
                enabled: settings.customThemeEnabled,
                onPick: (color) {
                  final notifier =
                      ref.read(themeSettingsProvider.notifier);
                  notifier.setSurfaceColor(color);
                  notifier.addRecentColor(color);
                },
              ),
              const SizedBox(height: 12),
              _ColorPickerRow(
                label: 'Accent Color',
                color: settings.accentColor,
                options: _accentPalette,
                recentColors: state.recentColors,
                enabled: settings.customThemeEnabled,
                onPick: (color) {
                  final notifier =
                      ref.read(themeSettingsProvider.notifier);
                  notifier.setAccentColor(color);
                  notifier.addRecentColor(color);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            await ref
                                .read(themeSettingsProvider.notifier)
                                .saveCustomTheme();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Theme settings saved successfully'),
                                ),
                              );
                            }
                          },
                    icon: state.isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      state.isSaving ? 'Saving...' : 'Save Theme',
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (state.isDirty)
                    Text(
                      'Unsaved changes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _ContrastSummary(
                primaryResult: contrastPrimary,
                textResult: contrastText,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Theme Patterns',
          subtitle: 'Pick a curated palette and preview instantly.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ThemePattern.values.map((pattern) {
              final palette = ThemePatternPalette.forPattern(pattern);
              final selected = settings.pattern == pattern;
              return _PatternCard(
                label: pattern.label,
                palette: palette,
                selected: selected,
                onTap: () => ref
                    .read(themeSettingsProvider.notifier)
                    .applyPattern(pattern),
              );
            }).toList(),
          ),
        ),
      ],
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: Responsive.screenPadding(context),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: leftPane),
                  const SizedBox(width: 24),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.clamp(
                        context,
                        min: 280,
                        max: 420,
                        ratio: 0.32,
                      ),
                    ),
                    child: ThemePreviewPanel(previewTheme: previewTheme),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leftPane,
                  const SizedBox(height: 24),
                  ThemePreviewPanel(previewTheme: previewTheme),
                ],
              ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  final String label;
  final Color color;
  final List<Color> options;
  final List<Color> recentColors;
  final bool enabled;
  final ValueChanged<Color> onPick;

  const _ColorPickerRow({
    required this.label,
    required this.color,
    required this.options,
    required this.recentColors,
    required this.enabled,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
                  onTap: enabled
                ? () async {
                    final selected = await _showColorDialog(
                      context,
                      color,
                      options,
                      recentColors,
                    );
                    if (selected != null) {
                      onPick(selected);
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> _showColorDialog(
    BuildContext context,
    Color current,
    List<Color> options,
    List<Color> recentColors,
  ) {
    final theme = Theme.of(context);
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Select Color'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.clamp(
                context,
                min: 260,
                max: 360,
                ratio: 0.9,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recentColors.isNotEmpty) ...[
                  Text(
                    'Recently Used',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: recentColors.map((color) {
                      return _AnimatedSwatch(
                        color: color,
                        isSelected:
                            color.toARGB32() == current.toARGB32(),
                        onTap: () => Navigator.of(context).pop(color),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Palette',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: options.map((color) {
                    return _AnimatedSwatch(
                      color: color,
                      isSelected:
                          color.toARGB32() == current.toARGB32(),
                      onTap: () => Navigator.of(context).pop(color),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _PatternCard extends StatefulWidget {
  final String label;
  final ThemePatternPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PatternCard({
    required this.label,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_PatternCard> createState() => _PatternCardState();
}

class _PatternCardState extends State<_PatternCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canHover = Responsive.width(context) > 900;
    final showHover = canHover && _hovered;
    return MouseRegion(
      onEnter: (_) {
        if (!canHover) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!canHover) return;
        setState(() => _hovered = false);
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              border: Border.all(
                color: widget.selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: showHover
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ColorDot(color: widget.palette.primary),
                    const SizedBox(width: 6),
                    _ColorDot(color: widget.palette.surface),
                    const SizedBox(width: 6),
                    _ColorDot(color: widget.palette.accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _AnimatedSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}

class _ContrastSummary extends StatelessWidget {
  final ContrastResult primaryResult;
  final ContrastResult textResult;

  const _ContrastSummary({
    required this.primaryResult,
    required this.textResult,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contrast Check',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _ContrastRow(
          label: 'Primary vs Surface',
          result: primaryResult,
        ),
        const SizedBox(height: 6),
        _ContrastRow(
          label: 'Text vs Background',
          result: textResult,
        ),
        if (!primaryResult.passes || !textResult.passes) ...[
          const SizedBox(height: 8),
          Text(
            'Contrast below recommended level. Consider adjusting colors.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _ContrastRow extends StatelessWidget {
  final String label;
  final ContrastResult result;

  const _ContrastRow({required this.label, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradeLabel = switch (result.grade) {
      ContrastGrade.aaa => 'AAA',
      ContrastGrade.aa => 'AA',
      ContrastGrade.fail => 'Low',
    };
    final statusColor =
        result.passes ? colorScheme.primary : colorScheme.error;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          result.ratio.toStringAsFixed(2),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            gradeLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
