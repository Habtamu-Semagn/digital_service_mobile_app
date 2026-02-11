import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final String? serviceNameAm;
  final String userId;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // PENDING, CONFIRMED, COMPLETED, CANCELLED, NO_SHOW
  final DateTime createdAt;
  final String? cancellationReason;

  const Appointment({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    this.serviceNameAm,
    required this.userId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.cancellationReason,
  });

  @override
  List<Object?> get props => [
        id,
        serviceId,
        serviceName,
        serviceNameAm,
        userId,
        appointmentDate,
        timeSlot,
        status,
        createdAt,
        cancellationReason,
      ];
}

class TimeSlot extends Equatable {
  final String slot;
  final bool isAvailable;

  const TimeSlot({
    required this.slot,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [slot, isAvailable];
}
