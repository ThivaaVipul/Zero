import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/journal_entry_model.dart';
import '../../core/utils/date_formatter.dart';

class JournalRepository {
  final Box<JournalEntry> _box;

  JournalRepository(this._box);

  Future<void> saveEntry(JournalEntry entry) async {
    final key = DateFormatter.formatToKey(entry.date);
    await _box.put(key, entry);
  }

  Future<void> deleteEntry(JournalEntry entry) async {
    if (entry.isInBox) {
      await entry.delete();
    }
  }

  JournalEntry? getEntryForDate(DateTime date) {
    final key = DateFormatter.formatToKey(date);
    return _box.get(key);
  }

  List<JournalEntry> getHistory() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}
