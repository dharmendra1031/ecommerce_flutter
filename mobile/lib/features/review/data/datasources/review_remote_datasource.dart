import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<({List<ReviewModel> reviews, int page, int limit, int total, int pages})>
      getProductReviews(
    String productId, {
    int page,
    int limit,
  });

  Future<ReviewModel> createReview(
    String productId, {
    required int rating,
    required String title,
    required String comment,
  });

  Future<ReviewModel> updateReview(
    String reviewId, {
    required int rating,
    required String title,
    required String comment,
  });

  Future<void> deleteReview(String reviewId);

  Future<({List<ReviewModel> reviews, int page, int limit, int total, int pages})>
      getMyReviews({
    int page,
    int limit,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient _dioClient;

  ReviewRemoteDataSourceImpl(this._dioClient);

  @override
  Future<({List<ReviewModel> reviews, int page, int limit, int total, int pages})>
      getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '${ApiConstants.products}/$productId/reviews',
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final reviews = (data['reviews'] as List<dynamic>?)
            ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return (
      reviews: reviews,
      page: pagination['page'] as int? ?? page,
      limit: pagination['limit'] as int? ?? limit,
      total: pagination['total'] as int? ?? reviews.length,
      pages: pagination['pages'] as int? ?? 1,
    );
  }

  @override
  Future<ReviewModel> createReview(
    String productId, {
    required int rating,
    required String title,
    required String comment,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '${ApiConstants.products}/$productId/reviews',
      data: {
        'rating': rating,
        'title': title,
        'comment': comment,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return ReviewModel.fromJson(data['review'] as Map<String, dynamic>);
  }

  @override
  Future<ReviewModel> updateReview(
    String reviewId, {
    required int rating,
    required String title,
    required String comment,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      '${ApiConstants.reviews}/$reviewId',
      data: {
        'rating': rating,
        'title': title,
        'comment': comment,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return ReviewModel.fromJson(data['review'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _dioClient.delete<Map<String, dynamic>>(
      '${ApiConstants.reviews}/$reviewId',
    );
  }

  @override
  Future<({List<ReviewModel> reviews, int page, int limit, int total, int pages})>
      getMyReviews({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.myReviews,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response['data'] as Map<String, dynamic>;
    final reviews = (data['reviews'] as List<dynamic>)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;

    return (
      reviews: reviews,
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      total: pagination['total'] as int,
      pages: pagination['pages'] as int,
    );
  }
}
