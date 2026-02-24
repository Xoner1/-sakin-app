import 'package:adhan/adhan.dart' as adhan;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';
import '../models/location_info.dart';
import '../models/prayer_notification_settings.dart';
import '../core/services/settings_service.dart';
import '../core/services/device_offset_service.dart';

class PrayerAlarmScheduler {
  static const String _settingsBoxName = 'settings';
  static const String _lastScheduledKey = 'last_scheduled_date';

  /// Schedules prayer alarms/notifications for the next 30 days.
  /// Returns [true] if scheduling succeeded, [false] if location data is missing.
  static Future<bool> schedulePrayerAlarms() async {
    final box = await Hive.openBox(_settingsBoxName);

    final locationData = box.get('cached_location');
    final settingsData = box.get('notification_settings');

    final int devicePreEmptiveOffset =
        await DeviceOffsetService.getDeviceSpecificOffset();

    if (locationData == null) {
      debugPrint('⚠️ Cannot schedule: No location data found.');
      return false; // ← caller knows to retry later
    }

    final location =
        LocationInfo.fromJson(Map<String, dynamic>.from(locationData));
    final settings = settingsData != null
        ? PrayerNotificationSettings.fromJson(
            Map<String, dynamic>.from(settingsData))
        : const PrayerNotificationSettings();

    final coordinates =
        adhan.Coordinates(location.latitude, location.longitude);
    final params = adhan.CalculationMethod.muslim_world_league.getParameters();
    params.madhab = adhan.Madhab.shafi;

    // ✅ No legacy alarm cleanup needed:
    // New IDs are date-based (e.g. 202602230) — far above any old ID range.
    // Running cancel(0..350) was causing 351 useless calls on every app open.

    debugPrint('⏳ Scheduling prayers for 30 days starting from today...');
    debugPrint(
        '━━━━━━ TODAY\'s PRAYERS (${DateTime.now().toString().substring(0, 10)}) ━━━━━━');

    // Log today's schedule first for easy verification
    final todayDate = DateTime.now();
    final todayComponents = adhan.DateComponents.from(todayDate);
    final todayTimes = adhan.PrayerTimes(coordinates, todayComponents, params);
    debugPrint('  📋 Fajr:   ${todayTimes.fajr.toLocal()}');
    debugPrint('  📋 Dhuhr:  ${todayTimes.dhuhr.toLocal()}');
    debugPrint('  📋 Asr:    ${todayTimes.asr.toLocal()}');
    debugPrint('  📋 Maghrib:${todayTimes.maghrib.toLocal()}');
    debugPrint('  📋 Isha:   ${todayTimes.isha.toLocal()}');
    debugPrint(
        '  📋 Location: lat=${coordinates.latitude}, lng=${coordinates.longitude}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final dateComponents = adhan.DateComponents.from(date);
      final prayerTimes =
          adhan.PrayerTimes(coordinates, dateComponents, params);

      await _scheduleDayPrayers(
          prayerTimes, settings, date, devicePreEmptiveOffset);
    }

    await box.put(_lastScheduledKey, DateTime.now().toIso8601String());
    debugPrint('✅ Successfully finished scheduling prayer alarms.');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return true;
  }

  static Future<void> _scheduleDayPrayers(
      adhan.PrayerTimes prayerTimes,
      PrayerNotificationSettings settings,
      DateTime date,
      int deviceOffset) async {
    // Combining user global manualOffset with the auto-calculated deviceOffset
    final manualOffset = SettingsService.manualOffset + deviceOffset;

    // Fetch individual sub-offsets saved by the user in the UI
    final imsakOffset = SettingsService.getPrayerOffset('Imsak');
    final fajrOffset = SettingsService.getPrayerOffset('Fajr');
    final dhuhrOffset = SettingsService.getPrayerOffset('Dhuhr');
    final asrOffset = SettingsService.getPrayerOffset('Asr');
    final maghribOffset = SettingsService.getPrayerOffset('Maghrib');
    final ishaOffset = SettingsService.getPrayerOffset('Isha');

    final prayers = {
      'Imsak': prayerTimes.fajr
          .subtract(const Duration(minutes: 15))
          .add(Duration(minutes: imsakOffset + manualOffset)),
      'Fajr':
          prayerTimes.fajr.add(Duration(minutes: fajrOffset + manualOffset)),
      'Dhuhr':
          prayerTimes.dhuhr.add(Duration(minutes: dhuhrOffset + manualOffset)),
      'Asr': prayerTimes.asr.add(Duration(minutes: asrOffset + manualOffset)),
      'Maghrib': prayerTimes.maghrib
          .add(Duration(minutes: maghribOffset + manualOffset)),
      'Isha':
          prayerTimes.isha.add(Duration(minutes: ishaOffset + manualOffset)),
    };

    // Generate a stable ID based on the date: YYYYMMDD0
    // Example: 202402200 for Fajr on Feb 20, 2024
    int baseId = (date.year * 10000 + date.month * 100 + date.day) * 10;

    // ✅ Use `for` loop instead of `forEach` — async/await is NOT respected inside forEach
    for (final entry in prayers.entries) {
      final name = entry.key;
      final time = entry.value;
      bool isEnabled = false;
      int prayerId = baseId;

      switch (name) {
        case 'Imsak':
          isEnabled = settings.fajrEnabled; // Tie Imsak alarm to Fajr's setting
          prayerId += 5;
          break;
        case 'Fajr':
          isEnabled = settings.fajrEnabled;
          prayerId += 0;
          break;
        case 'Dhuhr':
          isEnabled = settings.dhuhrEnabled;
          prayerId += 1;
          break;
        case 'Asr':
          isEnabled = settings.asrEnabled;
          prayerId += 2;
          break;
        case 'Maghrib':
          isEnabled = settings.maghribEnabled;
          prayerId += 3;
          break;
        case 'Isha':
          isEnabled = settings.ishaEnabled;
          prayerId += 4;
          break;
      }

      if (isEnabled && time.isAfter(DateTime.now())) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await _scheduleAndroidAlarm(prayerId, name, time);
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          await _scheduleIOSNotification(prayerId, name, time);
        }
      } else {
        // Log why this prayer was skipped
        if (!isEnabled) {
          debugPrint('  ⏭️ SKIPPED [$name] — disabled in settings');
        } else {
          debugPrint(
              '  ⏭️ SKIPPED [$name] at ${time.toLocal()} — time already passed');
        }
      }
    }
  }

  static Future<void> _scheduleAndroidAlarm(
      int id, String prayerName, DateTime time) async {
    final success = await AndroidAlarmManager.oneShotAt(
      time,
      id,
      adhanAlarmCallback,
      exact: true,
      wakeup: true,
      alarmClock: true,
      rescheduleOnReboot: true,
      params: {'prayerName': prayerName},
    );
    debugPrint(
        '  ${success ? '✅' : '❌'} ALARM [$prayerName] | ID=$id | at=${time.toLocal()} | success=$success');
  }

  static Future<void> _scheduleIOSNotification(
      int id, String prayerName, DateTime time) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // iOS specific details with 30s adhan sound
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan.caf', // iOS requires .caf or .wav usually if custom
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(iOS: iosDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '🕌 حان وقت صلاة $prayerName',
      'اللهم إني أسألك الثبات في الأمر والعزيمة على الرشد',
      tz.TZDateTime.from(time, tz.local),
      platformDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Checks if the last scheduling was more than 7 days ago.
  static Future<void> checkAndNotifyTTL() async {
    final box = await Hive.openBox(_settingsBoxName);
    final lastScheduledStr = box.get(_lastScheduledKey);

    if (lastScheduledStr != null) {
      final lastScheduled = DateTime.parse(lastScheduledStr);
      final diff = DateTime.now().difference(lastScheduled).inDays;

      if (diff >= 25) {
        await NotificationService.showNotification(
          'تحديث مواقيت الصلاة مطلوب',
          'يرجى فتح التطبيق لتحديث المواقيت لضمان دقتها للشهر القادم.',
        );
      }
    }
  }
}
