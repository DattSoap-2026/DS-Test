import 'package:flutter/services.dart';

class NormalizedNumberInputFormatter extends TextInputFormatter {
  final bool allowDecimal;
  final bool keepZeroWhenEmpty;
  final int? maxDecimalPlaces;

  const NormalizedNumberInputFormatter._({
    required this.allowDecimal,
    required this.keepZeroWhenEmpty,
    required this.maxDecimalPlaces,
  });

  factory NormalizedNumberInputFormatter.integer({
    bool keepZeroWhenEmpty = false,
  }) {
    return NormalizedNumberInputFormatter._(
      allowDecimal: false,
      keepZeroWhenEmpty: keepZeroWhenEmpty,
      maxDecimalPlaces: null,
    );
  }

  factory NormalizedNumberInputFormatter.decimal({
    bool keepZeroWhenEmpty = false,
    int? maxDecimalPlaces,
  }) {
    return NormalizedNumberInputFormatter._(
      allowDecimal: true,
      keepZeroWhenEmpty: keepZeroWhenEmpty,
      maxDecimalPlaces: maxDecimalPlaces,
    );
  }

  static bool _isDigit(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  static String _trimLeadingZeros(String input) {
    if (input.isEmpty) return '';
    final trimmed = input.replaceFirst(RegExp(r'^0+'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text;

    if (raw.isEmpty) {
      if (!keepZeroWhenEmpty) return newValue;
      return const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    final sanitized = StringBuffer();
    var dotUsed = false;
    for (final rune in raw.runes) {
      final char = String.fromCharCode(rune);
      if (_isDigit(char)) {
        sanitized.write(char);
        continue;
      }
      if (allowDecimal && char == '.' && !dotUsed) {
        dotUsed = true;
        sanitized.write(char);
      }
    }

    raw = sanitized.toString();
    if (raw.isEmpty) {
      if (!keepZeroWhenEmpty) return const TextEditingValue(text: '');
      return const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    String normalized;
    if (!allowDecimal) {
      normalized = _trimLeadingZeros(raw);
    } else {
      final hasDot = raw.contains('.');
      final dotIndex = raw.indexOf('.');
      String integerPart;
      String decimalPart;
      if (dotIndex >= 0) {
        integerPart = raw.substring(0, dotIndex);
        decimalPart = raw.substring(dotIndex + 1);
      } else {
        integerPart = raw;
        decimalPart = '';
      }

      integerPart = _trimLeadingZeros(integerPart);
      if (integerPart.isEmpty) {
        integerPart = '0';
      }

      if (maxDecimalPlaces != null && decimalPart.length > maxDecimalPlaces!) {
        decimalPart = decimalPart.substring(0, maxDecimalPlaces!);
      }

      normalized = hasDot ? '$integerPart.$decimalPart' : integerPart;
    }

    if (normalized.isEmpty) {
      if (!keepZeroWhenEmpty) return const TextEditingValue(text: '');
      normalized = '0';
    }

    if (normalized == newValue.text) {
      return newValue;
    }

    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}
