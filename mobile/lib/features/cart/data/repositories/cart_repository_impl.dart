import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cart = await _remoteDataSource.getCart();
      return Right(cart.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load cart',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(UnknownFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart({
    required String productId,
    required int quantity,
    Map<String, String>? selectedVariants,
  }) async {
    try {
      final cart = await _remoteDataSource.addToCart(
        productId: productId,
        quantity: quantity,
        selectedVariants: selectedVariants,
      );
      return Right(cart.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to add item to cart',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(UnknownFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final cart = await _remoteDataSource.updateItem(
        itemId: itemId,
        quantity: quantity,
      );
      return Right(cart.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to update cart item',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(UnknownFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem(String itemId) async {
    try {
      final cart = await _remoteDataSource.removeItem(itemId);
      return Right(cart.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to remove item from cart',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(UnknownFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await _remoteDataSource.clearCart();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to clear cart',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(UnknownFailure(message: 'Invalid response format'));
    }
  }
}
