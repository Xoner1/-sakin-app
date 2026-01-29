import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';

import '../../core/theme.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم اللغة
            _buildSectionHeader(l10n.language),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildLanguageItem(context, l10n.arabic, const Locale('ar')),
                  const Divider(height: 1),
                  _buildLanguageItem(context, l10n.english, const Locale('en')),
                  const Divider(height: 1),
                  _buildLanguageItem(context, l10n.french, const Locale('fr')),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // قسم معلومات التطبيق
            _buildSectionHeader(l10n.appVersion),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/app_icon.png',
                    height: 80,
                    width: 80,
                    errorBuilder: (c, e, s) => const Icon(Icons.mosque,
                        size: 60, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Sakin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${l10n.version}: $_appVersion",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // الدعاء (Footer)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                  const SizedBox(height: 10),
                  Text(
                    l10n.supplication,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
      BuildContext context, String title, Locale itemLocale) {
    final settings = Provider.of<SettingsService>(context, listen: false);
    final isSelected = settings.locale.languageCode == itemLocale.languageCode;

    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        settings.setLocale(itemLocale);
      },
    );
  }
}
