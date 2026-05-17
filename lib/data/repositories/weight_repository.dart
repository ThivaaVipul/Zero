import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/weight_entry_model.dart';

class WeightRepository {
  final Box<WeightEntry> _box;

  WeightRepository(this._box);

  Future<void> addWeight(double weight) async {
    final entry = WeightEntry(date: DateTime.now(), weight: weight);
    await _box.add(entry);
  }

  Future<void> deleteWeight(WeightEntry entry) async {
    if (entry.isInBox) {
      await entry.delete();
    }
  }

  List<WeightEntry> getWeightHistory() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  WeightEntry? getLatestWeight() {
    final history = getWeightHistory();
    return history.isNotEmpty ? history.first : null;
  }
}
