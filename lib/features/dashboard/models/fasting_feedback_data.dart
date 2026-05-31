import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

enum FastingFeedbackTier {
  notCounted,
  earlyStop,
  partialProgress,
  goalCompleted,
}

class FastingFeedbackData {
  final FastingFeedbackTier tier;
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final String buttonText;

  const FastingFeedbackData({
    required this.tier,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.buttonText,
  });
}

FastingFeedbackData getFastingFeedbackData({
  required Duration duration,
  required int targetHours,
}) {
  final safeTargetHours = targetHours <= 0 ? 1 : targetHours;
  final elapsedSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final targetSeconds = Duration(hours: safeTargetHours).inSeconds;
  final completionRatio = targetSeconds == 0 ? 0.0 : elapsedSeconds / targetSeconds;
  final percentComplete = (completionRatio * 100).clamp(0.0, 999.0).round();
  final durationLabel = _formatDuration(Duration(seconds: elapsedSeconds));
  final phaseName = _getPhaseName(Duration(seconds: elapsedSeconds));

  if (elapsedSeconds < const Duration(minutes: 30).inSeconds) {
    return FastingFeedbackData(
      tier: FastingFeedbackTier.notCounted,
      icon: Icons.warning_amber_rounded,
      title: 'FAST TOO SHORT',
      accentColor: AppColors.error,
      buttonText: 'OK',
      description:
          'You logged $durationLabel, which is too short to meaningfully count toward a ${safeTargetHours}h fasting goal. This record was saved, and you can delete it from history if the timer was started by mistake.',
    );
  }

  if (completionRatio < 0.5) {
    return FastingFeedbackData(
      tier: FastingFeedbackTier.earlyStop,
      icon: Icons.flag_rounded,
      title: 'ENDED EARLY',
      accentColor: AppColors.error,
      buttonText: 'OK',
      description:
          'You logged $durationLabel, about $percentComplete% of your ${safeTargetHours}h goal. This fast ended early, so use it as a reset point and start again when you are ready.',
    );
  }

  if (completionRatio < 1.0) {
    return FastingFeedbackData(
      tier: FastingFeedbackTier.partialProgress,
      icon: Icons.trending_up_rounded,
      title: 'PARTIAL PROGRESS',
      accentColor: AppColors.accent,
      buttonText: 'GOT IT',
      description:
          'You logged $durationLabel, about $percentComplete% of your ${safeTargetHours}h goal. You did not complete the full target, but this still built fasting consistency.',
    );
  }

  return FastingFeedbackData(
    tier: FastingFeedbackTier.goalCompleted,
    icon: Icons.emoji_events_rounded,
    title: 'GOAL COMPLETED!',
    accentColor: AppColors.secondary,
    buttonText: 'GREAT',
    description:
        'Outstanding discipline! You planned a ${safeTargetHours}h fast and logged a total of $durationLabel. Your body achieved the "$phaseName" phase, supporting insulin depletion, fat oxidation, and healthy cellular repair.',
  );
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}

String _getPhaseName(Duration duration) {
  if (duration.inHours < 4) {
    return 'Blood Sugar Drop';
  } else if (duration.inHours < 12) {
    return 'Fat Oxidation';
  } else if (duration.inHours < 18) {
    return 'Ketosis Inception';
  }
  return 'Cellular Autophagy';
}
