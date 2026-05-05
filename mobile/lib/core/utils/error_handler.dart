import 'package:dio/dio.dart';
import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const UnknownFailure();
    }
  }

  static Failure _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    final message = _extractMessage(data) ?? 'An error occurred';

    switch (statusCode) {
      case 400:
        return ValidationFailure(
          message: message,
          statusCode: statusCode,
          errors: _extractFieldErrors(data),
        );
      case 401:
        return const UnauthorizedFailure();
      case 403:
        return ServerFailure(
          message: message,
          statusCode: statusCode,
        );
      case 404:
        return NotFoundFailure(message: message);
      case 422:
        return ValidationFailure(
          message: message,
          statusCode: statusCode,
          errors: _extractFieldErrors(data),
        );
      case 429:
        final retryAfter = error.response?.headers.value('retry-after');
        return RateLimitFailure(
          message: message,
          retryAfterSeconds: retryAfter != null ? int.tryParse(retryAfter) : null,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return UnknownFailure(message: message);
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return null;

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.cast<String>());
      }
      return MapEntry(key, [value.toString()]);
    });
  }
}
