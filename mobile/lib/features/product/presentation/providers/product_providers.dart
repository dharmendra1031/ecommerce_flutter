import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';

part 'product_providers.g.dart';

@riverpod
ProductRemoteDataSource productRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductRemoteDataSourceImpl(dioClient);
}

@riverpod
ProductRepository productRepository(Ref ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
}

@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  @override
  Future<List<ProductEntity>> build() async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProducts();

    return result.fold(
      (failure) => throw failure,
      (paginated) => paginated.products,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}

@riverpod
class FeaturedProductsNotifier extends _$FeaturedProductsNotifier {
  @override
  Future<List<ProductEntity>> build() async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getFeaturedProducts();

    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }
}

@riverpod
class FlashSaleNotifier extends _$FlashSaleNotifier {
  @override
  Future<FlashSaleState> build() async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getFlashSaleProducts();

    return result.fold(
      (failure) => throw failure,
      (result) => FlashSaleState(
        products: result.products,
        flashSaleEndTime: result.flashSaleEndTime,
        count: result.count,
      ),
    );
  }
}

class FlashSaleState {
  final List<ProductEntity> products;
  final DateTime? flashSaleEndTime;
  final int count;

  FlashSaleState({
    required this.products,
    this.flashSaleEndTime,
    required this.count,
  });
}

@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  @override
  Future<List<CategoryEntity>> build() async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getCategories();

    return result.fold(
      (failure) => throw failure,
      (categories) => categories,
    );
  }
}

@riverpod
class ProductDetailNotifier extends _$ProductDetailNotifier {
  @override
  Future<ProductEntity?> build(String productId) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProduct(productId);

    return result.fold(
      (failure) => throw failure,
      (product) => product,
    );
  }
}

@riverpod
class ProductSearchNotifier extends _$ProductSearchNotifier {
  int _page = 1;
  bool _hasMore = true;

  // Filter state preservation
  String? _currentQuery;
  String? _currentCategory;
  String? _currentSort;
  double? _currentMinPrice;
  double? _currentMaxPrice;

  @override
  Future<List<ProductEntity>> build() async {
    _page = 1;
    _hasMore = true;
    // Reset filter state on rebuild
    _currentQuery = null;
    _currentCategory = null;
    _currentSort = null;
    _currentMinPrice = null;
    _currentMaxPrice = null;
    // Return empty list initially - search() will be called to load data
    return [];
  }

  Future<List<ProductEntity>> _fetchProducts() async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProducts(
      page: _page,
      limit: 10,
      search: _currentQuery,
      category: _currentCategory,
      sort: _currentSort,
      minPrice: _currentMinPrice,
      maxPrice: _currentMaxPrice,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) {
        _hasMore = _page < paginated.pages;
        return paginated.products;
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentProducts = state.valueOrNull ?? [];
    state = const AsyncValue.loading();

    _page++;
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProducts(
      page: _page,
      limit: 10,
      search: _currentQuery,
      category: _currentCategory,
      sort: _currentSort,
      minPrice: _currentMinPrice,
      maxPrice: _currentMaxPrice,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (paginated) {
        _hasMore = _page < paginated.pages;
        return AsyncValue.data([...currentProducts, ...paginated.products]);
      },
    );
  }

  Future<void> search({
    String? query,
    String? category,
    String? sort,
    double? minPrice,
    double? maxPrice,
  }) async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;

    // Preserve filter state for subsequent loadMore calls
    _currentQuery = query;
    _currentCategory = category;
    _currentSort = sort;
    _currentMinPrice = minPrice;
    _currentMaxPrice = maxPrice;

    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProducts(
      page: _page,
      limit: 10,
      search: query,
      category: category,
      sort: sort,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (paginated) {
        _hasMore = _page < paginated.pages;
        return AsyncValue.data(paginated.products);
      },
    );
  }
}
