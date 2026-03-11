import 'package:flutter/material.dart';

class AppSelect<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? errorText;
  final Widget? suffixIcon;
  final FormFieldValidator<T>? validator;

  const AppSelect({
    super.key,
    this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.hintText,
    this.errorText,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double radius = 12.0;
    const double height = 44.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: height,
          child: DropdownButtonFormField<T>(
            key: ValueKey(value),
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ).applyDefaults(theme.inputDecorationTheme),
            icon: suffixIcon ?? const Icon(Icons.keyboard_arrow_down, size: 20),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
