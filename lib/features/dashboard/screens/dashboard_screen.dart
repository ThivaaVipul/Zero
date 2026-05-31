import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/fasting_session_model.dart';
import '../../../data/models/weight_entry_model.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../progress/providers/weight_provider.dart';
import '../services/motivation_service.dart';
import '../utils/dashboard_time_pickers.dart';
import '../widgets/dashboard_body.dart';
import '../widgets/discard_fasting_dialog.dart';
import '../widgets/end_fasting_sheet.dart';
import '../widgets/fasting_feedback_dialog.dart';
import '../widgets/fasting_plan_selector_sheet.dart';
import '../widgets/motivation_overlay_sheet.dart';
import '../widgets/weight_entry_dialog.dart';
import '../widgets/weight_feedback_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final AppLifecycleListener _lifecycleListener;
  int _selectedHours = 16;

  @override
  void initState() {
    super.initState();

    final box = Hive.box('settingsBox');
    _selectedHours = box.get('selectedFastingHours', defaultValue: 16) as int;

    _lifecycleListener = AppLifecycleListener(
      onResume: _showMotivationOverlay,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _showMotivationOverlay();
      });
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeFastingSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ZERO',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => GoRouter.of(context).push('/progress'),
          ).animate().fadeIn(delay: 200.ms).scale(),
        ],
      ),
      body: DashboardBody(
        session: session,
        selectedHours: _selectedHours,
        onStartFast: () => ref.read(activeFastingSessionProvider.notifier).startFasting(_selectedHours),
        onEndFast: _showEndFastingBottomSheet,
        onEditStartTime: (startTime) => _adjustActiveStartTime(context, startTime),
        onSelectPlan: _showPlanSelectorBottomSheet,
        onOpenHydration: () => GoRouter.of(context).push('/hydration'),
        onOpenJournal: () => GoRouter.of(context).push('/journal'),
        onRecordWeight: () => _showWeightDialog(context, ref),
      ),
    );
  }

  void _showMotivationOverlay() {
    final session = ref.read(activeFastingSessionProvider);
    if (session == null || !mounted) return;

    final duration = DateTime.now().difference(session.startTime);
    final targetDuration = Duration(hours: session.fastingHours);
    final progress = duration.inSeconds / targetDuration.inSeconds;
    final quote = MotivationService.getRandomMessage();
    final encouragement = MotivationService.getProgressEncouragement(progress);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) => MotivationOverlaySheet(
        icon: quote.icon,
        quote: quote.text,
        author: quote.author,
        encouragement: encouragement,
      ),
    );
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref) {
    final screenContext = context;

    showDialog(
      context: screenContext,
      builder: (dialogContext) => WeightEntryDialog(
        onSave: (weight) {
          final weightHistory = ref.read(weightProvider);
          final WeightEntry? previousEntry = weightHistory.isNotEmpty ? weightHistory.first : null;

          ref.read(weightProvider.notifier).addWeight(weight);
          if (screenContext.mounted) {
            WeightFeedbackDialog.show(screenContext, weight, previousEntry);
          }
        },
      ),
    );
  }

  void _showPlanSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) => FastingPlanSelectorSheet(
        selectedHours: _selectedHours,
        onApply: (hours) async {
          setState(() {
            _selectedHours = hours;
          });
          await Hive.box('settingsBox').put('selectedFastingHours', hours);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _adjustActiveStartTime(BuildContext context, DateTime currentStart) async {
    final newStartTime = await pickActiveFastingStartTime(context, currentStart);
    if (newStartTime == null) return;

    if (newStartTime.isAfter(DateTime.now())) {
      if (context.mounted) {
        _showSnackBar('Start time cannot be in the future', AppColors.error);
      }
      return;
    }

    await ref.read(activeFastingSessionProvider.notifier).updateActiveStartTime(newStartTime);

    if (context.mounted) {
      _showSnackBar('Start time updated successfully', AppColors.secondary);
    }
  }

  void _showEndFastingBottomSheet(FastingSession session) {
    final screenContext = context;

    showModalBottomSheet(
      context: screenContext,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (sheetContext) => EndFastingSheet(
        session: session,
        onEndNow: () => _endFastingNow(sheetContext, screenContext, session),
        onEndAtTarget: () => _endFastingAtTarget(sheetContext, screenContext, session),
        onCustomEndTime: () async {
          Navigator.pop(sheetContext);
          await _selectCustomEndTime(screenContext, session);
        },
        onDiscard: () {
          Navigator.pop(sheetContext);
          _confirmDiscardSession(screenContext, session);
        },
      ),
    );
  }

  Future<void> _endFastingNow(
    BuildContext sheetContext,
    BuildContext screenContext,
    FastingSession session,
  ) async {
    final durationNow = DateTime.now().difference(session.startTime);
    await ref.read(activeFastingSessionProvider.notifier).endFasting();

    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    if (screenContext.mounted) {
      FastingFeedbackDialog.show(screenContext, durationNow, session.fastingHours);
    }
  }

  Future<void> _endFastingAtTarget(
    BuildContext sheetContext,
    BuildContext screenContext,
    FastingSession session,
  ) async {
    final targetDuration = Duration(hours: session.fastingHours);
    final targetEndTime = session.startTime.add(targetDuration);

    await ref.read(activeFastingSessionProvider.notifier).endFastingCustom(targetEndTime);

    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    if (screenContext.mounted) {
      FastingFeedbackDialog.show(screenContext, targetDuration, session.fastingHours);
    }
  }

  Future<void> _selectCustomEndTime(BuildContext screenContext, FastingSession session) async {
    final customEndTime = await pickFastingEndTime(screenContext, session);
    if (customEndTime == null) return;

    if (customEndTime.isBefore(session.startTime)) {
      if (screenContext.mounted) {
        _showSnackBar('End time cannot be before start time', AppColors.error);
      }
      return;
    }

    if (customEndTime.isAfter(DateTime.now())) {
      if (screenContext.mounted) {
        _showSnackBar('End time cannot be in the future', AppColors.error);
      }
      return;
    }

    await ref.read(activeFastingSessionProvider.notifier).endFastingCustom(customEndTime);

    if (screenContext.mounted) {
      _showSnackBar('Fasting session recorded successfully', AppColors.secondary);
      FastingFeedbackDialog.show(
        screenContext,
        customEndTime.difference(session.startTime),
        session.fastingHours,
      );
    }
  }

  Future<void> _confirmDiscardSession(BuildContext context, FastingSession session) async {
    final confirmed = await confirmDiscardFastingSession(context);

    if (confirmed) {
      await ref.read(activeFastingSessionProvider.notifier).deleteSession(session);
      if (context.mounted) {
        _showSnackBar('Fasting timer discarded', AppColors.error);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
