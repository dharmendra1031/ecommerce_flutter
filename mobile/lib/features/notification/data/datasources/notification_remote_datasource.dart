import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';
import '../../../product/data/models/pagination_model.dart';

abstract class NotificationRemoteDataSource {
  Future<({List<NotificationModel> notifications, PaginationModel pagination})>
      getNotifications({
    int page,
    int limit,
  });

  Future<int> getUnreadCount();

  Future<NotificationModel> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  NotificationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<({List<NotificationModel> notifications, PaginationModel pagination})>
      getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response['data'] as Map<String, dynamic>;
    final notifications = (data['notifications'] as List<dynamic>)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination =
        PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>);

    return (notifications: notifications, pagination: pagination);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.unreadCount,
    );

    final data = response['data'] as Map<String, dynamic>;
    return data['count'] as int;
  }

  @override
  Future<NotificationModel> markAsRead(String id) async {
    final response = await _dioClient.patch<Map<String, dynamic>>(
      '${ApiConstants.notifications}/$id/read',
    );

    final data = response['data'] as Map<String, dynamic>;
    return NotificationModel.fromJson(data['notification'] as Map<String, dynamic>);
  }

  @override
  Future<void> markAllAsRead() async {
    await _dioClient.patch<Map<String, dynamic>>(
      '${ApiConstants.notifications}/read-all',
    );
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _dioClient.delete<Map<String, dynamic>>(
      '${ApiConstants.notifications}/$id',
    );
  }
}
