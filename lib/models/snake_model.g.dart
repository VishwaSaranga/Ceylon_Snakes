// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snake_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SnakeAdapter extends TypeAdapter<Snake> {
  @override
  final int typeId = 0;

  @override
  Snake read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Snake(
      name: fields[0] as String,
      venomLevel: fields[1] as String,
      identification: fields[2] as String,
      venomEffect: fields[3] as String,
      activeTime: fields[4] as String,
      imagePath: fields[5] as String,
      isFavorite: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Snake obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.venomLevel)
      ..writeByte(2)
      ..write(obj.identification)
      ..writeByte(3)
      ..write(obj.venomEffect)
      ..writeByte(4)
      ..write(obj.activeTime)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnakeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
