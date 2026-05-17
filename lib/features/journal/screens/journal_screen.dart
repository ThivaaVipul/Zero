// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/journal_provider.dart';
import '../widgets/journal_feedback_dialog.dart';
import '../../../app/theme/app_colors.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  int mood = 3;
  int energy = 3;
  int cravings = 1;
  int sleep = 7;
  final notesController = TextEditingController();

  final List<String> moodEmojis = ['😫', '😕', '😐', '🙂', '🤩'];
  final List<String> moodLabels = ['Awful', 'Poor', 'Neutral', 'Good', 'Amazing'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DAILY JOURNAL')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            // Emoji Mood Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(moodEmojis.length, (index) {
                final isSelected = mood == index + 1;
                return GestureDetector(
                  onTap: () => setState(() => mood = index + 1),
                  child: Column(
                    children: [
                      Text(
                        moodEmojis[index],
                        style: TextStyle(fontSize: isSelected ? 44 : 32),
                      ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                      const SizedBox(height: 8),
                      Text(
                        moodLabels[index],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).scale(begin: const Offset(0.8, 0.8));
              }),
            ),
            const SizedBox(height: 40),
            _buildGradientSlider('Energy Level', energy, 1, 5, AppColors.accent, (val) => setState(() => energy = val.toInt()))
                .animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
            _buildGradientSlider('Cravings', cravings, 1, 5, AppColors.error, (val) => setState(() => cravings = val.toInt()))
                .animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
            _buildGradientSlider('Sleep (Hours)', sleep, 1, 12, AppColors.secondary, (val) => setState(() => sleep = val.toInt()))
                .animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            Text('Journal Notes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Describe your fasting experience today...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () => _handleSave(),
                child: const Text('SAVE JOURNAL ENTRY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    await ref.read(journalProvider.notifier).saveEntry(
      mood: mood,
      energy: energy,
      cravings: cravings,
      sleep: sleep,
      notes: notesController.text,
    );
    
    if (!mounted) return;
    
    final parentNavigator = Navigator.of(context);
    final parentContext = parentNavigator.context;
    
    parentNavigator.pop(); // Pop the Journal input screen/sheet
    
    JournalFeedbackDialog.show(
      context: parentContext,
      mood: mood,
      energy: energy,
      cravings: cravings,
      sleep: sleep,
      notes: notesController.text,
    );
  }

  Widget _buildGradientSlider(String label, int value, int min, int max, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: AppColors.card,
            thumbColor: color,
            overlayColor: color.withAlpha(51),
            trackHeight: 8,
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
