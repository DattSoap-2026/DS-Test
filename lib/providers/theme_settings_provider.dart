import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme/theme_settings.dart';
import '../services/theme_settings_storage.dart';

class ThemeSettingsState {
  final ThemeSettings settings;
  final ThemeSettings persisted;
  final bool isLoading;
  final bool isSaving;
  final List<Color> recentColors;

  const ThemeSettingsState({
    required this.settings,
    required this.persisted,
    required this.isLoading,
    required this.isSaving,
    required this.recentColors,
  });

  factory ThemeSettingsState.initial() {
    final defaults = ThemeSettings.defaults();
    return ThemeSettingsState(
      settings: defaults,
      persisted: defaults,
      isLoading: true,
      isSaving: false,
      recentColors: const [],
    );
  }

  bool get isDirty => settings != persisted;

  ThemeSettingsState copyWith({
    ThemeSettings? settings,
    ThemeSettings? persisted,
    bool? isLoading,
    bool? isSaving,
    List<Color>? recentColors,
  }) {
    return ThemeSettingsState(
      settings: settings ?? this.settings,
      persisted: persisted ?? this.persisted,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      recentColors: recentColors ?? this.recentColors,
    );
  }
}

class ThemeSettingsController extends StateNotifier<ThemeSettingsState> {
  ThemeSettingsController(this._storage) : super(ThemeSettingsState.initial()) {
    load();
  }

  final ThemeSettingsStorage _storage;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final settings = await _storage.load();
      state = state.copyWith(
        settings: settings,
        persisted: settings,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(
      settings: state.settings.copyWith(themeMode: mode),
    );
    await _storage.saveThemeMode(mode);
    state = state.copyWith(
      persisted: state.persisted.copyWith(themeMode: mode),
    );
  }

  Future<void> toggleQuickMode(Brightness platformBrightness) async {
    final current = state.settings.themeMode;
    final resolved = current == ThemeMode.system
        ? (platformBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light)
        : current;
    final next = resolved == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  void setCustomThemeEnabled(bool enabled) {
    state = state.copyWith(
      settings: state.settings.copyWith(customThemeEnabled: enabled),
    );
  }

  void setPrimaryColor(Color color) {
    state = state.copyWith(
      settings: state.settings.copyWith(primaryColor: color),
    );
  }

  void setSurfaceColor(Color color) {
    state = state.copyWith(
      settings: state.settings.copyWith(surfaceColor: color),
    );
  }

  void setAccentColor(Color color) {
    state = state.copyWith(
      settings: state.settings.copyWith(accentColor: color),
    );
  }

  void addRecentColor(Color color) {
    final normalized = color.toARGB32();
    final filtered = state.recentColors
        .where((c) => c.toARGB32() != normalized)
        .toList();
    final updated = [color, ...filtered];
    state = state.copyWith(
      recentColors: updated.take(6).toList(growable: false),
    );
  }

  void applyPattern(ThemePattern pattern) {
    final palette = ThemePatternPalette.forPattern(pattern);
    state = state.copyWith(
      settings: state.settings.copyWith(
        customThemeEnabled: true,
        primaryColor: palette.primary,
        surfaceColor: palette.surface,
        accentColor: palette.accent,
        pattern: pattern,
      ),
    );
  }

  Future<void> saveCustomTheme() async {
    state = state.copyWith(isSaving: true);
    try {
      await _storage.saveCustomTheme(state.settings);
      state = state.copyWith(
        persisted: state.settings,
        isSaving: false,
      );
    } catch (_) {
      state = state.copyWith(isSaving: false);
    }
  }
}

final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsController, ThemeSettingsState>(
  (ref) => ThemeSettingsController(ThemeSettingsStorage()),
);
