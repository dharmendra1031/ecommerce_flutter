import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';

part 'review_providers.g.dart';

@riverpod
ReviewRemoteDataSource reviewRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReviewRemoteDataSourceImpl(dioClient);
}

@riverpod
ReviewRepository reviewRepository(Ref ref) {
  final remoteDataSource = ref.watch(reviewRemoteDataSourceProvider);
  return ReviewRepositoryImpl(remoteDataSource);
}

@riverpod
class ProductReviewsNotifier extends _$ProductReviewsNotifier {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<ReviewEntity>> build(String productId) async {
    _page = 1;
    _hasMore = true;
    return _fetchReviews(productId);
  }

  Future<List<ReviewEntity>> _fetchReviews(String productId) async {
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.getProductReviews(
      productId,
      page: _page,
      limit: 10,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) {
        _hasMore = _page < paginated.pages;
        return paginated.reviews;
      },
    );
  }

  Future<void> loadMore(String productId) async {
    if (!_hasMore || state.isLoading) return;

    final currentReviews = state.valueOrNull ?? [];
    state = const AsyncValue.loading();

    _page++;
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.getProductReviews(
      productId,
      page: _page,
      limit: 10,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (paginated) {
        _hasMore = _page < paginated.pages;
        return AsyncValue.data([...currentReviews, ...paginated.reviews]);
      },
    );
  }

  Future<void> refresh(String productId) async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    state = await AsyncValue.guard(() => _fetchReviews(productId));
  }

  Future<AsyncValue<void>> createReview(
    String productId, {
    required int rating,
    required String title,
    required String comment,
  }) async {
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.createReview(
      productId,
      rating: rating,
      title: title,
      comment: comment,
    );

    return result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (review) {
        final currentReviews = state.valueOrNull ?? [];
        // Defer state update to avoid framework assertion errors during widget tree changes
        Future.microtask(() {
          state = AsyncValue.data([review, ...currentReviews]);
        });
        return const AsyncValue.data(null);
      },
    );
  }
}

@riverpod
class MyReviewsNotifier extends _$MyReviewsNotifier {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<ReviewEntity>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchMyReviews();
  }

  Future<List<ReviewEntity>> _fetchMyReviews() async {
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.getMyReviews(
      page: _page,
      limit: 10,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) {
        _hasMore = _page < paginated.pages;
        return paginated.reviews;
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentReviews = state.valueOrNull ?? [];
    state = const AsyncValue.loading();

    _page++;
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.getMyReviews(
      page: _page,
      limit: 10,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (paginated) {
        _hasMore = _page < paginated.pages;
        return AsyncValue.data([...currentReviews, ...paginated.reviews]);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    state = await AsyncValue.guard(() => _fetchMyReviews());
  }

  Future<AsyncValue<void>> createReview(
    String productId, {
    required int rating,
    required String title,
    required String comment,
  }) async {
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.createReview(
      productId,
      rating: rating,
      title: title,
      comment: comment,
    );

    return result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (review) {
        final currentReviews = state.valueOrNull ?? [];
        // Defer state update to avoid framework assertion errors during widget tree changes
        Future.microtask(() {
          state = AsyncValue.data([review, ...currentReviews]);
        });
        return const AsyncValue.data(null);
      },
    );
  }

  Future<AsyncValue<void>> updateReview(
    String reviewId, {
    required int rating,
    required String title,
    required String comment,
  }) async {
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.updateReview(
      reviewId,
      rating: rating,
      title: title,
      comment: comment,
    );

    return result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (updatedReview) {
        final currentReviews = state.valueOrNull ?? [];
        // Defer state update to avoid framework assertion errors during widget tree changes
        Future.microtask(() {
          state = AsyncValue.data(
            currentReviews.map((r) => r.id == reviewId ? updatedReview : r).toList(),
          );
        });
        return const AsyncValue.data(null);
      },
    );
  }

  Future<AsyncValue<void>> deleteReview(String reviewId) async {
    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.deleteReview(reviewId);

    return result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) {
        final currentReviews = state.valueOrNull ?? [];
        // Defer state update to avoid framework assertion errors during widget tree changes
        Future.microtask(() {
          state = AsyncValue.data(
            currentReviews.where((r) => r.id != reviewId).toList(),
          );
        });
        return const AsyncValue.data(null);
      },
    );
  }
}
