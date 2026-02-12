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
}
