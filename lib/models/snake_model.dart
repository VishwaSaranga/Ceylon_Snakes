import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'snake_model.g.dart';

@HiveType(typeId: 0)
class Snake extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String venomLevel;

  @HiveField(2)
  final String identification;

  @HiveField(3)
  final String venomEffect;

  @HiveField(4)
  final String activeTime;

  @HiveField(5)
  final String imagePath;

  @HiveField(6)
  bool isFavorite;

  Snake({
    required this.name,
    required this.venomLevel,
    required this.identification,
    required this.venomEffect,
    required this.activeTime,
    required this.imagePath,
    this.isFavorite = false,
  });

  Color get venomColor {
    if (venomLevel.contains('උග්‍ර විෂ') || venomLevel.contains('උග්ර විෂ')) {
      return Colors.red;
    } else if (venomLevel.contains('මද විෂ')) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
