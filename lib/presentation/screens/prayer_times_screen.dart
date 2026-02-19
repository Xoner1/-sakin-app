import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/utils/number_converter.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Map<String, DateTime>? _prayerTimes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  void _loadPrayerTimes() {
    setState(() {
      _prayerTimes = PrayerService.getPrayerTimesForToday();
    });
  }

  // Fallback times if no location is set yet (matching previous dummy data)
  final Map<String, TimeOfDay> _fallbackTimes = {
    'Fajr': const TimeOfDay(hour: 5, minute: 30),
    'Dhuhr': const TimeOfDay(hour: 12, minute: 35),
    'Asr': const TimeOfDay(hour: 15, minute: 45),
    'Maghrib': const TimeOfDay(hour: 18, minute: 10),
    'Isha': const TimeOfDay(hour: 19, minute: 40),
  };

  Future<void> _onRefreshLocation() async {
    setState(() => _isLoading = true);

    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.updatingLocation),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      // 0. Capture old location
      final double? oldLat = SettingsService.latitude;
      final double? oldLong = SettingsService.longitude;

      // 1. Fetch Location
      await LocationService.getUserLocation();

      // 2. Check for Offset Conflict
      if (SettingsService.hasOffsets && mounted) {
        bool shouldAsk = true;

        // If we had a previous location, check distance
        if (oldLat != null && oldLong != null) {
          final newLat = SettingsService.latitude!;
          final newLong = SettingsService.longitude!;
          final double distanceInMeters =
              LocationService.distanceBetween(oldLat, oldLong, newLat, newLong);

          // Only ask if distance > 10km (10,000 meters)
          if (distanceInMeters < 10000) {
            shouldAsk = false;
          }
        }

        if (shouldAsk) {
          // Show Dialog
          final l10n = AppLocalizations.of(context)!;
          final shouldReset = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.changeLocation, textAlign: TextAlign.right),
              content: Text(
                l10n.locationChangeDetected,
                textAlign: TextAlign.right,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false), // Keep
                  child: Text(l10n.keep),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true), // Reset
                  child: Text(l10n.reset,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (shouldReset == true) {
            await SettingsService.resetPrayerOffsets();
          }
        }
      }

      // 3. Update Times
      _loadPrayerTimes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationUpdatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "${AppLocalizations.of(context)!.errorOccurred}: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;
    HijriCalendar.setLocal(l10n.localeName);
    final hijriDate = HijriCalendar.now();
    final gregDate = DateTime.now();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.prayerTimes),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header: Location & Date
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const HugeIcon(
                                icon: HugeIcons.strokeRoundedLocation01,
                                color: AppTheme.primaryColor,
                                size: 20),
                            const SizedBox(width: 8),
                            // Use SettingService directly which updates on refresh
                            Text(
                              SettingsService.location ??
                                  AppLocalizations.of(context)!.selectLocation,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hijriDate.toFormat("dd MMMM yyyy"),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          DateFormat('EEEE، d MMMM yyyy', l10n.localeName)
                              .format(gregDate),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _onRefreshLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const HugeIcon(
                                  icon: HugeIcons.strokeRoundedRefresh,
                                  color: AppTheme.primaryColor,
                                  size: 16,
                                ),
                          label: Text(
                            _isLoading ? l10n.refreshing : l10n.refreshLocation,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Prayer List
              Expanded(
                child: ListView(
                  children: [
                    _buildPrayerCard(context, "Fajr", l10n.fajr),
                    _buildPrayerCard(context, "Dhuhr", l10n.dhuhr),
                    _buildPrayerCard(context, "Asr", l10n.asr),
                    _buildPrayerCard(context, "Maghrib", l10n.maghrib),
                    _buildPrayerCard(context, "Isha", l10n.isha),
                    const SizedBox(height: 20),
                    _buildHintBox(isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedInformationCircle,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.mosqueTimeSync,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.mosqueTimeSyncDesc,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(BuildContext context, String id, String nameAr) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get base time: either calculated or fallback
    DateTime baseDateTime;
    if (_prayerTimes != null && _prayerTimes!.containsKey(id)) {
      baseDateTime = _prayerTimes![id]!;
    } else {
      // Create DateTime from fallback TimeOfDay
      final now = DateTime.now();
      final tod = _fallbackTimes[id]!;
      baseDateTime =
          DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    }

    // Apply User Offset
    final int offset = SettingsService.getPrayerOffset(id);
    final DateTime adjustedDateTime =
        baseDateTime.add(Duration(minutes: offset));
    final String displayTime =
        DateFormat.jm().format(adjustedDateTime).toWesternArabic;

    return GestureDetector(
      onTap: () => _showAdjustmentDialog(context, id, nameAr, offset),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(
                  icon: (id == 'Fajr' || id == 'Dhuhr' || id == 'Asr')
                      ? HugeIcons.strokeRoundedSun03
                      : HugeIcons.strokeRoundedMoon02,
                  color: AppTheme.primaryColor,
                  size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              nameAr,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            // Badge if offset exists
            if (offset != 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange, // Warning color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${offset > 0 ? '+' : ''}$offset min",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              displayTime,
              style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdjustmentDialog(
      BuildContext context, String id, String name, int currentOffset) async {
    int newOffset = currentOffset;

    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(l10n.adjustTime(name), textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.adjustTimeDesc),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => newOffset--),
                      icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedMinusSign,
                          color: Colors.red,
                          size: 24),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "${newOffset > 0 ? '+' : ''}$newOffset",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () => setState(() => newOffset++),
                      icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedPlusSign,
                          color: Colors.green,
                          size: 24),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  await SettingsService.setPrayerOffset(id, newOffset);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
    // Refresh screen after dialog closes to show updated time with offset
    if (mounted) {
      setState(() {});
      // Note: In a real app we might also want to reschedule notifications here
    }
  }
}
