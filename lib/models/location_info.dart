enum LocationMode {
  cached, // الموقع محفوظ (لا يوجد إنترنت)
  live // الموقع مباشر (GPS)
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String address;
  final LocationMode mode;
  final DateTime lastUpdated;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.mode,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  LocationInfo copy() {
    return LocationInfo(
      latitude: latitude,
      longitude: longitude,
      address: address,
      mode: mode,
      lastUpdated: lastUpdated,
    );
  }

  // تحويل إلى Map للحفظ في Hive
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'mode': mode.toString(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // إنشاء من Map
  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      mode: json['mode'] == 'LocationMode.live'
          ? LocationMode.live
          : LocationMode.cached,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
