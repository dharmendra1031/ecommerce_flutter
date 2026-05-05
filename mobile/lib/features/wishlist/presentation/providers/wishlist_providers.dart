import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/repositories/wishlist_repository.dart';

part 'wishlist_providers.g.dart';

@riverpod
WishlistRemoteDataSource wishlistRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WishlistRemoteDataSourceImpl(dioClient);
}

@riverpod
WishlistRepository wishlistRepository(Ref ref) {
  final remoteDataSource = ref.watch(wishlistRemoteDataSourceProvider);
  return WishlistRepositoryImpl(remoteDataSource);
}

@riverpod
class WishlistNotifier extends _$WishlistNotifier {
  @override
  Future<List<ProductEntity>> build() async {
    final repository = ref.read(wishlistRepositoryProvider);
    final result = await repository.getWishlist();

    return result.fold(
      (failure) => throw failure,
      (wishlist) => wishlist,
    );
  }

  Future<void> addToWishlist(String productId) async {
    final repository = ref.read(wishlistRepositoryProvider);
    final result = await repository.addToWishlist(productId);

    result.fold(
      (failure) => throw failure,
      (_) {
        ref.invalidateSelf();
      },
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    final repository = ref.read(wishlistRepositoryProvider);
    final result = await repository.removeFromWishlist(productId);

    result.fold(
      (failure) => throw failure,
      (_) {
        ref.invalidateSelf();
      },
    );
  }

  Future<bool> checkWishlist(String productId) async {
    final repository = ref.read(wishlistRepositoryProvider);
    final result = await repository.checkWishlist(productId);

    return result.fold(
      (failure) => false,
      (isInWishlist) => isInWishlist,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}

final wishlistCountProvider = Provider<AsyncValue<int>>((ref) {
  final wishlistAsync = ref.watch(wishlistNotifierProvider);
  return wishlistAsync.when(
    data: (wishlist) => AsyncValue.data(wishlist.length),
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
