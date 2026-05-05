import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final AvatarModel? avatar;
  final List<String> wishlist;
  final SavedCardModel? savedCard;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.wishlist = const [],
    this.savedCard,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
      avatar: json['avatar'] != null
          ? AvatarModel.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      wishlist: (json['wishlist'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      savedCard: json['savedCard'] != null
          ? SavedCardModel.fromJson(json['savedCard'] as Map<String, dynamic>)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'] as String)?.toLocal()) ??
              DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (DateTime.tryParse(json['updatedAt'] as String)?.toLocal()) ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar?.toJson(),
      'wishlist': wishlist,
      'savedCard': savedCard?.toJson(),
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      avatar: avatar?.toEntity(),
      wishlist: wishlist,
      savedCard: savedCard?.toEntity(),
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AvatarModel {
  final String publicId;
  final String url;

  const AvatarModel({
    required this.publicId,
    required this.url,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      publicId: json['public_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }

  AvatarEntity toEntity() {
    return AvatarEntity(
      publicId: publicId,
      url: url,
    );
  }
}

class SavedCardModel {
  final String? cardNumber;
  final String cardholderName;
  final String expiry;
  final String cvv;
  final String cardType;
  final String last4;

  const SavedCardModel({
    this.cardNumber,
    required this.cardholderName,
    required this.expiry,
    required this.cvv,
    required this.cardType,
    required this.last4,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      cardNumber: json['cardNumber'] as String?,
      cardholderName: json['cardholderName'] as String? ?? '',
      expiry: json['expiry'] as String? ?? '',
      cvv: json['cvv'] as String? ?? '',
      cardType: json['cardType'] as String? ?? '',
      last4: json['last4'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'cardholderName': cardholderName,
      'expiry': expiry,
      'cvv': cvv,
      'cardType': cardType,
      'last4': last4,
    };
  }

  SavedCardEntity toEntity() {
    return SavedCardEntity(
      cardNumber: cardNumber,
      cardholderName: cardholderName,
      expiry: expiry,
      cvv: cvv,
      cardType: cardType,
      last4: last4,
    );
  }
}
