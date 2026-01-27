import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/prayer_notification_settings.dart';

/// خدمة لإدارة إعدادات الإشعارات
class SettingsService with ChangeNotifier {
  PrayerNotificationSettings _settings = PrayerNotificationSettings();

  PrayerNotificationSettings get settings => _settings;

  /// تحميل الإعدادات من Hive
  Future<void> loadSettings() async {
    try {
      final box = await Hive.openBox('settings');
      final data = box.get('prayer_notifications');
      if (data != null) {
        _settings = PrayerNotificationSettings.fromJson(
            Map<String, dynamic>.from(data));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الإعدادات: $e');
    }
  }

  /// حفظ الإعدادات في Hive
  Future<void> saveSettings() async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('prayer_notifications', _settings.toJson());
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في حفظ الإعدادات: $e');
    }
  }

  /// تحديث حالة صلاة معينة
  Future<void> togglePrayer(String prayerName, bool value) async {
    switch (prayerName) {
      case 'fajr':
        _settings.fajrEnabled = value;
        break;
      case 'dhuhr':
        _settings.dhuhrEnabled = value;
        break;
      case 'asr':
        _settings.asrEnabled = value;
        break;
      case 'maghrib':
        _settings.maghribEnabled = value;
        break;
      case 'isha':
        _settings.ishaEnabled = value;
        break;
    }
    await saveSettings();
  }
}
