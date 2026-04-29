import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _accentColor = AppColors.primary;
  String _languageCode = 'en'; 
  String _notificationSound = 'universfield_new_notification_022_370046'; // Default sound

  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;
  String get languageCode => _languageCode;
  String get notificationSound => _notificationSound;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    // ignore: deprecated_member_use
    int colorValue = prefs.getInt('accentColor') ?? AppColors.primary.value;
    // ignore: deprecated_member_use
    _accentColor = Color(colorValue);
    _languageCode = prefs.getString('languageCode') ?? 'en';
    _notificationSound = prefs.getString('notificationSound') ?? 'universfield_new_notification_022_370046';
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // ignore: deprecated_member_use
    await prefs.setInt('accentColor', color.value);
  }

  Future<void> setLanguage(String lang) async {
    _languageCode = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', lang);
  }

  Future<void> setNotificationSound(String soundName) async {
    _notificationSound = soundName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationSound', soundName);
  }
}
