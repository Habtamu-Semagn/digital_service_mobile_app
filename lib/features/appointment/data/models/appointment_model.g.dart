// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String?,
      serviceName:
          AppointmentModel._readServiceName(json, 'serviceName') as String,
      serviceNameAm:
          AppointmentModel._readServiceNameAm(json, 'serviceNameAm') as String?,
      userId: json['userId'] as String?,
      appointmentDate: json['date'] as String,
      timeSlot: json['timeSlot'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      cancellationReason: json['cancellationReason'] as String?,
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceNameAm': instance.serviceNameAm,
      'userId': instance.userId,
      'date': instance.appointmentDate,
      'timeSlot': instance.timeSlot,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'cancellationReason': instance.cancellationReason,
    };

TimeSlotModel _$TimeSlotModelFromJson(Map<String, dynamic> json) =>
    TimeSlotModel(
      slot: json['slot'] as String,
      isAvailable: json['isAvailable'] as bool,
    );

Map<String, dynamic> _$TimeSlotModelToJson(TimeSlotModel instance) =>
    <String, dynamic>{
      'slot': instance.slot,
      'isAvailable': instance.isAvailable,
    };
