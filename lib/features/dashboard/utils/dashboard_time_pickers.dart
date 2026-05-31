import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/fasting_session_model.dart';

Future<DateTime?> pickActiveFastingStartTime(
  BuildContext context,
  DateTime currentStart,
) async {
  final selectedDate = await showDatePicker(
    context: context,
    initialDate: currentStart,
    firstDate: currentStart.subtract(const Duration(days: 7)),
    lastDate: DateTime.now(),
    builder: _dateTimePickerThemeBuilder,
  );

  if (selectedDate == null || !context.mounted) return null;

  final selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(currentStart),
    builder: _dateTimePickerThemeBuilder,
  );

  if (selectedTime == null) return null;

  return DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
}

Future<DateTime?> pickFastingEndTime(
  BuildContext context,
  FastingSession session,
) async {
  final now = DateTime.now();
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (context) => _CustomEndTimeSheet(
      session: session,
      initialEndTime: now,
    ),
  );
}

class _CustomEndTimeSheet extends StatefulWidget {
  final FastingSession session;
  final DateTime initialEndTime;

  const _CustomEndTimeSheet({
    required this.session,
    required this.initialEndTime,
  });

  @override
  State<_CustomEndTimeSheet> createState() => _CustomEndTimeSheetState();
}

class _CustomEndTimeSheetState extends State<_CustomEndTimeSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  DateTime get _selectedEndTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  bool get _isBeforeStart => _selectedEndTime.isBefore(widget.session.startTime);
  bool get _isInFuture => _selectedEndTime.isAfter(DateTime.now());
  bool get _isValid => !_isBeforeStart && !_isInFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialEndTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialEndTime);
  }

  @override
  Widget build(BuildContext context) {
    final duration = _selectedEndTime.difference(widget.session.startTime);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        32,
        24,
        32 + MediaQuery.of(context).viewInsets.bottom,
      ),
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
            'CUSTOM END TIME',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Choose the exact date and time you actually ended your fast.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _PickerTile(
            icon: Icons.calendar_month_rounded,
            title: 'Date',
            value: DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          _PickerTile(
            icon: Icons.schedule_rounded,
            title: 'Time',
            value: _selectedTime.format(context),
            onTap: _pickTime,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background.withAlpha(128),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isValid ? AppColors.primary.withAlpha(20) : AppColors.error.withAlpha(60),
              ),
            ),
            child: Text(
              _statusText(duration),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isValid ? AppColors.textSecondary : AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isValid ? AppColors.primary : AppColors.textSecondary.withAlpha(80),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _isValid ? () => Navigator.pop(context, _selectedEndTime) : null,
              child: const Text(
                'SAVE END TIME',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateOnly(_selectedDate),
      firstDate: _dateOnly(widget.session.startTime),
      lastDate: _dateOnly(DateTime.now()),
      builder: _dateTimePickerThemeBuilder,
    );

    if (selectedDate == null) return;

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: _dateTimePickerThemeBuilder,
    );

    if (selectedTime == null) return;

    setState(() {
      _selectedTime = selectedTime;
    });
  }

  String _statusText(Duration duration) {
    if (_isBeforeStart) {
      return 'End time cannot be before the fast started.';
    }
    if (_isInFuture) {
      return 'End time cannot be in the future.';
    }

    return 'Duration to save: ${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withAlpha(15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

Widget _dateTimePickerThemeBuilder(BuildContext context, Widget? child) {
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
      ),
    ),
    child: child!,
  );
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
