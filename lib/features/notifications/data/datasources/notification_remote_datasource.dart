import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final DioClient _client;

  NotificationRemoteDataSource(this._client);

  Future<NotificationsResponse> getNotifications() async {
    final response = await _client.get('/notifications');
    return NotificationsResponse.fromJson(response.data);
  }

  Future<void> markAsRead(String notificationId) async {
    await _client.patch('/notifications/$notificationId/read');
  }
}
