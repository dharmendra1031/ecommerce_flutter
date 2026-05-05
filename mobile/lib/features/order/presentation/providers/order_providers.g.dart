// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderRemoteDataSourceHash() =>
    r'aaa19271f2b72b1b3c53f6e9dfee13dc9e76b3f1';

/// See also [orderRemoteDataSource].
@ProviderFor(orderRemoteDataSource)
final orderRemoteDataSourceProvider =
    AutoDisposeProvider<OrderRemoteDataSource>.internal(
  orderRemoteDataSource,
  name: r'orderRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrderRemoteDataSourceRef
    = AutoDisposeProviderRef<OrderRemoteDataSource>;
String _$orderRepositoryHash() => r'71880b683d68273e2d06cc4b5710541027abc55b';

/// See also [orderRepository].
@ProviderFor(orderRepository)
final orderRepositoryProvider = AutoDisposeProvider<OrderRepository>.internal(
  orderRepository,
  name: r'orderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrderRepositoryRef = AutoDisposeProviderRef<OrderRepository>;
String _$ordersNotifierHash() => r'37af3260331ace15899bc68d875ec309d4498ada';

/// See also [OrdersNotifier].
@ProviderFor(OrdersNotifier)
final ordersNotifierProvider = AutoDisposeAsyncNotifierProvider<OrdersNotifier,
    List<OrderEntity>>.internal(
  OrdersNotifier.new,
  name: r'ordersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrdersNotifier = AutoDisposeAsyncNotifier<List<OrderEntity>>;
String _$orderDetailNotifierHash() =>
    r'0f1499692284f116b0978bd375672e47e84c28d2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$OrderDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<OrderEntity?> {
  late final String orderId;

  FutureOr<OrderEntity?> build(
    String orderId,
  );
}

/// See also [OrderDetailNotifier].
@ProviderFor(OrderDetailNotifier)
const orderDetailNotifierProvider = OrderDetailNotifierFamily();

/// See also [OrderDetailNotifier].
class OrderDetailNotifierFamily extends Family<AsyncValue<OrderEntity?>> {
  /// See also [OrderDetailNotifier].
  const OrderDetailNotifierFamily();

  /// See also [OrderDetailNotifier].
  OrderDetailNotifierProvider call(
    String orderId,
  ) {
    return OrderDetailNotifierProvider(
      orderId,
    );
  }

  @override
  OrderDetailNotifierProvider getProviderOverride(
    covariant OrderDetailNotifierProvider provider,
  ) {
    return call(
      provider.orderId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderDetailNotifierProvider';
}

/// See also [OrderDetailNotifier].
class OrderDetailNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    OrderDetailNotifier, OrderEntity?> {
  /// See also [OrderDetailNotifier].
  OrderDetailNotifierProvider(
    String orderId,
  ) : this._internal(
          () => OrderDetailNotifier()..orderId = orderId,
          from: orderDetailNotifierProvider,
          name: r'orderDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$orderDetailNotifierHash,
          dependencies: OrderDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              OrderDetailNotifierFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  OrderDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  FutureOr<OrderEntity?> runNotifierBuild(
    covariant OrderDetailNotifier notifier,
  ) {
    return notifier.build(
      orderId,
    );
  }

  @override
  Override overrideWith(OrderDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailNotifierProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<OrderDetailNotifier, OrderEntity?>
      createElement() {
    return _OrderDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailNotifierProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<OrderEntity?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<OrderDetailNotifier,
        OrderEntity?> with OrderDetailNotifierRef {
  _OrderDetailNotifierProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailNotifierProvider).orderId;
}

String _$createOrderNotifierHash() =>
    r'3d777a64ab69283df86e1c52454a2a0fe5688799';

/// See also [CreateOrderNotifier].
@ProviderFor(CreateOrderNotifier)
final createOrderNotifierProvider = AutoDisposeNotifierProvider<
    CreateOrderNotifier, AsyncValue<OrderEntity?>>.internal(
  CreateOrderNotifier.new,
  name: r'createOrderNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createOrderNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateOrderNotifier = AutoDisposeNotifier<AsyncValue<OrderEntity?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
