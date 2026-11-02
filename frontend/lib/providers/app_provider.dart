import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/diagnostic_models.dart';

class AppProvider extends ChangeNotifier {
  final StorageService storageService;
  late final ApiService apiService;

  Locale _currentLocale = const Locale('en');
  bool _isDarkMode = false;
  bool _isServerOnline = false;
  bool _isLoadingHistory = false;
  List<DiagnosisRecordModel> _history = [];
  Map<String, String> _profile = {};

  AppProvider({required this.storageService}) {
    apiService = ApiService(baseUrl: storageService.getBaseUrl());
    _currentLocale = Locale(storageService.getLanguage());
    _isDarkMode = storageService.isDarkMode();
    _profile = storageService.getProfile();
    _history = storageService.getCachedHistory();
    checkConnection();
  }

  Locale get currentLocale => _currentLocale;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isServerOnline => _isServerOnline;
  bool get isLoadingHistory => _isLoadingHistory;
  List<DiagnosisRecordModel> get history => _history;
  Map<String, String> get profile => _profile;
  String get baseUrl => apiService.baseUrl;

  void setLocale(String langCode) async {
    if (_currentLocale.languageCode != langCode) {
      _currentLocale = Locale(langCode);
      await storageService.setLanguage(langCode);
      notifyListeners();
    }
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await storageService.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> setBaseUrl(String newUrl) async {
    apiService.updateBaseUrl(newUrl);
    await storageService.setBaseUrl(apiService.baseUrl);
    await checkConnection();
    notifyListeners();
  }

  Future<bool> checkConnection() async {
    final status = await apiService.checkHealth();
    _isServerOnline = status;
    notifyListeners();
    return status;
  }

  Future<void> fetchHistory({String? crop}) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final records = await apiService.getHistory(crop: crop);
      _history = records;
      await storageService.cacheHistory(records);
    } catch (_) {
      // Keep cached records on network failure
      _history = storageService.getCachedHistory();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecord(int id) async {
    try {
      final ok = await apiService.deleteHistoryRecord(id);
      if (ok) {
        _history.removeWhere((item) => item.id == id);
        await storageService.cacheHistory(_history);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> updateProfile(Map<String, String> newProfile) async {
    _profile = newProfile;
    await storageService.saveProfile(newProfile);
    notifyListeners();
  }
}
