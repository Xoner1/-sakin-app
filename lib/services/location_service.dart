import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_info.dart';
import 'alarm_service.dart';

class LocationService with ChangeNotifier {
  LocationInfo? _currentLocation;
  bool _isLoading = false;
  String? _errorMessage;

  LocationInfo? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch current location (GPS)
  Future<LocationInfo?> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location service is disabled';
        _isLoading = false;
        notifyListeners();
        return _loadCachedLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
          notifyListeners();
          return _loadCachedLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied';
        _isLoading = false;
        notifyListeners();
        return _loadCachedLocation();
      }

      // Fetch position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Get city name from coordinates
      String cityName = 'Current Location';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          cityName = placemark.locality ??
              placemark.administrativeArea ??
              'Current Location';
        }
      } catch (e) {
        debugPrint('Error fetching city name: $e');
      }

      _currentLocation = LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        address: cityName,
        mode: LocationMode.live,
      );

      // Save location to Hive
      await _saveLocationToCache(_currentLocation!);

      // Trigger prayer scheduling for the new location
      await PrayerAlarmScheduler.schedulePrayerAlarms();

      _isLoading = false;
      notifyListeners();
      return _currentLocation;
    } catch (e) {
      _errorMessage = 'Error fetching location: $e';
      _isLoading = false;
      notifyListeners();
      return _loadCachedLocation();
    }
  }

  // Set location manually from address (City, Country)
  Future<void> setManualLocation(String address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        _currentLocation = LocationInfo(
          latitude: loc.latitude,
          longitude: loc.longitude,
          address: address, // Or fetch formatted address if desired
          mode: LocationMode.manual,
        );

        await _saveLocationToCache(_currentLocation!);
        await PrayerAlarmScheduler.schedulePrayerAlarms();

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Address not found';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error setting location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save location to Hive
  Future<void> _saveLocationToCache(LocationInfo location) async {
    final box = await Hive.openBox('settings');
    await box.put('cached_location', location.toJson());
  }

  // Load cached location
  Future<LocationInfo?> _loadCachedLocation() async {
    try {
      final box = await Hive.openBox('settings');
      final cachedData = box.get('cached_location');
      if (cachedData != null) {
        // Convert Map correctly
        final jsonData = Map<String, dynamic>.from(cachedData);
        _currentLocation = LocationInfo.fromJson(jsonData);
        // Update mode to cached
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
      debugPrint('Error loading cached location: $e');
      return null;
    }
  }

  // Initialize service (load cached location)
  Future<void> init() async {
    await _loadCachedLocation();
  }
}
