import 'package:flutter/material.dart';
import 'app_button.dart';
import '../../../utils/responsive.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool isLoading;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsiveConstraints = Responsive.dialogConstraints(
      context,
      maxWidth: Responsive.isSmall(context) ? 520 : 780,
      maxHeightFactor: 0.9,
    );

    return SafeArea(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsiveConstraints.maxWidth,
            maxHeight: responsiveConstraints.maxHeight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: content,
                ),
              ),
              const SizedBox(height: 24),
              // Sticky Footer Actions
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (secondaryActionLabel != null)
                      AppButton(
                        label: secondaryActionLabel!,
                        variant: ButtonVariant.secondary,
                        onPressed:
                            onSecondaryAction ?? () => Navigator.pop(context),
                        isDisabled: isLoading,
                      ),
                    if (primaryActionLabel != null)
                      AppButton(
                        label: primaryActionLabel!,
                        onPressed: onPrimaryAction,
                        isLoading: isLoading,
                      ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    List<Widget>? actions,
    bool isLoading = false,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        actions: actions,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction,
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction,
        isLoading: isLoading,
      ),
    );
  }
}
