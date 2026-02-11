part of 'appointment_bloc.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentSlotsLoading extends AppointmentState {}

class AppointmentBooking extends AppointmentState {}

class AppointmentSlotsLoaded extends AppointmentState {
  final List<TimeSlot> slots;

  const AppointmentSlotsLoaded({required this.slots});

  @override
  List<Object?> get props => [slots];
}

class AppointmentBooked extends AppointmentState {
  final Appointment appointment;

  const AppointmentBooked({required this.appointment});

  @override
  List<Object?> get props => [appointment];
}

class AppointmentListLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const AppointmentListLoaded({required this.appointments});

  @override
  List<Object?> get props => [appointments];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError({required this.message});

  @override
  List<Object?> get props => [message];
}
