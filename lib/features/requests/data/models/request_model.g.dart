// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestModel _$RequestModelFromJson(Map<String, dynamic> json) => RequestModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      serviceNameAm: json['serviceNameAm'] as String?,
      userId: json['userId'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
      queueNumber: json['queueNumber'] as String?,
      appointmentDate: json['appointmentDate'] as String?,
      appointmentTimeSlot: json['appointmentTimeSlot'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$RequestModelToJson(RequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceNameAm': instance.serviceNameAm,
      'userId': instance.userId,
      'type': instance.type,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'completedAt': instance.completedAt,
      'queueNumber': instance.queueNumber,
      'appointmentDate': instance.appointmentDate,
      'appointmentTimeSlot': instance.appointmentTimeSlot,
      'rejectionReason': instance.rejectionReason,
    };
