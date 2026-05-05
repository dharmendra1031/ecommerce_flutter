// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRemoteDataSourceHash() =>
    r'1e298f86f34faaa677512415069b0f7cf4f75c67';

/// See also [profileRemoteDataSource].
@ProviderFor(profileRemoteDataSource)
final profileRemoteDataSourceProvider =
    AutoDisposeProvider<ProfileRemoteDataSource>.internal(
  profileRemoteDataSource,
  name: r'profileRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRemoteDataSourceRef
    = AutoDisposeProviderRef<ProfileRemoteDataSource>;
String _$profileRepositoryHash() => r'80ff30ea97624daea87d2e6947abc235d39ba25c';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$profileStatsNotifierHash() =>
    r'6cbcb55db00baf76fe6398be4797164288522c37';

/// See also [ProfileStatsNotifier].
@ProviderFor(ProfileStatsNotifier)
final profileStatsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ProfileStatsNotifier, ProfileStats>.internal(
  ProfileStatsNotifier.new,
  name: r'profileStatsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileStatsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileStatsNotifier = AutoDisposeAsyncNotifier<ProfileStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
