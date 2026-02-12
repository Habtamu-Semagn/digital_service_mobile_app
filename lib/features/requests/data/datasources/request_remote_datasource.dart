import '../../../../core/network/dio_client.dart';
import '../models/request_model.dart';

class RequestRemoteDataSource {
  final DioClient _client;

  RequestRemoteDataSource(this._client);

  Future<void> submitRequest({
    required String serviceId,
    required Map<String, dynamic> data,
    String? remarks,
  }) async {
    await _client.post(
      '/requests/submit',
      data: {
        'serviceId': serviceId,
        'data': data,
        'remarks': remarks,
      },
    );
  }

  Future<RequestsResponse> getMyRequests() async {
    final response = await _client.get('/requests/my-requests');
    // Handle both wrapped and direct array responses if needed,
    // but assuming standard { success, data } format from model
    return RequestsResponse.fromJson(response.data);
  }

  Future<RequestModel> getRequestById(String requestId) async {
    final response = await _client.get('/requests/$requestId');
    return RequestModel.fromJson(response.data['data']);
  }

  Future<List<RequestModel>> getSectorRequests(String sectorId) async {
    final response = await _client.get('/requests/sector/$sectorId');
    final dynamic data = response.data;
    List<dynamic> list = [];
    
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('data') && data['data'] is List) {
      list = data['data'];
    }
    
    return list.map((json) => RequestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> updateRequestStatus(String requestId, String status, String? remarks) async {
    await _client.patch(
      '/requests/status/$requestId',
      data: {
        'status': status,
        'remarks': remarks,
      },
    );
  }
}
