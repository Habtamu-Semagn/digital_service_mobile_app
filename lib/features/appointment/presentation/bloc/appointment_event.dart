part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class AppointmentLoadSlots extends AppointmentEvent {
  final String serviceId;
  final DateTime date;

  const AppointmentLoadSlots({
    required this.serviceId,
    required this.date,
  });

  @override
  List<Object?> get props => [serviceId, date];
}

class AppointmentBook extends AppointmentEvent {
  final String serviceId;
  final DateTime date;
  final String timeSlot;

  const AppointmentBook({
    required this.serviceId,
    required this.date,
    required this.timeSlot,
  });

  @override
  List<Object?> get props => [serviceId, date, timeSlot];
}

class AppointmentLoadMy extends AppointmentEvent {}

class AppointmentCancel extends AppointmentEvent {
  final String appointmentId;

  const AppointmentCancel({required this.appointmentId});

  @override
  List<Object?> get props => [appointmentId];
}
