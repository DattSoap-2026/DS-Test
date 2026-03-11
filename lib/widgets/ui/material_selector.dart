import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/types/product_types.dart' as p_types;
import 'package:flutter_app/utils/responsive.dart';

class MaterialSelector extends StatelessWidget {
  final String? selectedMaterialId;
  final List<p_types.Product> materials;
  final Function(p_types.Product) onChanged;
  final String label;

  const MaterialSelector({
    super.key,
    required this.selectedMaterialId,
    required this.materials,
    required this.onChanged,
    this.label = 'Select Material',
  });

  @override
  Widget build(BuildContext context) {
    final selectedMaterial = materials.firstWhere(
      (m) => m.id == selectedMaterialId,
      orElse: () => p_types.Product.empty(),
    );

    final theme = Theme.of(context);
    final hasSelection =
        selectedMaterialId != null && selectedMaterialId!.isNotEmpty;

    return InkWell(
      onTap: () => _showSearchDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          fillColor: theme.dividerColor.withValues(alpha: 0.02),
          filled: true,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                !hasSelection
                    ? 'Tap to search material...'
                    : selectedMaterial.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasSelection
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: !hasSelection
                      ? theme.hintColor
                      : theme.textTheme.bodyMedium?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.search_rounded,
              size: 18,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MaterialSearchSheet(
        materials: materials,
        onSelected: (mat) {
          onChanged(mat);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _MaterialSearchSheet extends StatefulWidget {
  final List<p_types.Product> materials;
  final Function(p_types.Product) onSelected;

  const _MaterialSearchSheet({
    required this.materials,
    required this.onSelected,
  });

  @override
  State<_MaterialSearchSheet> createState() => _MaterialSearchSheetState();
}

class _MaterialSearchSheetState extends State<_MaterialSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.materials
        .where(
          (m) =>
              m.name.toLowerCase().contains(_query.toLowerCase()) ||
              (m.category.toLowerCase().contains(_query.toLowerCase())) ||
              (m.sku.toLowerCase().contains(_query.toLowerCase())),
        )
        .toList();

    return Container(
      height: Responsive.height(context) * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Select Material',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name, category or SKU...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.dividerColor.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No materials found',
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final mat = filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        title: Text(
                          mat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${mat.category}  ${mat.baseUnit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                        ),
                        trailing: Text(
                          'Stock: ${mat.stock}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: mat.stock > 0
                                ? AppColors.success
                                : theme.colorScheme.error,
                          ),
                        ),
                        onTap: () => widget.onSelected(mat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


