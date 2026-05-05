import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  ReviewRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PaginatedReviews>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getProductReviews(
        productId,
        page: page,
        limit: limit,
      );

      return Right(PaginatedReviews(
        reviews: result.reviews.map((e) => e.toEntity()).toList(),
        page: result.page,
        limit: result.limit,
        total: result.total,
        pages: result.pages,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to load reviews',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException catch (e) {
      return Left(ParseFailure(message: 'Invalid response format: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> createReview(
    String productId, {
    required int rating,
    required String title,
    required String comment,
  }) async {
    try {
      final review = await _remoteDataSource.createReview(
        productId,
        rating: rating,
        title: title,
        comment: comment,
      );
      return Right(review.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to create review',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> updateReview(
    String reviewId, {
    required int rating,
    required String title,
    required String comment,
  }) async {
    try {
      final review = await _remoteDataSource.updateReview(
        reviewId,
        rating: rating,
        title: title,
        comment: comment,
      );
      return Right(review.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to update review',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await _remoteDataSource.deleteReview(reviewId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to delete review',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, PaginatedReviews>> getMyReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getMyReviews(
        page: page,
        limit: limit,
      );

      return Right(PaginatedReviews(
        reviews: result.reviews.map((e) => e.toEntity()).toList(),
        page: result.page,
        limit: result.limit,
        total: result.total,
        pages: result.pages,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to load my reviews',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ParseFailure(message: 'Invalid response format'));
    }
  }
}
