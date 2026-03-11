import 'package:flutter/material.dart';

class SearchableAccountDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> accounts;
  final String? selectedAccountCode;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const SearchableAccountDropdown({
    super.key,
    required this.accounts,
    this.selectedAccountCode,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // DropdownMenu requires a unique controller if we want to programmatically set text,
    // but here we rely on initialSelection.
    // However, DropdownMenu in Flutter has some limitations with dynamic updates.
    // We will use Autocomplete for better control if DropdownMenu proves difficult,
    // but DropdownMenu is the standard Material 3 way.

    // We need to map accounts to DropdownMenuEntry
    final entries = accounts.map((account) {
      final code = (account['code'] ?? '').toString();
      final name = (account['name'] ?? code).toString();
      return DropdownMenuEntry<String>(
        value: code,
        label: '$name ($code)',
        style: MenuItemButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth,
          initialSelection: selectedAccountCode,
          label: const Text('Select Ledger'),
          dropdownMenuEntries: entries,
          onSelected: onChanged,
          enableFilter: true,
          errorText: errorText,
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          ),
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );
      },
    );
  }
}
