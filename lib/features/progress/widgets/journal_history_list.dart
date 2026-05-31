import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/journal_entry_model.dart';
import '../../journal/providers/journal_provider.dart';
import '../utils/progress_dialogs.dart';
import 'empty_state.dart';
import 'metric_icon.dart';

class JournalHistoryList extends ConsumerWidget {
  final List<JournalEntry> history;

  const JournalHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (history.isEmpty) {
      return const EmptyState(message: 'No journal entries yet')
          .animate()
          .fadeIn(duration: 400.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final moodEmojis = ['😫', '😕', '😐', '🙂', '🤩'];
        final moodLabels = ['Awful', 'Poor', 'Neutral', 'Good', 'Amazing'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.only(
              left: 20,
              right: 8,
              top: 8,
              bottom: 8,
            ),
            leading: Text(
              moodEmojis[entry.mood - 1],
              style: const TextStyle(fontSize: 28),
            ),
            title: Text(
              DateFormat('EEEE, MMM dd').format(entry.date),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              moodLabels[entry.mood - 1],
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () => confirmDelete(
                    context,
                    'Delete Journal Entry?',
                    () => ref.read(journalProvider.notifier).deleteEntry(entry),
                  ),
                ),
                const Icon(Icons.expand_more, color: AppColors.textSecondary),
              ],
            ),
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              const Divider(color: AppColors.background, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MetricIcon(
                    icon: Icons.bolt,
                    label: 'Energy',
                    value: '${entry.energy}/5',
                    color: AppColors.accent,
                  ),
                  MetricIcon(
                    icon: Icons.restaurant,
                    label: 'Cravings',
                    value: '${entry.cravings}/5',
                    color: AppColors.error,
                  ),
                  MetricIcon(
                    icon: Icons.bedtime,
                    label: 'Sleep',
                    value: '${entry.sleep}h',
                    color: AppColors.secondary,
                  ),
                ],
              ),
              if (entry.notes.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background.withAlpha(128),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NOTES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.notes,
                        style: TextStyle(
                          color: AppColors.textPrimary.withAlpha(200),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (index * 60).ms, duration: 350.ms)
            .slideX(begin: 0.12, end: 0, curve: Curves.easeOutQuad);
      },
    );
  }
}
