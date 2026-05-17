// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_intake_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterIntakeAdapter extends TypeAdapter<WaterIntake> {
  @override
  final typeId = 3;

  @override
  WaterIntake read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterIntake(
      timestamp: fields[0] as DateTime,
      amountMl: (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, WaterIntake obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.amountMl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterIntakeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
