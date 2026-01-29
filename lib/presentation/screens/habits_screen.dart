import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import '../../core/theme.dart';
import '../../data/hive_database.dart';
import '../../services/prayer_service.dart';
import '../../services/settings_service.dart';
import '../widgets/monthly_heatmap.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = Provider.of<HiveDatabase>(context);
    final prayerService = Provider.of<PrayerService>(context);
    final settingsService = Provider.of<SettingsService>(context);

    // قائمة الصلوات المتاحة للتتبع
    final prayers = [
      {
        'name': l10n.fajr,
        'key': 'fajr',
        'icon': Icons.wb_twilight,
        'prayer': Prayer.fajr
      },
      {
        'name': l10n.dhuhr,
        'key': 'dhuhr',
        'icon': Icons.wb_sunny_outlined,
        'prayer': Prayer.dhuhr
      },
      {
        'name': l10n.asr,
        'key': 'asr',
        'icon': Icons.light_mode,
        'prayer': Prayer.asr
      },
      {
        'name': l10n.maghrib,
        'key': 'maghrib',
        'icon': Icons.nightlight,
        'prayer': Prayer.maghrib
      },
      {
        'name': l10n.isha,
        'key': 'isha',
        'icon': Icons.nights_stay,
        'prayer': Prayer.isha
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayerTracking),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // بطاقة التتبع اليومية
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  l10n.dailyTracking,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: prayers.map((p) {
                    final key = p['key'] as String;
                    final prayer = p['prayer'] as Prayer;
                    final isDone = db.getHabitStatus(key);

                    // التحقق من الوقت
                    final prayerTime =
                        prayerService.prayerTimes?.timeForPrayer(prayer);
                    final isPastOrNow = prayerTime != null &&
                        DateTime.now().isAfter(prayerTime);

                    return GestureDetector(
                      onTap: () {
                        if (!isPastOrNow) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("${l10n.nextPrayer} لم يحن وقتها بعد!"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                        db.toggleHabit(key);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade100,
                              border: isDone
                                  ? null
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              isDone
                                  ? Icons.check_rounded
                                  : (p['icon'] as IconData),
                              color: isDone ? Colors.white : Colors.grey,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDone ? AppTheme.primaryColor : Colors.grey,
                              fontWeight:
                                  isDone ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              l10n.monthlyStats,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // عرض الخرائط الحرارية
          ..._buildHeatMaps(settingsService, db),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  List<Widget> _buildHeatMaps(SettingsService settings, HiveDatabase db) {
    if (settings.installDate == null) return [];

    List<Widget> maps = [];
    DateTime now = DateTime.now();
    DateTime current =
        DateTime(settings.installDate!.year, settings.installDate!.month, 1);

    while (current.isBefore(now) ||
        (current.year == now.year && current.month == now.month)) {
      maps.insert(
          0,
          MonthlyHeatMap(
            month: current,
            getCompletionCount: (date) => db.getPrayersCountForDay(date),
            locale: settings.locale,
          ));
      current = DateTime(current.year, current.month + 1, 1);
    }

    return maps;
  }
}
