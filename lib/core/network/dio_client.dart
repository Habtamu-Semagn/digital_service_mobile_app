import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../utils/secure_storage_service.dart';

class DioClient {
  final Dio _dio;
  final SecureStorageService _storage;
  final Logger _logger = Logger();

  DioClient(this._storage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
            receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _logger),
      _LoggingInterceptor(_logger),
      _ErrorInterceptor(_logger),
    ]);
    _logger.i('DioClient initialized with baseUrl: ${_dio.options.baseUrl}');
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Authentication Interceptor - Adds JWT token to requests
class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Logger _logger;

  _AuthInterceptor(this._storage, this._logger);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Don't add auth token to login request
    if (options.path.contains('/auth/login')) {
      return handler.next(options);
    }

    // Get token from secure storage
    final token = await _storage.readSecure(AppConstants.keyAccessToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      _logger.d('Added auth token to request: ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Token expired
    // Don't attempt refresh for login requests
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/login')) {
      _logger.w('Token expired, attempting refresh...');

      try {
        // Attempt to refresh token
        final refreshToken = await _storage.readSecure(AppConstants.keyRefreshToken);

        if (refreshToken != null && refreshToken.isNotEmpty) {
          final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
          final response = await dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newToken = response.data['data']['token'];
            final newRefreshToken = response.data['data']['refreshToken'];

            // Save new tokens
            await _storage.writeSecure(AppConstants.keyAccessToken, newToken);
            await _storage.writeSecure(AppConstants.keyRefreshToken, newRefreshToken);

            // Retry original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final clonedRequest = await dio.fetch(err.requestOptions);
            return handler.resolve(clonedRequest);
          }
        }
      } catch (e) {
        _logger.e('Token refresh failed', error: e);
        // Clear tokens and let the error propagate
        await _storage.deleteSecure(AppConstants.keyAccessToken);
        await _storage.deleteSecure(AppConstants.keyRefreshToken);
      }
    }

    handler.next(err);
  }
}

/// Logging Interceptor - Logs requests and responses
class _LoggingInterceptor extends Interceptor {
  final Logger _logger;

  _LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('''
📤 REQUEST
Method: ${options.method}
URL: ${options.baseUrl}${options.path}
Headers: ${options.headers}
Query Parameters: ${options.queryParameters}
Body: ${options.data}
    ''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('''
📥 RESPONSE
Status Code: ${response.statusCode}
URL: ${response.requestOptions.path}
Data: ${response.data}
    ''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('''
❌ ERROR
Method: ${err.requestOptions.method}
URL: ${err.requestOptions.path}
Status Code: ${err.response?.statusCode}
Error: ${err.message}
Response: ${err.response?.data}
    ''');
    handler.next(err);
  }
}

/// Error Interceptor - Handles common errors
class _ErrorInterceptor extends Interceptor {
  final Logger _logger;

  _ErrorInterceptor(this._logger);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An error occurred';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'Received invalid response from server';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      default:
        errorMessage = err.message ?? 'Unknown error';
    }

    _logger.e('Dio Error: $errorMessage');
    handler.next(err);
  }
}
