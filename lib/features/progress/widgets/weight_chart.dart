import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/weight_entry_model.dart';
import '../../../app/theme/app_colors.dart';

class WeightChart extends StatelessWidget {
  final List<WeightEntry> history;

  const WeightChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Add more weight entries to see trend', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    // Prepare data (last 7 entries)
    final entries = history.reversed.toList();
    if (entries.length > 7) entries.removeRange(0, entries.length - 7);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
      child: LineChart(
        LineChartData(
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
                    final date = entries[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(entries.length, (index) => FlSpot(index.toDouble(), entries[index].weight)),
              isCurved: true,
              color: AppColors.accent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accent.withAlpha(51),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
