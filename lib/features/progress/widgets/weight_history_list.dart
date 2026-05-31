import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/weight_entry_model.dart';
import '../providers/weight_provider.dart';
import '../utils/progress_dialogs.dart';
import 'empty_state.dart';
import 'weight_chart.dart';

class WeightHistoryList extends ConsumerWidget {
  final List<WeightEntry> history;

  const WeightHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'WEIGHT TREND',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        WeightChart(history: history)
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .scaleY(begin: 0.9, end: 1, curve: Curves.easeOutQuad),
        const SizedBox(height: 32),
        const Text(
          'HISTORY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 16),
        if (history.isEmpty)
          const EmptyState(message: 'No weight entries yet')
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
        else
          ...List.generate(
            history.length,
            (index) => _buildWeightTile(context, ref, history[index], index),
          ),
      ],
    );
  }

  Widget _buildWeightTile(
    BuildContext context,
    WidgetRef ref,
    WeightEntry entry,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withAlpha(51),
          child: const Icon(Icons.monitor_weight, color: AppColors.accent, size: 20),
        ),
        title: Text(
          '${entry.weight} kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy • HH:mm').format(entry.date),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => confirmDelete(
            context,
            'Delete Weight Entry?',
            () => ref.read(weightProvider.notifier).deleteWeight(entry),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (200 + index * 60).ms, duration: 350.ms)
        .slideX(begin: 0.12, end: 0, curve: Curves.easeOutQuad);
  }
}
