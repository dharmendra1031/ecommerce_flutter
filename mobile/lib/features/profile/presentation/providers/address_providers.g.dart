// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addressRemoteDataSourceHash() =>
    r'94b151c46de9ec29834145785813961d54e6e6be';

/// See also [addressRemoteDataSource].
@ProviderFor(addressRemoteDataSource)
final addressRemoteDataSourceProvider =
    AutoDisposeProvider<AddressRemoteDataSource>.internal(
  addressRemoteDataSource,
  name: r'addressRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addressRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddressRemoteDataSourceRef
    = AutoDisposeProviderRef<AddressRemoteDataSource>;
String _$addressRepositoryHash() => r'9b985e4d86ed01ea1db9d272a30f23cd418306a3';

/// See also [addressRepository].
@ProviderFor(addressRepository)
final addressRepositoryProvider =
    AutoDisposeProvider<AddressRepository>.internal(
  addressRepository,
  name: r'addressRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addressRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddressRepositoryRef = AutoDisposeProviderRef<AddressRepository>;
String _$defaultAddressHash() => r'e84bfa88776192adebfc15add280a9b87af25f7b';

/// See also [defaultAddress].
@ProviderFor(defaultAddress)
final defaultAddressProvider = AutoDisposeProvider<AddressEntity?>.internal(
  defaultAddress,
  name: r'defaultAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultAddressRef = AutoDisposeProviderRef<AddressEntity?>;
String _$addressesNotifierHash() => r'f4440ba8e3d0bbee4d6c9415cdb122098404465c';

/// See also [AddressesNotifier].
@ProviderFor(AddressesNotifier)
final addressesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    AddressesNotifier, List<AddressEntity>>.internal(
  AddressesNotifier.new,
  name: r'addressesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addressesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AddressesNotifier = AutoDisposeAsyncNotifier<List<AddressEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
