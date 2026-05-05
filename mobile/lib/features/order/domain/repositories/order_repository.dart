import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, PaginatedOrders>> getMyOrders({
    int page,
    int limit,
    OrderStatus? status,
  });

  Future<Either<Failure, OrderEntity>> getOrder(String id);

  Future<Either<Failure, OrderEntity>> createOrder({
    required List<OrderItemEntity> orderItems,
    required ShippingAddressEntity shippingAddress,
    required PaymentInfoEntity paymentInfo,
    required double itemsPrice,
    required double shippingPrice,
    required double taxPrice,
    required double totalPrice,
  });

  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String id,
    required String reason,
  });
}

class PaginatedOrders {
  final List<OrderEntity> orders;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginatedOrders({
    required this.orders,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });
}
