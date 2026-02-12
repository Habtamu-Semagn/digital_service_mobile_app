import '../../../../../core/network/dio_client.dart';
import '../models/queue_model.dart';

class QueueRemoteDataSource {
  final DioClient _client;

  QueueRemoteDataSource(this._client);

  Future<QueueModel> generateQueue(String serviceId) async {
    final response = await _client.post(
      '/queues',
      data: {'serviceId': serviceId},
    );
    // Backend returns unwrapped Queue object for this endpoint
    return QueueResponse.fromJson(response.data).data;
  }

  Future<QueueModel?> getActiveQueue() async {
    try {
      final response = await _client.get('/queues/active');
      if (response.data == null || response.data == '') {
        return null;
      }
      // Backend returns unwrapped Queue object for this endpoint
      return QueueResponse.fromJson(response.data).data;
    } catch (e) {
      // 404 means no active queue
      return null;
    }
  }

  Future<QueueModel> getQueueById(String queueId) async {
    final response = await _client.get('/queues/$queueId');
    final queueResponse = QueueResponse.fromJson(response.data);
    return queueResponse.data;
  }

  Future<List<QueueModel>> getQueueList(String sectorId) async {
    final response = await _client.get('/queues/list/$sectorId');
    final dynamic data = response.data;
    List<dynamic> list = [];
    
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('data') && data['data'] is List) {
      list = data['data'];
    }
    
    return list.map((json) => QueueModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<QueueModel> updateQueueStatus(String queueId, String status) async {
    final response = await _client.patch(
      '/queues/status/$queueId',
      data: {'status': status},
    );
    return QueueModel.fromJson(response.data);
  }

  Future<QueueModel> registerWalkIn(String name, String phoneNumber, String serviceId) async {
    final response = await _client.post(
      '/queues/register-walkin',
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
        'serviceId': serviceId,
      },
    );
    return QueueModel.fromJson(response.data);
  }
}
