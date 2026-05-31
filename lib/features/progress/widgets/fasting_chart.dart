import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/fasting_session_model.dart';
import '../../../app/theme/app_colors.dart';

class FastingChart extends StatelessWidget {
  final List<FastingSession> history;

  const FastingChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    // Prepare data (last 7 completed sessions)
    final entries = history.where((s) => s.completed && s.endTime != null).toList().reversed.toList();
    if (entries.length > 7) entries.removeRange(0, entries.length - 7);

    if (entries.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Complete a fast to see your statistics',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    // Determine the maximum value for y-axis (minimum 24.0 hours)
    double maxHours = 24.0;
    for (final entry in entries) {
      final hours = entry.endTime!.difference(entry.startTime).inMinutes / 60.0;
      if (hours > maxHours) {
        maxHours = hours;
      }
    }

    // Add 15% headroom and round to next multiple of 4
    double maxY = (maxHours * 1.15).ceilToDouble();
    if (maxY % 4 != 0) {
      maxY = ((maxY / 4).ceil() * 4).toDouble();
    }
    
    // Interval for y-axis titles & gridlines
    final yInterval = maxY / 4;

    return Container(
      height: 185,
      padding: const EdgeInsets.fromLTRB(4, 16, 8, 0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.card.withAlpha(240),
              tooltipBorder: BorderSide(color: AppColors.primary.withAlpha(50), width: 1.5),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final session = entries[group.x.toInt()];
                final duration = session.endTime!.difference(session.startTime);
                final hours = duration.inHours;
                final minutes = duration.inMinutes.remainder(60);
                
                final isGoalMet = (duration.inMinutes / 60.0) >= session.fastingHours;
                
                return BarTooltipItem(
                  '${hours}h ${minutes}m\n',
                  const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '${session.fastingHours}h Target\n',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: isGoalMet ? '✓ Goal Achieved' : '✗ Unfinished',
                      style: TextStyle(
                        color: isGoalMet ? AppColors.accent : AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondary.withAlpha(20),
                strokeWidth: 1.2,
                dashArray: [6, 6],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    final date = entries[index].startTime;
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      '${value.toInt()}h',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (index) {
            final session = entries[index];
            final durationInHours = session.endTime!.difference(session.startTime).inMinutes / 60.0;
            final isGoalMet = durationInHours >= session.fastingHours;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: durationInHours,
                  gradient: isGoalMet
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.secondary.withAlpha(120),
                            AppColors.secondary,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.background.withAlpha(140),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
