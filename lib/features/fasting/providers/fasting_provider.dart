import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/fasting_session_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../data/repositories/fasting_repository.dart';

final activeFastingSessionProvider = NotifierProvider<FastingSessionNotifier, FastingSession?>(() {
  return FastingSessionNotifier();
});

final fastingHistoryVersionProvider = NotifierProvider<FastingVersionNotifier, int>(() => FastingVersionNotifier());

class FastingVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

class FastingSessionNotifier extends Notifier<FastingSession?> {
  late FastingRepository _repository;

  @override
  FastingSession? build() {
    _repository = ref.watch(fastingRepositoryProvider);
    return _repository.getActiveSession();
  }

  Future<void> startFasting(int hours) async {
    final session = await _repository.startFasting(targetHours: hours);
    state = session;
    ref.read(fastingHistoryVersionProvider.notifier).increment();
  }

  Future<void> endFasting() async {
    await _repository.endFasting();
    state = null;
    ref.read(fastingHistoryVersionProvider.notifier).increment();
  }

  Future<void> deleteSession(FastingSession session) async {
    await _repository.deleteSession(session);
    ref.read(fastingHistoryVersionProvider.notifier).increment();
    // If it was the active session, clear state
    if (state?.id == session.id) {
      state = null;
    }
  }
}

final fastingHistoryProvider = Provider<List<FastingSession>>((ref) {
  ref.watch(fastingHistoryVersionProvider);
  final repo = ref.watch(fastingRepositoryProvider);
  return repo.getHistory();
});

final fastingTimerProvider = StreamProvider<Duration>((ref) {
  final session = ref.watch(activeFastingSessionProvider);
  if (session == null) {
    return Stream.value(Duration.zero);
  }

  // Calculate immediately before periodic stream kicks in
  final initialDuration = DateTime.now().difference(session.startTime);
  
  final streamController = StreamController<Duration>();
  streamController.add(initialDuration);
  
  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (!streamController.isClosed) {
      streamController.add(DateTime.now().difference(session.startTime));
    }
  });

  ref.onDispose(() {
    timer.cancel();
    streamController.close();
  });

  return streamController.stream;
});
