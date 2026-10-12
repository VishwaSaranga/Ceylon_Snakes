import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 1)
class ScanHistory extends HiveObject {
  @HiveField(0)
  final String snakeName;

  @HiveField(1)
  final DateTime scanDate;

  @HiveField(2)
  final String confidenceLevel;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final double? latitude;

  @HiveField(5)
  final double? longitude;

  ScanHistory({
    required this.snakeName,
    required this.scanDate,
    required this.confidenceLevel,
    required this.imagePath,
    this.latitude,
    this.longitude,
  });
}
