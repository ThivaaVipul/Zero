import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/fasting_session_model.dart';
import 'active_fasting_circle.dart';
import 'active_session_details.dart';
import 'fasting_plan_selector_card.dart';
import 'inactive_fasting_circle.dart';
import 'quick_action_button.dart';

class DashboardBody extends StatelessWidget {
  final FastingSession? session;
  final int selectedHours;
  final VoidCallback onStartFast;
  final ValueChanged<FastingSession> onEndFast;
  final ValueChanged<DateTime> onEditStartTime;
  final VoidCallback onSelectPlan;
  final VoidCallback onOpenHydration;
  final VoidCallback onOpenJournal;
  final VoidCallback onRecordWeight;

  const DashboardBody({
    super.key,
    required this.session,
    required this.selectedHours,
    required this.onStartFast,
    required this.onEndFast,
    required this.onEditStartTime,
    required this.onSelectPlan,
    required this.onOpenHydration,
    required this.onOpenJournal,
    required this.onRecordWeight,
  });

  @override
  Widget build(BuildContext context) {
    final activeSession = session;
    final isFasting = activeSession != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: isFasting ? const ActiveFastingCircle() : const InactiveFastingCircle(),
                ),
              ),
            ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
            if (activeSession != null) ...[
              const SizedBox(height: 16),
              ActiveSessionDetails(
                session: activeSession,
                onEditStartTime: onEditStartTime,
              ),
            ],
            if (!isFasting) ...[
              const SizedBox(height: 16),
              FastingPlanSelectorCard(
                selectedHours: selectedHours,
                onTap: onSelectPlan,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.15, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFasting ? AppColors.error : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: (isFasting ? AppColors.error : AppColors.primary).withAlpha(100),
              ),
              onPressed: () {
                if (activeSession != null) {
                  onEndFast(activeSession);
                } else {
                  onStartFast();
                }
              },
              child: Text(
                isFasting ? 'END FAST' : 'START FAST',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuickActionButton(
                  icon: Icons.water_drop_outlined,
                  label: 'Water',
                  delay: 100,
                  onTap: onOpenHydration,
                ),
                QuickActionButton(
                  icon: Icons.edit_note_outlined,
                  label: 'Journal',
                  delay: 200,
                  onTap: onOpenJournal,
                ),
                QuickActionButton(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  delay: 300,
                  onTap: onRecordWeight,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
