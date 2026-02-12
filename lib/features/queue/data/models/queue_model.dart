import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/queue.dart';

part 'queue_model.g.dart';

@JsonSerializable()
class QueueModel {
  final String id;
  final String queueNumber;
  final String? serviceId;
  final String serviceName;
  final String? serviceNameAm;
  final String? userId;
  final String status;
  final int position;
  final String estimatedWaitTime;
  final String createdAt;
  final String? calledAt;
  final String? completedAt;

  QueueModel({
    required this.id,
    required this.queueNumber,
    this.serviceId,
    required this.serviceName,
    this.serviceNameAm,
    this.userId,
    required this.status,
    required this.position,
    required this.estimatedWaitTime,
    required this.createdAt,
    this.calledAt,
    this.completedAt,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    // Handle nested service name if Prisma include: { service: true } is used
    String sName = json['serviceName'] ?? '';
    if (sName.isEmpty && json['service'] != null) {
      sName = json['service']['name'] ?? '';
    }

    return QueueModel(
      id: json['id'] ?? '',
      queueNumber: (json['queueNumber'] ?? json['ticketNumber'] ?? '').toString(),
      serviceId: json['serviceId'],
      serviceName: sName,
      serviceNameAm: json['serviceNameAm'],
      userId: json['userId'],
      status: json['status'] ?? 'WAITING',
      position: json['position'] ?? json['peopleAhead'] ?? 0,
      estimatedWaitTime: json['estimatedWaitTime'] ?? 
          (json['peopleAhead'] != null ? '${(json['peopleAhead'] + 1) * 15} min' : '---'),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      calledAt: json['calledAt'],
      completedAt: json['completedAt'],
    );
  }

  Map<String, dynamic> toJson() => _$QueueModelToJson(this);

  Queue toEntity() {
    return Queue(
      id: id,
      queueNumber: queueNumber,
      serviceId: serviceId ?? '',
      serviceName: serviceName,
      serviceNameAm: serviceNameAm,
      userId: userId ?? '',
      status: status,
      position: position,
      estimatedWaitTime: estimatedWaitTime,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      calledAt: calledAt != null ? DateTime.tryParse(calledAt!) : null,
      completedAt: completedAt != null ? DateTime.tryParse(completedAt!) : null,
    );
  }
}

class QueueResponse {
  final bool success;
  final QueueModel data;

  QueueResponse({
    required this.success,
    required this.data,
  });

  factory QueueResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        return QueueResponse(
          success: json['success'] ?? true,
          data: QueueModel.fromJson(json['data'] as Map<String, dynamic>),
        );
      }
      return QueueResponse(
        success: true,
        data: QueueModel.fromJson(json),
      );
    }
    throw const FormatException('Invalid queue response format');
  }
}
