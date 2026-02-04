import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static late SharedPreferences _prefs;

  static const String _keyDarkMode = 'isDarkMode';
  static const String _keyLanguage = 'languageCode';
  static const String _keyLocation = 'location';
  static const String _keyManualOffset = 'manualTimeOffset';
  static const String _keyBatteryOptim = 'ignoreBatteryOptimizations';
  static const String _keyPrayerOffsets = 'prayerOffsets';
  static const String _keyInstallDate = 'installDate';
  static const String _keyLatitude = 'latitude';
  static const String _keyLongitude = 'longitude';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    if (_prefs.getString(_keyInstallDate) == null) {
      await _prefs.setString(_keyInstallDate, DateTime.now().toIso8601String());
    }
  }

  // Dark Mode
  static bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? false;
  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }

  // Language
  static String get language => _prefs.getString(_keyLanguage) ?? 'ar';
  static Future<void> setLanguage(String value) async {
    await _prefs.setString(_keyLanguage, value);
  }

  // Location
  static String get location => _prefs.getString(_keyLocation) ?? 'تونس، قابس';
  static Future<void> setLocation(String value) async {
    await _prefs.setString(_keyLocation, value);
  }

  static double? get latitude => _prefs.getDouble(_keyLatitude);
  static double? get longitude => _prefs.getDouble(_keyLongitude);

  static Future<void> setCoordinates(double lat, double long) async {
    await _prefs.setDouble(_keyLatitude, lat);
    await _prefs.setDouble(_keyLongitude, long);
  }

  // Manual Time Offset (Global)
  static int get manualOffset => _prefs.getInt(_keyManualOffset) ?? 0;
  static Future<void> setManualOffset(int value) async {
    await _prefs.setInt(_keyManualOffset, value);
  }

  // Per-Prayer Offsets
  static int getPrayerOffset(String prayerId) {
    final String? jsonString = _prefs.getString(_keyPrayerOffsets);
    if (jsonString == null) return 0;
    try {
      final Map<String, dynamic> offsets = jsonDecode(jsonString);
      return offsets[prayerId] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> setPrayerOffset(String prayerId, int minutes) async {
    final String? jsonString = _prefs.getString(_keyPrayerOffsets);
    Map<String, dynamic> offsets = {};
    if (jsonString != null) {
      try {
        offsets = jsonDecode(jsonString);
      } catch (_) {}
    }
    offsets[prayerId] = minutes;
    await _prefs.setString(_keyPrayerOffsets, jsonEncode(offsets));
  }

  static bool get hasOffsets {
    final String? jsonString = _prefs.getString(_keyPrayerOffsets);
    if (jsonString == null) return false;
    try {
      final Map<String, dynamic> offsets = jsonDecode(jsonString);
      // Check if any value is non-zero
      return offsets.values.any((val) => (val as int? ?? 0) != 0);
    } catch (_) {
      return false;
    }
  }

  static Future<void> resetPrayerOffsets() async {
    await _prefs.remove(_keyPrayerOffsets);
  }

  // Battery Optimization
  static bool get ignoreBatteryOptimizations =>
      _prefs.getBool(_keyBatteryOptim) ?? false;
  static Future<void> setIgnoreBatteryOptimizations(bool value) async {
    await _prefs.setBool(_keyBatteryOptim, value);
  }

  // Install Date
  static String? get installDate => _prefs.getString(_keyInstallDate);

  // Prayer Notifications
  static bool getPrayerNotification(String prayerKey) {
    return _prefs.getBool('notification_$prayerKey') ?? true;
  }

  static Future<void> setPrayerNotification(
      String prayerKey, bool value) async {
    await _prefs.setBool('notification_$prayerKey', value);
  }
}
