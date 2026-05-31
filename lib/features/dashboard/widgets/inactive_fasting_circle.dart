import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import 'fasting_progress_circle.dart';

class InactiveFastingCircle extends StatelessWidget {
  const InactiveFastingCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return FastingProgressCircle(
      progress: 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'READY TO START?',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '00:00:00',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary.withAlpha(80),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .shimmer(duration: 3.seconds, color: AppColors.primary.withAlpha(40)),
        ],
      ),
    );
  }
}
