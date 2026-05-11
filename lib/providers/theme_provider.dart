// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

import '../services/prefs_service.dart';

/// Owns the app's [ThemeMode] and persists the choice to [SharedPreferences]
/// via [PrefsService].
///
/// Spec requirement #4: "Persist at least one simple preference using
/// SharedPreferences." This is that preference.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required PrefsService prefs}) : _prefs = prefs {
    _load();
  }

  final PrefsService _prefs;
  ThemeMode _mode = ThemeMode.system;
  bool _loaded = false;

  ThemeMode get themeMode => _mode;
  bool get isReady => _loaded;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> _load() async {
    final raw = await _prefs.readThemeMode();
    _mode = _decode(raw);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _prefs.writeThemeMode(_encode(mode));
  }

  /// Toggles between light and dark, used by the Profile "Appearance" item.
  Future<void> toggle() async {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _decode(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
