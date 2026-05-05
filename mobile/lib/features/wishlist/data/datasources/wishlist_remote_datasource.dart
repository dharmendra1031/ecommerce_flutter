import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../product/data/models/product_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
  Future<bool> checkWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final DioClient _dioClient;

  WishlistRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getWishlist() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.wishlist,
    );

    final data = response['data'] as Map<String, dynamic>;
    return (data['wishlist'] as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addToWishlist(String productId) async {
    await _dioClient.post<Map<String, dynamic>>(
      '${ApiConstants.wishlist}/$productId',
    );
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    await _dioClient.delete<Map<String, dynamic>>(
      '${ApiConstants.wishlist}/$productId',
    );
  }

  @override
  Future<bool> checkWishlist(String productId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '${ApiConstants.wishlist}/check/$productId',
    );

    final data = response['data'] as Map<String, dynamic>;
    return data['isInWishlist'] as bool;
  }
}
