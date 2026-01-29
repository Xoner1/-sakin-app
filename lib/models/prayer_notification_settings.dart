import 'package:adhan/adhan.dart';
import 'package:hive/hive.dart';

part 'prayer_notification_settings.g.dart';

/// نموذج إعدادات التنبيهات لكل صلاة.
/// يستخدم لإدارة تفعيل أو تعطيل التنبيهات لكل صلاة بشكل مستقل.
@HiveType(typeId: 1)
class PrayerNotificationSettings {
  @HiveField(0)
  final bool fajrEnabled;

  @HiveField(1)
  final bool dhuhrEnabled;

  @HiveField(2)
  final bool asrEnabled;

  @HiveField(3)
  final bool maghribEnabled;

  @HiveField(4)
  final bool ishaEnabled;

  const PrayerNotificationSettings({
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
  });

  /// التحقق من تفعيل تنبيه صلاة معينة.
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

  /// تحويل كائن الإعدادات إلى [Map] كدعم إضافي بجانب Hive.
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajrEnabled,
      'dhuhr': dhuhrEnabled,
      'asr': asrEnabled,
      'maghrib': maghribEnabled,
      'isha': ishaEnabled,
    };
  }

  /// إنشاء كائن [PrayerNotificationSettings] من [Map].
  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationSettings(
      fajrEnabled: json['fajr'] ?? true,
      dhuhrEnabled: json['dhuhr'] ?? true,
      asrEnabled: json['asr'] ?? true,
      maghribEnabled: json['maghrib'] ?? true,
      ishaEnabled: json['isha'] ?? true,
    );
  }

  /// إنشاء نسخة جديدة من الإعدادات مع تعديل بعض الحقول.
  /// يساعد في الحفاظ على الجمود (Immutability).
  PrayerNotificationSettings copyWith({
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
  }) {
    return PrayerNotificationSettings(
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
    );
  }
}
