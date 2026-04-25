import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = ChangeNotifierProvider<SettingsController>((ref) {
  final controller = SettingsController();
  controller.load();
  return controller;
});

class SettingsController extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get loaded => _loaded;

  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_themeModeKey);

    switch (mode) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
