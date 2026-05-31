import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class FastingPlanSelectorCard extends StatelessWidget {
  final int selectedHours;
  final VoidCallback onTap;

  const FastingPlanSelectorCard({
    super.key,
    required this.selectedHours,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final planName = getFastingPlanName(selectedHours);
    final eatingHours = selectedHours < 24 ? 24 - selectedHours : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(30), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FASTING PLAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    planName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedHours >= 24
                        ? 'Extended Fast: ${selectedHours}h'
                        : 'Fast: ${selectedHours}h - Eat: ${eatingHours}h',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

String getFastingPlanName(int hours) {
  switch (hours) {
    case 12:
      return 'Circadian Rhythm 12:12';
    case 14:
      return 'Fat Burner 14:10';
    case 16:
      return 'LeanGains 16:8';
    case 18:
      return 'Keto Fast 18:6';
    case 20:
      return 'Warrior Diet 20:4';
    case 23:
      return 'OMAD 23:1';
    default:
      return 'Custom Fast ${hours}h';
  }
}
