import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';

part 'cart_providers.g.dart';

@riverpod
CartRemoteDataSource cartRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CartRemoteDataSourceImpl(dioClient);
}

@riverpod
CartRepository cartRepository(Ref ref) {
  final remoteDataSource = ref.watch(cartRemoteDataSourceProvider);
  return CartRepositoryImpl(remoteDataSource);
}

@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  CartRepository? _repository;
  bool _isCleared = false;

  CartRepository get _repo => _repository!;

  @override
  Future<CartEntity?> build() async {
    if (_isCleared) {
      _isCleared = false;
      return null;
    }

    _repository ??= ref.read(cartRepositoryProvider);

    final result = await _repo.getCart();

    return result.fold(
      (failure) => null,
      (cart) => cart,
    );
  }

  Future<Failure?> addToCart({
    required String productId,
    required int quantity,
    Map<String, String>? selectedVariants,
  }) async {
    _isCleared = false;

    final result = await _repo.addToCart(
      productId: productId,
      quantity: quantity,
      selectedVariants: selectedVariants,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure;
      },
      (cart) {
        state = AsyncValue.data(cart);
        return null;
      },
    );
  }

  Future<Failure?> updateItem({
    required String itemId,
    required int quantity,
  }) async {
    if (quantity < 1) {
      return removeItem(itemId);
    }

    final result = await _repo.updateItem(
      itemId: itemId,
      quantity: quantity,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure;
      },
      (cart) {
        state = AsyncValue.data(cart);
        return null;
      },
    );
  }

  Future<Failure?> removeItem(String itemId) async {
    final result = await _repo.removeItem(itemId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure;
      },
      (cart) {
        state = AsyncValue.data(cart);
        return null;
      },
    );
  }

  Future<Failure?> clearCart() async {
    final result = await _repo.clearCart();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return failure;
      },
      (_) {
        _isCleared = true;
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}

final cartBadgeCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartNotifierProvider);
  return cartState.when(
    data: (cart) => cart?.itemCount ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartNotifierProvider);
  return cartState.when(
    data: (cart) => cart?.subtotal ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartNotifierProvider);
  return cartState.when(
    data: (cart) => cart?.total ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final cartItemsProvider = Provider<List<CartItemEntity>>((ref) {
  final cartState = ref.watch(cartNotifierProvider);
  return cartState.when(
    data: (cart) => cart?.items ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});
