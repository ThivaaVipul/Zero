import 'package:hive_ce/hive.dart';

part 'water_intake_model.g.dart';

@HiveType(typeId: 3)
class WaterIntake extends HiveObject {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  int amountMl;

  WaterIntake({
    required this.timestamp,
    required this.amountMl,
  });
}
