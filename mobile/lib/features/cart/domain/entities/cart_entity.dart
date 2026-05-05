import 'package:equatable/equatable.dart';

class CartEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        subtotal,
        shippingCost,
        tax,
        total,
        createdAt,
        updatedAt,
      ];

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartEntity copyWith({
    String? id,
    String? userId,
    List<CartItemEntity>? items,
    double? subtotal,
    double? shippingCost,
    double? tax,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String name;
  final String slug;
  final String? sku;
  final String image;
  final double price;
  final double? comparePrice;
  final int quantity;
  final int stock;
  final Map<String, String>? selectedVariants;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.name,
    required this.slug,
    this.sku,
    required this.image,
    required this.price,
    this.comparePrice,
    required this.quantity,
    required this.stock,
    this.selectedVariants,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        name,
        slug,
        sku,
        image,
        price,
        comparePrice,
        quantity,
        stock,
        selectedVariants,
        addedAt,
      ];

  double get totalPrice => price * quantity;

  int? get discountPercentage {
    if (comparePrice == null || comparePrice! <= price) return null;
    return ((comparePrice! - price) / comparePrice! * 100).round();
  }

  bool get isOnSale => comparePrice != null && comparePrice! > price;

  bool get isInStock => stock > 0 && quantity <= stock;

  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? name,
    String? slug,
    String? sku,
    String? image,
    double? price,
    double? comparePrice,
    int? quantity,
    int? stock,
    Map<String, String>? selectedVariants,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      sku: sku ?? this.sku,
      image: image ?? this.image,
      price: price ?? this.price,
      comparePrice: comparePrice ?? this.comparePrice,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
