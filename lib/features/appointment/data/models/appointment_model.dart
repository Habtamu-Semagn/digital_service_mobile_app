import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/appointment.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
class AppointmentModel {
  final String id;
  final String? serviceId;
  
  @JsonKey(readValue: _readServiceName)
  final String serviceName;
  
  @JsonKey(readValue: _readServiceNameAm)
  final String? serviceNameAm;
  
  final String? userId;
  
  @JsonKey(name: 'date')
  final String appointmentDate;
  
  final String timeSlot;
  final String status;
  final String createdAt;
  final String? cancellationReason;

  AppointmentModel({
    required this.id,
    this.serviceId,
    required this.serviceName,
    this.serviceNameAm,
    this.userId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.cancellationReason,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      serviceId: json['serviceId'],
      serviceName: _readServiceName(json, 'serviceName') as String,
      serviceNameAm: _readServiceNameAm(json, 'serviceNameAm') as String?,
      userId: json['userId'],
      appointmentDate: (json['date'] ?? json['appointmentDate'] ?? DateTime.now().toIso8601String()).toString(),
      timeSlot: json['timeSlot'] ?? '---',
      status: json['status'] ?? 'SCHEDULED',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      cancellationReason: json['cancellationReason'],
    );
  }

  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  Appointment toEntity() {
    return Appointment(
      id: id,
      serviceId: serviceId ?? '',
      serviceName: serviceName,
      serviceNameAm: serviceNameAm,
      userId: userId ?? '',
      appointmentDate: DateTime.tryParse(appointmentDate) ?? DateTime.now(),
      timeSlot: timeSlot,
      status: status,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      cancellationReason: cancellationReason,
    );
  }

  static Object? _readServiceName(Map map, String key) {
    if (map.containsKey('serviceName') && map['serviceName'] != null) {
      return map['serviceName'];
    }
    final service = map['service'] as Map?;
    return service?['name'] ?? 'Unknown Service';
  }

  static Object? _readServiceNameAm(Map map, String key) {
    if (map.containsKey('serviceNameAm') && map['serviceNameAm'] != null) {
      return map['serviceNameAm'];
    }
    final service = map['service'] as Map?;
    return service?['nameAm'];
  }
}

@JsonSerializable()
class TimeSlotModel {
  final String slot;
  final bool isAvailable;

  TimeSlotModel({
    required this.slot,
    required this.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      slot: json['slot'] ?? '---',
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$TimeSlotModelToJson(this);

  TimeSlot toEntity() {
    return TimeSlot(
      slot: slot,
      isAvailable: isAvailable,
    );
  }
}

class AppointmentResponse {
  final bool success;
  final AppointmentModel data;

  AppointmentResponse({
    required this.success,
    required this.data,
  });

  factory AppointmentResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        return AppointmentResponse(
          success: json['success'] ?? true,
          data: AppointmentModel.fromJson(json['data'] as Map<String, dynamic>),
        );
      }
      return AppointmentResponse(
        success: true,
        data: AppointmentModel.fromJson(json),
      );
    }
    throw const FormatException('Invalid appointment response format');
  }
}

class TimeSlotsResponse {
  final bool success;
  final List<TimeSlotModel> data;

  TimeSlotsResponse({
    required this.success,
    required this.data,
  });

  factory TimeSlotsResponse.fromJson(dynamic json) {
    if (json is List) {
      return TimeSlotsResponse(
        success: true,
        data: json
            .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      if (json.containsKey('data') && json['data'] is List) {
        return TimeSlotsResponse(
          success: json['success'] ?? true,
          data: (json['data'] as List)
              .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
    }
    return TimeSlotsResponse(success: false, data: []);
  }
}
