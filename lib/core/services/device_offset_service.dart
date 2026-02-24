import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceOffsetService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // List of manufacturers known for aggressive battery optimization (Doze mode)
  // that typically delay exact alarms by 1 to 2 minutes.
  static const List<String> _aggressiveOems = [
    'xiaomi',
    'redmi',
    'poco',
    'huawei',
    'honor',
    'oppo',
    'vivo',
    'realme',
    'oneplus',
  ];

  /// Calculates a pre-emptive offset (in minutes) based on the device manufacturer.
  /// Returns 0 for iOS or Android devices with standard AOSP alarm behavior (like Pixel/Samsung).
  /// Returns a negative value (e.g., -1 or -2) for aggressive OEMs.
  static Future<int> getDeviceSpecificOffset() async {
    if (!Platform.isAndroid) return 0;

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final manufacturer = androidInfo.manufacturer.toLowerCase();
      final brand = androidInfo.brand.toLowerCase();

      // Check if the device is from a known aggressive OEM
      final isAggressive = _aggressiveOems
          .any((oem) => manufacturer.contains(oem) || brand.contains(oem));

      if (isAggressive) {
        // Pre-emptively subtract 2 minutes to counter the OS batching delay
        return -2;
      }

      return 0;
    } catch (e) {
      // Fallback to 0 if device info cannot be read
      return 0;
    }
  }
}
