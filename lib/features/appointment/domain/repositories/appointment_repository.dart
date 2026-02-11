import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<TimeSlot>>> getAvailableSlots(
    String serviceId,
    DateTime date,
  );
  Future<Either<Failure, Appointment>> bookAppointment(
    String serviceId,
    DateTime date,
    String timeSlot,
  );
  Future<Either<Failure, List<Appointment>>> getMyAppointments();
  Future<Either<Failure, void>> cancelAppointment(String appointmentId);
}
