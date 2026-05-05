import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();

  Future<CartModel> addToCart({
    required String productId,
    required int quantity,
    Map<String, String>? selectedVariants,
  });

  Future<CartModel> updateItem({
    required String itemId,
    required int quantity,
  });

  Future<CartModel> removeItem(String itemId);

  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient _dioClient;

  CartRemoteDataSourceImpl(this._dioClient);

  @override
  Future<CartModel> getCart() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.cart,
    );

    final data = response['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data['cart'] as Map<String, dynamic>);
  }

  @override
  Future<CartModel> addToCart({
    required String productId,
    required int quantity,
    Map<String, String>? selectedVariants,
  }) async {
    // Convert selectedVariants to variant format expected by backend
    // Backend expects: variant: { name: String, value: String }
    Map<String, String>? variant;
    if (selectedVariants != null && selectedVariants.isNotEmpty) {
      final firstEntry = selectedVariants.entries.first;
      variant = {
        'name': firstEntry.key,
        'value': firstEntry.value,
      };
    }

    final body = <String, dynamic>{
      'productId': productId,
      'quantity': quantity,
      if (variant != null) 'variant': variant,
    };

    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.cart,
      data: body,
    );

    final data = response['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data['cart'] as Map<String, dynamic>);
  }

  @override
  Future<CartModel> updateItem({
    required String itemId,
    required int quantity,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      '${ApiConstants.cart}/$itemId',
      data: {'quantity': quantity},
    );

    final data = response['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data['cart'] as Map<String, dynamic>);
  }

  @override
  Future<CartModel> removeItem(String itemId) async {
    final response = await _dioClient.delete<Map<String, dynamic>>(
      '${ApiConstants.cart}/$itemId',
    );

    final data = response['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data['cart'] as Map<String, dynamic>);
  }

  @override
  Future<void> clearCart() async {
    await _dioClient.delete<Map<String, dynamic>>(ApiConstants.cart);
  }
}
