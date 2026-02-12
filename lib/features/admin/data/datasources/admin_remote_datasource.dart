import '../../../../../core/network/dio_client.dart';
import '../models/admin_stats_model.dart';
import '../models/system_log_model.dart';
import '../../../auth/data/models/user_model.dart';

class AdminRemoteDataSource {
  final DioClient _client;

  AdminRemoteDataSource(this._client);

  Future<AdminStats> getStats() async {
    final response = await _client.get('/admin/stats');
    return AdminStats.fromJson(response.data);
  }

  Future<List<UserModel>> getUsers() async {
    final response = await _client.get('/admin/users');
    final List<dynamic> data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<List<SystemLog>> getLogs() async {
    final response = await _client.get('/admin/logs');
    final List<dynamic> data = response.data;
    return data.map((json) => SystemLog.fromJson(json)).toList();
  }

  Future<List<dynamic>> getSectors() async {
    final response = await _client.get('/services/sectors');
    return response.data;
  }

  // Sector Management
  Future<void> createSector(Map<String, dynamic> sectorData) async {
    await _client.post('/services/sectors', data: sectorData);
  }

  Future<void> updateSector(String id, Map<String, dynamic> sectorData) async {
    await _client.patch('/services/sectors/$id', data: sectorData);
  }

  Future<void> deleteSector(String id) async {
    await _client.delete('/services/sectors/$id');
  }

  // Service Management
  Future<void> createService(Map<String, dynamic> serviceData) async {
    await _client.post('/services/services', data: serviceData);
  }

  Future<void> updateService(String id, Map<String, dynamic> serviceData) async {
    await _client.patch('/services/services/$id', data: serviceData);
  }

  Future<void> deleteService(String id) async {
    await _client.delete('/services/services/$id');
  }
}
