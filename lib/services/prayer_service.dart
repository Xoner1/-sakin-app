import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';
import '../models/prayer_notification_settings.dart';

class PrayerService with ChangeNotifier {
  PrayerTimes? _prayerTimes;
  SunnahTimes? _sunnahTimes;
  Coordinates _coordinates = Coordinates(33.8869, 9.7963); // Default: Tunisia

  PrayerService() {
    calculatePrayers();
  }

  void updateLocation(double latitude, double longitude) {
    _coordinates = Coordinates(latitude, longitude);
    calculatePrayers();
  }

  void calculatePrayers() {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    _prayerTimes = PrayerTimes(_coordinates, date, params);

    // حساب أوقات السنة (الsunnah)
    if (_prayerTimes != null) {
      _sunnahTimes = SunnahTimes(_prayerTimes!);
    }

    notifyListeners();
  }

  /// جدولة الإشعارات بناءً على الإعدادات الحالية
  Future<void> scheduleNotifications(
      PrayerNotificationSettings settings) async {
    if (_prayerTimes == null) return;

    debugPrint('⏳ 📅 Scheduling notifications...');

    // قائمة بالصلوات لجدولتها
    final currentPrayers = {
      'الفجر': _prayerTimes!.fajr,
      'الظهر': _prayerTimes!.dhuhr,
      'العصر': _prayerTimes!.asr,
      'المغرب': _prayerTimes!.maghrib,
      'العشاء': _prayerTimes!.isha,
    };

    int alarmId = 0;
    final now = DateTime.now();

    for (var entry in currentPrayers.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      // تحقق من التفعيل
      bool isEnabled = false;
      switch (prayerName) {
        case 'الفجر':
          isEnabled = settings.fajrEnabled;
          break;
        case 'الظهر':
          isEnabled = settings.dhuhrEnabled;
          break;
        case 'العصر':
          isEnabled = settings.asrEnabled;
          break;
        case 'المغرب':
          isEnabled = settings.maghribEnabled;
          break;
        case 'العشاء':
          isEnabled = settings.ishaEnabled;
          break;
      }

      if (isEnabled && prayerTime.isAfter(now)) {
        debugPrint('✅ Scheduling $prayerName at $prayerTime');
        await NotificationService.scheduleAdhan(
            alarmId, prayerName, prayerTime);
      }
      alarmId++;
    }
  }

  PrayerTimes? get prayerTimes => _prayerTimes;
  SunnahTimes? get sunnahTimes => _sunnahTimes;

  Prayer get nextPrayer => _prayerTimes?.nextPrayer() ?? Prayer.none;

  // وقت منتصف الليل
  DateTime? get middleOfTheNight => _sunnahTimes?.middleOfTheNight;

  // الثلث الأخير من الليل
  DateTime? get lastThirdOfTheNight => _sunnahTimes?.lastThirdOfTheNight;

  // إرجاع الصلاة القادمة والوقت كبيانات خام
  DateTime? getNextPrayerTime() {
    if (_prayerTimes == null) return null;
    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return null;
    return _prayerTimes!.timeForPrayer(next);
  }

  // دالة لجلب الوقت المتبقي كـ Duration
  Duration? getTimeRemainingDuration() {
    if (_prayerTimes == null) return null;

    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return null;

    final nextTime = _prayerTimes!.timeForPrayer(next)!;
    final now = DateTime.now();
    return nextTime.difference(now);
  }

  // يمكن حذف getHijriDate أو الاحتفاظ بها مع تمرير locale إذا لزم الأمر،
  // لكن الأحسن التعامل مع التاريخ في الواجهة
  DateTime get now => DateTime.now();

  // Format time (e.g., 5:30 PM)
  String getFormattedTime(DateTime? time) {
    if (time == null) return "";
    return DateFormat.jm().format(time);
  }

  // Get remaining time as string (e.g., 02:15:30)
  String getTimeRemaining() {
    final duration = getTimeRemainingDuration();
    if (duration == null) return "";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Get Hijri date (Placeholder/Basic implementation)
  String getHijriDate() {
    // Note: To support real Hijri dates, the 'hijri' or 'jhijri' package is needed.
    // Returning Gregorian date for now to prevent errors.
    return DateFormat.yMMMMd('ar').format(DateTime.now());
  }
}
