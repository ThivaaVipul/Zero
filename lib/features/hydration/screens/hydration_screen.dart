import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/hydration_provider.dart';
import '../../../app/theme/app_colors.dart';

class HydrationScreen extends ConsumerStatefulWidget {
  const HydrationScreen({super.key});

  @override
  ConsumerState<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends ConsumerState<HydrationScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  bool _justAdded = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _triggerAddFeedback() {
    setState(() => _justAdded = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _justAdded = false);
    });
  }

  void _showGoalCelebrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(200), // Rich translucent backdrop
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Ultra-premium glassmorphism blur
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.card.withAlpha(240),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: AppColors.primary.withAlpha(60), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(25),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing breathing trophy achievement visualizer
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(15),
                        border: Border.all(color: AppColors.primary.withAlpha(30), width: 1.5),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scale(end: const Offset(1.12, 1.12), duration: 1200.ms, curve: Curves.easeInOut),
                    
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(25),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded, // Premium trophy icon representing milestone victory
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ).animate()
                     .scale(duration: 600.ms, curve: Curves.easeOutBack)
                     .then()
                     .shake(duration: 800.ms),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                const Text(
                  'GOAL COMPLETED!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'You have successfully achieved your daily 2000 ml hydration goal. Excellent discipline, your body is thanking you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                      'AWESOME',
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
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayTotal = ref.watch(hydrationProvider);
    final history = ref.watch(hydrationHistoryProvider);
    const target = 2000;
    final progress = (todayTotal / target).clamp(0.0, 1.0);
    final isGoalReached = todayTotal >= target;

    // Listen to changes in hydration and trigger the dialog exactly when they cross 100%
    ref.listen<int>(hydrationProvider, (previous, next) {
      if (previous != null && previous < target && next >= target) {
        _showGoalCelebrationDialog(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HYDRATION',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Unified header content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Liquid wave vessel
                    AnimatedScale(
                      scale: _justAdded ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none, // Allow concentric overflow ripples to expand beyond stack bounds
                        children: [
                          // Concentric Overflow Ripple 1 (Radiates outward from circle when goal is met)
                          if (isGoalReached)
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(80),
                                  width: 1.5,
                                ),
                              ),
                            ).animate(onPlay: (controller) => controller.repeat())
                             .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.3, 1.3), duration: 2.seconds, curve: Curves.easeOut)
                             .fadeOut(duration: 2.seconds),
                          
                          // Concentric Overflow Ripple 2 (Slower larger ripple)
                          if (isGoalReached)
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(40),
                                  width: 1.0,
                                ),
                              ),
                            ).animate(onPlay: (controller) => controller.repeat())
                             .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.6, 1.6), delay: 800.ms, duration: 2.seconds, curve: Curves.easeOut)
                             .fadeOut(duration: 2.seconds),

                          // Soft Outer Glow
                          Container(
                            width: 230,
                            height: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(20),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          // Circle Water vessel (Pure & Minimalist)
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.card,
                              border: Border.all(
                                color: AppColors.primary.withAlpha(80),
                                width: 2,
                              ),
                            ),
                            child: ClipPath(
                              clipper: _CircleClipper(),
                              child: AnimatedBuilder(
                                animation: _waveController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: _LiquidPainter(
                                      progress: progress,
                                      wavePhase: _waveController.value * 2 * pi,
                                      isGoalReached: false, // Standard waves inside
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Content inside circle (Zen Minimalist)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.water_drop,
                                color: AppColors.primary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$todayTotal',
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '/ $target ml',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // Actual Dripping Droplet Overflow Animation (Emerges from various curved rim points and falls)
                          if (isGoalReached) ...[
                            // Drop 1: Far-left curve drip (slides down from the lower left curve)
                            Positioned(
                              bottom: 30,
                              left: 15,
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: AppColors.primary,
                                size: 10,
                              ).animate(onPlay: (controller) => controller.repeat())
                               .slide(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 5.0), duration: 2200.ms, curve: Curves.easeIn)
                               .fadeOut(duration: 2200.ms),
                            ),
                            // Drop 2: Left-center curve drip
                            Positioned(
                              bottom: -8,
                              left: 65,
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: AppColors.primary,
                                size: 13,
                              ).animate(onPlay: (controller) => controller.repeat())
                               .slideY(begin: 0.0, end: 4.2, delay: 400.ms, duration: 1800.ms, curve: Curves.easeIn)
                               .fadeOut(duration: 1800.ms),
                            ),
                            // Drop 3: Center-bottom drip
                            Positioned(
                              bottom: -22,
                              left: 114,
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: AppColors.primary,
                                size: 15,
                              ).animate(onPlay: (controller) => controller.repeat())
                               .slideY(begin: 0.0, end: 3.8, delay: 1000.ms, duration: 1500.ms, curve: Curves.easeIn)
                               .fadeOut(duration: 1500.ms),
                            ),
                            // Drop 4: Right-center curve drip
                            Positioned(
                              bottom: -8,
                              right: 65,
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: AppColors.primary,
                                size: 12,
                              ).animate(onPlay: (controller) => controller.repeat())
                               .slideY(begin: 0.0, end: 4.2, delay: 700.ms, duration: 1900.ms, curve: Curves.easeIn)
                               .fadeOut(duration: 1900.ms),
                            ),
                            // Drop 5: Far-right curve drip (slides down from the lower right curve)
                            Positioned(
                              bottom: 30,
                              right: 15,
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: AppColors.primary,
                                size: 10,
                              ).animate(onPlay: (controller) => controller.repeat())
                               .slide(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 5.0), delay: 1300.ms, duration: 2100.ms, curve: Curves.easeIn)
                               .fadeOut(duration: 2100.ms),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Continuous Progress Text / Indicator (Pristine checkmark-free water drop feedback)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isGoalReached
                          ? Row(
                              key: const ValueKey('goal_achieved_indicator'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.verified_rounded, // Premium verified badge milestone indicator instead of redundant water drop
                                  color: AppColors.primary,
                                  size: 18,
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(end: const Offset(1.2, 1.2), duration: 1.seconds),
                                const SizedBox(width: 8),
                                const Text(
                                  'DAILY HYDRATION GOAL COMPLETED',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '${((todayTotal / target) * 100).toInt()}% OF DAILY TARGET REACHED',
                              key: const ValueKey('progress_active_indicator'),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            ).animate().fadeIn(),
                    ),
                    
                    const SizedBox(height: 32),

                    // Quick Add Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QuickAddButton(
                          ml: 250,
                          icon: Icons.local_drink_outlined,
                          onTap: _triggerAddFeedback,
                        ),
                        _QuickAddButton(
                          ml: 500,
                          icon: Icons.water_drop_outlined,
                          onTap: _triggerAddFeedback,
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Logs list section header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'TODAY\'S LOGS',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              letterSpacing: 2,
                              color: AppColors.textSecondary.withAlpha(150),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Logs list
            if (history.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      'No water logged today',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final intake = history[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withAlpha(20), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.water_drop, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${intake.amountMl} ml',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('hh:mm a').format(intake.timestamp),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                              onPressed: () => _confirmDeleteHydration(context, intake, ref),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                    },
                    childCount: history.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteHydration(BuildContext context, dynamic intake, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Water Log?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this water entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn(),
    );

    if (confirmed == true) {
      ref.read(hydrationProvider.notifier).deleteIntake(intake);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Water entry deleted successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final bool isGoalReached;

  _LiquidPainter({
    required this.progress,
    required this.wavePhase,
    required this.isGoalReached,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final yOffset = size.height * (1.0 - progress);

    // Primary Liquid color
    final primaryLiquidPaint = Paint()
      ..color = AppColors.primary.withAlpha(160)
      ..style = PaintingStyle.fill;

    // Background Depth Liquid color
    final depthLiquidPaint = Paint()
      ..color = AppColors.secondary.withAlpha(80)
      ..style = PaintingStyle.fill;

    // Draw background/depth wave
    final depthPath = Path();
    depthPath.moveTo(0, yOffset);
    final waveAmpMultiplier = isGoalReached ? 1.4 : 1.0;
    for (double x = 0; x <= size.width; x++) {
      final y = yOffset + cos(wavePhase + x * 0.03) * 10 * waveAmpMultiplier;
      depthPath.lineTo(x, y);
    }
    depthPath.lineTo(size.width, size.height);
    depthPath.lineTo(0, size.height);
    depthPath.close();
    canvas.drawPath(depthPath, depthLiquidPaint);

    // Draw foreground wave
    final primaryPath = Path();
    primaryPath.moveTo(0, yOffset);
    for (double x = 0; x <= size.width; x++) {
      final y = yOffset + sin(wavePhase + x * 0.035) * 12 * waveAmpMultiplier;
      primaryPath.lineTo(x, y);
    }
    primaryPath.lineTo(size.width, size.height);
    primaryPath.lineTo(0, size.height);
    primaryPath.close();
    canvas.drawPath(primaryPath, primaryLiquidPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.wavePhase != wavePhase || oldDelegate.isGoalReached != isGoalReached;
  }
}

class _QuickAddButton extends ConsumerWidget {
  final int ml;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.ml,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: AppColors.primary.withAlpha(30), width: 1.5),
          elevation: 0,
        ),
        onPressed: () {
          ref.read(hydrationProvider.notifier).addWater(ml);
          onTap();
        },
        icon: Icon(icon, size: 22),
        label: Text(
          '+$ml ML',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
