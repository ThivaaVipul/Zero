import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';

class FastingPlanSelectorSheet extends StatefulWidget {
  final int selectedHours;
  final ValueChanged<int> onApply;

  const FastingPlanSelectorSheet({
    super.key,
    required this.selectedHours,
    required this.onApply,
  });

  @override
  State<FastingPlanSelectorSheet> createState() => _FastingPlanSelectorSheetState();
}

class _FastingPlanSelectorSheetState extends State<FastingPlanSelectorSheet> {
  late int _tempHours;

  @override
  void initState() {
    super.initState();
    _tempHours = widget.selectedHours;
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = ![12, 14, 16, 18, 20, 23].contains(_tempHours);
    final eatingHours = _tempHours < 24 ? 24 - _tempHours : 0;
    final estimatedEndTime = DateTime.now().add(Duration(hours: _tempHours));
    final formattedEndTime = DateFormat('EEEE, hh:mm a').format(estimatedEndTime);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.card.withAlpha(245),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.primary.withAlpha(40), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'SELECT FASTING PLAN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildPlanTile(12, 'Circadian Rhythm 12:12', 'Fasting: 12h - Eating: 12h - Balanced start'),
                  _buildPlanTile(14, 'Fat Burner 14:10', 'Fasting: 14h - Eating: 10h - Increased fat burn'),
                  _buildPlanTile(16, 'LeanGains 16:8', 'Fasting: 16h - Eating: 8h - Most popular standard'),
                  _buildPlanTile(18, 'Keto Fast 18:6', 'Fasting: 18h - Eating: 6h - Deeper cellular cleansing'),
                  _buildPlanTile(20, 'Warrior Diet 20:4', 'Fasting: 20h - Eating: 4h - Warrior diet pattern'),
                  _buildPlanTile(23, 'OMAD 23:1', 'Fasting: 23h - Eating: 1h - One meal a day expert'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.background, thickness: 1.5),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CUSTOM PLAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCustom ? AppColors.accent : AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCustom ? AppColors.accent.withAlpha(20) : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCustom ? AppColors.accent : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_tempHours}h',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCustom ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _tempHours.toDouble(),
              min: 1,
              max: 72,
              divisions: 71,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.background,
              onChanged: (val) {
                setState(() {
                  _tempHours = val.toInt();
                });
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withAlpha(128),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Fasting Duration', '$_tempHours hours'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Eating Window', _tempHours >= 24 ? 'N/A (Multi-day)' : '$eatingHours hours'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Expected End', formattedEndTime, valueColor: AppColors.secondary),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => widget.onApply(_tempHours),
                child: const Text(
                  'APPLY FASTING PLAN',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanTile(int hours, String title, String subtitle) {
    final isSelected = _tempHours == hours;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withAlpha(20) : AppColors.background.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.primary.withAlpha(10),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _tempHours = hours;
          });
        },
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withAlpha(200),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
