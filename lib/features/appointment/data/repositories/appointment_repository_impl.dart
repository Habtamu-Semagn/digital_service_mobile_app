import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableSlots(
    String serviceId,
    DateTime date,
  ) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final slots = await remoteDataSource.getAvailableSlots(serviceId, dateStr);
      return Right(slots.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> bookAppointment(
    String serviceId,
    DateTime date,
    String timeSlot,
  ) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final appointment = await remoteDataSource.bookAppointment(
        serviceId,
        dateStr,
        timeSlot,
      );
      return Right(appointment.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getMyAppointments() async {
    try {
      final appointments = await remoteDataSource.getMyAppointments();
      return Right(appointments.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAppointment(String appointmentId) async {
    try {
      await remoteDataSource.cancelAppointment(appointmentId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
