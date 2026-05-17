import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class FastingProgressCircle extends StatelessWidget {
  final double progress;
  final Widget child;

  const FastingProgressCircle({
    super.key,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(25),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(260, 260),
          painter: _ProgressPainter(progress),
        ),
        child,
      ],
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;

  _ProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;

    final bgPaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.primary,
          AppColors.secondary,
          AppColors.primary,
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

    // Draw progress arc
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    
    // Add shadow to the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.primary.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
