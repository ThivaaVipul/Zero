import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class MetricIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const MetricIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
