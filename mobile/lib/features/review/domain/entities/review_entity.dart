import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final UserInfo user;
  final String product;
  final ProductInfo? productInfo;
  final int rating;
  final String title;
  final String comment;
  final bool isVerifiedPurchase;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.user,
    required this.product,
    this.productInfo,
    required this.rating,
    required this.title,
    required this.comment,
    this.isVerifiedPurchase = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        user,
        product,
        productInfo,
        rating,
        title,
        comment,
        isVerifiedPurchase,
        createdAt,
      ];
}

class UserInfo extends Equatable {
  final String name;
  final String? avatar;

  const UserInfo({
    required this.name,
    this.avatar,
  });

  @override
  List<Object?> get props => [name, avatar];
}

class ProductInfo extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String? slug;

  const ProductInfo({
    required this.id,
    required this.name,
    this.image,
    this.slug,
  });

  @override
  List<Object?> get props => [id, name, image, slug];
}
