import 'package:flutter/material.dart';
import '../../../data/models/fasting_session_model.dart';
import '../../../data/models/journal_entry_model.dart';
import '../../../data/models/weight_entry_model.dart';
import '../models/insight_model.dart';
import '../../../app/theme/app_colors.dart';

class InsightService {
  List<Insight> generateInsights({
    required List<FastingSession> fastingHistory,
    required List<JournalEntry> journalHistory,
    required List<WeightEntry> weightHistory,
  }) {
    final insights = <Insight>[];

    // 1. Fasting Streak
    final streak = _calculateStreak(fastingHistory);
    if (streak >= 3) {
      insights.add(Insight(
        title: '$streak Day Streak!',
        description: 'You are on fire! Keep up the consistency for better metabolic health.',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        type: InsightType.positive,
      ));
    }

    // 2. Sleep & Fasting Correlation
    final sleepEffect = _analyzeSleepEffect(fastingHistory, journalHistory);
    if (sleepEffect != null) {
      insights.add(Insight(
        title: 'Sleep Connection',
        description: sleepEffect,
        icon: Icons.bedtime,
        color: AppColors.secondary,
        type: InsightType.neutral,
      ));
    }

    // 3. Weight Trend
    if (weightHistory.length >= 2) {
      final trend = weightHistory.first.weight - weightHistory.last.weight;
      if (trend < 0) {
        insights.add(Insight(
          title: 'Weight Trending Down',
          description: 'You\'ve lost ${(trend.abs()).toStringAsFixed(1)}kg since you started tracking. Great progress!',
          icon: Icons.trending_down,
          color: AppColors.primary,
          type: InsightType.positive,
        ));
      }
    }

    // 4. Mood Correlation
    final moodInsight = _analyzeMoodCorrelation(fastingHistory, journalHistory);
    if (moodInsight != null) {
      insights.add(Insight(
        title: 'Mood & Fasting',
        description: moodInsight,
        icon: Icons.wb_sunny,
        color: AppColors.accent,
        type: InsightType.positive,
      ));
    }

    // Default if empty
    if (insights.isEmpty) {
      insights.add(Insight(
        title: 'Collect More Data',
        description: 'Keep logging your fasts and mood to unlock personalized insights.',
        icon: Icons.insights,
        color: AppColors.textSecondary,
        type: InsightType.neutral,
      ));
    }

    return insights;
  }

  int _calculateStreak(List<FastingSession> history) {
    if (history.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Simplistic streak: how many consecutive days have a completed session
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final hasSession = history.any((s) => 
        s.completed && 
        s.startTime.year == date.year && 
        s.startTime.month == date.month && 
        s.startTime.day == date.day
      );
      if (hasSession) {
        streak++;
      } else if (i > 0) {
        // If it's not today and no session, streak ends
        break;
      }
    }
    return streak;
  }

  String? _analyzeSleepEffect(List<FastingSession> fasts, List<JournalEntry> journals) {
    if (fasts.isEmpty || journals.isEmpty) return null;
    
    double avgFastOnGoodSleep = 0;
    int goodSleepCount = 0;
    double avgFastOnPoorSleep = 0;
    int poorSleepCount = 0;

    for (var journal in journals) {
      final fastOnThatDay = fasts.where((f) => 
        f.startTime.year == journal.date.year &&
        f.startTime.month == journal.date.month &&
        f.startTime.day == journal.date.day
      ).toList();

      if (fastOnThatDay.isNotEmpty) {
        final duration = fastOnThatDay.first.endTime?.difference(fastOnThatDay.first.startTime).inHours ?? 0;
        if (journal.sleep >= 7) {
          avgFastOnGoodSleep += duration;
          goodSleepCount++;
        } else {
          avgFastOnPoorSleep += duration;
          poorSleepCount++;
        }
      }
    }

    if (goodSleepCount > 0 && poorSleepCount > 0) {
      final goodAvg = avgFastOnGoodSleep / goodSleepCount;
      final poorAvg = avgFastOnPoorSleep / poorSleepCount;
      if (goodAvg > poorAvg + 1) {
        return 'You fast about ${(goodAvg - poorAvg).toStringAsFixed(1)} hours longer on days after getting 7+ hours of sleep.';
      }
    }
    return null;
  }

  String? _analyzeMoodCorrelation(List<FastingSession> fasts, List<JournalEntry> journals) {
    // Similar logic for mood...
    return null; // For brevity in initial implementation
  }
}
