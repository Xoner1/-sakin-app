import 'package:sakin_app/l10n/generated/app_localizations.dart';

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isJummahToday {
    return weekday == DateTime.friday;
  }
}

extension AppLocalizationsExtensions on AppLocalizations {
  String get locale => localeName;

  String getAdhanName(int type, {bool isJummah = false}) {
    switch (type) {
      case 0: // Fajr
        return fajr;
      case 1: // Sunrise
        return 'الشروق'; // Placeholder or add to arb
      case 2: // Dhuhr
        return isJummah
            ? 'الجمعة'
            : dhuhr; // Assuming 'Jummah' isn't in arb yet, using hardcoded or logic
      case 3: // Asr
        return asr;
      case 4: // Maghrib
        return maghrib;
      case 5: // Isha
        return isha;
      case 6: // Midnight
        return midnight;
      case 7: // Third Night
        return lastThird;
      default:
        return '';
    }
  }
}
