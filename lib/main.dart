import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'services/prayer_service.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/location_service.dart';
import 'services/settings_service.dart';
import 'data/hive_database.dart';
import 'presentation/widgets/nav_bar.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/habits_screen.dart';
import 'presentation/screens/prayer_times_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. تهيئة intl locale للعربية
  await initializeDateFormatting('ar', null);

  // 1. طلب الأذونات الضرورية
  await Permission.notification.request();

  // 2. تهيئة الخدمات
  await NotificationService.init();
  await initializeService(); // الخلفية

  // 3. تهيئة قاعدة البيانات
  final hiveDb = HiveDatabase();
  await hiveDb.init();

  // 4. تهيئة خدمة الموقع
  final locationService = LocationService();
  await locationService.init();

  // 5. إعداد listener لأحداث الخلفية (تشغيل الأذان)
  final service = FlutterBackgroundService();
  service.on('playAdhan').listen((event) async {
    final prayerName = event?['prayerName'] ?? '';
    debugPrint('🔔 استقبال حدث تشغيل الأذان: $prayerName');
    await NotificationService.showPrayerNotificationWithAdhan(prayerName);
  });

  runApp(SakinApp(hiveDb: hiveDb, locationService: locationService));
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
        ChangeNotifierProvider(create: (_) => PrayerService()),
        ChangeNotifierProvider.value(value: hiveDb),
        ChangeNotifierProvider.value(value: locationService),
        ChangeNotifierProvider(create: (_) => SettingsService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sakin',
        theme: AppTheme.lightTheme,
        home: const MainLayout(),
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const HabitsScreen(),
    const PrayerTimesScreen(),
    const Scaffold(body: Center(child: Text("صفحة الإعدادات (قريباً)"))),
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
