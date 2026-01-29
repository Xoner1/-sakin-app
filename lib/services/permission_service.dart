import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Check if the device requires special permissions (Xiaomi/Samsung/Oppo/Vivo)
  Future<bool> hasPowerRestrictions() async {
    if (!Platform.isAndroid) return false;

    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    final String manufacturer = androidInfo.manufacturer.toLowerCase();

    return ['xiaomi', 'oppo', 'vivo', 'letv', 'huawei', 'honor']
        .contains(manufacturer);
  }

  /// Open the specific settings page for the device manufacturer
  Future<void> openPowerSettings() async {
    if (!Platform.isAndroid) return;

    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    final String manufacturer = androidInfo.manufacturer.toLowerCase();

    try {
      if (manufacturer == 'xiaomi') {
        // Try to open Autostart settings
        await const AndroidIntent(
          action: 'miui.intent.action.OP_AUTO_START',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        ).launch();
      } else if (manufacturer == 'oppo') {
        await const AndroidIntent(
          action:
              'com.coloros.safecenter.permission.startup.StartupAppListActivity',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        ).launch();
      } else if (manufacturer == 'vivo') {
        await const AndroidIntent(
          action:
              'com.vivo.permissionmanager.activity.BgStartUpManagerActivity',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        ).launch();
      } else {
        // Default to App Settings
        await openAppSettings();
      }
    } catch (e) {
      // Fallback
      await openAppSettings();
    }
  }

  /// Request critical notification permissions
  Future<bool> requestNotificationPermissions() async {
    // 1. Notification Permission
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    // 2. Schedule Exact Alarm (Android 12+)
    if (Platform.isAndroid) {
      var alarmStatus = await Permission.scheduleExactAlarm.status;
      if (alarmStatus.isDenied) {
        // This permission must be granted via settings on some versions
        alarmStatus = await Permission.scheduleExactAlarm.request();
      }
    }

    // 3. System Alert Window (For full screen intent on some ROMs)
    var systemAlertStatus = await Permission.systemAlertWindow.status;
    if (!systemAlertStatus.isGranted) {
      await Permission.systemAlertWindow.request();
    }

    return status.isGranted;
  }
}
