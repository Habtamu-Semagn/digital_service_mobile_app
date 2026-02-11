import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification.dart' as entity;
import '../../domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<NotificationLoadAll>(_onLoadAll);
    on<NotificationMarkAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadAll(
    NotificationLoadAll event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final notificationsResult = await notificationRepository.getNotifications();
    
    notificationsResult.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    
    // Optimistically update UI if in Loaded state
    if (currentState is NotificationLoaded) {
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.notificationId) {
          return entity.Notification(
            id: n.id,
            userId: n.userId,
            title: n.title,
            titleAm: n.titleAm,
            message: n.message,
            messageAm: n.messageAm,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
            relatedId: n.relatedId,
          );
        }
        return n;
      }).toList();
      
      final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;
      emit(NotificationLoaded(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    }

    // Call repository
    await notificationRepository.markAsRead(event.notificationId);
    
    // We don't necessarily need to reload everything if optimistic update worked,
    // but a real implementation might check result.
  }
}
