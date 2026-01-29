import 'package:hive/hive.dart';

part 'location_info.g.dart';

/// أوضاع الموقع المدعومة.
@HiveType(typeId: 2)
enum LocationMode {
  /// الموقع محفوظ محلياً (لا يوجد إنترنت).
  @HiveField(0)
  cached,

  /// الموقع يتم جلبه مباشرة عبر GPS.
  @HiveField(1)
  live,

  /// الموقع تم إدخاله يدوياً.
  @HiveField(2)
  manual,
}

/// نموذج معلومات الموقع.
/// يستخدم لتخزين الإحداثيات والعنوان وحالة تحديث الموقع.
@HiveType(typeId: 3)
class LocationInfo {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final LocationMode mode;

  @HiveField(4)
  final DateTime lastUpdated;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.mode,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// إنشاء نسخة جديدة من معلومات الموقع مع إمكانية تعديل بعض الحلقول.
  LocationInfo copyWith({
    double? latitude,
    double? longitude,
    String? address,
    LocationMode? mode,
    DateTime? lastUpdated,
  }) {
    return LocationInfo(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      mode: mode ?? this.mode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// تحويل البيانات إلى [Map] للحفظ كخيار بديل.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'mode': mode.name,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// إنشاء كائن [LocationInfo] من [Map].
  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      mode: LocationMode.values.byName(json['mode'] ?? 'cached'),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
