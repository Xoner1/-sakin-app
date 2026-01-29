import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_info.dart';

class LocationService with ChangeNotifier {
  LocationInfo? _currentLocation;
  bool _isLoading = false;
  String? _errorMessage;

  LocationInfo? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // جلب الموقع الحالي (GPS)
  Future<LocationInfo?> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // التحقق من الأذونات
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'خدمة الموقع غير مفعّلة';
        _isLoading = false;
        notifyListeners();
        return _loadCachedLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'تم رفض إذن الموقع';
          _isLoading = false;
          notifyListeners();
          return _loadCachedLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'إذن الموقع مرفوض بشكل نهائي';
        _isLoading = false;
        notifyListeners();
        return _loadCachedLocation();
      }

      // جلب الموقع
      // جلب الموقع
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // جلب اسم المدينة من الإحداثيات
      String cityName = 'الموقع الحالي';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          cityName = placemark.locality ??
              placemark.administrativeArea ??
              'الموقع الحالي';
        }
      } catch (e) {
        debugPrint('خطأ في جلب اسم المدينة: $e');
      }

      _currentLocation = LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        address: cityName,
        mode: LocationMode.live,
      );

      // حفظ الموقع في Hive
      await _saveLocationToCache(_currentLocation!);

      _isLoading = false;
      notifyListeners();
      return _currentLocation;
    } catch (e) {
      _errorMessage = 'خطأ في جلب الموقع: $e';
      _isLoading = false;
      notifyListeners();
      return _loadCachedLocation();
    }
  }

  // حفظ الموقع في Hive
  Future<void> _saveLocationToCache(LocationInfo location) async {
    final box = await Hive.openBox('settings');
    await box.put('cached_location', location.toJson());
  }

  // تحميل الموقع المحفوظ
  Future<LocationInfo?> _loadCachedLocation() async {
    try {
      final box = await Hive.openBox('settings');
      final cachedData = box.get('cached_location');
      if (cachedData != null) {
        // تحويل Map بشكل صحيح
        final jsonData = Map<String, dynamic>.from(cachedData);
        _currentLocation = LocationInfo.fromJson(jsonData);
        // تحديث الوضع إلى cached
        _currentLocation = LocationInfo(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
          address: _currentLocation!.address,
          mode: LocationMode.cached,
          lastUpdated: _currentLocation!.lastUpdated,
        );
        notifyListeners();
        return _currentLocation;
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في تحميل الموقع المحفوظ: $e');
      return null;
    }
  }

  // تهيئة الخدمة (تحميل الموقع المحفوظ)
  Future<void> init() async {
    await _loadCachedLocation();
  }
}
