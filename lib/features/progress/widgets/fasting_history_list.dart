import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/fasting_session_model.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../utils/progress_dialogs.dart';
import 'empty_state.dart';
import 'fasting_chart.dart';

class FastingHistoryList extends ConsumerWidget {
  final List<FastingSession> history;

  const FastingHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'LAST 7 DAYS',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withAlpha(15), width: 1),
          ),
          child: FastingChart(history: history),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 32),
        const Text(
          'HISTORY RECORDS',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          const EmptyState(message: 'No fasting history yet')
        else
          ...List.generate(history.length, (index) {
            final session = history[index];
            return _buildFastingTile(context, ref, session, index);
          }),
      ],
    );
  }

  Widget _buildFastingTile(
    BuildContext context,
    WidgetRef ref,
    FastingSession session,
    int index,
  ) {
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : Duration.zero;

    final targetHours = session.fastingHours;
    final elapsedHoursDecimal = duration.inSeconds / 3600.0;
    final isGoalMet = elapsedHoursDecimal >= targetHours;
    final percentCompleted =
        (elapsedHoursDecimal / targetHours * 100).clamp(0.0, 100.0).toInt();

    String phaseLabel;
    IconData phaseIcon;
    Color phaseColor;

    if (duration.inHours < 4) {
      phaseLabel = 'SUGAR DROP';
      phaseIcon = Icons.water_drop_rounded;
      phaseColor = AppColors.primary;
    } else if (duration.inHours < 12) {
      phaseLabel = 'FAT BURN';
      phaseIcon = Icons.local_fire_department_rounded;
      phaseColor = Colors.orange;
    } else if (duration.inHours < 18) {
      phaseLabel = 'KETOSIS';
      phaseIcon = Icons.bolt_rounded;
      phaseColor = AppColors.accent;
    } else {
      phaseLabel = 'AUTOPHAGY';
      phaseIcon = Icons.health_and_safety_rounded;
      phaseColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGoalMet ? Colors.green.withAlpha(20) : AppColors.primary.withAlpha(15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isGoalMet ? Colors.green : Colors.orange.withAlpha(150),
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isGoalMet ? Colors.green : AppColors.primary).withAlpha(12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alarm_rounded,
                  color: isGoalMet ? Colors.green : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM dd • HH:mm')
                          .format(session.startTime)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${duration.inHours}h ${duration.inMinutes.remainder(60)}m Fasted',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isGoalMet
                              ? Icons.check_circle_outline_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 11,
                          color: isGoalMet ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isGoalMet
                                ? 'Target ${targetHours}h exceeded!'
                                : 'Target ${targetHours}h ($percentCompleted% complete)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isGoalMet ? Colors.green : Colors.orange,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: phaseColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: phaseColor.withAlpha(50), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(phaseIcon, color: phaseColor, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          phaseLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: phaseColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showEditFastingDialog(context, ref, session),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => confirmDelete(
                          context,
                          'Delete Fasting Session?',
                          () => ref
                              .read(activeFastingSessionProvider.notifier)
                              .deleteSession(session),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (40 * index).ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }

  Future<void> _showEditFastingDialog(
    BuildContext context,
    WidgetRef ref,
    FastingSession session,
  ) async {
    DateTime editedStart = session.startTime;
    DateTime editedEnd = session.endTime ?? DateTime.now();
    int editedTargetHours = session.fastingHours;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final duration = editedEnd.difference(editedStart);
          final isValid = editedEnd.isAfter(editedStart);

          Future<void> pickStart() async {
            final date = await showDatePicker(
              context: context,
              initialDate: editedStart,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.card,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (date == null) return;

            if (!context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(editedStart),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.card,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (time == null) return;

            setDialogState(() {
              editedStart = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }

          Future<void> pickEnd() async {
            final date = await showDatePicker(
              context: context,
              initialDate: editedEnd,
              firstDate: editedStart,
              lastDate: DateTime.now().add(const Duration(days: 1)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.card,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (date == null) return;

            if (!context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(editedEnd),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.card,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (time == null) return;

            setDialogState(() {
              editedEnd = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }

          return AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text(
              'EDIT FASTING RECORD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'START TIME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.textPrimary,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(editedStart)),
                    onPressed: pickStart,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'END TIME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.textPrimary,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      color: AppColors.error,
                      size: 18,
                    ),
                    label: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(editedEnd)),
                    onPressed: pickEnd,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TARGET PLAN HOURS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: editedTargetHours.toDouble(),
                          min: 1,
                          max: 72,
                          divisions: 71,
                          activeColor: AppColors.accent,
                          inactiveColor: AppColors.background,
                          onChanged: (val) {
                            setDialogState(() {
                              editedTargetHours = val.toInt();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 50,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${editedTargetHours}h',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isValid
                          ? AppColors.primary.withAlpha(10)
                          : AppColors.error.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isValid
                            ? AppColors.primary.withAlpha(30)
                            : AppColors.error.withAlpha(30),
                      ),
                    ),
                    child: Text(
                      isValid
                          ? 'New Duration: ${duration.inHours}h ${duration.inMinutes.remainder(60)}m logged'
                          : '⚠️ End Time must be after Start Time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isValid ? AppColors.textPrimary : AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: isValid
                    ? () async {
                        await ref.read(activeFastingSessionProvider.notifier).updateSession(
                              session,
                              startTime: editedStart,
                              endTime: editedEnd,
                              fastingHours: editedTargetHours,
                              completed: true,
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Fasting record updated'),
                              backgroundColor: AppColors.secondary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text('SAVE'),
              ),
            ],
          );
        },
      ),
    );
  }
}
