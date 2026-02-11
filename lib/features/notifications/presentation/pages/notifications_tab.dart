import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_localizations.dart';
import '../bloc/notification_bloc.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(NotificationLoadAll());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(NotificationLoadAll());
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<NotificationBloc>().add(NotificationLoadAll());
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('No notifications found'),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead 
                      ? theme.disabledColor.withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      _getIcon(notification.type),
                      color: notification.isRead ? theme.disabledColor : theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.message),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().add_jm().format(notification.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!notification.isRead) {
                      context.read<NotificationBloc>().add(
                        NotificationMarkAsRead(notificationId: notification.id),
                      );
                    }
                    // TODO: Navigate to related resource if applicable
                  },
                  tileColor: notification.isRead ? null : theme.colorScheme.primary.withOpacity(0.05),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'QUEUE_ISSUED':
      case 'QUEUE_CALLED':
      case 'QUEUE_UPDATE':
        return Icons.confirmation_number_outlined;
      case 'APPOINTMENT_CONFIRMED':
      case 'APPOINTMENT_REMINDER':
        return Icons.calendar_today_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }
}
