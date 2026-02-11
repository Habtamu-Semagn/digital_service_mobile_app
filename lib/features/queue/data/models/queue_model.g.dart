// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueModel _$QueueModelFromJson(Map<String, dynamic> json) => QueueModel(
      id: json['id'] as String,
      queueNumber: json['queueNumber'] as String,
      serviceId: json['serviceId'] as String?,
      serviceName: json['serviceName'] as String,
      serviceNameAm: json['serviceNameAm'] as String?,
      userId: json['userId'] as String?,
      status: json['status'] as String,
      position: (json['position'] as num).toInt(),
      estimatedWaitTime: json['estimatedWaitTime'] as String,
      createdAt: json['createdAt'] as String,
      calledAt: json['calledAt'] as String?,
      completedAt: json['completedAt'] as String?,
    );

Map<String, dynamic> _$QueueModelToJson(QueueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'queueNumber': instance.queueNumber,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceNameAm': instance.serviceNameAm,
      'userId': instance.userId,
      'status': instance.status,
      'position': instance.position,
      'estimatedWaitTime': instance.estimatedWaitTime,
      'createdAt': instance.createdAt,
      'calledAt': instance.calledAt,
      'completedAt': instance.completedAt,
    };
