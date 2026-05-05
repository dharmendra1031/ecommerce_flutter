import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PaginatedProducts>> getProducts({
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
    try {
      final result = await _remoteDataSource.getProducts(
        page: page,
        limit: limit,
        sort: sort,
        category: category,
        brand: brand,
        minPrice: minPrice,
        maxPrice: maxPrice,
        rating: rating,
        search: search,
      );

      return Right(PaginatedProducts(
        products: result.products.map((e) => e.toEntity()).toList(),
        page: result.pagination.page,
        limit: result.pagination.limit,
        total: result.pagination.total,
        pages: result.pagination.pages,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load products',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String id) async {
    try {
      final product = await _remoteDataSource.getProduct(id);
      return Right(product.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load product',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductBySlug(String slug) async {
    try {
      final product = await _remoteDataSource.getProductBySlug(slug);
      return Right(product.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load product',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int limit = 8,
  }) async {
    try {
      final products =
          await _remoteDataSource.getFeaturedProducts(limit: limit);
      return Right(products.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load featured products',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, FlashSaleResult>> getFlashSaleProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getFlashSaleProducts(
        page: page,
        limit: limit,
      );

      return Right(FlashSaleResult(
        products: result.products.map((e) => e.toEntity()).toList(),
        flashSaleEndTime: result.flashSaleEndTime,
        count: result.count,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load flash sale products',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, PaginatedProducts>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 12,
    String? sort,
  }) async {
    try {
      final result = await _remoteDataSource.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
        sort: sort,
      );

      return Right(PaginatedProducts(
        products: result.products.map((e) => e.toEntity()).toList(),
        page: result.pagination.page,
        limit: result.pagination.limit,
        total: result.pagination.total,
        pages: result.pagination.pages,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load products',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return Right(categories.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load categories',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategory(String id) async {
    try {
      final category = await _remoteDataSource.getCategory(id);
      return Right(category.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load category',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }
}
