import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String userId;
  final List<OrderItemEntity> orderItems;
  final ShippingAddressEntity shippingAddress;
  final PaymentInfoEntity paymentInfo;
  final double itemsPrice;
  final double shippingPrice;
  final double taxPrice;
  final double totalPrice;
  final OrderStatus status;
  final DateTime? paidAt;
  final DateTime? deliveredAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.orderItems,
    required this.shippingAddress,
    required this.paymentInfo,
    required this.itemsPrice,
    required this.shippingPrice,
    required this.taxPrice,
    required this.totalPrice,
    required this.status,
    this.paidAt,
    this.deliveredAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        userId,
        orderItems,
        shippingAddress,
        paymentInfo,
        itemsPrice,
        shippingPrice,
        taxPrice,
        totalPrice,
        status,
        paidAt,
        deliveredAt,
        cancellationReason,
        createdAt,
        updatedAt,
      ];
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String? variant;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.variant,
  });

  @override
  List<Object?> get props => [
        productId,
        name,
        image,
        price,
        quantity,
        variant,
      ];
}

class ShippingAddressEntity extends Equatable {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const ShippingAddressEntity({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  @override
  List<Object?> get props => [
        fullName,
        phone,
        address,
        city,
        state,
        postalCode,
        country,
      ];
}

class PaymentInfoEntity extends Equatable {
  final String method;
  final String? transactionId;
  final String status;
  final String? cardLast4;

  const PaymentInfoEntity({
    required this.method,
    this.transactionId,
    required this.status,
    this.cardLast4,
  });

  @override
  List<Object?> get props => [
        method,
        transactionId,
        status,
        cardLast4,
      ];
}
