import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/fasting_session_model.dart';

class EndFastingSheet extends StatelessWidget {
  final FastingSession session;
  final VoidCallback onEndNow;
  final VoidCallback onEndAtTarget;
  final VoidCallback onCustomEndTime;
  final VoidCallback onDiscard;

  const EndFastingSheet({
    super.key,
    required this.session,
    required this.onEndNow,
    required this.onEndAtTarget,
    required this.onCustomEndTime,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final targetDuration = Duration(hours: session.fastingHours);
    final targetEndTime = session.startTime.add(targetDuration);
    final now = DateTime.now();
    final durationNow = now.difference(session.startTime);
    final targetPassed = now.isAfter(targetEndTime);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.card.withAlpha(245),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.primary.withAlpha(40), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'END FASTING SESSION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Select how you would like to record this session.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ResolutionTile(
              icon: Icons.timer_rounded,
              color: AppColors.primary,
              title: 'End Now',
              subtitle:
                  'Log end time as ${DateFormat('hh:mm a').format(now)} (Duration: ${durationNow.inHours}h ${durationNow.inMinutes.remainder(60)}m)',
              onTap: onEndNow,
            ),
            if (targetPassed)
              ResolutionTile(
                icon: Icons.check_circle_rounded,
                color: AppColors.secondary,
                title: 'End at Scheduled Target',
                subtitle:
                    'Log end time as exactly ${DateFormat('MMM dd, hh:mm a').format(targetEndTime)} (Duration: ${session.fastingHours}h)',
                onTap: onEndAtTarget,
              ),
            ResolutionTile(
              icon: Icons.edit_calendar_rounded,
              color: AppColors.accent,
              title: 'End at Custom Time...',
              subtitle: 'Specify a custom date and time when you actually finished your fast.',
              onTap: onCustomEndTime,
            ),
            ResolutionTile(
              icon: Icons.delete_forever_rounded,
              color: AppColors.error,
              title: 'Discard Fasting Session',
              subtitle: 'Completely delete this active timer without saving a log record.',
              onTap: onDiscard,
            ),
          ],
        ),
      ),
    );
  }
}

class ResolutionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ResolutionTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(15), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
          ),
        ),
      ),
    );
  }
}
