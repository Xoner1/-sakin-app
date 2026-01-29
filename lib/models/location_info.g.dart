// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationInfoAdapter extends TypeAdapter<LocationInfo> {
  @override
  final int typeId = 3;

  @override
  LocationInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationInfo(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      address: fields[2] as String,
      mode: fields[3] as LocationMode,
      lastUpdated: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationModeAdapter extends TypeAdapter<LocationMode> {
  @override
  final int typeId = 2;

  @override
  LocationMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LocationMode.cached;
      case 1:
        return LocationMode.live;
      case 2:
        return LocationMode.manual;
      default:
        return LocationMode.cached;
    }
  }

  @override
  void write(BinaryWriter writer, LocationMode obj) {
    switch (obj) {
      case LocationMode.cached:
        writer.writeByte(0);
        break;
      case LocationMode.live:
        writer.writeByte(1);
        break;
      case LocationMode.manual:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
