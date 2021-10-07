import 'package:flutter/material.dart';
import '../services/sharedpref.dart';
import '../constants/themes.dart';

class ThemeModel extends ChangeNotifier {
  bool? _isDark;
  ThemePreferences? _preferences;
  bool get isDark => _isDark!;

  ThemeModel() {
    _isDark = false;
    _preferences = ThemePreferences();
    getPreferences();
  }
  set isDark(bool value) {
    _isDark = value;
    _preferences!.setTheme(value);
    notifyListeners();
  }

  get getTheme {
    if (_isDark!) {
      return darkTheme;
    } else {
      return lightTheme;
    }
  }

  getPreferences() async {
    _isDark = await _preferences!.getTheme();
    notifyListeners();
  }
}
