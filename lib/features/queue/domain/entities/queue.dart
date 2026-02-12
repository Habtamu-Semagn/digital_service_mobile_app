import 'package:equatable/equatable.dart';

class Queue extends Equatable {
  final String id;
  final String queueNumber;
  final String serviceId;
  final String serviceName;
  final String? serviceNameAm;
  final String userId;
  final String status; // WAITING, CALLED, IN_SERVICE, COMPLETED, CANCELLED
  final int? position;
  final String? estimatedWaitTime;
  final DateTime createdAt;
  final DateTime? calledAt;
  final DateTime? completedAt;

  const Queue({
    required this.id,
    required this.queueNumber,
    required this.serviceId,
    required this.serviceName,
    this.serviceNameAm,
    required this.userId,
    required this.status,
    this.position,
    this.estimatedWaitTime,
    required this.createdAt,
    this.calledAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        queueNumber,
        serviceId,
        serviceName,
        serviceNameAm,
        userId,
        status,
        position,
        estimatedWaitTime,
        createdAt,
        calledAt,
        completedAt,
      ];
}
