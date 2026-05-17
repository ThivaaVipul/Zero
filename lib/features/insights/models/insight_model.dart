import 'package:flutter/material.dart';

enum InsightType { positive, warning, neutral }

class Insight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final InsightType type;

  Insight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
  });
}
