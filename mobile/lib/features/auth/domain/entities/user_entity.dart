import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final AvatarEntity? avatar;
  final List<String> wishlist;
  final SavedCardEntity? savedCard;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
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

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    AvatarEntity? avatar,
    List<String>? wishlist,
    SavedCardEntity? savedCard,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      wishlist: wishlist ?? this.wishlist,
      savedCard: savedCard ?? this.savedCard,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        avatar,
        wishlist,
        savedCard,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];
}

class AvatarEntity extends Equatable {
  final String publicId;
  final String url;

  const AvatarEntity({
    required this.publicId,
    required this.url,
  });

  @override
  List<Object?> get props => [publicId, url];
}

class SavedCardEntity extends Equatable {
  final String? cardNumber;
  final String cardholderName;
  final String expiry;
  final String cvv;
  final String cardType;
  final String last4;

  const SavedCardEntity({
    this.cardNumber,
    required this.cardholderName,
    required this.expiry,
    required this.cvv,
    required this.cardType,
    required this.last4,
  });

  @override
  List<Object?> get props =>
      [cardNumber, cardholderName, expiry, cvv, cardType, last4];
}
