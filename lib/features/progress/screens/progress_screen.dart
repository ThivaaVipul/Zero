import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/weight_provider.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../insights/providers/insights_provider.dart';
import '../widgets/weight_chart.dart';
import '../widgets/fasting_chart.dart';
import '../../../app/theme/app_colors.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightHistory = ref.watch(weightProvider);
    final journalHistory = ref.watch(journalHistoryProvider);
    final fastingHistory = ref.watch(fastingHistoryProvider);
    final insights = ref.watch(insightsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PROGRESS & ANALYTICS'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            isScrollable: true,
            tabs: [
              Tab(text: 'Insights'),
              Tab(text: 'Fasting'),
              Tab(text: 'Weight'),
              Tab(text: 'Journal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InsightsList(insights: insights),
            _FastingHistoryList(history: fastingHistory),
            _WeightHistoryList(history: weightHistory),
            _JournalHistoryList(history: journalHistory),
          ],
        ),
      ),
    );
  }
}

class _FastingStage {
  final String title;
  final String durationText;
  final String desc;
  final String cellActivity;
  final String somaticTip;
  final IconData icon;
  final Color color;
  final int minHours;
  final int maxHours;

  const _FastingStage({
    required this.title,
    required this.durationText,
    required this.desc,
    required this.cellActivity,
    required this.somaticTip,
    required this.icon,
    required this.color,
    required this.minHours,
    required this.maxHours,
  });
}

class _InsightsList extends ConsumerStatefulWidget {
  final List<dynamic> insights; // Retained for interface matching
  const _InsightsList({required this.insights});

  @override
  ConsumerState<_InsightsList> createState() => _InsightsListState();
}

class _InsightsListState extends ConsumerState<_InsightsList> {
  int? expandedIndex = 0; // Default first item expanded for quick scanning

  static final List<_FastingStage> _stages = [
    const _FastingStage(
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
    const _FastingStage(
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
    const _FastingStage(
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
    const _FastingStage(
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
              border: Border.all(color: AppColors.primary.withAlpha(40), width: 1.5),
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
    // 1. Fetch active session state safely
    final activeSession = ref.watch(activeFastingSessionProvider);
    final timerAsync = ref.watch(fastingTimerProvider);
    
    int activeStageIndex = -1;
    double elapsedHours = 0;
    bool isFasting = activeSession != null;

    if (isFasting) {
      timerAsync.whenData((duration) {
        elapsedHours = duration.inSeconds / 3600.0;
        for (int i = 0; i < _stages.length; i++) {
          final s = _stages[i];
          if (elapsedHours >= s.minHours && elapsedHours < s.maxHours) {
            activeStageIndex = i;
            break;
          }
        }
      });
    }

    // 2. Fetch history counts for sleek minimal progress stats
    final fastingHistory = ref.watch(fastingHistoryProvider);
    final completedFastsCount = fastingHistory.isNotEmpty
        ? fastingHistory.where((s) => s.completed).length
        : 0;
    final totalFastedHours = fastingHistory.isNotEmpty
        ? fastingHistory
            .where((s) => s.completed)
            .map((s) => s.endTime != null ? s.endTime!.difference(s.startTime).inHours : 0)
            .fold<int>(0, (a, b) => a + b)
        : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // A. Sleek Minimal Metrics Block
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
              // Fasting summary stat
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
              // Dynamic Somatic state helper
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

        // B. Section Header with Science Info Button
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

        // C. Live Somatic Status Alert Banner
        if (!isFasting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(30), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 12),
                const Expanded(
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

        // D. Interactive Stages List
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
                      // Stage circle icon badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: stage.color.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          stage.icon,
                          color: stage.color,
                          size: 18,
                        ),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  
                  // Expandable panel with smooth height transition
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
                              // Specific cellular details
                              _buildDetailBullet(
                                icon: Icons.biotech_rounded,
                                title: 'CELLULAR MECHANISM',
                                value: stage.cellActivity,
                                color: stage.color,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailBullet(
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
          ).animate(key: ValueKey(stage.title)).fadeIn(delay: (60 * index).ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
        }),
      ],
    );
  }

  Widget _buildDetailBullet({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FastingHistoryList extends ConsumerWidget {
  final List<dynamic> history;
  const _FastingHistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'LAST 7 DAYS',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withAlpha(15), width: 1),
          ),
          child: FastingChart(history: history.cast()),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 32),
        const Text(
          'HISTORY RECORDS',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          const _EmptyState(message: 'No fasting history yet')
        else
          ...List.generate(history.length, (index) {
            final session = history[index];
            return _buildFastingTile(context, ref, session, index);
          }),
      ],
    );
  }

  Widget _buildFastingTile(BuildContext context, WidgetRef ref, dynamic session, int index) {
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : Duration.zero;

    final targetHours = session.fastingHours ?? 16;
    final elapsedHoursDecimal = duration.inSeconds / 3600.0;
    final isGoalMet = elapsedHoursDecimal >= targetHours;
    final percentCompleted = (elapsedHoursDecimal / targetHours * 100).clamp(0.0, 100.0).toInt();

    // Calculate Somatic Phase reached based on duration
    String phaseLabel;
    IconData phaseIcon;
    Color phaseColor;

    if (duration.inHours < 4) {
      phaseLabel = 'SUGAR DROP';
      phaseIcon = Icons.water_drop_rounded;
      phaseColor = AppColors.primary;
    } else if (duration.inHours < 12) {
      phaseLabel = 'FAT BURN';
      phaseIcon = Icons.local_fire_department_rounded;
      phaseColor = Colors.orange;
    } else if (duration.inHours < 18) {
      phaseLabel = 'KETOSIS';
      phaseIcon = Icons.bolt_rounded;
      phaseColor = AppColors.accent;
    } else {
      phaseLabel = 'AUTOPHAGY';
      phaseIcon = Icons.health_and_safety_rounded;
      phaseColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGoalMet ? Colors.green.withAlpha(20) : AppColors.primary.withAlpha(15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          // Subtle left indicator border matching success status
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isGoalMet ? Colors.green : Colors.orange.withAlpha(150),
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              // Left side - clock icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isGoalMet ? Colors.green : AppColors.primary).withAlpha(12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alarm_rounded,
                  color: isGoalMet ? Colors.green : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Middle column - Date and duration details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM dd • HH:mm').format(session.startTime).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${duration.inHours}h ${duration.inMinutes.remainder(60)}m Fasted',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Goal Target feedback chip/text
                    Row(
                      children: [
                        Icon(
                          isGoalMet ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
                          size: 11,
                          color: isGoalMet ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isGoalMet 
                                ? 'Target ${targetHours}h exceeded!' 
                                : 'Target ${targetHours}h ($percentCompleted% complete)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isGoalMet ? Colors.green : Colors.orange,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right column - Somatic phase badge & delete trigger
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Somatic phase achieved badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: phaseColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: phaseColor.withAlpha(50), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(phaseIcon, color: phaseColor, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          phaseLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: phaseColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmDelete(
                      context,
                      'Delete Fasting Session?',
                      () => ref.read(activeFastingSessionProvider.notifier).deleteSession(session),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }
}

class _WeightHistoryList extends ConsumerWidget {
  final List<dynamic> history;
  const _WeightHistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('WEIGHT TREND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        WeightChart(history: history.cast()),
        const SizedBox(height: 32),
        const Text('HISTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        if (history.isEmpty) 
          const _EmptyState(message: 'No weight entries yet')
        else
          ...history.map((entry) => _buildWeightTile(context, ref, entry)),
      ],
    );
  }

  Widget _buildWeightTile(BuildContext context, WidgetRef ref, dynamic entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withAlpha(51),
          child: const Icon(Icons.monitor_weight, color: AppColors.accent, size: 20),
        ),
        title: Text('${entry.weight} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('MMM dd, yyyy • HH:mm').format(entry.date), style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => _confirmDelete(
            context, 
            'Delete Weight Entry?', 
            () => ref.read(weightProvider.notifier).deleteWeight(entry),
          ),
        ),
      ),
    );
  }
}

class _JournalHistoryList extends ConsumerWidget {
  final List<dynamic> history;
  const _JournalHistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (history.isEmpty) return const _EmptyState(message: 'No journal entries yet');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final moodEmojis = ['😫', '😕', '😐', '🙂', '🤩'];
        final moodLabels = ['Awful', 'Poor', 'Neutral', 'Good', 'Amazing'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8),
            leading: Text(moodEmojis[entry.mood - 1], style: const TextStyle(fontSize: 28)),
            title: Text(
              DateFormat('EEEE, MMM dd').format(entry.date),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(moodLabels[entry.mood - 1], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(
                    context, 
                    'Delete Journal Entry?', 
                    () => ref.read(journalProvider.notifier).deleteEntry(entry),
                  ),
                ),
                const Icon(Icons.expand_more, color: AppColors.textSecondary),
              ],
            ),
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              const Divider(color: AppColors.background, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricIcon(icon: Icons.bolt, label: 'Energy', value: '${entry.energy}/5', color: AppColors.accent),
                  _MetricIcon(icon: Icons.restaurant, label: 'Cravings', value: '${entry.cravings}/5', color: AppColors.error),
                  _MetricIcon(icon: Icons.bedtime, label: 'Sleep', value: '${entry.sleep}h', color: AppColors.secondary),
                ],
              ),
              if (entry.notes.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background.withAlpha(128),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NOTES',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.notes,
                        style: TextStyle(color: AppColors.textPrimary.withAlpha(200), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Future<void> _confirmDelete(BuildContext context, String title, VoidCallback onDelete) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: const Text('This action cannot be undone. Are you sure?'),
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
    ),
  );

  if (confirmed == true) {
    onDelete();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Deleted successfully'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

class _MetricIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricIcon({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 64, color: AppColors.card),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
