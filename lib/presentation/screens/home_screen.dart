import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme.dart';
import '../../core/utils/number_converter.dart';
import '../../services/prayer_service.dart';
import 'adhkar_screen.dart';
import 'tasbih_screen.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';
import '../../core/services/settings_service.dart';
import '../../services/location_service.dart';
import '../../services/ramadan_messages_service.dart';
import '../widgets/ramadan_welcome_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocation();
    });
  }

  void _checkLocation() {
    // Check for Ramadan Welcome Dialog
    RamadanMessagesService.shouldShowWelcomeDialog().then((shouldShow) {
      if (shouldShow && mounted) {
        showDialog(
          context: context,
          builder: (context) => const RamadanWelcomeDialog(),
        );
        RamadanMessagesService.markWelcomeDialogShown();
      }
    });

    // If location is not set, fetch it in background without await
    if (SettingsService.location == null) {
      debugPrint("HomeScreen: No location found. Fetching in background...");
      // Fire and forget
      Provider.of<LocationService>(context, listen: false).getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generic l10n safety check
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Hijri setup
    final localeName = l10n.localeName;
    try {
      HijriCalendar.setLocal(localeName);
    } catch (_) {
      // Fallback to English if locale is not supported
      HijriCalendar.setLocal('en');
    }

    HijriCalendar hijriDate;
    try {
      hijriDate = HijriCalendar.now();
    } catch (_) {
      // Emergency fallback if .now() fails due to internal issues
      HijriCalendar.setLocal('en');
      hijriDate = HijriCalendar.now();
    }
    final gregDate = DateTime.now();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Defines shadow that is subtle in light mode and invisible/dark in dark mode
    final List<BoxShadow> adaptiveShadow = isDark
        ? [] // No shadow in dark mode for cleaner look
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 30),
              _buildPrayerRing(theme, isDark),
              const SizedBox(height: 25),
              // Dates Section
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: adaptiveShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      hijriDate.toFormat("dd MMMM yyyy").toWesternArabic,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE، d MMMM yyyy', localeName)
                          .format(gregDate)
                          .toWesternArabic,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Grid (Row)
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      context,
                      AppLocalizations.of(context)!.adhkar,
                      "Adhkar", // Keep English fallback/subtitle or remove if redundant
                      HugeIcons.strokeRoundedBookOpen01,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdhkarScreen())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      context,
                      AppLocalizations.of(context)!.tasbih,
                      "Tasbih", // Keep English or remove
                      HugeIcons.strokeRoundedFingerPrint, // Updated Icon
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TasbihScreen())),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    // Need access to l10n here, but since parent checked it, it should be fine.
    // However, looking up via context again is cleaner than passing arguments down.
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Aligned to start
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.greeting,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
          ],
        ),
        // Notification Icon Removed
      ],
    );
  }

  Widget _buildPrayerRing(ThemeData theme, bool isDark) {
    return Consumer<PrayerService>(
      builder: (context, prayerService, _) {
        final nextPrayer = prayerService.nextPrayer;

        final l10n = AppLocalizations.of(context);
        if (l10n == null) return const SizedBox();

        String prayerName = "Loading...";
        String prayerTime = "--:--";
        dynamic icon = HugeIcons.strokeRoundedMoon02;
        String nextPrayerName = l10n.nextPrayer;

        if (prayerService.prayerTimes != null) {
          final adjustedNext = prayerService.getAdjustedTime(nextPrayer);

          switch (nextPrayer) {
            case adhan.Prayer.fajr:
              prayerName = l10n.fajr;
              icon = HugeIcons.strokeRoundedSun02;
              break;
            case adhan.Prayer.dhuhr:
              prayerName = l10n.dhuhr;
              icon = HugeIcons.strokeRoundedSun03;
              break;
            case adhan.Prayer.asr:
              prayerName = l10n.asr;
              icon = HugeIcons.strokeRoundedSun01;
              break;
            case adhan.Prayer.maghrib:
              prayerName = l10n.maghrib;
              icon = HugeIcons.strokeRoundedSunset;
              break;
            case adhan.Prayer.isha:
              prayerName = l10n.isha;
              icon = HugeIcons.strokeRoundedMoon01;
              break;
            case adhan.Prayer.none:
              prayerName = l10n.fajr; // Rolls over to Fajr next day typically
              icon = HugeIcons.strokeRoundedSun02;
              break;
            default:
              prayerName = l10n.fajr;
          }

          if (adjustedNext != null) {
            // Use local format (e.g. 12h or 24h depending on locale if needed, but jm is good)
            prayerTime = DateFormat.jm(l10n.localeName).format(adjustedNext);
          } else if (nextPrayer == adhan.Prayer.none) {
            final fajr = prayerService.fajr;
            if (fajr != null) {
              prayerTime = DateFormat.jm(l10n.localeName).format(fajr);
            }
          }
        }

        return Container(
          height: 240,
          width: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.08),
                AppTheme.primaryColor.withValues(alpha: 0.03),
              ],
            ),
            border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.white.withValues(alpha: 0.6),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(icon: icon, color: AppTheme.primaryColor, size: 32),
              const SizedBox(height: 12),
              Text(prayerName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 22, fontWeight: FontWeight.w500)),
              Text(prayerTime.toWesternArabic,
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme
                          .primaryColor, // Changed to primary for consistency in dark mode
                      height: 1.0)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(nextPrayerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle,
      dynamic icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor, // Dynamic background
                borderRadius: BorderRadius.circular(18),
              ),
              child:
                  HugeIcon(icon: icon, color: AppTheme.primaryColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
            // Subtitle removed or used for English if needed, currently using title for main text
            if (subtitle.isNotEmpty && subtitle != title)
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
