import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

/// خدمة للتعامل مع استثناء تحسين البطارية
/// هذا ضروري لضمان استمرار عمل خدمة الأذان في الخلفية
class BatteryOptimizationService {
  static const String _boxName = 'settings';
  static const String _promptShownKey = 'battery_prompt_shown';

  /// التحقق مما إذا كان التطبيق مستثنى من تحسين البطارية
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true; // iOS لا تحتاج هذا

    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// التحقق مما إذا تم عرض الحوار من قبل
  static Future<bool> wasPromptShown() async {
    try {
      final box = await Hive.openBox(_boxName);
      return box.get(_promptShownKey, defaultValue: false) as bool;
    } catch (e) {
      debugPrint('Error checking prompt status: $e');
      // Fail-safe: If we can't check, assume it was shown to avoid annoyance
      return true;
    }
  }

  /// تسجيل أن الحوار تم عرضه
  static Future<void> markPromptAsShown() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_promptShownKey, true);
    } catch (e) {
      debugPrint('Error marking prompt as shown: $e');
    }
  }

  /// الحصول على الشركة المصنعة للجهاز
  static Future<String?> _getManufacturer() async {
    if (!Platform.isAndroid) return null;
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.manufacturer.toLowerCase();
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return null;
    }
  }

  /// فتح إعدادات التشغيل التلقائي لشاومي
  static Future<void> _openAutoStartSettings() async {
    try {
      const intent = AndroidIntent(
        action: 'miui.intent.action.OP_AUTO_START',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      debugPrint('Could not open Auto Start settings: $e');
      await openAppSettings();
    }
  }

  /// طلب استثناء التطبيق من تحسين البطارية
  static Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }

  /// فتح إعدادات البطارية مباشرة
  static Future<void> openBatterySettings() async {
    await openAppSettings();
  }

  /// إظهار حوار يشرح للمستخدم أهمية استثناء البطارية
  static Future<void> showBatteryOptimizationDialog(
      BuildContext context) async {
    if (!context.mounted) return;

    // Detect Manufacturer
    final manufacturer = await _getManufacturer();

    if (!context.mounted) return;

    final bool isXiaomi = manufacturer?.contains('xiaomi') ?? false;
    final bool isSamsung = manufacturer?.contains('samsung') ?? false;

    // Customize Text based on Device
    String titleText = 'تنبيه مهم';
    String contentText =
        'لضمان وصول تنبيهات الأذان في وقتها، يُرجى استثناء التطبيق من تحسين البطارية.';

    if (isXiaomi) {
      titleText = 'إعدادات التشغيل التلقائي';
      contentText =
          'لضمان عمل الأذان، يرجى تفعيل "البدء التلقائي" (Auto Start) من الإعدادات.';
    } else if (isSamsung) {
      titleText = 'إعدادات البطارية';
      contentText =
          'لضمان عمل الأذان، يرجى اختيار وضع "بلا قيود" (Unrestricted) للبطارية.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.settings_power, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titleText,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentText,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            if (!isXiaomi && !isSamsung)
              const Text(
                'هذا يمنع النظام من إيقاف التطبيق تلقائياً.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('لاحقاً', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (context.mounted) Navigator.pop(context);

              if (isXiaomi) {
                await _openAutoStartSettings();
              } else {
                await requestIgnoreBatteryOptimizations();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C59),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isXiaomi ? 'فتح الإعدادات' : 'الإعدادات'),
          ),
        ],
      ),
    );
  }

  /// التحقق وإظهار الحوار إذا لزم الأمر (يُستدعى عند فتح التطبيق)
  static Future<void> checkAndPrompt(BuildContext context) async {
    // 0. الانتظار قليلاً لضمان جاهزية الـ UI و Hive
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!context.mounted) return;

    // 1. التحقق مما إذا كنا قد أظهرنا الحوار سابقاً
    final bool wasShown = await wasPromptShown();
    debugPrint('Battery Prompt Shown Before: $wasShown');

    if (wasShown) {
      return;
    }

    // 2. التحقق من حالة الإذن الحالية (الحقيقة من النظام)
    // حتى لو لم يتم عرضه، إذا كان الاذن ممنوحاً فلا داعي للعرض
    final bool isIgnoring = await isIgnoringBatteryOptimizations();

    // 3. STRICT: Mark as shown IMMEDIATELY
    // This ensures it runs Only Once even if user dismisses, crashes, or allows.
    await markPromptAsShown();

    if (isIgnoring) {
      return;
    }

    // 4. إظهار الحوار
    if (context.mounted) {
      await showBatteryOptimizationDialog(context);
    }
  }
}
