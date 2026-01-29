import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/prayer_service.dart';
import '../../services/location_service.dart';
import '../../services/settings_service.dart';
import '../../models/location_info.dart';
import 'package:adhan/adhan.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الموقع عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      if (locationService.currentLocation == null) {
        locationService.getCurrentLocation();
      }

      // تحميل الإعدادات
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);
      settingsService.loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prayerService = Provider.of<PrayerService>(context);
    final locationService = Provider.of<LocationService>(context);
    final settingsService = Provider.of<SettingsService>(context);

    // قائمة الصلوات (نستبعد sunrise لأنه ليس وقت صلاة)
    final prayers = [
      {
        'name': 'الفجر',
        'prayer': Prayer.fajr,
        'icon': Icons.wb_twilight,
        'key': 'fajr'
      },
      {
        'name': 'الظهر',
        'prayer': Prayer.dhuhr,
        'icon': Icons.wb_sunny_outlined,
        'key': 'dhuhr'
      },
      {
        'name': 'العصر',
        'prayer': Prayer.asr,
        'icon': Icons.light_mode,
        'key': 'asr'
      },
      {
        'name': 'المغرب',
        'prayer': Prayer.maghrib,
        'icon': Icons.nightlight,
        'key': 'maghrib'
      },
      {
        'name': 'العشاء',
        'prayer': Prayer.isha,
        'icon': Icons.nights_stay,
        'key': 'isha'
      },
    ];

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayerTimes),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header بلون أخضر
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // معلومات الموقع
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      locationService.currentLocation?.address ??
                          'جاري تحديد الموقع...',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (locationService.currentLocation?.mode ==
                        LocationMode.cached)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child:
                            Icon(Icons.cached, color: Colors.orange, size: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // التاريخ الهجري واليوم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      prayerService.getHijriDate(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // زر تحديث الموقع
                ElevatedButton.icon(
                  onPressed: locationService.isLoading
                      ? null
                      : () async {
                          final loc =
                              await locationService.getCurrentLocation();
                          if (loc != null) {
                            prayerService.scheduleNotifications(
                                settingsService.settings);
                          }
                        },
                  icon: locationService.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(locationService.isLoading
                      ? 'جاري التحديث...'
                      : 'تحديث الموقع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // قائمة الصلوات
          Expanded(
            child: prayerService.prayerTimes == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: prayers.length,
                    itemBuilder: (context, index) {
                      final prayerData = prayers[index];
                      final prayer = prayerData['prayer'] as Prayer;
                      final prayerKey = prayerData['key'] as String;
                      final time =
                          prayerService.prayerTimes!.timeForPrayer(prayer);
                      final isNext = prayerService.nextPrayer == prayer;

                      // حالة التفعيل
                      bool isEnabled = true;
                      switch (prayerKey) {
                        case 'fajr':
                          isEnabled = settingsService.settings.fajrEnabled;
                          break;
                        case 'dhuhr':
                          isEnabled = settingsService.settings.dhuhrEnabled;
                          break;
                        case 'asr':
                          isEnabled = settingsService.settings.asrEnabled;
                          break;
                        case 'maghrib':
                          isEnabled = settingsService.settings.maghribEnabled;
                          break;
                        case 'isha':
                          isEnabled = settingsService.settings.ishaEnabled;
                          break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isNext
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isNext
                                ? AppTheme.primaryColor
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isNext
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              prayerData['icon'] as IconData,
                              color:
                                  isNext ? Colors.white : AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            prayerData['name'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  isNext ? FontWeight.bold : FontWeight.w500,
                              color: isNext
                                  ? AppTheme.primaryColor
                                  : Colors.black87,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // الوقت
                              Text(
                                time != null
                                    ? prayerService.getFormattedTime(time)
                                    : '--:--',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isNext
                                      ? AppTheme.primaryColor
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Switch لتفعيل/إيقاف
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: isEnabled,
                                  activeThumbColor: AppTheme.primaryColor,
                                  onChanged: (value) async {
                                    await settingsService.togglePrayer(
                                        prayerKey, value);
                                    // إعادة جدولة المنبهات فوراً بعد التغيير
                                    prayerService.scheduleNotifications(
                                        settingsService.settings);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
