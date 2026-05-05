import 'package:equatable/equatable.dart';

enum NotificationType {
  order,
  promo,
  system;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => NotificationType.system,
    );
  }
}

class NotificationData extends Equatable {
  final String? orderId;
  final String? reviewId;
  final String? productId;
  final String? status;

  const NotificationData({
    this.orderId,
    this.reviewId,
    this.productId,
    this.status,
  });

  @override
  List<Object?> get props => [orderId, reviewId, productId, status];
}

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final NotificationData? data;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    NotificationData? data,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, isRead, data, createdAt];
}

class PaginatedNotifications {
  final List<NotificationEntity> notifications;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginatedNotifications({
    required this.notifications,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });
}
