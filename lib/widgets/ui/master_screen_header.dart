import 'package:flutter/material.dart';
import 'package:flutter_app/utils/mobile_header_typography.dart';
import 'package:flutter_app/utils/responsive.dart';

class MasterScreenHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? helperText;
  final Color? color;
  final IconData? icon;
  final String? emoji;
  final List<Widget>? actions;
  final bool actionsInline;
  final bool forceActionsBelowTitle;
  final int inlineTitleFlex;
  final int inlineActionsFlex;
  final VoidCallback? onBack;
  final bool isReadOnly;
  final bool isDashboardHeader;

  const MasterScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.helperText,
    this.color,
    this.icon,
    this.emoji,
    this.actions,
    this.onBack,
    this.isReadOnly = false,
    this.isDashboardHeader = false,
    this.actionsInline = false,
    this.forceActionsBelowTitle = false,
    this.inlineTitleFlex = 3,
    this.inlineActionsFlex = 2,
  });

  @override
  State<MasterScreenHeader> createState() => _MasterScreenHeaderState();
}

class _MasterScreenHeaderState extends State<MasterScreenHeader> {
  bool _showHelper = false;

  VoidCallback? _resolveBackAction(bool isNarrow) {
    if (widget.onBack != null) return widget.onBack;
    if (!isNarrow || widget.isDashboardHeader) return null;
    return () async {
      final navigator = Navigator.of(context);
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      final didPop = await navigator.maybePop();
      if (didPop) {
        return;
      }

      if (!identical(rootNavigator, navigator)) {
        await rootNavigator.maybePop();
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = widget.color ?? theme.colorScheme.primary;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final actions = widget.actions ?? const <Widget>[];
    final keepActionsInline = widget.actionsInline;
    final emoji = widget.emoji;
    final icon = widget.icon;
    final helperText = widget.helperText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaWidth = Responsive.width(context);
        final constrainedWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaWidth;
        final availableWidth = constrainedWidth < mediaWidth
            ? constrainedWidth
            : mediaWidth;
        final isNarrow = availableWidth < 600;
        final useMobileTypography = useMobileHeaderTypographyForWidth(
          availableWidth,
        );
        final backAction = _resolveBackAction(isNarrow);
        final forceActionsBelowForScale =
            keepActionsInline &&
            actions.isNotEmpty &&
            (availableWidth < 1280 || textScale > 1.1);
        final showActionsBelowTitle =
            actions.isNotEmpty &&
            (widget.forceActionsBelowTitle ||
                forceActionsBelowForScale ||
                (isNarrow && !keepActionsInline));

        return Padding(
          padding: EdgeInsets.fromLTRB(20, isNarrow ? 18 : 26, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Title Area
              Row(
                children: [
                  // Back Button
                  if (backAction != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: backAction,
                        tooltip: 'Back',
                      ),
                    ),

                  // Icon/Emoji
                  if (emoji != null || icon != null) ...[
                    if (emoji != null)
                      Text(emoji, style: const TextStyle(fontSize: 20))
                    else
                      Icon(icon, color: headerColor, size: 20),
                    const SizedBox(width: 12),
                  ],

                  // Title & Subtitle
                  Expanded(
                    flex: widget.inlineTitleFlex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: useMobileTypography
                                      ? mobileHeaderTitleFontSize
                                      : null,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: useMobileTypography
                                      ? -0.2
                                      : -0.3,
                                  height: useMobileTypography ? 1.2 : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isReadOnly) ...[
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 10,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'VIEW ONLY',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.tertiary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        if (widget.subtitle.isNotEmpty)
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: useMobileTypography
                                  ? mobileHeaderSubtitleFontSize
                                  : 12,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Inline actions on wider layouts or when explicitly forced.
                  if (actions.isNotEmpty && !showActionsBelowTitle) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: widget.inlineActionsFlex,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Info Toggle (If helper text exists)
                  if (helperText != null)
                    IconButton(
                      icon: Icon(
                        _showHelper ? Icons.info : Icons.info_outline,
                        color: _showHelper
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showHelper = !_showHelper),
                      tooltip: 'Info',
                    ),
                ],
              ),
              if (showActionsBelowTitle) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions,
                    ),
                  ),
                ),
              ],

              // Collapsible Helper Text
              if (_showHelper && helperText != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: headerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    helperText,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
