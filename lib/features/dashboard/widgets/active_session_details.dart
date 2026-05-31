import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/fasting_session_model.dart';

class ActiveSessionDetails extends StatelessWidget {
  final FastingSession session;
  final ValueChanged<DateTime> onEditStartTime;

  const ActiveSessionDetails({
    super.key,
    required this.session,
    required this.onEditStartTime,
  });

  @override
  Widget build(BuildContext context) {
    final startTimeStr = DateFormat('MMM dd, hh:mm a').format(session.startTime);
    final duration = DateTime.now().difference(session.startTime);
    final hasForgotten = duration.inHours >= (session.fastingHours + 24) || duration.inHours >= 48;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline_rounded, color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              'Started: $startTimeStr',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onEditStartTime(session.startTime),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 14),
              ),
            ),
          ],
        ),
        if (hasForgotten) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withAlpha(40), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forgot to end your fast?',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This fast has run for ${duration.inHours}h. Tap "END FAST" to resolve it.',
                        style: TextStyle(
                          color: AppColors.textSecondary.withAlpha(220),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().shake(),
        ],
      ],
    );
  }
}
