import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../progress/providers/weight_provider.dart';
import '../widgets/fasting_progress_circle.dart';
import '../../../app/theme/app_colors.dart';
import '../services/motivation_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _showMotivationOverlay,
    );
    
    // Also show motivation on initial launch after a short delay for premium feel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _showMotivationOverlay();
      });
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _showMotivationOverlay() {
    // Only show if there is an active session
    final session = ref.read(activeFastingSessionProvider);
    if (session == null || !mounted) return;

    final now = DateTime.now();
    final duration = now.difference(session.startTime);
    final targetDuration = Duration(hours: session.fastingHours);
    final progress = duration.inSeconds / targetDuration.inSeconds;
    
    final quote = MotivationService.getRandomMessage();
    final encouragement = MotivationService.getProgressEncouragement(progress);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
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
                child: Icon(quote.icon, color: AppColors.primary, size: 36),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).rotate(begin: -0.1, end: 0),
              const SizedBox(height: 32),
              Text(
                quote.text,
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
                "— ${quote.author}",
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
                  child: const Text('STAY FOCUSED', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeFastingSessionProvider);
    final isFasting = session != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ZERO',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => GoRouter.of(context).push('/progress'),
          ).animate().fadeIn(delay: 200.ms).scale(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Progress Circle and Timer
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: isFasting
                        ? const _ActiveFastingCircle()
                        : const _InactiveFastingCircle(),
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
              const SizedBox(height: 60),
              // Action Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFasting ? AppColors.error : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: (isFasting ? AppColors.error : AppColors.primary).withAlpha(100),
                ),
                onPressed: () {
                  if (isFasting) {
                    ref.read(activeFastingSessionProvider.notifier).endFasting();
                  } else {
                    ref.read(activeFastingSessionProvider.notifier).startFasting(16);
                  }
                },
                child: Text(
                  isFasting ? 'END FAST' : 'START FAST',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(height: 32),
              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickAction(
                    icon: Icons.water_drop_outlined,
                    label: 'Water',
                    delay: 100,
                    onTap: () => GoRouter.of(context).push('/hydration'),
                  ),
                  _QuickAction(
                    icon: Icons.edit_note_outlined,
                    label: 'Journal',
                    delay: 200,
                    onTap: () => GoRouter.of(context).push('/journal'),
                  ),
                  _QuickAction(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight',
                    delay: 300,
                    onTap: () => _showWeightDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Record Weight', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '00.0',
            suffixText: 'kg',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null) {
                ref.read(weightProvider.notifier).addWeight(weight);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Weight recorded successfully!',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final int delay;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2, end: 0);
  }
}

class _ActiveFastingCircle extends ConsumerWidget {
  const _ActiveFastingCircle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerAsync = ref.watch(fastingTimerProvider);
    final session = ref.watch(activeFastingSessionProvider);

    return timerAsync.when(
      data: (duration) {
        final targetHours = session?.fastingHours ?? 16;
        final targetDuration = Duration(hours: targetHours);
        
        // Cap duration at target for the UI display if user wants it to "stop"
        final displayDuration = duration >= targetDuration ? targetDuration : duration;
        final isGoalReached = duration >= targetDuration;

        final progress = duration.inSeconds / targetDuration.inSeconds;

        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String hours = twoDigits(displayDuration.inHours);
        String minutes = twoDigits(displayDuration.inMinutes.remainder(60));
        String seconds = twoDigits(displayDuration.inSeconds.remainder(60));

        return FastingProgressCircle(
          progress: progress,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isGoalReached ? 'GOAL REACHED' : 'FASTING',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 3,
                  color: isGoalReached ? AppColors.secondary : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ).animate(target: isGoalReached ? 1 : 0).tint(color: AppColors.secondary).shake(),
              const SizedBox(height: 12),
              Text(
                '$hours:$minutes:$seconds',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isGoalReached ? AppColors.secondary : AppColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ).animate(target: isGoalReached ? 1 : 0).shimmer(duration: 2000.ms, color: AppColors.secondary.withAlpha(100)),
              const SizedBox(height: 12),
              Text(
                isGoalReached ? 'You did it!' : 'Goal: $targetHours hrs',
                style: TextStyle(
                  color: isGoalReached ? AppColors.secondary : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ).animate(target: isGoalReached ? 1 : 0).fadeIn(),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => const Center(child: Text('Error')),
    );
  }
}

class _InactiveFastingCircle extends StatelessWidget {
  const _InactiveFastingCircle();

  @override
  Widget build(BuildContext context) {
    return FastingProgressCircle(
      progress: 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'READY TO START?',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 2,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '00:00:00',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary.withAlpha(100),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}
