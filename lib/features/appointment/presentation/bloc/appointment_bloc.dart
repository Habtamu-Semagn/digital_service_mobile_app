import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository appointmentRepository;

  AppointmentBloc({required this.appointmentRepository})
      : super(AppointmentInitial()) {
    on<AppointmentLoadSlots>(_onLoadSlots);
    on<AppointmentBook>(_onBookAppointment);
    on<AppointmentLoadMy>(_onLoadMyAppointments);
    on<AppointmentCancel>(_onCancelAppointment);
  }

  Future<void> _onLoadSlots(
    AppointmentLoadSlots event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentSlotsLoading());

    final result = await appointmentRepository.getAvailableSlots(
      event.serviceId,
      event.date,
    );

    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (slots) => emit(AppointmentSlotsLoaded(slots: slots)),
    );
  }

  Future<void> _onBookAppointment(
    AppointmentBook event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentBooking());

    final result = await appointmentRepository.bookAppointment(
      event.serviceId,
      event.date,
      event.timeSlot,
    );

    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (appointment) => emit(AppointmentBooked(appointment: appointment)),
    );
  }

  Future<void> _onLoadMyAppointments(
    AppointmentLoadMy event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());

    final result = await appointmentRepository.getMyAppointments();

    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (appointments) => emit(AppointmentListLoaded(appointments: appointments)),
    );
  }

  Future<void> _onCancelAppointment(
    AppointmentCancel event,
    Emitter<AppointmentState> emit,
  ) async {
    final result = await appointmentRepository.cancelAppointment(event.appointmentId);

    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (_) {
        // Reload appointments after cancellation
        add(AppointmentLoadMy());
      },
    );
  }
}
