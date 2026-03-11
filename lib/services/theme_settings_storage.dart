import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme/theme_settings.dart';

class ThemeSettingsStorage {
  ThemeSettingsStorage({String? scopeKey})
      : _scopeKey = scopeKey?.isNotEmpty == true ? scopeKey! : 'global';

  final String _scopeKey;

  String _key(String field) => 'theme_settings_${_scopeKey}_$field';

  Future<ThemeSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final modeValue = prefs.getString(_key('mode'));
    final patternValue = prefs.getString(_key('pattern'));

    final themeMode = _parseThemeMode(modeValue) ?? ThemeMode.system;
    final pattern = _parsePattern(patternValue) ??
        ThemeSettings.defaults().pattern;

    final customEnabled =
        prefs.getBool(_key('custom_enabled')) ?? false;
    final primaryColor = _readColor(
      prefs,
      _key('primary'),
      ThemeSettings.defaults().primaryColor,
    );
    final surfaceColor = _readColor(
      prefs,
      _key('surface'),
      ThemeSettings.defaults().surfaceColor,
    );
    final accentColor = _readColor(
      prefs,
      _key('accent'),
      ThemeSettings.defaults().accentColor,
    );

    return ThemeSettings(
      themeMode: themeMode,
      customThemeEnabled: customEnabled,
      primaryColor: primaryColor,
      surfaceColor: surfaceColor,
      accentColor: accentColor,
      pattern: pattern,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key('mode'), mode.name);
  }

  Future<void> saveCustomTheme(ThemeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key('custom_enabled'), settings.customThemeEnabled);
    await prefs.setInt(_key('primary'), settings.primaryColor.toARGB32());
    await prefs.setInt(_key('surface'), settings.surfaceColor.toARGB32());
    await prefs.setInt(_key('accent'), settings.accentColor.toARGB32());
    await prefs.setString(_key('pattern'), settings.pattern.name);
  }

  Color _readColor(SharedPreferences prefs, String key, Color fallback) {
    final value = prefs.getInt(key);
    if (value == null) return fallback;
    return Color(value);
  }

  ThemeMode? _parseThemeMode(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.replaceAll('ThemeMode.', '');
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == normalized,
      orElse: () => ThemeMode.system,
    );
  }

  ThemePattern? _parsePattern(String? value) {
    if (value == null || value.isEmpty) return null;
    return ThemePattern.values.firstWhere(
      (pattern) => pattern.name == value,
      orElse: () => ThemeSettings.defaults().pattern,
    );
  }
}
