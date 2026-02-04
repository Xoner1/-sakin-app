import 'package:adhan/adhan.dart';
import 'settings_service.dart';

class PrayerService {
  /// Calculates prayer times for a specific date and coordinates.
  /// Returns a Map<String, DateTime> with keys: Fajr, Dhuhr, Asr, Maghrib, Isha.
  static Map<String, DateTime> calculatePrayerTimes(
    DateTime date,
    double lat,
    double long,
  ) {
    final myCoordinates = Coordinates(lat, long);

    // Params: Muslim World League, Shafi
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    // You can also use PrayerTimes(myCoordinates, DateComponents.from(date), params)
    // but .today() uses DateTime.now(). Let's be specific for the 'date' param.
    final dateComponents = DateComponents.from(date);
    final times = PrayerTimes(myCoordinates, dateComponents, params);

    return {
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };
  }

  /// Convenience method to get today's times using stored location.
  /// Returns null if location is not set.
  static Map<String, DateTime>? getPrayerTimesForToday() {
    final lat = SettingsService.latitude;
    final long = SettingsService.longitude;

    if (lat == null || long == null) {
      return null;
    }

    return calculatePrayerTimes(DateTime.now(), lat, long);
  }

  /// Generates prayer times for Today + Next 6 days (Total 7 days).
  /// Useful for scheduling notifications.
  static Map<DateTime, Map<String, DateTime>>? getNext7DaysSchedule() {
    final lat = SettingsService.latitude;
    final long = SettingsService.longitude;

    if (lat == null || long == null) {
      return null;
    }

    final Map<DateTime, Map<String, DateTime>> schedule = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      // Normalize date to just Y-M-D for the key if needed, or keep full DateTime
      // strict Y-M-D key might be safer for map lookups
      final dateKey = DateTime(date.year, date.month, date.day);

      schedule[dateKey] = calculatePrayerTimes(date, lat, long);
    }

    return schedule;
  }
}
