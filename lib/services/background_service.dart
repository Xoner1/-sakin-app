import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:adhan/adhan.dart';
import 'package:hive_flutter/hive_flutter.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // إعداد الإشعار الدائم
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // حساب أولي للصلاة
  final coords = Coordinates(33.8869, 9.7963);
  final params = CalculationMethod.muslim_world_league.getParameters();
  params.madhab = Madhab.shafi;

  // متغير لتتبع الصلاة الأخيرة التي تم تشغيل الأذان لها
  Prayer? lastNotifiedPrayer;

  // تحديث كل 30 ثانية لسرعة الاستجابة
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      final prayerTimes = PrayerTimes.today(coords, params);
      final next = prayerTimes.nextPrayer();
      final current = prayerTimes.currentPrayer();
      final nextTime = prayerTimes.timeForPrayer(next);

      String notificationBody = "ذكر الله حياة القلوب";
      String title = "ساكن يعمل";

      if (next != Prayer.none && nextTime != null) {
        final now = DateTime.now();
        final diff = nextTime.difference(now);

        // اسم الصلاة بالعربية
        String prayerNameAr = "";
        switch (next) {
          case Prayer.fajr:
            prayerNameAr = "الفجر";
            break;
          case Prayer.dhuhr:
            prayerNameAr = "الظهر";
            break;
          case Prayer.asr:
            prayerNameAr = "العصر";
            break;
          case Prayer.maghrib:
            prayerNameAr = "المغرب";
            break;
          case Prayer.isha:
            prayerNameAr = "العشاء";
            break;
          default:
            prayerNameAr = "الصلاة";
        }

        title = "الصلاة القادمة: $prayerNameAr";
        notificationBody = "متبقي ${diff.inMinutes} دقيقة";

        // التحقق من دخول وقت صلاة جديدة
        if (current != Prayer.none && current != lastNotifiedPrayer) {
          // تحميل الإعدادات من Hive للتحقق من تفعيل الصلاة
          bool shouldNotify = true;
          try {
            final box = await Hive.openBox('settings');
            final settingsData = box.get('prayer_notifications');
            if (settingsData != null) {
              final settings = Map<String, dynamic>.from(settingsData);
              // التحقق حسب الصلاة
              switch (current) {
                case Prayer.fajr:
                  shouldNotify = settings['fajr'] ?? true;
                  break;
                case Prayer.dhuhr:
                  shouldNotify = settings['dhuhr'] ?? true;
                  break;
                case Prayer.asr:
                  shouldNotify = settings['asr'] ?? true;
                  break;
                case Prayer.maghrib:
                  shouldNotify = settings['maghrib'] ?? true;
                  break;
                case Prayer.isha:
                  shouldNotify = settings['isha'] ?? true;
                  break;
                default:
                  shouldNotify = false;
              }
            }
          } catch (e) {
            // في حالة الخطأ، نفترض أن التنبيه مفعل
            shouldNotify = true;
          }

          if (shouldNotify) {
            lastNotifiedPrayer = current;

            // اسم الصلاة الحالية
            String currentPrayerNameAr = "";
            switch (current) {
              case Prayer.fajr:
                currentPrayerNameAr = "الفجر";
                break;
              case Prayer.dhuhr:
                currentPrayerNameAr = "الظهر";
                break;
              case Prayer.asr:
                currentPrayerNameAr = "العصر";
                break;
              case Prayer.maghrib:
                currentPrayerNameAr = "المغرب";
                break;
              case Prayer.isha:
                currentPrayerNameAr = "العشاء";
                break;
              default:
                currentPrayerNameAr = "الصلاة";
            }

            // إرسال حدث إلى التطبيق الرئيسي لتشغيل الأذان
            service.invoke('playAdhan', {'prayerName': currentPrayerNameAr});

            // إشعار خاص بدخول الوقت
            await flutterLocalNotificationsPlugin.show(
              999, // ID مختلف لإشعار الأذان
              '🕌 حان وقت صلاة $currentPrayerNameAr',
              'اللهم إني أسألك الثبات في الأمر والعزيمة على الرشد',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'sakin_adhan',
                  'Prayer Adhan',
                  importance: Importance.max,
                  priority: Priority.high,
                  enableVibration: true,
                ),
              ),
            );
          }
        }
      }

      await flutterLocalNotificationsPlugin.show(
        888, // ID ثابت للإشعار الدائم
        title,
        notificationBody,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sakin_foreground',
            'Sakin Service',
            icon: 'ic_bg_service_small',
            ongoing: true,
            importance: Importance.low,
          ),
        ),
      );
    }
  });
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: true, // تشغيل تلقائي بعد restart
      isForegroundMode: true,
      notificationChannelId: 'sakin_foreground',
      initialNotificationTitle: 'Sakin Service',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );
  service.startService();
}
