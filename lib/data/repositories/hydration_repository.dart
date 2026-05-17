import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/water_intake_model.dart';

class HydrationRepository {
  final Box<WaterIntake> _box;

  HydrationRepository(this._box);

  Future<void> addWater(int amountMl) async {
    final entry = WaterIntake(
      timestamp: DateTime.now(),
      amountMl: amountMl,
    );
    await _box.add(entry);
  }

  Future<void> deleteIntake(WaterIntake intake) async {
    if (intake.isInBox) {
      await intake.delete();
    }
  }

  List<WaterIntake> getIntakeForDay(DateTime date) {
    return _box.values.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }

  int getTodayTotalMl() {
    final today = DateTime.now();
    return getIntakeForDay(today).fold(0, (sum, entry) => sum + entry.amountMl);
  }
}
