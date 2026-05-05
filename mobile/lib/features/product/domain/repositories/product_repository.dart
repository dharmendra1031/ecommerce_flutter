import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, PaginatedProducts>> getProducts({
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

  Future<Either<Failure, ProductEntity>> getProduct(String id);

  Future<Either<Failure, ProductEntity>> getProductBySlug(String slug);

  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int limit,
  });

  Future<Either<Failure, FlashSaleResult>> getFlashSaleProducts({
    int page,
    int limit,
  });

  Future<Either<Failure, PaginatedProducts>> getProductsByCategory({
    required String categoryId,
    int page,
    int limit,
    String? sort,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, CategoryEntity>> getCategory(String id);
}

class PaginatedProducts {
  final List<ProductEntity> products;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginatedProducts({
    required this.products,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });
}

class FlashSaleResult {
  final List<ProductEntity> products;
  final DateTime? flashSaleEndTime;
  final int count;

  const FlashSaleResult({
    required this.products,
    this.flashSaleEndTime,
    required this.count,
  });
}
