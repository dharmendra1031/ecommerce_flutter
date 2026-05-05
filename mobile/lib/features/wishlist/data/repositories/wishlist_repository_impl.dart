import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getWishlist() async {
    try {
      final products = await _remoteDataSource.getWishlist();
      return Right(products.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load wishlist',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String productId) async {
    try {
      await _remoteDataSource.addToWishlist(productId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to add to wishlist',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(String productId) async {
    try {
      await _remoteDataSource.removeFromWishlist(productId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to remove from wishlist',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkWishlist(String productId) async {
    try {
      final isInWishlist = await _remoteDataSource.checkWishlist(productId);
      return Right(isInWishlist);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to check wishlist',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }
}
