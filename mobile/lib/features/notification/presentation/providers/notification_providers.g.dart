// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationRemoteDataSourceHash() =>
    r'cbc3870b9ff7b3bf7c90f135d521bd1828073dcb';

/// See also [notificationRemoteDataSource].
@ProviderFor(notificationRemoteDataSource)
final notificationRemoteDataSourceProvider =
    AutoDisposeProvider<NotificationRemoteDataSource>.internal(
  notificationRemoteDataSource,
  name: r'notificationRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRemoteDataSourceRef
    = AutoDisposeProviderRef<NotificationRemoteDataSource>;
String _$notificationRepositoryHash() =>
    r'ecfecb73514b4e3713b54be327ce323b398df355';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepository>.internal(
  notificationRepository,
  name: r'notificationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRepositoryRef
    = AutoDisposeProviderRef<NotificationRepository>;
String _$notificationsNotifierHash() =>
    r'3e1a3b2882bdf4b1d56ff2b9a109abf1b8219909';

/// See also [NotificationsNotifier].
@ProviderFor(NotificationsNotifier)
final notificationsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    NotificationsNotifier, List<NotificationEntity>>.internal(
  NotificationsNotifier.new,
  name: r'notificationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationsNotifier
    = AutoDisposeAsyncNotifier<List<NotificationEntity>>;
String _$unreadCountNotifierHash() =>
    r'b4b74d11aa9f5dbf3dc2fb0270d907b6ef923937';

/// See also [UnreadCountNotifier].
@ProviderFor(UnreadCountNotifier)
final unreadCountNotifierProvider =
    AutoDisposeAsyncNotifierProvider<UnreadCountNotifier, int>.internal(
  UnreadCountNotifier.new,
  name: r'unreadCountNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadCountNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnreadCountNotifier = AutoDisposeAsyncNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
