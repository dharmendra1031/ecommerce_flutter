import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network and try again.',
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please login again.',
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
    super.statusCode,
  });

  @override
  List<Object?> get props => [message, errors, statusCode];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found.',
  });
}

class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;

  const RateLimitFailure({
    required super.message,
    this.retryAfterSeconds,
  });

  @override
  List<Object?> get props => [message, retryAfterSeconds];
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong. Please try again.',
  });
}

class ParseFailure extends Failure {
  const ParseFailure({
    super.message = 'Failed to parse data. Please try again.',
  });
}
