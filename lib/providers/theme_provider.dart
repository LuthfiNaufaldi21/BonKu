import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Default awal kita buat ke mode gelap (Dark Mode) karena sesuai dengan style BonKu
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadThemePreference();
  }

  // Mengubah status tema dan menyimpannya ke memori HP
  void toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isOn);
  }

  // Memuat preferensi tema yang tersimpan sebelumnya
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true; // Default true (dark)
    notifyListeners();
  }
}