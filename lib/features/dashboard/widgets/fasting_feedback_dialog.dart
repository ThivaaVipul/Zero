import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../models/fasting_feedback_data.dart';

class FastingFeedbackDialog extends StatelessWidget {
  final Duration duration;
  final int targetHours;

  const FastingFeedbackDialog({
    super.key,
    required this.duration,
    required this.targetHours,
  });

  /// Static helper to trigger the premium feedback modal dynamically from any screen
  static Future<void> show(BuildContext context, Duration duration, int targetHours) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(200), // Rich translucent backdrop
      builder: (context) => FastingFeedbackDialog(
        duration: duration,
        targetHours: targetHours,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedback = getFastingFeedbackData(
      duration: duration,
      targetHours: targetHours,
    );

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
            border: Border.all(color: feedback.accentColor.withAlpha(60), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: feedback.accentColor.withAlpha(25),
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
                      color: feedback.accentColor.withAlpha(15),
                      border: Border.all(color: feedback.accentColor.withAlpha(30), width: 1.5),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(end: const Offset(1.12, 1.12), duration: 1200.ms, curve: Curves.easeInOut),
                  
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: feedback.accentColor.withAlpha(25),
                    ),
                    child: Icon(
                      feedback.icon,
                      color: feedback.accentColor,
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
                feedback.title,
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
                feedback.description,
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
                    backgroundColor: feedback.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    feedback.buttonText,
                    style: const TextStyle(
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
