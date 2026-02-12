import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Convert exceptions to failures
  static Failure handleException(dynamic error) {
    _logger.e('Error occurred', error: error);

    if (error is DioException) {
      return _handleDioException(error);
    } else if (error is ServerException) {
      return ServerFailure(error.message, error.code);
    } else if (error is NetworkException) {
      return NetworkFailure(error.message, error.code);
    } else if (error is UnauthorizedException) {
      return UnauthorizedFailure(error.message, error.code);
    } else if (error is ValidationException) {
      return ValidationFailure(error.message, error.code);
    } else if (error is NotFoundException) {
      return NotFoundFailure(error.message, error.code);
    } else if (error is CacheException) {
      return CacheFailure(error.message, error.code);
    } else {
      return UnknownFailure(error.toString());
    }
  }

  /// Handle Dio exceptions
  static Failure _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet connection.',
          'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return const NetworkFailure('Request cancelled', 'CANCELLED');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
          'NO_CONNECTION',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          'Security certificate error',
          'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
      default:
        return NetworkFailure(
          'An unexpected error occurred: ${error.message}',
          'UNKNOWN',
        );
    }
  }

  /// Handle bad HTTP responses
  static Failure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'An error occurred';
    String? code;

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      if (data.containsKey('error')) {
        final errorData = data['error'];
        if (errorData is Map<String, dynamic>) {
          message = errorData['message'] ?? message;
          code = errorData['code'];
        } else if (errorData is String) {
          message = errorData;
        }
      } else if (data.containsKey('message') && data['message'] != null) {
        message = data['message'];
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(message, code ?? 'BAD_REQUEST');
      case 401:
        return UnauthorizedFailure(
          message.isEmpty ? 'Unauthorized. Please login again.' : message,
          code ?? 'UNAUTHORIZED',
        );
      case 403:
        return UnauthorizedFailure(
          message.isEmpty ? 'Access forbidden' : message,
          code ?? 'FORBIDDEN',
        );
      case 404:
        return NotFoundFailure(
          message.isEmpty ? 'Resource not found' : message,
          code ?? 'NOT_FOUND',
        );
      case 422:
        return ValidationFailure(
          message.isEmpty ? 'Validation error' : message,
          code ?? 'VALIDATION_ERROR',
        );
      case 429:
        return ServerFailure(
          'Too many requests. Please try again later.',
          'RATE_LIMIT',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          'Server error. Please try again later.',
          code ?? 'SERVER_ERROR',
        );
      default:
        return ServerFailure(message, code ?? 'UNKNOWN_ERROR');
    }
  }

  /// Get user-friendly error message
  static String getUserMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is UnauthorizedFailure) {
      return 'Your session has expired. Please login again.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NotFoundFailure) {
      return 'The requested resource was not found.';
    } else if (failure is ServerFailure) {
      return 'Server error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Log error
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    _logger.e('Error', error: error, stackTrace: stackTrace);
  }

  /// Log info
  static void logInfo(String message) {
    _logger.i(message);
  }

  /// Log debug
  static void logDebug(String message) {
    _logger.d(message);
  }

  /// Log warning
  static void logWarning(String message) {
    _logger.w(message);
  }
}
