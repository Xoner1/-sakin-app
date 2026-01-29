class Adhan {
  final int type;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int notifyBefore;
  final int manualCorrection;
  final String localCode;
  final DateTime startingPrayerTime;
  final bool shouldCorrect;

  Adhan({
    required this.type,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.notifyBefore,
    required this.manualCorrection,
    required this.localCode,
    required this.startingPrayerTime,
    required this.shouldCorrect,
  });

  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  void modifyForNotification() {
    // Logic to modify adhan properties for notification if needed
    // Typically used adjusting times based on offsets/settings
  }
}
