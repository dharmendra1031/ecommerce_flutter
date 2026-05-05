import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
    bool verifyOnly = false,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(AuthResult(
        user: response.user.toEntity(),
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ));
    } on UnauthorizedFailure catch (_) {
      // Different error messages based on context:
      // - verifyOnly (delete account): only password field shown
      // - normal login: both email and password fields shown
      return Left(
        ValidationFailure(
          message:
              verifyOnly ? 'Incorrect password' : 'Invalid email or password',
          statusCode: 401,
        ),
      );
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      return Right(AuthResult(
        user: response.user.toEntity(),
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ));
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        token: token,
        password: password,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final response = await _remoteDataSource.refreshToken(refreshToken);
      return Right(AuthTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ));
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmail() async {
    try {
      await _remoteDataSource.sendVerificationEmail();
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        name: name,
        phone: phone,
      );
      return Right(user.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }
}
