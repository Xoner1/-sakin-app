import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' as intl;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async'; // Added for Timer
import 'adhan_player.dart';

// Callback to handle notification taps
typedef NotificationTapCallback = void Function(String? payload);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AdhanPlayer _adhanPlayer = AdhanPlayer();

  // Callback invoked when an adhkar notification is tapped
  static NotificationTapCallback? onAdhkarTap;

  // ── Notification IDs (named constants — never use raw numbers) ──
  static const int generalNotificationId = 0;
  static const int adhanNotificationId = 1;
  static const int stickyNotificationId = 99;
  static const int stickyAlarmId = 888;
  static const int testNotificationId = 999;

  static Future<void> init() async {
    // UPDATED: Use localized notification icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    // ── Foreground Service Channel (Silent Background) ──
    const AndroidNotificationChannel foregroundChannel =
        AndroidNotificationChannel(
      'sakin_foreground',
      'خدمة ساكن',
      description: 'خدمة خلفية لمتابعة مواقيت الصلاة',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);

    // ── General Notifications Channel ──
    const AndroidNotificationChannel regularChannel =
        AndroidNotificationChannel(
      'sakin_channel',
      'إشعارات ساكن',
      description: 'إشعارات مواقيت الصلاة',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(regularChannel);

    // ── Adhan Channel (Highest priority with sound) ──
    const AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      'sakin_adhan_v8',
      'أذان الصلاة',
      description: 'إشعار الأذان بصوت كامل عند دخول وقت الصلاة',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: RawResourceAndroidNotificationSound('adhan'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(adhanChannel);

    // ── Prayer Adhkar Channel ──
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

    // ── Upcoming Prayer Channel (Sticky - Silent) ──
    const AndroidNotificationChannel stickyChannel = AndroidNotificationChannel(
      'sakin_sticky',
      'الصلاة القادمة',
      description: 'إشعار دائم يُظهر الوقت المتبقي حتى الصلاة القادمة',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(stickyChannel);

    // ── Ramadan Messages Channel ──
    const AndroidNotificationChannel ramadanChannel =
        AndroidNotificationChannel(
      'ramadan_messages_channel',
      'رسائل رمضانية',
      description: 'رسائل تحفيزية وتذكيرية خلال شهر رمضان المبارك',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(ramadanChannel);

    // ✅ Automated cleanup of old channels on each update
    if (Platform.isAndroid) {
      await _migrateChannelsIfNeeded();
    }
  }

  /// Checks the app version — if it has changed since the last run,
  /// it automatically deletes old notification channels without manual intervention.
  ///
  /// How it works:
  /// 1. Reads current version from [package_info_plus]
  /// 2. Compares it with the saved version in [SharedPreferences]
  /// 3. If different → deletes old channels → saves the new version
  static Future<void> _migrateChannelsIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "2.1.2"

      const versionKey = 'notification_channel_version';
      final storedVersion = prefs.getString(versionKey);

      if (storedVersion == currentVersion) {
        // Same version — nothing to do
        return;
      }

      debugPrint(
          '🔄 App updated: $storedVersion → $currentVersion. Migrating notification channels...');

      final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // Comprehensive list of all old channels across app history
      // Add any old channel ID here — the app will delete it automatically
      const obsoleteChannelIds = [
        'sakin_adhan',
        'sakin_adhan_v2',
        'sakin_adhan_v3',
        'sakin_adhan_v4',
        'sakin_adhan_v5',
        'sakin_adhan_v6',
        'sakin_adhan_v7',
        // Do not add sakin_adhan_v8 here because it is the current version
      ];

      for (final channelId in obsoleteChannelIds) {
        await plugin?.deleteNotificationChannel(channelId);
        debugPrint('🗑️ Deleted old channel: $channelId');
      }

      // Save the new version — this will not be repeated until the next update
      await prefs.setString(versionKey, currentVersion);
      debugPrint('✅ Channel migration complete for v$currentVersion');
    } catch (e) {
      debugPrint('⚠️ Channel migration error (non-fatal): $e');
    }
  }

  /// Background Notification interaction
  @pragma('vm:entry-point')
  static Future<void> onBackgroundNotificationTap(
      NotificationResponse response) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (response.actionId == 'stop_adhan') {
      await stopAdhan();
    }
  }

  /// Handle notification interaction
  @pragma('vm:entry-point')
  static void onNotificationTap(NotificationResponse response) {
    debugPrint(
        '📱 Notification tapped: ${response.actionId} - ${response.payload}');

    if (response.actionId == 'stop_adhan' || response.payload == 'adhan') {
      // Stop adhan directly without opening any UI
      stopAdhan();
    } else if (response.actionId == 'read_adhkar' ||
        response.payload == 'adhkar') {
      onAdhkarTap?.call(response.payload);
    }
  }

  // Show immediate notification (For testing)
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sakin_channel',
      'إشعارات ساكن',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'notification_icon',
      largeIcon: DrawableResourceAndroidBitmap('notification_large_icon'),
      color: Color(0xFF673AB7),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      generalNotificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Prayer notification with Adhan playback
  static Future<void> showPrayerNotificationWithAdhan(String prayerName) async {
    await _adhanPlayer.playAdhan();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sakin_adhan_v6',
      'أذان الصلاة',
      channelDescription: 'إشعار الأذان عند دخول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: false,
      styleInformation: BigTextStyleInformation(''),
      icon: 'notification_icon',
      largeIcon: DrawableResourceAndroidBitmap('notification_large_icon'),
      color: Color(0xFF673AB7),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      adhanNotificationId,
      '🕌 حان وقت صلاة $prayerName',
      'اللهم إني أسألك الثبات في الأمر والعزيمة على الرشد',
      platformChannelSpecifics,
    );
  }

  // Schedule Adhan as an alarm using AndroidAlarmManager
  static Future<void> scheduleAdhan(
      int id, String prayerName, DateTime prayerTime) async {
    if (Platform.isAndroid) {
      // Use AlarmManager to ensure execution even in Doze Mode
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
  }

  // This function runs in a background isolate
  // MOVED TO TOP LEVEL TO FIX ENTRY POINT ERROR
  /*
  @pragma('vm:entry-point')
  static Future<void> adhanAlarmCallback(
      int id, Map<String, dynamic> params) async {
      ...
  }
  */

  // Immediate test (Sanity Check)
  static Future<void> showImmediateNotification() async {
    await adhanAlarmCallback(testNotificationId, {'prayerName': 'تجربة فورية'});
  }

  // Stop Adhan playback and cancel notifications
  static Future<void> stopAdhan() async {
    // Tell the background audio isolate to stop playing via SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('stop_adhan_flag', true);
    } catch (e) {
      debugPrint('stopAdhan: SharedPreferences error $e');
    }

    // ✅ Release wakelock immediately — don't wait for the 3-min delayed timer
    try {
      await WakelockPlus.disable();
    } catch (_) {}

    try {
      await _adhanPlayer.stopAdhan();
    } catch (e) {
      debugPrint('stopAdhan: _adhanPlayer error $e');
    }

    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('stopAdhan: cancelAll error $e');
    }
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

  // IDs moved to top-level constants above (stickyNotificationId / stickyAlarmId)

  /// Start the background loop to update "Next Prayer" notification every minute
  static Future<void> startStickyNotificationLoop(
      double lat, double long) async {
    await _updateStickyNotification({'lat': lat, 'long': long});

    if (Platform.isAndroid) {
      await AndroidAlarmManager.periodic(
        const Duration(minutes: 1),
        stickyAlarmId,
        _stickyNotificationCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {'lat': lat, 'long': long},
      );
    }
  }

  static Future<void> stopStickyNotificationLoop() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(stickyAlarmId);
    }
    await _notificationsPlugin.cancel(stickyNotificationId);
  }

  static Future<void> _updateStickyNotification(
      Map<String, dynamic> params) async {
    await _stickyNotificationCallback(stickyAlarmId, params);
  }
}

// --- Background Callbacks ---

@pragma('vm:entry-point')
Future<void> adhanAlarmCallback(int id, Map<String, dynamic> params) async {
  final String prayerName = params['prayerName'] ?? 'Prayer';
  debugPrint('⏰ [Background] Alarm Fired! Prayer: $prayerName');

  // 1. Acquire Wakelock immediately to prevent sleep during setup
  try {
    await WakelockPlus.enable();
    // Use an explicit Timer instead of Future.delayed.
    // In background isolates on Android, Timer is sometimes preserved better
    // than implicit Futures, ensuring the wakelock is released.
    Timer(const Duration(minutes: 3), () async {
      try {
        await WakelockPlus.disable();
        debugPrint('Wakelock auto-released after 3 minutes');
      } catch (_) {}
    });
  } catch (e) {
    debugPrint('Wakelock error: $e');
  }

  // 2. Initialize Notifications Plugin (Lightweight init)
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: NotificationService.onNotificationTap,
    onDidReceiveBackgroundNotificationResponse:
        NotificationService.onBackgroundNotificationTap,
  );

  // 3. Configure Android Notification Details
  AndroidNotificationDetails androidPlatformChannelSpecifics;
  String title;
  String body;

  if (prayerName == 'Imsak') {
    // Imsak gets a standard notification with a default sound (no full Adhan, no full screen)
    androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'sakin_channel', // Use the regular channel which has sound enabled natively
      'إشعارات ساكن',
      importance: Importance.max,
      priority: Priority.max,
      icon: 'notification_icon',
      enableVibration: true,
      color: Color.fromARGB(255, 67, 107, 62),
    );
    title = 'تذكير بالإمساك';
    body = 'الرجاء التوقف عن الأكل والشرب، اقترب أذان الفجر.';
  } else {
    // Regular Prayers get the full Adhan experience
    androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'sakin_adhan_v8',
      'أذان الصلاة',
      channelDescription: 'إشعار الأذان بصوت كامل عند دخول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
      icon: 'notification_icon',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      autoCancel: false,
      ongoing: true, // Cannot be swiped away
      color: Color.fromARGB(255, 67, 107, 62),
      // Action buttons
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_adhan',
          'إيقاف الأذان',
          icon: DrawableResourceAndroidBitmap('notification_icon'),
          showsUserInterface: false, // Prevents opening the app
          cancelNotification: true, // Automatically dismisses the notification
        ),
      ],
    );
    title = 'حان وقت صلاة $prayerName';
    body = 'اضغط لإيقاف الأذان';
  }

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  debugPrint('🔔 Showing Notification for $prayerName');
  await notificationsPlugin.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: prayerName == 'Imsak' ? 'imsak' : 'adhan',
  );

  // 4. Play Adhan manually using AdhanPlayer in this background isolate.
  // This will loop and poll until the user presses 'Stop Adhan'.
  if (prayerName != 'Imsak') {
    await AdhanPlayer().playAdhan();
  }
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

    var next = prayerTimes.nextPrayer();
    var nextTime = prayerTimes.timeForPrayer(next);

    if (next == Prayer.none || nextTime == null) {
      // End of day (after Isha), show tomorrow's Fajr
      next = Prayer.fajr;
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowTimes = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        calcParams,
      );
      nextTime = tomorrowTimes.fajr;
    }

    // 3. Format Title & Body
    final now = DateTime.now();
    final diff = nextTime.difference(now);

    if (diff.isNegative) {
      debugPrint(
          '⚠️ Warning: Next prayer time is in the past. Re-evaluating...');
      return;
    }

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

    // Format remaining: "1 hour and 30 minutes"
    String remainingString = "";
    final int hours = diff.inHours;
    final int minutes = diff.inMinutes.remainder(60);

    if (hours > 0) {
      remainingString = "$hours ساعة و $minutes دقيقة";
    } else {
      remainingString = "$minutes دقيقة";
    }

    // ── Sticky Upcoming Prayer Notification ──
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sakin_sticky',
      'الصلاة القادمة',
      channelDescription: 'إشعار دائم يُظهر الوقت المتبقي حتى الصلاة القادمة',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: 'notification_icon',
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
