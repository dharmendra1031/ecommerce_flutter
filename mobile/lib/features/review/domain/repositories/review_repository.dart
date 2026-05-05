import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, PaginatedReviews>> getProductReviews(
    String productId, {
    int page,
    int limit,
  });

  Future<Either<Failure, ReviewEntity>> createReview(
    String productId, {
    required int rating,
    required String title,
    required String comment,
  });

  Future<Either<Failure, ReviewEntity>> updateReview(
    String reviewId, {
    required int rating,
    required String title,
    required String comment,
  });

  Future<Either<Failure, void>> deleteReview(String reviewId);

  Future<Either<Failure, PaginatedReviews>> getMyReviews({
    int page,
    int limit,
  });
}

class PaginatedReviews {
  final List<ReviewEntity> reviews;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginatedReviews({
    required this.reviews,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });
}
