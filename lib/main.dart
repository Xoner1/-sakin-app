import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/adhan_alarm_page.dart';

import 'core/theme.dart';
import 'services/prayer_service.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'services/settings_service.dart';
import 'services/battery_optimization_service.dart';
import 'services/background_service_new.dart';

import 'data/hive_database.dart';
import 'presentation/widgets/nav_bar.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/habits_screen.dart';
import 'presentation/screens/prayer_times_screen.dart';
import 'presentation/screens/adhkar_screen.dart';

import 'package:sakin_app/models/location_info.dart';
import 'package:sakin_app/providers/dependencies/adhan_dependency_provider.dart';
import 'package:sakin_app/providers/adhan_playback_provider.dart';
import 'package:sakin_app/providers/adhan_provider.dart';
import 'package:sakin_app/providers/adhan_notification_provider.dart';

// مفتاح للتنقل العام
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة خدمة الخلفية
  initFlutterAndroidBackgroundService();

  // 0. تهيئة intl locale للعربية
  await initializeDateFormatting('ar', null);
  tz.initializeTimeZones();

  // 1. تهيئة قاعدة البيانات (Ensure Hive is initialized first)
  final hiveDb = HiveDatabase();
  await hiveDb.init();

  // 2. طلب الأذونات الضرورية (مرة واحدة فقط)
  // نستخدم Hive (Settings Box) للتحقق مما إذا طلبنا الأذونات من قبل
  var settingsBox = await Hive.openBox('settings');
  bool permissionsRequested =
      settingsBox.get('permissions_requested', defaultValue: false);

  if (!permissionsRequested) {
    debugPrint('Requesting permissions for the first time...');
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.location,
    ].request();

    debugPrint('Notification Permission: ${statuses[Permission.notification]}');
    debugPrint(
        'Schedule Alarm Permission: ${statuses[Permission.scheduleExactAlarm]}');

    // Mark as requested preventing future prompts
    await settingsBox.put('permissions_requested', true);
  } else {
    debugPrint('Permissions already requested previously. Skipping.');
  }

  // 3. تهيئة الخدمات (Restored)
  await NotificationService.init();
  await AndroidAlarmManager.initialize(); // تهيئة مدير المنبهات

  // 5. تهيئة خدمة الموقع
  final locationService = LocationService();
  await locationService.init();

  // 7. إعداد callback لفتح صفحة الأذكار عند النقر على الإشعار
  NotificationService.onAdhkarTap = (payload) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const AdhkarScreen()),
    );
  };

  runApp(SakinApp(hiveDb: hiveDb, locationService: locationService));
}

// دالة تهيئة الخدمة الخلفية
void initFlutterAndroidBackgroundService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'sakin_foreground_service',
      channelName: 'Sakin Service',
      channelDescription: 'Running in background for prayer times',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(60000),
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

class SakinApp extends StatelessWidget {
  final HiveDatabase hiveDb;
  final LocationService locationService;
  const SakinApp(
      {super.key, required this.hiveDb, required this.locationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: hiveDb),
        ChangeNotifierProvider.value(value: locationService),
        ChangeNotifierProvider(
            create: (_) => SettingsService()..loadSettings()),
        ChangeNotifierProvider(create: (_) => AdhanDependencyProvider()),
        ChangeNotifierProvider(create: (_) => AdhanPlayBackProvider()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Sakin',
            theme: AppTheme.lightTheme,
            locale: settings.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
              Locale('fr'),
            ],
            builder: (context, child) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProxyProvider2<AdhanDependencyProvider,
                      LocationService, AdhanProvider>(
                    create: (context) => AdhanProvider(
                      Provider.of<AdhanDependencyProvider>(context,
                          listen: false),
                      Provider.of<LocationService>(context, listen: false)
                              .currentLocation ??
                          LocationInfo(
                              latitude: 0,
                              longitude: 0,
                              address: '',
                              mode: LocationMode.manual), // Default
                      null,
                    ),
                    update: (context, dep, loc, prev) {
                      return AdhanProvider(
                        dep,
                        loc.currentLocation ??
                            LocationInfo(
                                latitude: 0,
                                longitude: 0,
                                address: '',
                                mode: LocationMode.manual),
                        AppLocalizations.of(context),
                      );
                    },
                  ),
                  ChangeNotifierProxyProvider2<AdhanDependencyProvider,
                      LocationService, AdhanNotificationProvider>(
                    create: (context) => AdhanNotificationProvider(
                      Provider.of<AdhanDependencyProvider>(context,
                          listen: false),
                      Provider.of<LocationService>(context, listen: false)
                              .currentLocation ??
                          LocationInfo(
                              latitude: 0,
                              longitude: 0,
                              address: '',
                              mode: LocationMode.manual),
                      null,
                    ),
                    update: (context, dep, loc, prev) {
                      return AdhanNotificationProvider(
                        dep,
                        loc.currentLocation ??
                            LocationInfo(
                                latitude: 0,
                                longitude: 0,
                                address: '',
                                mode: LocationMode.manual),
                        AppLocalizations.of(context),
                      );
                    },
                  ),
                  // Keep PrayerService for now if needed, or rely on refactor
                  ChangeNotifierProxyProvider<LocationService, PrayerService>(
                    create: (_) => PrayerService(),
                    update: (_, location, prayerService) {
                      if (prayerService != null &&
                          location.currentLocation != null) {
                        prayerService.updateLocation(
                          location.currentLocation!.latitude,
                          location.currentLocation!.longitude,
                        );
                      }
                      return prayerService ?? PrayerService();
                    },
                  ),
                ],
                child: child!,
              );
            },
            home: const MainLayout(),
            routes: {
              '/adhkar': (context) => const AdhkarScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      BatteryOptimizationService.checkAndPrompt(context);
      _checkNotificationLaunch();
      _startForegroundService(); // Start new service

      // Schedule notifications on start
      _scheduleInitialNotifications();
    });
  }

  void _scheduleInitialNotifications() {
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final settingsService =
        Provider.of<SettingsService>(context, listen: false);

    prayerService.scheduleNotifications(settingsService.settings);
  }

  void _startForegroundService() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Sakin Service',
      notificationText: 'Running...',
      callback: startCallback,
    );
  }

  Future<void> _checkNotificationLaunch() async {
    final bool launchedFromAdhan =
        await NotificationService.didLaunchFromAdhan();
    if (launchedFromAdhan && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdhanAlarmPage()),
      );
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const HabitsScreen(),
    const PrayerTimesScreen(),
    const SettingsScreen(), // الصفحة الجديدة
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
