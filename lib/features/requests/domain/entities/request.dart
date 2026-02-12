import 'package:equatable/equatable.dart';

class Request extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final String? serviceNameAm;
  final String userId;
  final String type; // QUEUE, APPOINTMENT, ONLINE
  final String status; // PENDING, IN_PROGRESS, COMPLETED, CANCELLED, REJECTED
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? queueNumber;
  final DateTime? appointmentDate;
  final String? appointmentTimeSlot;
  final String? rejectionReason;
  final Map<String, dynamic>? data;

  const Request({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    this.serviceNameAm,
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.queueNumber,
    this.appointmentDate,
    this.appointmentTimeSlot,
    this.rejectionReason,
    this.data,
  });

  @override
  List<Object?> get props => [
        id,
        serviceId,
        serviceName,
        serviceNameAm,
        userId,
        type,
        status,
        createdAt,
        completedAt,
        queueNumber,
        appointmentDate,
        appointmentTimeSlot,
        rejectionReason,
        data,
      ];
}
