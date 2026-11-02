import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diagnostic_models.dart';

class StorageService {
  static const String keyLanguage = 'pref_lang';
  static const String keyDarkMode = 'pref_dark_mode';
  static const String keyBaseUrl = 'pref_base_url';
  static const String keyProfile = 'pref_farmer_profile';
  static const String keyCachedHistory = 'cache_diagnoses';

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // In-memory fallback if platform channel unavailable
      _prefs = null;
    }
  }

  String getLanguage() {
    return _prefs?.getString(keyLanguage) ?? 'en';
  }

  Future<void> setLanguage(String lang) async {
    await _prefs?.setString(keyLanguage, lang);
  }

  bool isDarkMode() {
    return _prefs?.getBool(keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool(keyDarkMode, isDark);
  }

  String getBaseUrl() {
    return _prefs?.getString(keyBaseUrl) ?? 'http://10.0.2.2:8000/api';
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs?.setString(keyBaseUrl, url);
  }

  Map<String, String> getProfile() {
    final raw = _prefs?.getString(keyProfile);
    if (raw != null) {
      try {
        final map = json.decode(raw) as Map<String, dynamic>;
        return map.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {}
    }
    return {
      'name': 'Rameshbhai Patel',
      'location': 'Anand, Gujarat',
      'acreage': '12.5',
      'primary_crop': 'Guava',
    };
  }

  Future<void> saveProfile(Map<String, String> profile) async {
    await _prefs?.setString(keyProfile, json.encode(profile));
  }

  List<DiagnosisRecordModel> getCachedHistory() {
    final raw = _prefs?.getString(keyCachedHistory);
    if (raw != null) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        return list.map((e) => DiagnosisRecordModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> cacheHistory(List<DiagnosisRecordModel> records) async {
    try {
      final list = records.take(30).map((r) => {
        'id': r.id,
        'sample_id': r.sampleId,
        'timestamp': r.timestamp,
        'crop': r.crop,
        'diagnosis_type': r.diagnosisType,
        'is_paired_sample': r.isPairedSample,
        'leaf_disease': r.leafDisease,
        'leaf_confidence': r.leafConfidence,
        'gradcam_filename': r.gradcamFilename,
        'soil_status': r.soilStatus,
        'soil_confidence': r.soilConfidence,
        'overall_risk_level': r.overallRiskLevel,
        'agronomic_summary': r.agronomicSummary,
        'report_pdf_filename': r.reportPdfFilename,
      }).toList();
      await _prefs?.setString(keyCachedHistory, json.encode(list));
    } catch (_) {}
  }
}
