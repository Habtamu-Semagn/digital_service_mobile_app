import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? titleAm;
  final String message;
  final String? messageAm;
  final String type; // QUEUE_UPDATE, APPOINTMENT_REMINDER, GENERAL
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId; // Queue ID or Appointment ID

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    this.titleAm,
    required this.message,
    this.messageAm,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        titleAm,
        message,
        messageAm,
        type,
        isRead,
        createdAt,
        relatedId,
      ];
}
