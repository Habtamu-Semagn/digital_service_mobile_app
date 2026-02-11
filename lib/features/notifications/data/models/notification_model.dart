import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notification.dart' as entity;

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String? userId;
  final String title;
  final String? titleAm;
  final String message;
  final String? messageAm;
  final String? type;
  final bool isRead;
  final String createdAt;
  final String? relatedId;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    this.titleAm,
    required this.message,
    this.messageAm,
    this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  entity.Notification toEntity() {
    return entity.Notification(
      id: id,
      userId: userId ?? '',
      title: title,
      titleAm: titleAm,
      message: message,
      messageAm: messageAm,
      type: type ?? 'INFO',
      isRead: isRead,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      relatedId: relatedId,
    );
  }
}

class NotificationsResponse {
  final bool success;
  final List<NotificationModel> data;
  final int unreadCount;

  NotificationsResponse({
    required this.success,
    required this.data,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(dynamic json) {
    if (json is List) {
      final notifications = json
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return NotificationsResponse(
        success: true,
        data: notifications,
        unreadCount: notifications.where((n) => !n.isRead).length,
      );
    } else if (json is Map<String, dynamic>) {
      // Handle mobile format: { success: true, data: [...], unreadCount: 5 }
      if (json.containsKey('data') && json['data'] is List) {
        final notifications = (json['data'] as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return NotificationsResponse(
          success: json['success'] ?? true,
          data: notifications,
          unreadCount: json['unreadCount'] ?? 
              notifications.where((n) => !n.isRead).length,
        );
      }
    }
    
    return NotificationsResponse(
      success: false,
      data: [],
      unreadCount: 0,
    );
  }
}
