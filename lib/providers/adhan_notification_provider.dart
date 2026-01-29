import 'package:sakin_app/models/adhan_model.dart';
import 'package:sakin_app/providers/adhan_provider.dart';

class AdhanNotificationProvider extends AdhanProvider {
  AdhanNotificationProvider(
      super.adhanDependencyProvider, super.locationInfo, super.appLocalization);

  Adhan? get notificationAdhan {
    final list = getAdhanData(DateTime.now())
      ..forEach((element) {
        element.modifyForNotification();
      });

    try {
      return list.firstWhere((element) =>
          element.isCurrent &&
          (adhanDependencyProvider.showPersistant ||
              adhanDependencyProvider.notifyID(element.type) != 0));
    } catch (e) {
      return null;
    }
  }

  Adhan? get nextNotifcationAdhan {
    final List<Adhan> fullList = [];
    final currentTime = DateTime.now();
    fullList.addAll(getAdhanData(currentTime));
    fullList.addAll(getAdhanData(DateTime.now().add(const Duration(days: 1))));
    fullList.addAll(getAdhanData(DateTime.now().add(const Duration(days: 2))));

    for (var element in fullList) {
      element.modifyForNotification();
    }

    final filteredList = fullList
        .where((element) =>
            element.startTime.isAfter(currentTime) &&
            (adhanDependencyProvider.showPersistant ||
                adhanDependencyProvider.notifyID(element.type) != 0))
        .toList();

    if (filteredList.isNotEmpty) {
      return filteredList[0];
    } else {
      return null;
    }
  }
}
