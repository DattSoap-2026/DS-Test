import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final bool isSearch;
  final bool autofocus;
  final String? prefixText;
  final String? suffixText;
  final int maxLines;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;

  const AppInput({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.isSearch = false,
    this.autofocus = false,
    this.prefixText,
    this.suffixText,
    this.maxLines = 1,
    this.focusNode,
    this.validator,
    this.initialValue,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const double radius = 12.0;
    // For single line, use fixed 44px height. For multi-line, let it expand.
    final double? height = maxLines > 1 ? null : 44.0;

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
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            focusNode: focusNode,
            autofocus: autofocus,
            validator: validator,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: isSearch
                  ? const Icon(Icons.search, size: 18)
                  : prefixIcon,
              prefixText: prefixText,
              suffixIcon: suffixIcon,
              suffixText: suffixText,
              suffixStyle: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
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
        ] else if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
