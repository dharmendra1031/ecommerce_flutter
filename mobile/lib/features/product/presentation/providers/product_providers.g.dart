// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRemoteDataSourceHash() =>
    r'954798907bb0c9baade27b84eaba612a5dec8f68';

/// See also [productRemoteDataSource].
@ProviderFor(productRemoteDataSource)
final productRemoteDataSourceProvider =
    AutoDisposeProvider<ProductRemoteDataSource>.internal(
  productRemoteDataSource,
  name: r'productRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductRemoteDataSourceRef
    = AutoDisposeProviderRef<ProductRemoteDataSource>;
String _$productRepositoryHash() => r'3ae178f2642f0ec2588bd2e6b51b2b67141ea468';

/// See also [productRepository].
@ProviderFor(productRepository)
final productRepositoryProvider =
    AutoDisposeProvider<ProductRepository>.internal(
  productRepository,
  name: r'productRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductRepositoryRef = AutoDisposeProviderRef<ProductRepository>;
String _$productsNotifierHash() => r'6ad1d9b5a99bc4086381b2a4cf32946407552655';

/// See also [ProductsNotifier].
@ProviderFor(ProductsNotifier)
final productsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ProductsNotifier, List<ProductEntity>>.internal(
  ProductsNotifier.new,
  name: r'productsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductsNotifier = AutoDisposeAsyncNotifier<List<ProductEntity>>;
String _$featuredProductsNotifierHash() =>
    r'fc90f2119971682cc4871a82f20dd13981fbec8c';

/// See also [FeaturedProductsNotifier].
@ProviderFor(FeaturedProductsNotifier)
final featuredProductsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    FeaturedProductsNotifier, List<ProductEntity>>.internal(
  FeaturedProductsNotifier.new,
  name: r'featuredProductsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featuredProductsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FeaturedProductsNotifier
    = AutoDisposeAsyncNotifier<List<ProductEntity>>;
String _$flashSaleNotifierHash() => r'13057b9e361b1f4d9e3802e7051e35755b10d696';

/// See also [FlashSaleNotifier].
@ProviderFor(FlashSaleNotifier)
final flashSaleNotifierProvider = AutoDisposeAsyncNotifierProvider<
    FlashSaleNotifier, FlashSaleState>.internal(
  FlashSaleNotifier.new,
  name: r'flashSaleNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$flashSaleNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FlashSaleNotifier = AutoDisposeAsyncNotifier<FlashSaleState>;
String _$categoriesNotifierHash() =>
    r'6b33e468538575c1d73464aeed6b4a005117fa58';

/// See also [CategoriesNotifier].
@ProviderFor(CategoriesNotifier)
final categoriesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    CategoriesNotifier, List<CategoryEntity>>.internal(
  CategoriesNotifier.new,
  name: r'categoriesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoriesNotifier = AutoDisposeAsyncNotifier<List<CategoryEntity>>;
String _$productDetailNotifierHash() =>
    r'ee4819c35047570e264006c294c7060bd8d7a155';

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

abstract class _$ProductDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<ProductEntity?> {
  late final String productId;

  FutureOr<ProductEntity?> build(
    String productId,
  );
}

/// See also [ProductDetailNotifier].
@ProviderFor(ProductDetailNotifier)
const productDetailNotifierProvider = ProductDetailNotifierFamily();

/// See also [ProductDetailNotifier].
class ProductDetailNotifierFamily extends Family<AsyncValue<ProductEntity?>> {
  /// See also [ProductDetailNotifier].
  const ProductDetailNotifierFamily();

  /// See also [ProductDetailNotifier].
  ProductDetailNotifierProvider call(
    String productId,
  ) {
    return ProductDetailNotifierProvider(
      productId,
    );
  }

  @override
  ProductDetailNotifierProvider getProviderOverride(
    covariant ProductDetailNotifierProvider provider,
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
  String? get name => r'productDetailNotifierProvider';
}

/// See also [ProductDetailNotifier].
class ProductDetailNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProductDetailNotifier,
        ProductEntity?> {
  /// See also [ProductDetailNotifier].
  ProductDetailNotifierProvider(
    String productId,
  ) : this._internal(
          () => ProductDetailNotifier()..productId = productId,
          from: productDetailNotifierProvider,
          name: r'productDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productDetailNotifierHash,
          dependencies: ProductDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              ProductDetailNotifierFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductDetailNotifierProvider._internal(
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
  FutureOr<ProductEntity?> runNotifierBuild(
    covariant ProductDetailNotifier notifier,
  ) {
    return notifier.build(
      productId,
    );
  }

  @override
  Override overrideWith(ProductDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ProductDetailNotifier, ProductEntity?>
      createElement() {
    return _ProductDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailNotifierProvider &&
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
mixin ProductDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<ProductEntity?> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductDetailNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductDetailNotifier,
        ProductEntity?> with ProductDetailNotifierRef {
  _ProductDetailNotifierProviderElement(super.provider);

  @override
  String get productId => (origin as ProductDetailNotifierProvider).productId;
}

String _$productSearchNotifierHash() =>
    r'38da1ab557057cdedee9511be728d5682a70cfdb';

/// See also [ProductSearchNotifier].
@ProviderFor(ProductSearchNotifier)
final productSearchNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ProductSearchNotifier, List<ProductEntity>>.internal(
  ProductSearchNotifier.new,
  name: r'productSearchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productSearchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductSearchNotifier = AutoDisposeAsyncNotifier<List<ProductEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
