import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/hydration_provider.dart';
import '../../../app/theme/app_colors.dart';

class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTotal = ref.watch(hydrationProvider);
    final history = ref.watch(hydrationHistoryProvider);
    const target = 2000;
    final progress = (todayTotal / target).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('HYDRATION')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.water_drop, color: AppColors.secondary, size: 48).animate().scale(delay: 200.ms),
                    const SizedBox(height: 16),
                    Text(
                      '$todayTotal / $target ml',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.background,
                      color: AppColors.secondary,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ).animate().shimmer(delay: 500.ms, duration: 1500.ms),
                    const SizedBox(height: 16),
                    Text(
                      '${(progress * 100).toInt()}% of daily goal',
                      style: Theme.of(context).textTheme.labelLarge,
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const _QuickAddButton(ml: 250, icon: Icons.local_drink).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2, end: 0),
                const _QuickAddButton(ml: 500, icon: Icons.water_drop).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2, end: 0),
              ],
            ),
            const SizedBox(height: 40),
            Text('TODAY\'S LOGS', style: Theme.of(context).textTheme.titleSmall?.copyWith(letterSpacing: 1.5, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('No water logged today', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final intake = history[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.water_drop, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${intake.amountMl} ml', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(DateFormat('HH:mm').format(intake.timestamp), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                onPressed: () => _confirmDeleteHydration(context, intake, ref),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteHydration(BuildContext context, dynamic intake, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Water Log?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this water entry?'),
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
      ref.read(hydrationProvider.notifier).deleteIntake(intake);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Water entry deleted'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

class _QuickAddButton extends ConsumerWidget {
  final int ml;
  final IconData icon;

  const _QuickAddButton({required this.ml, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => ref.read(hydrationProvider.notifier).addWater(ml),
      icon: Icon(icon),
      label: Text('+$ml ml'),
    );
  }
}
