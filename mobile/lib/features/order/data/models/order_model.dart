import '../../domain/entities/order_entity.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final List<OrderItemModel> orderItems;
  final ShippingAddressModel shippingAddress;
  final PaymentInfoModel paymentInfo;
  final double itemsPrice;
  final double shippingPrice;
  final double taxPrice;
  final double totalPrice;
  final String status;
  final DateTime? paidAt;
  final DateTime? deliveredAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle paymentMethod/paymentInfo from backend
    final paymentMethod = json['paymentMethod'] as String? ?? 'cod';
    final paymentResult = json['paymentResult'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['_id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      userId: json['user'] is String
          ? json['user'] as String
          : (json['user'] as Map<String, dynamic>?)?['_id'] as String? ?? '',
      orderItems: (json['orderItems'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddressModel.fromJson(
              json['shippingAddress'] as Map<String, dynamic>)
          : const ShippingAddressModel(
              fullName: '',
              phone: '',
              address: '',
              city: '',
              state: '',
              postalCode: '',
              country: '',
            ),
      paymentInfo: PaymentInfoModel(
        method: paymentMethod,
        transactionId: paymentResult?['id'] as String?,
        status: paymentResult?['status'] as String? ?? 'pending',
        cardLast4: paymentResult?['cardLast4'] as String?,
      ),
      itemsPrice: (json['itemsPrice'] as num?)?.toDouble() ?? 0.0,
      shippingPrice: (json['shippingPrice'] as num?)?.toDouble() ?? 0.0,
      taxPrice: (json['taxPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String).toLocal()
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String).toLocal()
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'user': userId,
      'orderItems': orderItems.map((e) => e.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentInfo': paymentInfo.toJson(),
      'itemsPrice': itemsPrice,
      'shippingPrice': shippingPrice,
      'taxPrice': taxPrice,
      'totalPrice': totalPrice,
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      userId: userId,
      orderItems: orderItems.map((e) => e.toEntity()).toList(),
      shippingAddress: shippingAddress.toEntity(),
      paymentInfo: paymentInfo.toEntity(),
      itemsPrice: itemsPrice,
      shippingPrice: shippingPrice,
      taxPrice: taxPrice,
      totalPrice: totalPrice,
      status: OrderStatus.fromString(status),
      paidAt: paidAt,
      deliveredAt: deliveredAt,
      cancellationReason: cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String? variant;

  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.variant,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Handle variant which can be String or Object {name, value}
    final dynamic variantField = json['variant'];
    String? variantString;
    if (variantField is String) {
      variantString = variantField;
    } else if (variantField is Map<String, dynamic>) {
      final name = variantField['name'] as String?;
      final value = variantField['value'] as String?;
      if (name != null && value != null) {
        variantString = '$name: $value';
      }
    }

    return OrderItemModel(
      productId: json['product'] is String
          ? json['product'] as String
          : (json['product'] as Map<String, dynamic>?)?['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Product',
      image: json['image'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      variant: variantString,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'variant': variant,
    };
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      productId: productId,
      name: name,
      image: image,
      price: price,
      quantity: quantity,
      variant: variant,
    );
  }
}

class ShippingAddressModel {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const ShippingAddressModel({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  ShippingAddressEntity toEntity() {
    return ShippingAddressEntity(
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
    );
  }
}

class PaymentInfoModel {
  final String method;
  final String? transactionId;
  final String status;
  final String? cardLast4;

  const PaymentInfoModel({
    required this.method,
    this.transactionId,
    required this.status,
    this.cardLast4,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentInfoModel(
      method: json['method'] as String,
      transactionId: json['transactionId'] as String?,
      status: json['status'] as String,
      cardLast4: json['cardLast4'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'transactionId': transactionId,
      'status': status,
      'cardLast4': cardLast4,
    };
  }

  PaymentInfoEntity toEntity() {
    return PaymentInfoEntity(
      method: method,
      transactionId: transactionId,
      status: status,
      cardLast4: cardLast4,
    );
  }
}
