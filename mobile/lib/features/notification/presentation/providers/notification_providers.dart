import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';

part 'notification_providers.g.dart';

@riverpod
NotificationRemoteDataSource notificationRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationRemoteDataSourceImpl(dioClient);
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource);
}

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<NotificationEntity>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchNotifications();
  }

  Future<List<NotificationEntity>> _fetchNotifications() async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.getNotifications(
      page: _page,
      limit: 10,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) {
        _hasMore = _page < paginated.pages;
        return paginated.notifications;
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentNotifications = state.valueOrNull ?? [];
    state = const AsyncValue.loading();

    _page++;
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.getNotifications(page: _page, limit: 10);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (paginated) {
        _hasMore = _page < paginated.pages;
        return AsyncValue.data([...currentNotifications, ...paginated.notifications]);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    ref.invalidateSelf();
  }

  Future<Failure?> markAsRead(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAsRead(id);

    return result.fold(
      (failure) => failure,
      (notification) {
        final currentNotifications = state.valueOrNull ?? [];
        final updatedNotifications = currentNotifications.map((n) {
          return n.id == notification.id ? notification : n;
        }).toList();
        state = AsyncValue.data(updatedNotifications);
        ref.invalidate(unreadCountNotifierProvider);
        return null;
      },
    );
  }

  Future<Failure?> markAllAsRead() async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAllAsRead();

    return result.fold(
      (failure) => failure,
      (_) {
        final currentNotifications = state.valueOrNull ?? [];
        final updatedNotifications = currentNotifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        state = AsyncValue.data(updatedNotifications);
        ref.invalidate(unreadCountNotifierProvider);
        return null;
      },
    );
  }

  Future<Failure?> deleteNotification(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.deleteNotification(id);

    return result.fold(
      (failure) => failure,
      (_) {
        final currentNotifications = state.valueOrNull ?? [];
        final updatedNotifications =
            currentNotifications.where((n) => n.id != id).toList();
        state = AsyncValue.data(updatedNotifications);
        ref.invalidate(unreadCountNotifierProvider);
        return null;
      },
    );
  }
}

@riverpod
class UnreadCountNotifier extends _$UnreadCountNotifier {
  @override
  Future<int> build() async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.getUnreadCount();

    return result.fold(
      (failure) => throw failure,
      (count) => count,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final hasMoreNotificationsProvider = Provider<bool>((ref) {
  final notifier = ref.read(notificationsNotifierProvider.notifier);
  return notifier._hasMore;
});
