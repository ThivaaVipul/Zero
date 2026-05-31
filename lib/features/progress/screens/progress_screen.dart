import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../insights/providers/insights_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../providers/weight_provider.dart';
import '../widgets/fasting_history_list.dart';
import '../widgets/insights_list.dart';
import '../widgets/journal_history_list.dart';
import '../widgets/weight_history_list.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightHistory = ref.watch(weightProvider);
    final journalHistory = ref.watch(journalHistoryProvider);
    final fastingHistory = ref.watch(fastingHistoryProvider);
    final insights = ref.watch(insightsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PROGRESS & ANALYTICS'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            isScrollable: true,
            tabs: [
              Tab(text: 'Insights'),
              Tab(text: 'Fasting'),
              Tab(text: 'Weight'),
              Tab(text: 'Journal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InsightsList(insights: insights),
            FastingHistoryList(history: fastingHistory),
            WeightHistoryList(history: weightHistory),
            JournalHistoryList(history: journalHistory),
          ],
        ),
      ),
    );
  }
}
