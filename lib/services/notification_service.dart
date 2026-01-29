import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' as intl;
import 'adhan_player.dart';

// Callback للتعامل مع النقر على الإشعارات
typedef NotificationTapCallback = void Function(String? payload);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AdhanPlayer _adhanPlayer = AdhanPlayer();

  // Callback يُستدعى عند النقر على إشعار الأذكار
  static NotificationTapCallback? onAdhkarTap;

  static Future<void> init() async {
    // UPDATED: Use localized notification icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // إنشاء قناة الإشعارات للخدمة الأمامية
    const AndroidNotificationChannel foregroundChannel =
        AndroidNotificationChannel(
      'sakin_foreground',
      'Sakin Service',
      description: 'Background service for prayer times',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);

    // إنشاء قناة الإشعارات العادية
    const AndroidNotificationChannel regularChannel =
        AndroidNotificationChannel(
      'sakin_channel',
      'Sakin Notifications',
      description: 'Prayer time notifications',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(regularChannel);

    // إنشاء قناة خاصة بالأذان (صوت عالي) - UPDATED V5
    const AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      'sakin_adhan_v5', // Match the ID used in show()
      'Adhan Alarm Final', // Match the name
      description: 'Full screen adhan notification',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
          'adhan'), // Explicitly set sound here too
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(adhanChannel);

    // إنشاء قناة خاصة بالأذكار
    const AndroidNotificationChannel adhkarChannel = AndroidNotificationChannel(
      'sakin_adhkar',
      'أذكار الصلاة',
      description: 'إشعارات أذكار ما بعد الصلاة',
      importance: Importance.high,
      enableVibration: true,
      playSound: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(adhkarChannel);
  }

  /// التعامل مع النقر على الإشعار
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint(
        '📱 تم النقر على الإشعار: ${response.actionId} - ${response.payload}');

    if (response.actionId == 'stop_adhan') {
      stopAdhan();
    } else if (response.actionId == 'read_adhkar' ||
        response.payload == 'adhkar') {
      onAdhkarTap?.call(response.payload);
    }
  }

  // إظهار إشعار فوري (للتجربة)
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sakin_channel',
      'Sakin Notifications',
      importance: Importance.max,
      priority: Priority.high,
      // UPDATED: Using custom icons
      icon: 'notification_icon',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF673AB7), // Colors.deepPurple
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // إظهار إشعار الصلاة مع تشغيل الأذان (Old Method)
  static Future<void> showPrayerNotificationWithAdhan(String prayerName) async {
    await _adhanPlayer.playAdhan();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sakin_adhan',
      'Prayer Adhan',
      channelDescription: 'Adhan notifications for prayer times',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: false,
      styleInformation: BigTextStyleInformation(''),
      // UPDATED: Icons
      icon: 'notification_icon',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF673AB7),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      1,
      '🕌 حان وقت صلاة $prayerName',
      'اللهم إني أسألك الثبات في الأمر والعزيمة على الرشد',
      platformChannelSpecifics,
    );
  }

  // جدولة الأذان كمنبه (Alarm) - باستخدام AndroidAlarmManager
  static Future<void> scheduleAdhan(
      int id, String prayerName, DateTime prayerTime) async {
    // استخدام AlarmManager لضمان التشغيل حتى في وضع الغفوة (Doze Mode)
    await AndroidAlarmManager.oneShotAt(
      prayerTime,
      id,
      adhanAlarmCallback,
      exact: true,
      wakeup: true,
      alarmClock: true,
      rescheduleOnReboot: true,
      params: {'prayerName': prayerName},
    );
  }

  // 172. هذه الدالة تعمل في الخلفية (Background Isolate)
  // MOVED TO TOP LEVEL TO FIX ENTRY POINT ERROR
  /*
  @pragma('vm:entry-point')
  static Future<void> adhanAlarmCallback(
      int id, Map<String, dynamic> params) async {
      ...
  }
  */

  // اختبار فوري (Sanity Check)
  static Future<void> showImmediateNotification() async {
    // نستخدم نفس الدالة لضمان تطابق السلوك
    await adhanAlarmCallback(999, {'prayerName': 'تجربة فورية'});
  }

  // إيقاف الأذان وإلغاء الإشعار
  static Future<void> stopAdhan() async {
    await _adhanPlayer.stopAdhan();
    await _notificationsPlugin.cancelAll();
  }

  // Check if app launched from Adhan notification
  static Future<bool> didLaunchFromAdhan() async {
    final NotificationAppLaunchDetails? details =
        await _notificationsPlugin.getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload == 'adhan';
    }
    return false;
  }

  // --- Sticky Notification Logic (Background Loop) ---

  static const int _stickyNotificationId = 99;
  static const int _stickyAlarmId = 888;

  /// Start the background loop to update "Next Prayer" notification every minute
  static Future<void> startStickyNotificationLoop(
      double lat, double long) async {
    // Initial show
    await _updateStickyNotification({'lat': lat, 'long': long});

    // Schedule recursive updates
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 1),
      _stickyAlarmId,
      _stickyNotificationCallback,
      exact: true,
      wakeup: true, // Wake up to update time
      rescheduleOnReboot: true,
      params: {'lat': lat, 'long': long},
    );
  }

  static Future<void> stopStickyNotificationLoop() async {
    await AndroidAlarmManager.cancel(_stickyAlarmId);
    await _notificationsPlugin.cancel(_stickyNotificationId);
  }

  // Helper to calculate and show immediately (for testing or app resume)
  static Future<void> _updateStickyNotification(
      Map<String, dynamic> params) async {
    // We can just call the callback manually
    await _stickyNotificationCallback(_stickyAlarmId, params);
  }
}

// --- Background Callbacks ---

@pragma('vm:entry-point')
Future<void> adhanAlarmCallback(int id, Map<String, dynamic> params) async {
  final String prayerName = params['prayerName'] ?? 'Prayer';
  debugPrint('⏰ Alarm Fired! Prayer: $prayerName');

  // Try to wake the screen programmatically
  try {
    await WakelockPlus.enable();
    // Disable after 30 seconds to save battery
    Future.delayed(const Duration(seconds: 30), () async {
      await WakelockPlus.disable();
    });
  } catch (e) {
    debugPrint('Wakelock error: $e');
  }

  // 2. إظهار الإشعار الثابت مع زر الإيقاف
  await NotificationService.init(); // التأكد من تهيئة القناة

  // إعدادات خاصة للأندرويد ليعامل الإشعار كمنبه
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'sakin_adhan_v5', // New Channel ID to refresh settings
    'Adhan Alarm Final',
    channelDescription: 'Full screen adhan notification',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('adhan'),
    playSound: true,
    icon: 'notification_icon',
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    audioAttributesUsage: AudioAttributesUsage.alarm,
    enableVibration: true,
    autoCancel: false,
    ongoing: true,
    color: Color.fromARGB(255, 67, 107, 62),
    // ADDED: Stop Action
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'stop_adhan',
        'إيقاف الأذان',
        icon: DrawableResourceAndroidBitmap('notification_icon'),
        showsUserInterface: true,
        cancelNotification: true,
      ),
    ],
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await notificationsPlugin.show(
    id,
    'حان وقت صلاة $prayerName',
    'اضغط لإيقاف الأذان',
    platformChannelSpecifics,
    payload: 'adhan',
  );
}

@pragma('vm:entry-point')
Future<void> _stickyNotificationCallback(
    int id, Map<String, dynamic> params) async {
  try {
    final double? lat = params['lat'];
    final double? long = params['long'];

    if (lat == null || long == null) return;

    // 1. Calculate Prayer Times
    // Default params: Muslim World League, Shafi
    final calcParams = CalculationMethod.muslim_world_league.getParameters();
    calcParams.madhab = Madhab.shafi;

    final coordinates = Coordinates(lat, long);
    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, calcParams);

    final next = prayerTimes.nextPrayer();
    final nextTime = prayerTimes.timeForPrayer(next);

    if (next == Prayer.none || nextTime == null) {
      // End of day, maybe show fajr? For now just return or show something generic
      return;
    }

    // 3. Format Title & Body
    final now = DateTime.now();
    final diff = nextTime.difference(now);

    if (diff.isNegative) return; // Should not happen if nextPrayer is correct

    String prayerName = '';
    switch (next) {
      case Prayer.fajr:
        prayerName = 'الفجر';
        break;
      case Prayer.sunrise:
        prayerName = 'الشروق';
        break;
      case Prayer.dhuhr:
        prayerName = 'الظهر';
        break;
      case Prayer.asr:
        prayerName = 'العصر';
        break;
      case Prayer.maghrib:
        prayerName = 'المغرب';
        break;
      case Prayer.isha:
        prayerName = 'العشاء';
        break;
      case Prayer.none:
        prayerName = '';
        break;
    }

    final String timeString = intl.DateFormat.jm('ar').format(nextTime);

    // Format remaining: "1 ساعة و 30 دقيقة"
    String remainingString = "";
    final int hours = diff.inHours;
    final int minutes = diff.inMinutes.remainder(60);

    if (hours > 0) {
      remainingString = "$hours ساعة و $minutes دقيقة";
    } else {
      remainingString = "$minutes دقيقة";
    }

    // 3. Show Sticky Notification
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sakin_sticky', // ID
      'Next Prayer', // Name
      channelDescription: 'Ongoing notification for next prayer',
      importance: Importance.low, // Low importance so it doesn't pop up
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: 'notification_icon',
      // No sound
      playSound: false,
      enableVibration: false,
    );

    await notificationsPlugin.show(
      99, // _stickyNotificationId
      'الصلاة القادمة: $prayerName ($timeString)',
      'متبقي $remainingString',
      const NotificationDetails(android: androidDetails),
    );
  } catch (e) {
    debugPrint('Sticky Notification Error: $e');
  }
}
