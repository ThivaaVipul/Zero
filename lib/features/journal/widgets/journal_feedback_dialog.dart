import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';

class JournalFeedbackDialog extends StatelessWidget {
  final int mood;
  final int energy;
  final int cravings;
  final int sleep;
  final String notes;

  const JournalFeedbackDialog({
    super.key,
    required this.mood,
    required this.energy,
    required this.cravings,
    required this.sleep,
    required this.notes,
  });

  /// Static helper to trigger the premium feedback modal dynamically from any screen
  static Future<void> show({
    required BuildContext context,
    required int mood,
    required int energy,
    required int cravings,
    required int sleep,
    required String notes,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(200), // Rich translucent backdrop
      builder: (context) => JournalFeedbackDialog(
        mood: mood,
        energy: energy,
        cravings: cravings,
        sleep: sleep,
        notes: notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IconData feedbackIcon;
    final String feedbackTitle;
    final String feedbackDesc;
    final Color accentColor;
    final String wellnessProtip;

    // 1. Determine baseline mood-based state
    if (mood >= 5) {
      feedbackIcon = Icons.wb_sunny_rounded;
      feedbackTitle = 'HIGH SPIRITS';
      accentColor = AppColors.accent; // Vibrant cyan
      feedbackDesc = 'Your emotional energy is soaring today! Keep riding this wave of positivity and let it fuel your wellness journey.';
    } else if (mood >= 4) {
      feedbackIcon = Icons.sentiment_satisfied_rounded;
      feedbackTitle = 'POSITIVE STATE';
      accentColor = AppColors.accent;
      feedbackDesc = 'You are in a wonderful, constructive state of mind. Nourish this momentum and stay conscious of your physical wins.';
    } else if (mood >= 3) {
      feedbackIcon = Icons.self_improvement_rounded;
      feedbackTitle = 'CENTERED & BALANCED';
      accentColor = AppColors.primary; // Neon blue
      feedbackDesc = 'You logged a centered state of equilibrium today. Balance is the ultimate platform for sustainable health progress.';
    } else {
      feedbackIcon = Icons.favorite_rounded;
      feedbackTitle = 'RESTORATION MODE';
      accentColor = AppColors.primary;
      feedbackDesc = 'You are weathering a heavier emotional flow. That is completely valid. Focus on warm self-care, deep hydration, and pure patience.';
    }

    // 2. Determine holistic actionable somatic tips
    if (cravings >= 4) {
      wellnessProtip = 'Somatic Insight: High cravings detected. Try sipping cold water or herbal tea; hydration naturally calms stomach receptors!';
    } else if (sleep < 6) {
      wellnessProtip = 'Somatic Insight: Sleep was low ($sleep hrs). Prioritizing 7+ hours tonight will stabilize cortisol and suppress tomorrow\'s cravings!';
    } else if (energy >= 4) {
      wellnessProtip = 'Somatic Insight: Your energy is soaring! This is a prime physiological window for a light walk to accelerate fat oxidation.';
    } else {
      wellnessProtip = 'Somatic Insight: A stable daily log reinforces consistency. You are carving out positive cellular habits day by day!';
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Ultra-premium glassmorphism blur
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.card.withAlpha(240),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: accentColor.withAlpha(60), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(25),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing breathing icon circular halo
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withAlpha(15),
                      border: Border.all(color: accentColor.withAlpha(30), width: 1.5),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(end: const Offset(1.12, 1.12), duration: 1200.ms, curve: Curves.easeInOut),
                  
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withAlpha(25),
                    ),
                    child: Icon(
                      feedbackIcon,
                      color: accentColor,
                      size: 36,
                    ),
                  ).animate()
                   .scale(duration: 600.ms, curve: Curves.easeOutBack)
                   .then()
                   .shake(duration: 800.ms),
                ],
              ),
              
              const SizedBox(height: 28),
              
              Text(
                feedbackTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                feedbackDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informative coaching card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background.withAlpha(140),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withAlpha(30), width: 1),
                ),
                child: Text(
                  wellnessProtip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary.withAlpha(220),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms).scaleY(begin: 0.9),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'COMPLETE JOURNAL',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.15, end: 0),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}
