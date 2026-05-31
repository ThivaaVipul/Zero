import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

Future<bool> confirmDiscardFastingSession(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Discard Fasting Session?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: const Text('This will delete the current timer and no history record will be saved.'),
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
          child: const Text('DISCARD'),
        ),
      ],
    ),
  );

  return confirmed == true;
}
