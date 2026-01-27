import 'package:adhan/adhan.dart';

/// نموذج إعدادات التنبيهات لكل صلاة
class PrayerNotificationSettings {
  bool fajrEnabled;
  bool dhuhrEnabled;
  bool asrEnabled;
  bool maghribEnabled;
  bool ishaEnabled;

  PrayerNotificationSettings({
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
  });

  // التحقق من تفعيل صلاة معينة
  bool isPrayerEnabled(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajrEnabled;
      case Prayer.dhuhr:
        return dhuhrEnabled;
      case Prayer.asr:
        return asrEnabled;
      case Prayer.maghrib:
        return maghribEnabled;
      case Prayer.isha:
        return ishaEnabled;
      default:
        return false;
    }
  }

  // تحويل إلى Map للحفظ في Hive
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajrEnabled,
      'dhuhr': dhuhrEnabled,
      'asr': asrEnabled,
      'maghrib': maghribEnabled,
      'isha': ishaEnabled,
    };
  }

  // إنشاء من Map
  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationSettings(
      fajrEnabled: json['fajr'] ?? true,
      dhuhrEnabled: json['dhuhr'] ?? true,
      asrEnabled: json['asr'] ?? true,
      maghribEnabled: json['maghrib'] ?? true,
      ishaEnabled: json['isha'] ?? true,
    );
  }

  // نسخة من الإعدادات
  PrayerNotificationSettings copy() {
    return PrayerNotificationSettings(
      fajrEnabled: fajrEnabled,
      dhuhrEnabled: dhuhrEnabled,
      asrEnabled: asrEnabled,
      maghribEnabled: maghribEnabled,
      ishaEnabled: ishaEnabled,
    );
  }
}
