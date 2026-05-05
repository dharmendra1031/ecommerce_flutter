// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentRemoteDataSourceHash() =>
    r'7d92a4cdfc35f6ae7aeab21bd4c6f784ff89e001';

/// See also [paymentRemoteDataSource].
@ProviderFor(paymentRemoteDataSource)
final paymentRemoteDataSourceProvider =
    AutoDisposeProvider<PaymentRemoteDataSource>.internal(
  paymentRemoteDataSource,
  name: r'paymentRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentRemoteDataSourceRef
    = AutoDisposeProviderRef<PaymentRemoteDataSource>;
String _$paymentRepositoryHash() => r'01c84e7de9a74dedc010e4b60d2e5d5352e7131b';

/// See also [paymentRepository].
@ProviderFor(paymentRepository)
final paymentRepositoryProvider =
    AutoDisposeProvider<PaymentRepository>.internal(
  paymentRepository,
  name: r'paymentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentRepositoryRef = AutoDisposeProviderRef<PaymentRepository>;
String _$paymentNotifierHash() => r'60c6cd4da0c1364d2e701f68c38a14c4d249a125';

/// See also [PaymentNotifier].
@ProviderFor(PaymentNotifier)
final paymentNotifierProvider = AutoDisposeNotifierProvider<PaymentNotifier,
    AsyncValue<PaymentResult?>>.internal(
  PaymentNotifier.new,
  name: r'paymentNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaymentNotifier = AutoDisposeNotifier<AsyncValue<PaymentResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
