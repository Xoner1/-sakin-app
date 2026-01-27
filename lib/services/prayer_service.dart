import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerService with ChangeNotifier {
  PrayerTimes? _prayerTimes;
  // إحداثيات (يمكن تغييرها لاحقاً لتكون ديناميكية) - حالياً تونس/الحامة
  final Coordinates _coordinates = Coordinates(33.8869, 9.7963);

  PrayerService() {
    calculatePrayers();
  }

  void calculatePrayers() {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    _prayerTimes = PrayerTimes(_coordinates, date, params);
    notifyListeners();
  }

  PrayerTimes? get prayerTimes => _prayerTimes;

  Prayer get nextPrayer => _prayerTimes?.nextPrayer() ?? Prayer.none;

  String getFormattedTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  // دالة لجلب الوقت المتبقي كنص
  String getTimeRemaining() {
    if (_prayerTimes == null) return "Loading...";

    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return "تمت صلوات اليوم";

    final nextTime = _prayerTimes!.timeForPrayer(next)!;
    final now = DateTime.now();
    final difference = nextTime.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return "$hours ساعة و $minutes دقيقة";
    } else {
      return "$minutes دقيقة";
    }
  }

  // دالة لعرض التاريخ الهجري
  String getHijriDate() {
    final now = DateTime.now();
    final hijriYear = (now.year - 579); // تقريب بسيط

    // استخدام format بسيط بدون locale معقد
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    return "$dateStr ($hijriYear هـ)";
  }
}
