import 'package:hive_ce/hive.dart';

part 'journal_entry_model.g.dart';

@HiveType(typeId: 2)
class JournalEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int mood;

  @HiveField(2)
  int energy;

  @HiveField(3)
  int cravings;

  @HiveField(4)
  int sleep;

  @HiveField(5)
  String notes;

  JournalEntry({
    required this.date,
    required this.mood,
    required this.energy,
    required this.cravings,
    required this.sleep,
    required this.notes,
  });
}
