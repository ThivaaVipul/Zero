import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../data/models/fasting_session_model.dart';
import '../../data/models/journal_entry_model.dart';
import '../../data/models/water_intake_model.dart';
import '../../data/models/weight_entry_model.dart';
import '../../data/repositories/fasting_repository.dart';
import '../../data/repositories/hydration_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/weight_repository.dart';

final fastingRepositoryProvider = Provider<FastingRepository>((ref) {
  final box = Hive.box<FastingSession>('fastingSessionsBox');
  return FastingRepository(box);
});

final hydrationRepositoryProvider = Provider<HydrationRepository>((ref) {
  final box = Hive.box<WaterIntake>('waterIntakesBox');
  return HydrationRepository(box);
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final box = Hive.box<JournalEntry>('journalEntriesBox');
  return JournalRepository(box);
});

final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  final box = Hive.box<WeightEntry>('weightEntriesBox');
  return WeightRepository(box);
});
