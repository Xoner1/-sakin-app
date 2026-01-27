import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'adhan_player.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AdhanPlayer _adhanPlayer = AdhanPlayer();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

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

    // إنشاء قناة خاصة بالأذان (صوت عالي)
    const AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      'sakin_adhan',
      'Prayer Adhan',
      description: 'Adhan notifications for prayer times',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(adhanChannel);
  }

  // إظهار إشعار فوري (للتجربة)
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sakin_channel',
      'Sakin Notifications',
      importance: Importance.max,
      priority: Priority.high,
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

  // إظهار إشعار الصلاة مع تشغيل الأذان
  static Future<void> showPrayerNotificationWithAdhan(String prayerName) async {
    // تشغيل الأذان
    await _adhanPlayer.playAdhan();

    // إظهار الإشعار
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sakin_adhan',
      'Prayer Adhan',
      channelDescription: 'Adhan notifications for prayer times',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: false, // الصوت يأتي من AdhanPlayer
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      1, // رقم مختلف عن الإشعارات العادية
      '🕌 حان وقت صلاة $prayerName',
      'اللهم إني أسألك الثبات في الأمر والعزيمة على الرشد',
      platformChannelSpecifics,
    );
  }

  // إيقاف الأذان
  static Future<void> stopAdhan() async {
    await _adhanPlayer.stopAdhan();
  }
}
