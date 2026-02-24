import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/screens/settings_screen.dart';
// import 'presentation/screens/adhan_alarm_page.dart';
import 'presentation/screens/splash_screen.dart'; // Import SplashScreen
import 'services/permission_service.dart';

import 'core/theme.dart';
import 'services/prayer_service.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/habit_service.dart';
import 'services/battery_optimization_service.dart';
import 'package:sakin_app/services/alarm_service.dart';
import 'package:sakin_app/services/ramadan_messages_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/hive_database.dart';
import 'data/repositories/misbaha_repository.dart';

import 'presentation/widgets/nav_bar.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/habits_screen.dart';
import 'presentation/screens/prayer_times_screen.dart';
import 'presentation/screens/adhkar_screen.dart';

import 'business_logic/cubits/misbaha/misbaha_cubit.dart';

import 'package:sakin_app/models/location_info.dart';
import 'package:sakin_app/providers/dependencies/adhan_dependency_provider.dart';
import 'package:sakin_app/providers/adhan_playback_provider.dart';
import 'package:sakin_app/providers/adhan_provider.dart';
import 'package:sakin_app/providers/adhan_notification_provider.dart';

// Global navigator key for navigation without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Listen to theme changes globally
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('ar'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isInitialized = false;
  late final HiveDatabase _hiveDb;
  late final MisbahaRepository _misbahaRepository;
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    // 1. Initialize Critical Base Services (Sequential)
    await SettingsService.init();

    // Update global notifiers immediately after settings load
    themeNotifier.value =
        SettingsService.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    localeNotifier.value = Locale(SettingsService.language);

    await HabitService.init();

    // 2. Initialize Database & Repository (Sequential)
    _hiveDb = HiveDatabase();
    await _hiveDb.init();

    _misbahaRepository = MisbahaRepository();
    await _misbahaRepository.init();

    // 3. Initialize Independent Services (Parallel)
    await Future.wait([
      initializeDateFormatting('ar', null),
      NotificationService.init(),
      if (Platform.isAndroid)
        AndroidAlarmManager.initialize()
      else
        Future.value(true),
      _initPermissions(),
      // ✅ Reschedule alarms if the app was updated or the device was rebooted
      _checkAndRescheduleAfterUpdate(),
    ]);

    tz.initializeTimeZones(); // Synchronous

    // 4. Initialize Location Service
    _locationService = LocationService();
    await _locationService.init();

    // 5. Setup callback
    NotificationService.onAdhkarTap = (payload) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const AdhkarScreen()),
      );
    };

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _checkAndRescheduleAfterUpdate() async {
    if (!Platform.isAndroid) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      const prefsKey = 'needs_reschedule_after_update';

      final needsReschedule = prefs.getBool(prefsKey) ?? false;

      if (needsReschedule) {
        debugPrint('🔄 Update or reboot detected — rescheduling alarms...');
        final success = await PrayerAlarmScheduler.schedulePrayerAlarms();

        if (success) {
          // ✅ Clear the flag only on actual success
          await prefs.setBool(prefsKey, false);
          debugPrint('✅ Alarms rescheduled successfully after update.');
        } else {
          // ⚠️ Location was not ready — keep the flag to retry on next launch
          debugPrint(
              '⚠️ Rescheduling failed (no location) — will retry on next launch.');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error checking reschedule flag: $e');
    }
  }

  Future<void> _initPermissions() async {
    var settingsBox = await Hive.openBox('settings');
    bool permissionsRequested =
        settingsBox.get('permissions_requested', defaultValue: false);

    if (!permissionsRequested) {
      debugPrint('Requesting permissions for the first time...');

      final permissionService = PermissionService();
      await permissionService.requestNotificationPermissions();
      await Permission.location.request();
      await settingsBox.put('permissions_requested', true);
    } else {
      debugPrint('Permissions already requested previously. Skipping.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    return SakinApp(
      hiveDb: _hiveDb,
      locationService: _locationService,
      misbahaRepository: _misbahaRepository,
    );
  }
}

class SakinApp extends StatefulWidget {
  final HiveDatabase hiveDb;
  final LocationService locationService;
  final MisbahaRepository misbahaRepository;

  const SakinApp({
    super.key,
    required this.hiveDb,
    required this.locationService,
    required this.misbahaRepository,
  });

  @override
  State<SakinApp> createState() => _SakinAppState();
}

class _SakinAppState extends State<SakinApp> {
  @override
  void initState() {
    super.initState();
    // Check if app was launched from Adhan notification and stop it
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final launchedFromAdhan = await NotificationService.didLaunchFromAdhan();
      if (launchedFromAdhan) {
        // Stop adhan without showing any UI
        await NotificationService.stopAdhan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.hiveDb),
        ChangeNotifierProvider.value(value: widget.locationService),
        ChangeNotifierProvider(create: (_) => AdhanDependencyProvider()),
        ChangeNotifierProvider(create: (_) => AdhanPlayBackProvider()),
        RepositoryProvider.value(value: widget.misbahaRepository),
        BlocProvider(create: (_) => MisbahaCubit(widget.misbahaRepository)),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, mode, _) {
          return ValueListenableBuilder<Locale>(
            valueListenable: localeNotifier,
            builder: (_, locale, __) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Sakin',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: mode,
                locale: locale,
                supportedLocales: const [
                  Locale('ar'),
                  Locale('en'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
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
                                  mode: LocationMode.manual),
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
                      ChangeNotifierProxyProvider<LocationService,
                          PrayerService>(
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
      // _checkNotificationLaunch();

      await PrayerAlarmScheduler.schedulePrayerAlarms();
      await PrayerAlarmScheduler.checkAndNotifyTTL();
      await RamadanMessagesService.scheduleDailyMessage();
    });
  }

  /*
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
  */

  final List<Widget> _screens = [
    const HomeScreen(),
    const HabitsScreen(),
    const PrayerTimesScreen(),
    const SettingsScreen(),
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
