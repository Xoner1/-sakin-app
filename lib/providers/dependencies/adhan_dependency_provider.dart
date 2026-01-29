import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

class AdhanDependencyProvider with ChangeNotifier {
  // Example default parameters - in a real app these would come from settings
  CalculationParameters params =
      CalculationMethod.muslim_world_league.getParameters();

  bool showPersistant = true;

  int getNotifyBefore(int adhanType) {
    return 0; // Default notify before in minutes
  }

  int getManualCorrection(int adhanType) {
    return 0; // Default manual correction in minutes
  }

  bool getVisibility(int adhanType) {
    return true; // Default visibility
  }

  int notifyID(int adhanType) {
    return 1; // Default notification ID
  }
}
