import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart' as adhan_lib;
import 'package:sakin_app/l10n/generated/app_localizations.dart';
import 'package:sakin_app/models/adhan_model.dart';
import 'package:sakin_app/models/location_info.dart';
import 'package:sakin_app/providers/dependencies/adhan_dependency_provider.dart';
import 'package:sakin_app/utils/extensions.dart';

const adhanTypeAny = -1;
const adhanTypeFajr = 0;
const adhanTypeSunrise = 1;
const adhanTypeDhuhr = 2;
const adhanTypeAsr = 3;
const adhanTypeMagrib = 4;
const adhanTypeIsha = 5;
const adhanTypeMidnight = 6;
const adhanTypeThirdNight = 7;

class AdhanProvider with ChangeNotifier {
  DateTime _viewingDate;

  AdhanDependencyProvider adhanDependencyProvider;
  LocationInfo locationInfo;
  AppLocalizations? appLocalization;

  AdhanProvider(
    this.adhanDependencyProvider,
    this.locationInfo,
    this.appLocalization,
  ) : _viewingDate = DateTime.now();

  int? get currentAdhanIndex {
    int? current;
    if (_viewingDate.isToday) {
      final adhans = getAdhanData(_viewingDate);
      for (int i = 0; i < adhans.length; i++) {
        if (adhans[i].isCurrent) {
          current = i;
        }
      }
    }
    return current;
  }

  Adhan? get currentAdhan {
    final index = currentAdhanIndex;
    if (index != null) {
      return getAdhanData(_viewingDate)[index];
    }

    return null;
  }

  DateTime get currentDate {
    return _viewingDate;
  }

  void changeDayOfDate(int days) {
    _viewingDate = DateTime.now().add(Duration(days: days));
    notifyListeners();
  }

  Adhan get nextAdhan {
    final List<Adhan> fullList = [];
    fullList.addAll(getAdhanData(_viewingDate));

    final currentTime = _viewingDate;
    final filteredList = fullList
        .where((element) => element.startTime.isAfter(currentTime))
        .toList();

    if (filteredList.length < 3) {
      filteredList
          .addAll(getAdhanData(DateTime.now().add(const Duration(days: 1))));
    }

    return filteredList[0];
  }

  Adhan createAdhan({
    required int type,
    required DateTime startTime,
    required DateTime endTime,
    required DateTime startingPrayerTime,
    required bool shouldCorrect,
  }) {
    return Adhan(
      type: type,
      title: appLocalization?.getAdhanName(type,
              isJummah: startTime.isJummahToday) ??
          '',
      startTime: startTime,
      endTime: endTime,
      notifyBefore: adhanDependencyProvider.getNotifyBefore(type),
      manualCorrection: adhanDependencyProvider.getManualCorrection(type),
      localCode: appLocalization?.locale.toString() ?? 'en',
      startingPrayerTime: startingPrayerTime,
      shouldCorrect: shouldCorrect,
    );
  }

  List<Adhan> getAdhanData(DateTime date) {
    // Ensure coordinates are valid
    final coords =
        adhan_lib.Coordinates(locationInfo.latitude, locationInfo.longitude);
    final params = adhanDependencyProvider.params;

    final prayerTimes = adhan_lib.PrayerTimes(
      coords,
      adhan_lib.DateComponents.from(date),
      params,
    );
    final sunnahTimes = adhan_lib.SunnahTimes(prayerTimes);

    return [
      createAdhan(
        type: adhanTypeFajr,
        startTime: prayerTimes.fajr,
        endTime: prayerTimes.sunrise,
        startingPrayerTime: prayerTimes.fajr,
        shouldCorrect: date.isToday,
      ),
      if (adhanDependencyProvider.getVisibility(adhanTypeSunrise))
        createAdhan(
          type: adhanTypeSunrise,
          startTime: prayerTimes.sunrise,
          endTime: prayerTimes.sunrise.add(const Duration(minutes: 15)),
          startingPrayerTime: prayerTimes.fajr,
          shouldCorrect: date.isToday,
        ),
      createAdhan(
        type: adhanTypeDhuhr,
        startTime: prayerTimes.dhuhr,
        endTime: prayerTimes.asr,
        startingPrayerTime: prayerTimes.fajr,
        shouldCorrect: date.isToday,
      ),
      createAdhan(
        type: adhanTypeAsr,
        startTime: prayerTimes.asr,
        endTime: prayerTimes.maghrib,
        startingPrayerTime: prayerTimes.fajr,
        shouldCorrect: date.isToday,
      ),
      createAdhan(
        type: adhanTypeMagrib,
        startTime: prayerTimes.maghrib,
        endTime: prayerTimes.isha,
        startingPrayerTime: prayerTimes.fajr,
        shouldCorrect: date.isToday,
      ),
      createAdhan(
        type: adhanTypeIsha,
        startTime: prayerTimes.isha,
        endTime: prayerTimes.fajr.add(const Duration(days: 1)),
        startingPrayerTime: prayerTimes.fajr,
        shouldCorrect: date.isToday,
      ),
      if (adhanDependencyProvider.getVisibility(adhanTypeMidnight))
        createAdhan(
          type: adhanTypeMidnight,
          startTime: sunnahTimes.middleOfTheNight,
          endTime: sunnahTimes.lastThirdOfTheNight,
          startingPrayerTime: prayerTimes.fajr,
          shouldCorrect: date.isToday,
        ),
      if (adhanDependencyProvider.getVisibility(adhanTypeThirdNight))
        createAdhan(
          type: adhanTypeThirdNight,
          startTime: sunnahTimes.lastThirdOfTheNight,
          endTime: prayerTimes.fajr.add(const Duration(days: 1)),
          startingPrayerTime: prayerTimes.fajr,
          shouldCorrect: date.isToday,
        ),
    ];
  }
}
