// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewRemoteDataSourceHash() =>
    r'cb714dd27bdb1457cec63a36113457962ba0e5bc';

/// See also [reviewRemoteDataSource].
@ProviderFor(reviewRemoteDataSource)
final reviewRemoteDataSourceProvider =
    AutoDisposeProvider<ReviewRemoteDataSource>.internal(
  reviewRemoteDataSource,
  name: r'reviewRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewRemoteDataSourceRef
    = AutoDisposeProviderRef<ReviewRemoteDataSource>;
String _$reviewRepositoryHash() => r'b92961a0a5d162e38025b24df9b74a69dd78fd77';

/// See also [reviewRepository].
@ProviderFor(reviewRepository)
final reviewRepositoryProvider = AutoDisposeProvider<ReviewRepository>.internal(
  reviewRepository,
  name: r'reviewRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewRepositoryRef = AutoDisposeProviderRef<ReviewRepository>;
String _$productReviewsNotifierHash() =>
    r'5ee2732f1014a2964ec59b8f0fa7d4f20438dcb3';

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

abstract class _$ProductReviewsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ReviewEntity>> {
  late final String productId;

  FutureOr<List<ReviewEntity>> build(
    String productId,
  );
}

/// See also [ProductReviewsNotifier].
@ProviderFor(ProductReviewsNotifier)
const productReviewsNotifierProvider = ProductReviewsNotifierFamily();

/// See also [ProductReviewsNotifier].
class ProductReviewsNotifierFamily
    extends Family<AsyncValue<List<ReviewEntity>>> {
  /// See also [ProductReviewsNotifier].
  const ProductReviewsNotifierFamily();

  /// See also [ProductReviewsNotifier].
  ProductReviewsNotifierProvider call(
    String productId,
  ) {
    return ProductReviewsNotifierProvider(
      productId,
    );
  }

  @override
  ProductReviewsNotifierProvider getProviderOverride(
    covariant ProductReviewsNotifierProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'productReviewsNotifierProvider';
}

/// See also [ProductReviewsNotifier].
class ProductReviewsNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProductReviewsNotifier,
        List<ReviewEntity>> {
  /// See also [ProductReviewsNotifier].
  ProductReviewsNotifierProvider(
    String productId,
  ) : this._internal(
          () => ProductReviewsNotifier()..productId = productId,
          from: productReviewsNotifierProvider,
          name: r'productReviewsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productReviewsNotifierHash,
          dependencies: ProductReviewsNotifierFamily._dependencies,
          allTransitiveDependencies:
              ProductReviewsNotifierFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductReviewsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  FutureOr<List<ReviewEntity>> runNotifierBuild(
    covariant ProductReviewsNotifier notifier,
  ) {
    return notifier.build(
      productId,
    );
  }

  @override
  Override overrideWith(ProductReviewsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductReviewsNotifierProvider._internal(
        () => create()..productId = productId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductReviewsNotifier,
      List<ReviewEntity>> createElement() {
    return _ProductReviewsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductReviewsNotifierProvider &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductReviewsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ReviewEntity>> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductReviewsNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductReviewsNotifier,
        List<ReviewEntity>> with ProductReviewsNotifierRef {
  _ProductReviewsNotifierProviderElement(super.provider);

  @override
  String get productId => (origin as ProductReviewsNotifierProvider).productId;
}

String _$myReviewsNotifierHash() => r'4643b5c359a28b091cd79ac075da424ed253ec20';

/// See also [MyReviewsNotifier].
@ProviderFor(MyReviewsNotifier)
final myReviewsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    MyReviewsNotifier, List<ReviewEntity>>.internal(
  MyReviewsNotifier.new,
  name: r'myReviewsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myReviewsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyReviewsNotifier = AutoDisposeAsyncNotifier<List<ReviewEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
