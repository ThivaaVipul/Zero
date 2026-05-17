import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/weight_entry_model.dart';

class WeightFeedbackDialog extends StatelessWidget {
  final double newWeight;
  final WeightEntry? previousEntry;

  const WeightFeedbackDialog({
    super.key,
    required this.newWeight,
    this.previousEntry,
  });

  /// Static helper to trigger the premium feedback modal dynamically from any screen
  static Future<void> show(BuildContext context, double newWeight, WeightEntry? previousEntry) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(200), // Rich translucent backdrop
      builder: (context) => WeightFeedbackDialog(
        newWeight: newWeight,
        previousEntry: previousEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IconData feedbackIcon;
    final String feedbackTitle;
    final String feedbackDesc;
    final Color accentColor;

    if (previousEntry == null) {
      feedbackIcon = Icons.flag_rounded;
      feedbackTitle = 'JOURNEY STARTED';
      accentColor = AppColors.primary;
      feedbackDesc = 'Your first weight entry of ${newWeight.toStringAsFixed(1)} kg is successfully saved! Keep logging to uncover powerful health insights over time.';
    } else {
      final diff = newWeight - previousEntry!.weight;
      if (diff < 0) {
        feedbackIcon = Icons.trending_down_rounded;
        feedbackTitle = 'WEIGHT REDUCED';
        accentColor = AppColors.primary; // Neon blue primary
        feedbackDesc = 'You are down by ${(-diff).toStringAsFixed(1)} kg since your last log on ${DateFormat('MMM d').format(previousEntry!.date)}. Your discipline is paying off, keep pushing!';
      } else if (diff > 0) {
        feedbackIcon = Icons.fitness_center_rounded;
        feedbackTitle = 'RECORD LOGGED';
        accentColor = AppColors.accent; // Cyan accent
        feedbackDesc = 'You logged ${newWeight.toStringAsFixed(1)} kg (up by ${diff.toStringAsFixed(1)} kg since your last log). Stay focused, keep hydrated, and trust the process!';
      } else {
        feedbackIcon = Icons.balance_rounded;
        feedbackTitle = 'BALANCE MAINTAINED';
        accentColor = AppColors.primary;
        feedbackDesc = 'Perfect balance! Your weight has remained stable since your last log. Stability is a sign of steady metabolic progress.';
      }
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Premium background blur
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
                    'CONTINUE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}
