import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/fasting_session_model.dart';
import 'package:uuid/uuid.dart';

class FastingRepository {
  final Box<FastingSession> _box;
  final Uuid _uuid = const Uuid();

  FastingRepository(this._box);

  Future<void> saveSession(FastingSession session) async {
    await _box.put(session.id, session);
  }

  FastingSession? getActiveSession() {
    try {
      return _box.values.firstWhere((session) => !session.completed);
    } catch (_) {
      return null;
    }
  }

  List<FastingSession> getHistory() {
    return _box.values.where((session) => session.completed).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<FastingSession> startFasting({required int targetHours}) async {
    final active = getActiveSession();
    if (active != null) return active; // Already fasting

    final newSession = FastingSession(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      fastingHours: targetHours,
      completed: false,
    );
    await saveSession(newSession);
    return newSession;
  }

  Future<FastingSession?> endFasting() async {
    final active = getActiveSession();
    if (active == null) return null;

    active.endTime = DateTime.now();
    active.completed = true;
    await saveSession(active);
    return active;
  }

  Future<void> deleteSession(FastingSession session) async {
    if (session.isInBox) {
      await session.delete();
    }
  }
}
