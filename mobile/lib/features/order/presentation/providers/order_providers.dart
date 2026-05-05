import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';

part 'order_providers.g.dart';

@riverpod
OrderRemoteDataSource orderRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return OrderRemoteDataSourceImpl(dioClient);
}

@riverpod
OrderRepository orderRepository(Ref ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource);
}

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  int _page = 1;
  bool _hasMore = true;
  OrderStatus? _currentStatus;

  @override
  Future<List<OrderEntity>> build() async {
    _page = 1;
    _hasMore = true;
    _currentStatus = null;
    return _fetchOrders();
  }

  Future<List<OrderEntity>> _fetchOrders() async {
    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.getMyOrders(
      page: _page,
      limit: 10,
      status: _currentStatus,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) {
        _hasMore = _page < paginated.pages;
        return paginated.orders;
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentOrders = state.valueOrNull ?? [];
    state = const AsyncValue.loading();

    _page++;
    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.getMyOrders(
      page: _page,
      limit: 10,
      status: _currentStatus,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (paginated) {
        _hasMore = _page < paginated.pages;
        return AsyncValue.data([...currentOrders, ...paginated.orders]);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    ref.invalidateSelf();
  }

  Future<void> filterByStatus(OrderStatus? status) async {
    _currentStatus = status;
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();

    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.getMyOrders(
      page: _page,
      limit: 10,
      status: status,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (paginated) {
        _hasMore = _page < paginated.pages;
        return AsyncValue.data(paginated.orders);
      },
    );
  }

  Future<Failure?> cancelOrder(String id, String reason) async {
    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.cancelOrder(
      id: id,
      reason: reason,
    );

    return result.fold(
      (failure) => failure,
      (order) {
        final currentOrders = state.valueOrNull ?? [];
        final updatedOrders = currentOrders.map((o) {
          return o.id == order.id ? order : o;
        }).toList();
        state = AsyncValue.data(updatedOrders);
        return null;
      },
    );
  }
}

@riverpod
class OrderDetailNotifier extends _$OrderDetailNotifier {
  @override
  Future<OrderEntity?> build(String orderId) async {
    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.getOrder(orderId);

    return result.fold(
      (failure) => throw failure,
      (order) => order,
    );
  }

  Future<Failure?> cancelOrder(String reason) async {
    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.cancelOrder(
      id: orderId,
      reason: reason,
    );

    return result.fold(
      (failure) => failure,
      (order) {
        state = AsyncValue.data(order);
        return null;
      },
    );
  }
}

@riverpod
class CreateOrderNotifier extends _$CreateOrderNotifier {
  @override
  AsyncValue<OrderEntity?> build() {
    return const AsyncValue.data(null);
  }

  Future<(Failure?, OrderEntity?)> createOrder({
    required List<OrderItemEntity> orderItems,
    required ShippingAddressEntity shippingAddress,
    required PaymentInfoEntity paymentInfo,
    required double itemsPrice,
    required double shippingPrice,
    required double taxPrice,
    required double totalPrice,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.createOrder(
      orderItems: orderItems,
      shippingAddress: shippingAddress,
      paymentInfo: paymentInfo,
      itemsPrice: itemsPrice,
      shippingPrice: shippingPrice,
      taxPrice: taxPrice,
      totalPrice: totalPrice,
    );

    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return (failure, null);
      },
      (order) {
        state = AsyncValue.data(order);
        return (null, order);
      },
    );
  }
}

final hasMoreOrdersProvider = Provider<bool>((ref) {
  final notifier = ref.read(ordersNotifierProvider.notifier);
  return notifier._hasMore;
});
