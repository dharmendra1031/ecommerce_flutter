import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';
import '../models/pagination_model.dart';

abstract class OrderRemoteDataSource {
  Future<({List<OrderModel> orders, PaginationModel pagination})> getMyOrders({
    int page,
    int limit,
    OrderStatus? status,
  });

  Future<OrderModel> getOrder(String id);

  Future<OrderModel> createOrder({
    required List<OrderItemEntity> orderItems,
    required ShippingAddressEntity shippingAddress,
    required PaymentInfoEntity paymentInfo,
    required double itemsPrice,
    required double shippingPrice,
    required double taxPrice,
    required double totalPrice,
  });

  Future<OrderModel> cancelOrder({
    required String id,
    required String reason,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<({List<OrderModel> orders, PaginationModel pagination})> getMyOrders({
    int page = 1,
    int limit = 10,
    OrderStatus? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
    };

    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.orders,
      queryParameters: queryParams,
    );

    final data = response['data'] as Map<String, dynamic>;
    final orders = (data['orders'] as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination =
        PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>);

    return (orders: orders, pagination: pagination);
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '${ApiConstants.orders}/$id',
    );

    final data = response['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data['order'] as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> createOrder({
    required List<OrderItemEntity> orderItems,
    required ShippingAddressEntity shippingAddress,
    required PaymentInfoEntity paymentInfo,
    required double itemsPrice,
    required double shippingPrice,
    required double taxPrice,
    required double totalPrice,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.orders,
      data: {
        'shippingAddress': {
          'fullName': shippingAddress.fullName,
          'phone': shippingAddress.phone,
          'address': shippingAddress.address,
          'city': shippingAddress.city,
          'postalCode': shippingAddress.postalCode,
        },
        'paymentMethod': paymentInfo.method, // 'card' or 'cod'
        'paymentResult': paymentInfo.method == 'card'
            ? {
                'id': paymentInfo.transactionId,
                'status': paymentInfo.status,
                'cardLast4': paymentInfo.cardLast4,
              }
            : null,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data['order'] as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> cancelOrder({
    required String id,
    required String reason,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      '${ApiConstants.orders}/$id/cancel',
      data: {'reason': reason},
    );

    final data = response['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data['order'] as Map<String, dynamic>);
  }
}
