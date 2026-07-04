import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _initTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _initTheme() async {
    _isDarkMode = await LocalStorageService.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await LocalStorageService.setThemeMode(_isDarkMode);
    notifyListeners();
  }
}