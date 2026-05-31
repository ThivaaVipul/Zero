import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';

class WeightEntryDialog extends StatefulWidget {
  final ValueChanged<double> onSave;

  const WeightEntryDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<WeightEntryDialog> createState() => _WeightEntryDialogState();
}

class _WeightEntryDialogState extends State<WeightEntryDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Record Weight', style: TextStyle(fontWeight: FontWeight.bold)),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: '00.0',
          suffixText: 'kg',
          border: InputBorder.none,
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final weight = double.tryParse(_controller.text);
            if (weight == null) return;

            Navigator.pop(context);
            widget.onSave(weight);
          },
          child: const Text('SAVE'),
        ),
      ],
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn();
  }
}
