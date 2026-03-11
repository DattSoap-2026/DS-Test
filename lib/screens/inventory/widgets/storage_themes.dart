import 'package:flutter/material.dart';

class StorageTheme {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color liquidColor;
  final IconData icon;

  const StorageTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.liquidColor,
    required this.icon,
  });
}

const StorageTheme _sonaUnitTheme = StorageTheme(
  primary: Color(0xFFF2B705), // Golden yellow
  secondary: Color(0xFFFFF8DB),
  accent: Color(0xFFFFD54F),
  liquidColor: Color(0xFFE8A300),
  icon: Icons.water_drop,
);

const StorageTheme _gitaUnitTheme = StorageTheme(
  primary: Color(0xFF1D4ED8), // Strong blue
  secondary: Color(0xFFEFF6FF),
  accent: Color(0xFF60A5FA),
  liquidColor: Color(0xFF2563EB),
  icon: Icons.water_drop,
);

// Predefined themes for common departments
final Map<String, StorageTheme> _predefinedThemes = {
  'Soap Department': const StorageTheme(
    primary: Color(0xFF4F46E5), // Indigo
    secondary: Color(0xFFEEF2FF),
    accent: Color(0xFF818CF8),
    liquidColor: Color(0xFF6366F1),
    icon: Icons.bubble_chart,
  ),
  'Detergent Department': const StorageTheme(
    primary: Color(0xFF10B981), // Emerald
    secondary: Color(0xFFECFDF5),
    accent: Color(0xFF34D399),
    liquidColor: Color(0xFF10B981),
    icon: Icons.cleaning_services,
  ),
  'Liquid Department': const StorageTheme(
    primary: Color(0xFF06B6D4), // Cyan
    secondary: Color(0xFFECFEFF),
    accent: Color(0xFF22D3EE),
    liquidColor: Color(0xFF0891B2),
    icon: Icons.water_drop,
  ),
  'Packaging Department': const StorageTheme(
    primary: Color(0xFF8B5CF6), // Violet
    secondary: Color(0xFFF5F3FF),
    accent: Color(0xFFA78BFA),
    liquidColor: Color(0xFF7C3AED),
    icon: Icons.inventory_2,
  ),
  'Raw Material Store': const StorageTheme(
    primary: Color(0xFFF59E0B), // Amber
    secondary: Color(0xFFFFFBEB),
    accent: Color(0xFFFBBF24),
    liquidColor: Color(0xFFD97706),
    icon: Icons.warehouse,
  ),
};

// Default fallback theme
const StorageTheme _defaultTheme = StorageTheme(
  primary: Color(0xFF6B7280), // Gray
  secondary: Color(0xFFF9FAFB),
  accent: Color(0xFF9CA3AF),
  liquidColor: Color(0xFF4B5563),
  icon: Icons.storage,
);

// Palette of colors to cycle through for new departments
final List<Map<String, dynamic>> _colorPalette = [
  {
    'primary': const Color(0xFF3B82F6), // Blue
    'secondary': const Color(0xFFEFF6FF),
    'accent': const Color(0xFF60A5FA),
    'liquid': const Color(0xFF2563EB),
    'icon': Icons.business,
  },
  {
    'primary': const Color(0xFFEC4899), // Pink
    'secondary': const Color(0xFFFDF2F8),
    'accent': const Color(0xFFF472B6),
    'liquid': const Color(0xFFDB2777),
    'icon': Icons.local_florist,
  },
  {
    'primary': const Color(0xFF14B8A6), // Teal
    'secondary': const Color(0xFFF0FDFA),
    'accent': const Color(0xFF2DD4BF),
    'liquid': const Color(0xFF0F766E),
    'icon': Icons.water,
  },
  {
    'primary': const Color(0xFFEAB308), // Yellow
    'secondary': const Color(0xFFFEFCE8),
    'accent': const Color(0xFFFDE047),
    'liquid': const Color(0xFFCA8A04),
    'icon': Icons.wb_sunny,
  },
  {
    'primary': const Color(0xFFF97316), // Orange
    'secondary': const Color(0xFFFFF7ED),
    'accent': const Color(0xFFFB923C),
    'liquid': const Color(0xFFEA580C),
    'icon': Icons.local_fire_department,
  },
];

StorageTheme getThemeForDepartment(String? department) {
  if (department == null || department.isEmpty) return _defaultTheme;
  final normalizedDepartment = department.trim().toLowerCase();

  // [LOCKED] Unit-specific color coding
  if (normalizedDepartment.contains('sona')) {
    return _sonaUnitTheme;
  }
  if (normalizedDepartment.contains('gita')) {
    return _gitaUnitTheme;
  }

  // Check predefined themes first
  if (_predefinedThemes.containsKey(department)) {
    return _predefinedThemes[department]!;
  }

  // Generate theme based on department name hash
  final hash = department.hashCode.abs();
  final paletteIndex = hash % _colorPalette.length;
  final selectedPalette = _colorPalette[paletteIndex];

  return StorageTheme(
    primary: selectedPalette['primary'] as Color,
    secondary: selectedPalette['secondary'] as Color,
    accent: selectedPalette['accent'] as Color,
    liquidColor: selectedPalette['liquid'] as Color,
    icon: selectedPalette['icon'] as IconData,
  );
}
