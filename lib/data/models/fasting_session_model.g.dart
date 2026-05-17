// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FastingSessionAdapter extends TypeAdapter<FastingSession> {
  @override
  final typeId = 1;

  @override
  FastingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FastingSession(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      fastingHours: (fields[3] as num).toInt(),
      completed: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FastingSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.fastingHours)
      ..writeByte(4)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
