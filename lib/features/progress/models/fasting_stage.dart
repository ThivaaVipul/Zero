import 'package:flutter/material.dart';

class FastingStage {
  final String title;
  final String durationText;
  final String desc;
  final String cellActivity;
  final String somaticTip;
  final IconData icon;
  final Color color;
  final int minHours;
  final int maxHours;

  const FastingStage({
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
