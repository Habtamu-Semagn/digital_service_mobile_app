import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_localizations.dart';
import '../bloc/appointment_bloc.dart';

class AppointmentBookScreen extends StatefulWidget {
  final String serviceId;

  const AppointmentBookScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<AppointmentBookScreen> createState() => _AppointmentBookScreenState();
}

class _AppointmentBookScreenState extends State<AppointmentBookScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() {
    context.read<AppointmentBloc>().add(
          AppointmentLoadSlots(
            serviceId: widget.serviceId,
            date: _selectedDay,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookAppointment),
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.appointmentBooked),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/dashboard');
          } else if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calendar
                Card(
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (selectedDay.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedTimeSlot = null;
                        });
                        _loadSlots();
                      }
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selected Date
                Card(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(_selectedDay),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Slots
                Text(
                  l10n.selectTimeSlot,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (state is AppointmentSlotsLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is AppointmentSlotsLoaded)
                  _buildTimeSlots(state.slots, theme)
                else
                  const SizedBox.shrink(),

                const SizedBox(height: 24),

                // Book Button
                ElevatedButton(
                  onPressed: _selectedTimeSlot != null && state is! AppointmentBooking
                      ? _bookAppointment
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: state is AppointmentBooking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.confirmBooking),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(List<dynamic> slots, ThemeData theme) {
    if (slots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No available slots for this date',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isSelected = _selectedTimeSlot == slot.slot;
        final isAvailable = slot.isAvailable;

        return ChoiceChip(
          label: Text(slot.slot),
          selected: isSelected,
          onSelected: isAvailable
              ? (selected) {
                  setState(() {
                    _selectedTimeSlot = selected ? slot.slot : null;
                  });
                }
              : null,
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : isAvailable
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          backgroundColor: isAvailable
              ? null
              : theme.colorScheme.onSurface.withOpacity(0.05),
        );
      }).toList(),
    );
  }

  void _bookAppointment() {
    if (_selectedTimeSlot != null) {
      context.read<AppointmentBloc>().add(
            AppointmentBook(
              serviceId: widget.serviceId,
              date: _selectedDay,
              timeSlot: _selectedTimeSlot!,
            ),
          );
    }
  }
}
