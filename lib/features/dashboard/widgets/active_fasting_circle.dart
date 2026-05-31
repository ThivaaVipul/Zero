import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/providers/fasting_provider.dart';
import 'fasting_progress_circle.dart';

class ActiveFastingCircle extends ConsumerWidget {
  const ActiveFastingCircle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerAsync = ref.watch(fastingTimerProvider);
    final session = ref.watch(activeFastingSessionProvider);

    return timerAsync.when(
      data: (duration) {
        final targetHours = session?.fastingHours ?? 16;
        final targetDuration = Duration(hours: targetHours);
        final isGoalReached = duration >= targetDuration;
        final progress = duration.inSeconds / targetDuration.inSeconds;

        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final hours = twoDigits(duration.inHours);
        final minutes = twoDigits(duration.inMinutes.remainder(60));
        final seconds = twoDigits(duration.inSeconds.remainder(60));

        final subText = isGoalReached
            ? 'Goal Reached • +${twoDigits((duration - targetDuration).inHours)}h ${twoDigits((duration - targetDuration).inMinutes.remainder(60))}m'
            : 'Goal: $targetHours hrs • ${twoDigits((targetDuration - duration).inHours)}h ${twoDigits((targetDuration - duration).inMinutes.remainder(60))}m left';

        return FastingProgressCircle(
          progress: progress,
          isGoalReached: isGoalReached,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isGoalReached ? 'GOAL REACHED' : 'FASTING',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 3,
                      color: isGoalReached ? AppColors.accent : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate(target: isGoalReached ? 1 : 0).tint(color: AppColors.accent).shake(),
              const SizedBox(height: 12),
              Text(
                '$hours:$minutes:$seconds',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isGoalReached ? AppColors.accent : AppColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ).animate(target: isGoalReached ? 1 : 0).shimmer(
                    duration: 2000.ms,
                    color: AppColors.primary.withAlpha(100),
                  ),
              const SizedBox(height: 12),
              Text(
                subText,
                style: TextStyle(
                  color: isGoalReached ? AppColors.accent : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ).animate(target: isGoalReached ? 1 : 0).fadeIn(),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => const Center(child: Text('Error')),
    );
  }
}
