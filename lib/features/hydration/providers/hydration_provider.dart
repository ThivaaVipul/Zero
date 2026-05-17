import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/water_intake_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../data/repositories/hydration_repository.dart';

final hydrationProvider = NotifierProvider<HydrationNotifier, int>(() {
  return HydrationNotifier();
});

class HydrationNotifier extends Notifier<int> {
  late HydrationRepository _repository;

  @override
  int build() {
    _repository = ref.watch(hydrationRepositoryProvider);
    return _repository.getTodayTotalMl();
  }

  Future<void> addWater(int ml) async {
    await _repository.addWater(ml);
    state = _repository.getTodayTotalMl();
  }

  Future<void> deleteIntake(WaterIntake intake) async {
    await _repository.deleteIntake(intake);
    state = _repository.getTodayTotalMl();
  }
}

final hydrationHistoryProvider = Provider<List<WaterIntake>>((ref) {
  ref.watch(hydrationProvider);
  final repo = ref.watch(hydrationRepositoryProvider);
  return repo.getIntakeForDay(DateTime.now());
});
