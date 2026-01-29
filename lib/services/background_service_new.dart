import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:adhan/adhan.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // 1. Initialize intl for the isolate
    await initializeDateFormatting('ar', null);

    // 2. Initial update
    await _updateWithPrayerTimes();

    // 3. Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateWithPrayerTimes();
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _updateWithPrayerTimes();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _timer?.cancel();
  }

  Future<void> _updateWithPrayerTimes() async {
    try {
      // 1. Load Location from Hive (Background isolate needs its own Hive access)
      if (!Hive.isBoxOpen('settings')) {
        await Hive.initFlutter();
        await Hive.openBox('settings');
      }

      final box = Hive.box('settings');
      final cachedLocation = box.get('cached_location');

      if (cachedLocation == null) {
        _updateGeneric('الرجاء فتح التطبيق لتحديد الموقع');
        return;
      }

      // Convert to Map<String, dynamic> to be safe
      final Map<String, dynamic> locMap =
          Map<String, dynamic>.from(cachedLocation);
      final lat = locMap['latitude'] as double;
      final lng = locMap['longitude'] as double;

      // 2. Calculate Prayer Times
      final coordinates = Coordinates(lat, lng);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);

      // 3. Get Next Prayer
      final next = prayerTimes.nextPrayer();
      final nextTime = prayerTimes.timeForPrayer(next);

      if (next == Prayer.none || nextTime == null) {
        _updateGeneric('بانتظار صلاة الفجر');
        return;
      }

      // 4. Format Display
      final prayerName = _getPrayerNameArabic(next);
      final timeStr = DateFormat.jm('ar').format(nextTime);
      final diff = nextTime.difference(DateTime.now());
      final remainingStr = _formatDuration(diff);

      FlutterForegroundTask.updateService(
        notificationTitle: 'الصلاة القادمة: $prayerName ($timeStr)',
        notificationText: 'متبقي: $remainingStr',
      );
    } catch (e) {
      // Log error to terminal to see what's wrong
      print('❌ Background Update Error: $e');
      _updateGeneric('Sakin Service Running');
    }
  }

  void _updateGeneric(String text) {
    FlutterForegroundTask.updateService(
      notificationTitle: 'سكينة - أوقات الصلاة',
      notificationText: text,
    );
  }

  String _getPrayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return '';
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h ساعة و $m دقيقة';
    return '$m دقيقة';
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
  }
}
