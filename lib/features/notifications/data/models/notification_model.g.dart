// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      title: json['title'] as String,
      titleAm: json['titleAm'] as String?,
      message: json['message'] as String,
      messageAm: json['messageAm'] as String?,
      type: json['type'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] as String,
      relatedId: json['relatedId'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'titleAm': instance.titleAm,
      'message': instance.message,
      'messageAm': instance.messageAm,
      'type': instance.type,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
      'relatedId': instance.relatedId,
    };
