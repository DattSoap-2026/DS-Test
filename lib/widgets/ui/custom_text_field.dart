import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool readOnly;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
    this.prefixText,
    this.suffixText,
    this.helperText,
    this.onTap,
    this.isDense = false,
    this.textAlign = TextAlign.start,
  });

  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseDecoration = theme.inputDecorationTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: isPassword,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: isDense,
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  )
                : null,
            prefixText: prefixText,
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            helperText: helperText,
            filled: true,
            fillColor: readOnly
                ? theme.colorScheme.surfaceContainerHighest
                : baseDecoration.fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ).applyDefaults(baseDecoration),
        ),
      ],
    );
  }
}
