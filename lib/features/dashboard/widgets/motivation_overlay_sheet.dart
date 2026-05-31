import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';

class MotivationOverlaySheet extends StatelessWidget {
  final IconData icon;
  final String quote;
  final String author;
  final String encouragement;

  const MotivationOverlaySheet({
    super.key,
    required this.icon,
    required this.quote,
    required this.author,
    required this.encouragement,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
        decoration: BoxDecoration(
          color: AppColors.card.withAlpha(240),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.primary.withAlpha(40), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 36),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).rotate(begin: -0.1, end: 0),
            const SizedBox(height: 32),
            Text(
              quote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Text(
              '- $author',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 40),
            const Divider(color: AppColors.background, thickness: 2),
            const SizedBox(height: 24),
            Text(
              encouragement.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 600.ms).shimmer(duration: 2000.ms),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'STAY FOCUSED',
                  style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
