import '../../domain/entities/review_entity.dart';

class ReviewModel {
  final String id;
  final UserInfoModel user;
  final String product;
  final ProductInfoModel? productInfo;
  final int rating;
  final String title;
  final String comment;
  final bool isVerifiedPurchase;
  final DateTime createdAt;

  const ReviewModel({
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

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Product can be either a String (ID) or an object (populated)
    final dynamic productData = json['product'];
    String productId;
    ProductInfoModel? productInfo;

    if (productData is String) {
      productId = productData;
    } else if (productData is Map) {
      final productMap = productData as Map<String, dynamic>;
      productId = productMap['_id']?.toString() ?? '';
      productInfo = ProductInfoModel.fromJson(productMap);
    } else {
      productId = '';
    }

    // Handle user which can be String (ID) or Map (populated)
    UserInfoModel user;
    final userData = json['user'];
    if (userData is Map) {
      user = UserInfoModel.fromJson(userData as Map<String, dynamic>);
    } else {
      // If user is just an ID or null, create a default user
      user = const UserInfoModel(name: 'Anonymous');
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? '',
      user: user,
      product: productId,
      productInfo: productInfo,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'product': product,
      'rating': rating,
      'title': title,
      'comment': comment,
      'isVerifiedPurchase': isVerifiedPurchase,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      user: user.toEntity(),
      product: product,
      productInfo: productInfo?.toEntity(),
      rating: rating,
      title: title,
      comment: comment,
      isVerifiedPurchase: isVerifiedPurchase,
      createdAt: createdAt,
    );
  }
}

class ProductInfoModel {
  final String id;
  final String name;
  final String? image;
  final String? slug;

  const ProductInfoModel({
    required this.id,
    required this.name,
    this.image,
    this.slug,
  });

  factory ProductInfoModel.fromJson(Map<String, dynamic> json) {
    // Parse images array if present
    String? firstImage;
    final images = json['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      final imageData = images.first is Map ? images.first as Map<String, dynamic> : null;
      firstImage = imageData?['url']?.toString();
    }

    return ProductInfoModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: firstImage,
      slug: json['slug']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'slug': slug,
    };
  }

  ProductInfo toEntity() {
    return ProductInfo(
      id: id,
      name: name,
      image: image,
      slug: slug,
    );
  }
}

class UserInfoModel {
  final String name;
  final String? avatar;

  const UserInfoModel({
    required this.name,
    this.avatar,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    // Avatar can be a String (direct URL) or an Object {url, public_id}
    String? avatarUrl;
    final avatarData = json['avatar'];
    if (avatarData is String) {
      avatarUrl = avatarData;
    } else if (avatarData is Map) {
      avatarUrl = avatarData['url']?.toString();
    }

    return UserInfoModel(
      name: json['name']?.toString() ?? 'Anonymous',
      avatar: avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
    };
  }

  UserInfo toEntity() {
    return UserInfo(
      name: name,
      avatar: avatar,
    );
  }
}
