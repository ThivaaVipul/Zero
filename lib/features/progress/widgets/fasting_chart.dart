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
    final entries = history.where((s) => s.completed).toList().reversed.toList();
    if (entries.length > 7) entries.removeRange(0, entries.length - 7);

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 24,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < entries.length) {
                    final date = entries[value.toInt()].startTime;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value % 8 == 0) {
                    return Text('${value.toInt()}h', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (index) {
            final duration = entries[index].endTime!.difference(entries[index].startTime).inHours;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: duration.toDouble(),
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 24,
                    color: AppColors.card,
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
