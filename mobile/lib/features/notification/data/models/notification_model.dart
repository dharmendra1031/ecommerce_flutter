import '../../domain/entities/notification_entity.dart';

class NotificationDataModel {
  final String? orderId;
  final String? reviewId;
  final String? productId;
  final String? status;

  const NotificationDataModel({
    this.orderId,
    this.reviewId,
    this.productId,
    this.status,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      orderId: json['orderId'] as String?,
      reviewId: json['reviewId'] as String?,
      productId: json['productId'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'reviewId': reviewId,
      'productId': productId,
      'status': status,
    };
  }

  NotificationData toEntity() {
    return NotificationData(
      orderId: orderId,
      reviewId: reviewId,
      productId: productId,
      status: status,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final NotificationDataModel? data;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool,
      data: json['data'] != null
          ? NotificationDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'data': data?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      type: NotificationType.fromString(type),
      isRead: isRead,
      data: data?.toEntity(),
      createdAt: createdAt,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    NotificationDataModel? data,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
