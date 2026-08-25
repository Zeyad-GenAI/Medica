import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.light;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    final preferences = await SharedPreferences.getInstance();
    final themeName = preferences.getString('themeMode') ?? 'light';

    _themeMode = switch (themeName) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };

    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;

    _themeMode = mode;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('themeMode', mode.name);
    notifyListeners();
  }
}
