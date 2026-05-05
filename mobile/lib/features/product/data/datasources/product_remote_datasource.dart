import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/pagination_model.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<({List<ProductModel> products, PaginationModel pagination})>
      getProducts({
    int page,
    int limit,
    String? sort,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    int? rating,
    String? search,
  });

  Future<ProductModel> getProduct(String id);

  Future<ProductModel> getProductBySlug(String slug);

  Future<List<ProductModel>> getFeaturedProducts({int limit});

  Future<({List<ProductModel> products, DateTime? flashSaleEndTime, int count})>
      getFlashSaleProducts({int page, int limit});

  Future<({List<ProductModel> products, PaginationModel pagination})>
      getProductsByCategory({
    required String categoryId,
    int page,
    int limit,
    String? sort,
  });

  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> getCategory(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<({List<ProductModel> products, PaginationModel pagination})>
      getProducts({
    int page = 1,
    int limit = 12,
    String? sort,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    int? rating,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (sort != null) 'sort': sort,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (rating != null) 'rating': rating,
      if (search != null) 'search': search,
    };

    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.products,
      queryParameters: queryParams,
    );

    final data = response['data'] as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination =
        PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>);

    return (products: products, pagination: pagination);
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '${ApiConstants.products}/$id',
    );

    final data = response['data'] as Map<String, dynamic>;
    return ProductModel.fromJson(data['product'] as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '${ApiConstants.products}/slug/$slug',
    );

    final data = response['data'] as Map<String, dynamic>;
    return ProductModel.fromJson(data['product'] as Map<String, dynamic>);
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 8}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.featuredProducts,
      queryParameters: {'limit': limit},
    );

    final data = response['data'] as Map<String, dynamic>;
    return (data['products'] as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<({List<ProductModel> products, DateTime? flashSaleEndTime, int count})>
      getFlashSaleProducts({int page = 1, int limit = 10}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.flashSaleProducts,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response['data'] as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final flashSaleEndTime = data['flashSaleEndTime'] != null
        ? DateTime.parse(data['flashSaleEndTime'] as String)
        : null;
    final count = data['count'] as int;

    return (
      products: products,
      flashSaleEndTime: flashSaleEndTime,
      count: count
    );
  }

  @override
  Future<({List<ProductModel> products, PaginationModel pagination})>
      getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 12,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (sort != null) 'sort': sort,
    };

    final response = await _dioClient.get<Map<String, dynamic>>(
      '${ApiConstants.products}/category/$categoryId',
      queryParameters: queryParams,
    );

    final data = response['data'] as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination =
        PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>);

    return (products: products, pagination: pagination);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.categories,
    );

    final data = response['data'] as Map<String, dynamic>;
    return (data['categories'] as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CategoryModel> getCategory(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '${ApiConstants.categories}/$id',
    );

    final data = response['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data['category'] as Map<String, dynamic>);
  }
}
