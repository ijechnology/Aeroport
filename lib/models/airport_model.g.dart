// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AirportAdapter extends TypeAdapter<Airport> {
  @override
  final int typeId = 1;

  @override
  Airport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Airport(
      airportName: fields[0] as String,
      iataCode: fields[1] as String,
      country: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Airport obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.airportName)
      ..writeByte(1)
      ..write(obj.iataCode)
      ..writeByte(2)
      ..write(obj.country)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
