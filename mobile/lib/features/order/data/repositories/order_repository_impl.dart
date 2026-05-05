import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PaginatedOrders>> getMyOrders({
    int page = 1,
    int limit = 10,
    OrderStatus? status,
  }) async {
    try {
      final result = await _remoteDataSource.getMyOrders(
        page: page,
        limit: limit,
        status: status,
      );

      return Right(PaginatedOrders(
        orders: result.orders.map((e) => e.toEntity()).toList(),
        page: result.pagination.page,
        limit: result.pagination.limit,
        total: result.pagination.total,
        pages: result.pagination.pages,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load orders',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrder(String id) async {
    try {
      final order = await _remoteDataSource.getOrder(id);
      return Right(order.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load order',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<OrderItemEntity> orderItems,
    required ShippingAddressEntity shippingAddress,
    required PaymentInfoEntity paymentInfo,
    required double itemsPrice,
    required double shippingPrice,
    required double taxPrice,
    required double totalPrice,
  }) async {
    try {
      final order = await _remoteDataSource.createOrder(
        orderItems: orderItems,
        shippingAddress: shippingAddress,
        paymentInfo: paymentInfo,
        itemsPrice: itemsPrice,
        shippingPrice: shippingPrice,
        taxPrice: taxPrice,
        totalPrice: totalPrice,
      );
      return Right(order.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to create order',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String id,
    required String reason,
  }) async {
    try {
      final order = await _remoteDataSource.cancelOrder(
        id: id,
        reason: reason,
      );
      return Right(order.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to cancel order',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }
}
