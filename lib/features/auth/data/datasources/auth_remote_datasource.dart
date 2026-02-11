import '../../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSource(this._client);

  Future<LoginResponse> login(String phoneNumber, String password) async {
    final response = await _client.post(
      '/auth/login',
      data: {
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<UserModel> updateProfile(String name, String phoneNumber) async {
    final response = await _client.patch(
      '/auth/profile',
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
      },
    );

    // Backend returns { message, user: { ... } }
    return UserModel.fromJson(response.data['user']);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _client.patch(
      '/auth/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
