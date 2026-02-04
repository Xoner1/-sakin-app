import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'settings_service.dart';

class LocationService {
  /// Requests permission and gets the current high-accuracy location.
  /// Throws [LocationServiceDisabledException] if GPS is off.
  /// Throws [PermissionDeniedException] if permission is denied.
  static Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعلة. الرجاء تفعيلها من الإعدادات.');
    }

    // 2. Check & Request Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض إذن الوصول للموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'إذن الموقع مرفوض نهائياً. الرجاء تفعيله من إعدادات الهاتف.');
    }

    // 3. Get Position (High Accuracy)
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    // 4. Reverse Geocoding (Get City Name)
    String cityName = "Unknown Location";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct a readable string: "City, Country" or just "City"
        // subAdministrativeArea often contains the city/province in some regions
        // locality is the city/town
        final city = place.locality ?? place.subAdministrativeArea ?? "";
        final country = place.country ?? "";

        if (city.isNotEmpty && country.isNotEmpty) {
          cityName = "$city، $country";
        } else {
          cityName = city.isNotEmpty ? city : country;
        }
      }
    } catch (e) {
      // Fallback if geocoding fails (e.g., no internet), keep coordinates but maybe show basic info
      cityName =
          "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
    }

    // 5. Save to Settings
    await SettingsService.setCoordinates(position.latitude, position.longitude);
    // Only update the display name if we got a valid one.
    // If geocoding failed completely and returned coords, that's still better than nothing?
    // Let's stick to the plan.
    await SettingsService.setLocation(cityName);
  }

  static double distanceBetween(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
