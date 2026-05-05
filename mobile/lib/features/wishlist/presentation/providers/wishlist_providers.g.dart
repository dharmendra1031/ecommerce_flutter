// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wishlistRemoteDataSourceHash() =>
    r'021dde5778234e610403c0a0dd0c60b1366fd6f5';

/// See also [wishlistRemoteDataSource].
@ProviderFor(wishlistRemoteDataSource)
final wishlistRemoteDataSourceProvider =
    AutoDisposeProvider<WishlistRemoteDataSource>.internal(
  wishlistRemoteDataSource,
  name: r'wishlistRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistRemoteDataSourceRef
    = AutoDisposeProviderRef<WishlistRemoteDataSource>;
String _$wishlistRepositoryHash() =>
    r'c88f41bc12699494f4a906e74a70aa63381711d6';

/// See also [wishlistRepository].
@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider =
    AutoDisposeProvider<WishlistRepository>.internal(
  wishlistRepository,
  name: r'wishlistRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistRepositoryRef = AutoDisposeProviderRef<WishlistRepository>;
String _$wishlistNotifierHash() => r'c04392309893ef6ad36a4685a02b24c628a180e8';

/// See also [WishlistNotifier].
@ProviderFor(WishlistNotifier)
final wishlistNotifierProvider = AutoDisposeAsyncNotifierProvider<
    WishlistNotifier, List<ProductEntity>>.internal(
  WishlistNotifier.new,
  name: r'wishlistNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WishlistNotifier = AutoDisposeAsyncNotifier<List<ProductEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
