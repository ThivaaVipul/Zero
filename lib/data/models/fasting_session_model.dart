import 'package:hive_ce/hive.dart';

part 'fasting_session_model.g.dart';

@HiveType(typeId: 1)
class FastingSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  int fastingHours;

  @HiveField(4)
  bool completed;

  FastingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.fastingHours,
    required this.completed,
  });
}
