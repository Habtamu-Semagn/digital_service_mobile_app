import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/request.dart';

part 'request_model.g.dart';

@JsonSerializable()
class RequestModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String? serviceNameAm;
  final String userId;
  final String type;
  final String status;
  final String createdAt;
  final String? completedAt;
  final String? queueNumber;
  final String? appointmentDate;
  final String? appointmentTimeSlot;
  final String? rejectionReason;

  RequestModel({
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
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) =>
      _$RequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RequestModelToJson(this);

  Request toEntity() {
    return Request(
      id: id,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceNameAm: serviceNameAm,
      userId: userId,
      type: type,
      status: status,
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      queueNumber: queueNumber,
      appointmentDate:
          appointmentDate != null ? DateTime.parse(appointmentDate!) : null,
      appointmentTimeSlot: appointmentTimeSlot,
      rejectionReason: rejectionReason,
    );
  }
}

class RequestsResponse {
  final bool success;
  final List<RequestModel> data;

  RequestsResponse({
    required this.success,
    required this.data,
  });

  factory RequestsResponse.fromJson(dynamic json) {
    if (json is List) {
      return RequestsResponse(
        success: true,
        data: json
            .map((e) => RequestModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      if (json.containsKey('data') && json['data'] is List) {
        return RequestsResponse(
          success: json['success'] ?? true,
          data: (json['data'] as List)
              .map((e) => RequestModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
    }
    return RequestsResponse(success: false, data: []);
  }
}
