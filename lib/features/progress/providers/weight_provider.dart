import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../data/repositories/weight_repository.dart';
import '../../../data/models/weight_entry_model.dart';

final weightProvider = NotifierProvider<WeightNotifier, List<WeightEntry>>(() {
  return WeightNotifier();
});

class WeightNotifier extends Notifier<List<WeightEntry>> {
  late WeightRepository _repository;

  @override
  List<WeightEntry> build() {
    _repository = ref.watch(weightRepositoryProvider);
    return _repository.getWeightHistory();
  }

  Future<void> addWeight(double weight) async {
    await _repository.addWeight(weight);
    state = _repository.getWeightHistory();
  }

  Future<void> deleteWeight(WeightEntry entry) async {
    await _repository.deleteWeight(entry);
    state = _repository.getWeightHistory();
  }
}
