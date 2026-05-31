import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';

class FastingProgressCircle extends StatelessWidget {
  final double progress;
  final Widget child;
  final bool isGoalReached;

  const FastingProgressCircle({
    super.key,
    required this.progress,
    required this.child,
    this.isGoalReached = false,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = isGoalReached ? AppColors.secondary : AppColors.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing breathing background glow
        Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor.withAlpha(isGoalReached ? 35 : 20),
                blurRadius: 45,
                spreadRadius: 15,
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1.04, 1.04),
              duration: 2500.ms,
              curve: Curves.easeInOut,
            ),
        CustomPaint(
          size: const Size(260, 260),
          painter: _ProgressPainter(
            progress: progress,
            isGoalReached: isGoalReached,
          ),
        ),
        child,
      ],
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final bool isGoalReached;

  _ProgressPainter({
    required this.progress,
    required this.isGoalReached,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;

    final bgPaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final mainColor = isGoalReached ? AppColors.secondary : AppColors.primary;
    final accentColor = isGoalReached ? AppColors.accent : AppColors.secondary;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          mainColor,
          accentColor,
          mainColor,
        ],
        stops: const [0.0, 0.5, 1.0],
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawCircle(center, radius, bgPaint);

    // Draw luxury dial tick marks (24 marks representing hours of the clock)
    for (int i = 0; i < 24; i++) {
      final fraction = i / 24.0;
      final isPassed = progress > 0.0 && fraction <= progress;

      final tickPaint = Paint()
        ..color = isPassed
            ? AppColors.accent.withAlpha(200)
            : AppColors.textSecondary.withAlpha(35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isPassed ? 2.5 : 1.5
        ..strokeCap = StrokeCap.round;

      final angle = i * (2 * pi / 24) - pi / 2;
      final tickInnerRadius = radius - 24;
      final tickOuterRadius = radius - 14;

      final startX = center.dx + tickInnerRadius * cos(angle);
      final startY = center.dy + tickInnerRadius * sin(angle);
      final endX = center.dx + tickOuterRadius * cos(angle);
      final endY = center.dy + tickOuterRadius * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // Draw progress arc
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    if (progress > 0.0) {
      // Glow under progress arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = mainColor.withAlpha(100)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Sleek interactive indicator dot at the current progress tip
      final tipAngle = -pi / 2 + sweepAngle;
      final tipX = center.dx + radius * cos(tipAngle);
      final tipY = center.dy + radius * sin(tipAngle);

      // Dot backing glow shadow
      canvas.drawCircle(
        Offset(tipX, tipY),
        16,
        Paint()
          ..color = accentColor.withAlpha(160)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Dot outer bright ring
      canvas.drawCircle(
        Offset(tipX, tipY),
        9,
        Paint()..color = Colors.white,
      );

      // Dot center core
      canvas.drawCircle(
        Offset(tipX, tipY),
        5,
        Paint()..color = accentColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isGoalReached != isGoalReached;
  }
}
