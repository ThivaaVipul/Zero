import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../progress/providers/weight_provider.dart';
import '../models/insight_model.dart';
import '../services/insight_service.dart';

final insightServiceProvider = Provider((ref) => InsightService());

final insightsProvider = Provider<List<Insight>>((ref) {
  final fastingHistory = ref.watch(fastingHistoryProvider);
  final journalHistory = ref.watch(journalHistoryProvider);
  final weightHistory = ref.watch(weightProvider);
  
  final service = ref.watch(insightServiceProvider);
  
  return service.generateInsights(
    fastingHistory: fastingHistory,
    journalHistory: journalHistory,
    weightHistory: weightHistory,
  );
});
