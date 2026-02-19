import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme.dart';
import '../../main.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _isBatteryIgnored = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Monitor user return to app
    _checkBatteryStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Update status immediately when returning from system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBatteryStatus();
    }
  }

  Future<void> _checkBatteryStatus() async {
    final status = await Permission.ignoreBatteryOptimizations.isGranted;
    if (mounted) {
      setState(() => _isBatteryIgnored = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. General Section
            _sectionHeader(AppLocalizations.of(context)!.general),
            _buildBox([
              _tile(HugeIcons.strokeRoundedGlobal,
                  AppLocalizations.of(context)!.language,
                  trailing: _langName(context, SettingsService.language),
                  onTap: _showLangSheet),
              _divider(),
              _tile(HugeIcons.strokeRoundedMoon02,
                  AppLocalizations.of(context)!.darkMode,
                  trailingWidget: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      SettingsService.setDarkMode(val);
                      themeNotifier.value =
                          val ? ThemeMode.dark : ThemeMode.light;
                    },
                  )),
            ]),

            const SizedBox(height: 25),

            // ⚠️ "Prayer Settings" completely removed for stability ✅

            // 2. System Section
            _sectionHeader(AppLocalizations.of(context)!.system),
            _buildBox([
              _tile(HugeIcons.strokeRoundedNotification01,
                  AppLocalizations.of(context)!.notifications,
                  trailingWidget:
                      Switch.adaptive(value: true, onChanged: (v) {})),
              _divider(),
              // Smart Battery Button 🔋
              _tile(
                HugeIcons.strokeRoundedBatteryCharging01,
                AppLocalizations.of(context)!.ignoreBatteryOptimization,
                subtitle: _isBatteryIgnored
                    ? AppLocalizations.of(context)!.batteryOptimized
                    : AppLocalizations.of(context)!.batteryRestricted,
                trailingWidget: Switch.adaptive(
                  value: _isBatteryIgnored,
                  activeTrackColor: AppTheme.primaryColor,
                  onChanged: (val) async {
                    if (val) {
                      await Permission.ignoreBatteryOptimizations.request();
                    } else {
                      await openAppSettings();
                    }
                    _checkBatteryStatus();
                  },
                ),
              ),
            ]),

            const SizedBox(height: 40),
            _footer(),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---
  Widget _sectionHeader(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(t,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold))),
      );

  Widget _buildBox(List<Widget> c) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)
            ]),
        child: Column(children: c),
      );

  Widget _tile(dynamic i, String t,
      {String? subtitle,
      String? trailing,
      Widget? trailingWidget,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: HugeIcon(icon: i, color: AppTheme.primaryColor, size: 22)),
      title: Text(t,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey))
          : null,
      trailing: trailingWidget ??
          (trailing != null
              ? Text(trailing, style: const TextStyle(color: Colors.grey))
              : null),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 60);

  void _showLangSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).cardColor,
        builder: (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(l10n.changeLanguage,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                _langTile(l10n.arabic, 'ar'),
                _langTile(l10n.english, 'en'),
                const SizedBox(height: 20),
              ],
            ));
  }

  Widget _langTile(String title, String code) {
    bool isSelected = SettingsService.language == code;
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        SettingsService.setLanguage(code);
        localeNotifier.value = Locale(code);
        Navigator.pop(context);
      },
    );
  }

  String _langName(BuildContext context, String c) {
    final l10n = AppLocalizations.of(context)!;
    return c == 'ar' ? l10n.arabic : l10n.english;
  }

  Widget _footer() => Column(children: [
        const Text("Sakin v1.0.0", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 10),
        const Text("لا تنسونا من صالح دعائكم ❤️",
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          InkWell(
              onTap: () async => await launchUrl(
                  Uri.parse("https://github.com/Xoner1/-sakin-app")),
              child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedGithub,
                  color: Colors.grey,
                  size: 24)),
          const SizedBox(width: 20),
          InkWell(
              onTap: () async =>
                  await launchUrl(Uri.parse("mailto:fakhridfarhat@gmail.com")),
              child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedMail01,
                  color: Colors.grey,
                  size: 24)),
        ]),
      ]);
}
