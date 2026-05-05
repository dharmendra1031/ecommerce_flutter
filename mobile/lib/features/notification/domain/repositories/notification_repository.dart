import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, PaginatedNotifications>> getNotifications({
    int page,
    int limit,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, NotificationEntity>> markAsRead(String id);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(String id);
}
