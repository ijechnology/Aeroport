// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlightModelAdapter extends TypeAdapter<FlightModel> {
  @override
  final int typeId = 0;

  @override
  FlightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlightModel(
      airline: fields[0] as String,
      flightNumber: fields[1] as String,
      departureAirport: fields[2] as String,
      arrivalAirport: fields[3] as String,
      departureTime: fields[4] as DateTime,
      arrivalTime: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FlightModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.airline)
      ..writeByte(1)
      ..write(obj.flightNumber)
      ..writeByte(2)
      ..write(obj.departureAirport)
      ..writeByte(3)
      ..write(obj.arrivalAirport)
      ..writeByte(4)
      ..write(obj.departureTime)
      ..writeByte(5)
      ..write(obj.arrivalTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
