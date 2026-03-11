import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static const double _cardRadius = 18.0;
  static const double _controlRadius = 12.0;
  static const double _chipRadius = 10.0;
  static const double _inputHeight = 48.0;

  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightAccent,
    surface: AppColors.lightSurface,
    error: AppColors.lightError,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.lightTextPrimary,
    onSurfaceVariant: AppColors.lightTextMuted,
    outline: AppColors.lightBorder,
    outlineVariant: AppColors.lightBorder,
    surfaceContainerLowest: AppColors.lightSurface,
    surfaceContainerLow: AppColors.lightSurface,
    surfaceContainer: AppColors.lightBackground,
    surfaceContainerHigh: AppColors.lightBackground,
    surfaceContainerHighest: AppColors.lightBackground,
    inverseSurface: AppColors.lightTextPrimary,
    onInverseSurface: Colors.white,
    surfaceTint: AppColors.lightPrimary,
  );

  static final ColorScheme _darkScheme = ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkAccent,
    surface: AppColors.darkSurface,
    error: AppColors.darkError,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.darkTextPrimary,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkBorder,
    surfaceContainerLowest: AppColors.darkBackground,
    surfaceContainerLow: AppColors.darkSurface,
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkCard,
    surfaceContainerHighest: AppColors.darkCard,
    inverseSurface: AppColors.darkTextPrimary,
    onInverseSurface: AppColors.darkBackground,
    surfaceTint: AppColors.darkPrimary,
  );

  // --- Typography Rules ---
  // Headings: Sora (display), Body: Manrope (readable, modern)
  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    final body = GoogleFonts.manropeTextTheme(base)
        .apply(bodyColor: color, displayColor: color);

    return body.copyWith(
      displayLarge: GoogleFonts.sora(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.sora(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displaySmall: GoogleFonts.sora(
        color: color,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      headlineLarge: GoogleFonts.sora(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineMedium: GoogleFonts.sora(
        color: color,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      headlineSmall: GoogleFonts.sora(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.sora(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.manrope(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.manrope(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.manrope(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: GoogleFonts.manrope(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.manrope().fontFamily,
    brightness: Brightness.light,
    colorScheme: _lightScheme,
    scaffoldBackgroundColor: AppColors.lightBackground,
    hintColor: AppColors.lightTextMuted,
    disabledColor: AppColors.lightTextMuted.withValues(alpha: 0.6),
    hoverColor: _lightScheme.primary.withValues(alpha: 0.08),
    focusColor: _lightScheme.primary.withValues(alpha: 0.12),
    highlightColor: _lightScheme.primary.withValues(alpha: 0.08),
    splashColor: _lightScheme.primary.withValues(alpha: 0.12),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Modern transparent appbar
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
        size: 20,
      ),
      titleTextStyle: GoogleFonts.sora(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: _buildTextTheme(
      ThemeData.light().textTheme,
      AppColors.lightTextPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
      constraints: const BoxConstraints(minHeight: _inputHeight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.lightError),
      ),
      labelStyle: GoogleFonts.manrope(
        color: AppColors.lightTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: GoogleFonts.manrope(
        color: AppColors.lightTextMuted,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.manrope(
        color: AppColors.lightPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(96, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(color: AppColors.lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(96, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(72, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.lightTextSecondary,
      size: 20,
    ),
    listTileTheme: ListTileThemeData(
      dense: false,
      iconColor: AppColors.lightTextSecondary,
      textColor: AppColors.lightTextPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_chipRadius),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      backgroundColor: AppColors.lightSurface,
      labelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      secondaryLabelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      titleTextStyle: GoogleFonts.sora(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: GoogleFonts.manrope(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      modalBackgroundColor: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightSurface,
      contentTextStyle: GoogleFonts.manrope(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      actionTextColor: AppColors.lightPrimary,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: _lightScheme.inverseSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: GoogleFonts.manrope(
        color: _lightScheme.onInverseSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _lightScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      textStyle: GoogleFonts.manrope(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          _lightScheme.surfaceContainerHighest,
        ),
        side: WidgetStateProperty.all(
          const BorderSide(color: AppColors.lightBorder),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_controlRadius),
          ),
        ),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(
        AppColors.lightBackground,
      ),
      headingTextStyle: GoogleFonts.manrope(
        color: AppColors.lightTextSecondary,
        fontWeight: FontWeight.w700,
      ),
      dataTextStyle: GoogleFonts.manrope(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      dividerThickness: 1,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.lightPrimary,
      unselectedLabelColor: AppColors.lightTextSecondary,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.lightPrimary.withValues(alpha: 0.12),
      ),
      labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.manrope().fontFamily,
    brightness: Brightness.dark,
    colorScheme: _darkScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    hintColor: AppColors.darkTextMuted,
    disabledColor: AppColors.darkTextMuted.withValues(alpha: 0.6),
    hoverColor: _darkScheme.primary.withValues(alpha: 0.12),
    focusColor: _darkScheme.primary.withValues(alpha: 0.16),
    highlightColor: _darkScheme.primary.withValues(alpha: 0.12),
    splashColor: _darkScheme.primary.withValues(alpha: 0.16),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface, // Matches surface often
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 20,
      ),
      titleTextStyle: GoogleFonts.sora(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: _buildTextTheme(
      ThemeData.dark().textTheme,
      AppColors.darkTextPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
      constraints: const BoxConstraints(minHeight: _inputHeight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        borderSide: const BorderSide(color: AppColors.darkError),
      ),
      labelStyle: GoogleFonts.manrope(
        color: AppColors.darkTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: GoogleFonts.manrope(
        color: AppColors.darkTextMuted,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.manrope(
        color: AppColors.darkPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(96, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(96, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(72, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.darkTextSecondary,
      size: 20,
    ),
    listTileTheme: ListTileThemeData(
      dense: false,
      iconColor: AppColors.darkTextSecondary,
      textColor: AppColors.darkTextPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_chipRadius),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      backgroundColor: AppColors.darkSurface,
      labelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      secondaryLabelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      titleTextStyle: GoogleFonts.sora(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: GoogleFonts.manrope(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      modalBackgroundColor: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface,
      contentTextStyle: GoogleFonts.manrope(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      actionTextColor: AppColors.darkPrimary,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: _darkScheme.inverseSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: GoogleFonts.manrope(
        color: _darkScheme.onInverseSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _darkScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_controlRadius),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      textStyle: GoogleFonts.manrope(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          _darkScheme.surfaceContainerHighest,
        ),
        side: WidgetStateProperty.all(
          const BorderSide(color: AppColors.darkBorder),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_controlRadius),
          ),
        ),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(
        AppColors.darkCard,
      ),
      headingTextStyle: GoogleFonts.manrope(
        color: AppColors.darkTextSecondary,
        fontWeight: FontWeight.w700,
      ),
      dataTextStyle: GoogleFonts.manrope(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      dividerThickness: 1,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.darkPrimary,
      unselectedLabelColor: AppColors.darkTextSecondary,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.darkPrimary.withValues(alpha: 0.18),
      ),
      labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
    ),
  );
}
