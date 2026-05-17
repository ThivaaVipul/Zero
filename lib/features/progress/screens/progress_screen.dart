import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/weight_provider.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../insights/providers/insights_provider.dart';
import '../widgets/weight_chart.dart';
import '../widgets/fasting_chart.dart';
import '../../../app/theme/app_colors.dart';

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
            _InsightsList(insights: insights),
            _FastingHistoryList(history: fastingHistory),
            _WeightHistoryList(history: weightHistory),
            _JournalHistoryList(history: journalHistory),
          ],
        ),
      ),
    );
  }
}

class _InsightsList extends StatelessWidget {
  final List<dynamic> insights;
  const _InsightsList({required this.insights});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: insight.color.withAlpha(50), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: insight.color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(insight.icon, color: insight.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.description,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FastingHistoryList extends ConsumerWidget {
  final List<dynamic> history;
  const _FastingHistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('LAST 7 DAYS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        FastingChart(history: history.cast()),
        const SizedBox(height: 32),
        const Text('HISTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        if (history.isEmpty) 
          const _EmptyState(message: 'No fasting history yet')
        else
          ...history.map((session) => _buildFastingTile(context, ref, session)),
      ],
    );
  }

  Widget _buildFastingTile(BuildContext context, WidgetRef ref, dynamic session) {
    final duration = session.endTime != null 
        ? session.endTime!.difference(session.startTime) 
        : Duration.zero;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withAlpha(51),
          child: const Icon(Icons.timer, color: AppColors.primary, size: 20),
        ),
        title: Text('${duration.inHours}h ${duration.inMinutes.remainder(60)}m Fasted'),
        subtitle: Text(DateFormat('MMM dd, yyyy • HH:mm').format(session.startTime), style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${session.fastingHours}h',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _confirmDelete(
                context, 
                'Delete Fasting Session?', 
                () => ref.read(activeFastingSessionProvider.notifier).deleteSession(session),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightHistoryList extends ConsumerWidget {
  final List<dynamic> history;
  const _WeightHistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('WEIGHT TREND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        WeightChart(history: history.cast()),
        const SizedBox(height: 32),
        const Text('HISTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        if (history.isEmpty) 
          const _EmptyState(message: 'No weight entries yet')
        else
          ...history.map((entry) => _buildWeightTile(context, ref, entry)),
      ],
    );
  }

  Widget _buildWeightTile(BuildContext context, WidgetRef ref, dynamic entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withAlpha(51),
          child: const Icon(Icons.monitor_weight, color: AppColors.accent, size: 20),
        ),
        title: Text('${entry.weight} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('MMM dd, yyyy • HH:mm').format(entry.date), style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => _confirmDelete(
            context, 
            'Delete Weight Entry?', 
            () => ref.read(weightProvider.notifier).deleteWeight(entry),
          ),
        ),
      ),
    );
  }
}

class _JournalHistoryList extends ConsumerWidget {
  final List<dynamic> history;
  const _JournalHistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (history.isEmpty) return const _EmptyState(message: 'No journal entries yet');
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
            tilePadding: const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8),
            leading: Text(moodEmojis[entry.mood - 1], style: const TextStyle(fontSize: 28)),
            title: Text(
              DateFormat('EEEE, MMM dd').format(entry.date),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(moodLabels[entry.mood - 1], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(
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
                  _MetricIcon(icon: Icons.bolt, label: 'Energy', value: '${entry.energy}/5', color: AppColors.accent),
                  _MetricIcon(icon: Icons.restaurant, label: 'Cravings', value: '${entry.cravings}/5', color: AppColors.error),
                  _MetricIcon(icon: Icons.bedtime, label: 'Sleep', value: '${entry.sleep}h', color: AppColors.secondary),
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
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.notes,
                        style: TextStyle(color: AppColors.textPrimary.withAlpha(200), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Future<void> _confirmDelete(BuildContext context, String title, VoidCallback onDelete) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: const Text('This action cannot be undone. Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('DELETE'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    onDelete();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Deleted successfully'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

class _MetricIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricIcon({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 64, color: AppColors.card),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
