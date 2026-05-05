import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final addresses = await _remoteDataSource.getAddresses();
      return Right(addresses.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load addresses',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> addAddress({
    required String label,
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String stateName,
    required String postalCode,
    required String country,
    required bool isDefault,
  }) async {
    try {
      final result = await _remoteDataSource.addAddress(
        label: label,
        fullName: fullName,
        phone: phone,
        address: address,
        city: city,
        stateName: stateName,
        postalCode: postalCode,
        country: country,
        isDefault: isDefault,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to add address',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String id,
    required String label,
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String stateName,
    required String postalCode,
    required String country,
    required bool isDefault,
  }) async {
    try {
      final result = await _remoteDataSource.updateAddress(
        id: id,
        label: label,
        fullName: fullName,
        phone: phone,
        address: address,
        city: city,
        stateName: stateName,
        postalCode: postalCode,
        country: country,
        isDefault: isDefault,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to update address',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    try {
      await _remoteDataSource.deleteAddress(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to delete address',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> setDefaultAddress(String id) async {
    try {
      final result = await _remoteDataSource.setDefaultAddress(id);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to set default address',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }
}
