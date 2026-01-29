// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_notification_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerNotificationSettingsAdapter
    extends TypeAdapter<PrayerNotificationSettings> {
  @override
  final int typeId = 1;

  @override
  PrayerNotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerNotificationSettings(
      fajrEnabled: fields[0] as bool,
      dhuhrEnabled: fields[1] as bool,
      asrEnabled: fields[2] as bool,
      maghribEnabled: fields[3] as bool,
      ishaEnabled: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerNotificationSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fajrEnabled)
      ..writeByte(1)
      ..write(obj.dhuhrEnabled)
      ..writeByte(2)
      ..write(obj.asrEnabled)
      ..writeByte(3)
      ..write(obj.maghribEnabled)
      ..writeByte(4)
      ..write(obj.ishaEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerNotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
