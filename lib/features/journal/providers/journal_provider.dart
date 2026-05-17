import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../../data/models/journal_entry_model.dart';

final journalProvider = NotifierProvider<JournalNotifier, JournalEntry?>(() {
  return JournalNotifier();
});

class JournalNotifier extends Notifier<JournalEntry?> {
  late JournalRepository _repository;

  @override
  JournalEntry? build() {
    _repository = ref.watch(journalRepositoryProvider);
    return _repository.getEntryForDate(DateTime.now());
  }

  Future<void> saveEntry({
    required int mood,
    required int energy,
    required int cravings,
    required int sleep,
    required String notes,
  }) async {
    final entry = JournalEntry(
      date: DateTime.now(),
      mood: mood,
      energy: energy,
      cravings: cravings,
      sleep: sleep,
      notes: notes,
    );
    await _repository.saveEntry(entry);
    state = entry;
  }

  Future<void> deleteEntry(JournalEntry entry) async {
    await _repository.deleteEntry(entry);
    final today = DateTime.now();
    if (entry.date.year == today.year &&
        entry.date.month == today.month &&
        entry.date.day == today.day) {
      state = null;
    }
  }
}

final journalHistoryProvider = Provider<List<JournalEntry>>((ref) {
  ref.watch(journalProvider);
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getHistory();
});
