// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserResponseProfileAdapter extends TypeAdapter<UserResponseProfile> {
  @override
  final int typeId = 10;

  @override
  UserResponseProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserResponseProfile(
      communicationStyle: (fields[0] as Map?)?.cast<String, int>(),
      riskTolerance: (fields[1] as Map?)?.cast<String, int>(),
      conflictApproach: (fields[2] as Map?)?.cast<String, int>(),
      totalDecisions: fields[3] as int,
      profileVersion: fields[4] as String,
      lastUpdated: fields[5] as DateTime?,
      completedScenarioIds: (fields[6] as List?)?.cast<String>(),
      contextCounts: (fields[7] as Map?)?.cast<String, int>(),
      tagCounts: (fields[8] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserResponseProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.communicationStyle)
      ..writeByte(1)
      ..write(obj.riskTolerance)
      ..writeByte(2)
      ..write(obj.conflictApproach)
      ..writeByte(3)
      ..write(obj.totalDecisions)
      ..writeByte(4)
      ..write(obj.profileVersion)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.completedScenarioIds)
      ..writeByte(7)
      ..write(obj.contextCounts)
      ..writeByte(8)
      ..write(obj.tagCounts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserResponseProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
