import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../datasources/profile_remote_datasource.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileStats>> getProfileStats();
  Future<Either<Failure, void>> updateProfile({
    required String name,
    String? phone,
  });
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, AvatarEntity>> uploadAvatar(File imageFile);
  Future<Either<Failure, void>> deleteAvatar();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ProfileStats>> getProfileStats() async {
    try {
      final stats = await _remoteDataSource.getProfileStats();
      return Right(stats);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load profile stats',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      await _remoteDataSource.updateProfile(name: name, phone: phone);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to update profile',
        statusCode: e.response?.statusCode,
      ));
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
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to update password',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to delete account',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AvatarEntity>> uploadAvatar(File imageFile) async {
    try {
      final avatarData = await _remoteDataSource.uploadAvatar(imageFile);
      return Right(AvatarEntity(
        publicId: avatarData['public_id'] as String,
        url: avatarData['url'] as String,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to upload avatar',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAvatar() async {
    try {
      await _remoteDataSource.deleteAvatar();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to delete avatar',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    }
  }
}
