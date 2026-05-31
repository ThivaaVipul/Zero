import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../insights/models/insight_model.dart';
import '../models/fasting_stage.dart';

class InsightsList extends ConsumerStatefulWidget {
  final List<Insight> insights;

  const InsightsList({super.key, required this.insights});

  @override
  ConsumerState<InsightsList> createState() => _InsightsListState();
}

class _InsightsListState extends ConsumerState<InsightsList> {
  int? expandedIndex = 0;

  static final List<FastingStage> _stages = [
    const FastingStage(
      title: 'BLOOD SUGAR DROP',
      durationText: '0 – 4 Hours',
      desc: 'Your blood sugar levels start returning to normal. Insulin levels decline, signaling your cells to begin preparing for alternative metabolic fuel sources.',
      cellActivity: 'Insulin drop, glycogen mobilization',
      somaticTip: 'Sip plain water. This phase is about transitioning your mind away from constant grazing.',
      icon: Icons.water_drop_rounded,
      color: AppColors.primary,
      minHours: 0,
      maxHours: 4,
    ),
    const FastingStage(
      title: 'FAT OXIDATION',
      durationText: '4 – 12 Hours',
      desc: 'Liver glycogen stores deplete. Adipose tissue begins releasing free fatty acids to be converted into cellular energy.',
      cellActivity: 'Lipolysis mobilization, fatty acid release',
      somaticTip: 'A light walk in this phase can accelerate lipid transport and mobilize fatty acids.',
      icon: Icons.local_fire_department_rounded,
      color: Colors.orange,
      minHours: 4,
      maxHours: 12,
    ),
    const FastingStage(
      title: 'KETOSIS INCEPTION',
      durationText: '12 – 18 Hours',
      desc: 'Your liver transforms fats into ketone bodies. Ketones cross the blood-brain barrier, providing clean cerebral fuel and naturally suppressing your appetite.',
      cellActivity: 'Ketogenesis activation, appetite suppression',
      somaticTip: 'Your mental clarity is peaking here. Focus on heavy intellectual work or creative planning.',
      icon: Icons.bolt_rounded,
      color: AppColors.accent,
      minHours: 12,
      maxHours: 18,
    ),
    const FastingStage(
      title: 'CELLULAR AUTOPHAGY',
      durationText: '18 – 24+ Hours',
      desc: 'Cells trigger lysosomes to digest misfolded proteins, recycle damaged components, and clear out waste. It is your body\'s natural cellular rejuvenation program.',
      cellActivity: 'Autophagosome repair, waste recycling',
      somaticTip: 'Stay hydrated with warm green tea to assist lysosomes in cell-cleaning operations.',
      icon: Icons.health_and_safety_rounded,
      color: Colors.green,
      minHours: 18,
      maxHours: 999,
    ),
  ];

  void _showStagesInfo(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(160),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.card.withAlpha(245),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.primary.withAlpha(40),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.science_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'FASTING BIOMARKERS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your body transitions through distinct metabolic phases during a fast. By withholding food, you shift your cellular machinery from energy storage to clean fat burning and cellular recycling.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '💡 How to test this timeline:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your fasting timer on the Dashboard. As the clock runs, this screen will automatically highlight exactly which phase your body is currently experiencing in real-time!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'ACKNOWLEDGE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeFastingSessionProvider);
    final timerAsync = ref.watch(fastingTimerProvider);

    int activeStageIndex = -1;
    double elapsedHours = 0;
    final isFasting = activeSession != null;

    if (isFasting) {
      timerAsync.whenData((duration) {
        elapsedHours = duration.inSeconds / 3600.0;
        for (int i = 0; i < _stages.length; i++) {
          final stage = _stages[i];
          if (elapsedHours >= stage.minHours && elapsedHours < stage.maxHours) {
            activeStageIndex = i;
            break;
          }
        }
      });
    }

    final fastingHistory = ref.watch(fastingHistoryProvider);
    final completedFastsCount = fastingHistory.isNotEmpty
        ? fastingHistory.where((session) => session.completed).length
        : 0;
    final totalFastedHours = fastingHistory.isNotEmpty
        ? fastingHistory
            .where((session) => session.completed)
            .map((session) => session.endTime != null
                ? session.endTime!.difference(session.startTime).inHours
                : 0)
            .fold<int>(0, (total, hours) => total + hours)
        : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withAlpha(20), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL FASTED TIME',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$totalFastedHours Hours',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.primary.withAlpha(30)),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COMPLETED FASTS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedFastsCount Sessions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PHYSIOLOGICAL STAGES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _showStagesInfo(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha(15),
                ),
                child: const Icon(
                  Icons.science_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 14),
        if (!isFasting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(30), width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Start fasting on your Dashboard to trace active stages.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms)
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withAlpha(30), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.accent, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Active Fast: ${elapsedHours.toStringAsFixed(1)} hours logged today.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms),
        ...List.generate(_stages.length, (index) {
          final stage = _stages[index];
          final isCurrent = index == activeStageIndex;
          final isExpanded = expandedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => expandedIndex = isExpanded ? null : index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrent
                      ? stage.color.withAlpha(180)
                      : isExpanded
                          ? AppColors.primary.withAlpha(40)
                          : AppColors.primary.withAlpha(15),
                  width: isCurrent ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: stage.color.withAlpha(20),
                          blurRadius: 15,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: stage.color.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(stage.icon, color: stage.color, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  stage.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                    color: isCurrent ? stage.color : AppColors.textPrimary,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stage.color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: stage.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stage.durationText,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: AppColors.primary.withAlpha(20),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                stage.desc,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DetailBullet(
                                icon: Icons.biotech_rounded,
                                title: 'CELLULAR MECHANISM',
                                value: stage.cellActivity,
                                color: stage.color,
                              ),
                              const SizedBox(height: 8),
                              _DetailBullet(
                                icon: Icons.lightbulb_outline_rounded,
                                title: 'SOMATIC PRACTICE',
                                value: stage.somaticTip,
                                color: AppColors.primary,
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          )
              .animate(key: ValueKey(stage.title))
              .fadeIn(delay: (60 * index).ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
        }),
      ],
    );
  }
}

class _DetailBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailBullet({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
