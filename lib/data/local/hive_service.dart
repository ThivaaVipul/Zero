import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/fasting_session_model.dart';
import '../models/journal_entry_model.dart';
import '../models/water_intake_model.dart';
import '../models/weight_entry_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(FastingSessionAdapter());
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(WaterIntakeAdapter());
    Hive.registerAdapter(WeightEntryAdapter());

    // Open boxes
    await Hive.openBox<UserModel>('userBox');
    await Hive.openBox<FastingSession>('fastingSessionsBox');
    await Hive.openBox<JournalEntry>('journalEntriesBox');
    await Hive.openBox<WaterIntake>('waterIntakesBox');
    await Hive.openBox<WeightEntry>('weightEntriesBox');
    await Hive.openBox('settingsBox');
  }
}
