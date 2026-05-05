import '../../domain/entities/cart_entity.dart';

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartModel({
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

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Handle user field which can be either a String (ID) or an Object (populated)
    final dynamic userField = json['user'];
    final String userId;
    if (userField is String) {
      userId = userField;
    } else if (userField is Map<String, dynamic>) {
      userId = userField['_id'] as String? ?? '';
    } else {
      userId = '';
    }

    return CartModel(
      id: json['_id'] as String? ?? '',
      userId: userId,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      userId: userId,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      shippingCost: shippingCost,
      tax: tax,
      total: total,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class CartItemModel {
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

  const CartItemModel({
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

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Handle product field which can be either a String (ID) or an Object (populated)
    final dynamic productField = json['product'];
    final String productId;
    final String productName;
    final String productSlug;
    final String imageUrl;
    final double productPrice;
    final int productStock;

    if (productField is Map<String, dynamic>) {
      // Product is populated - extract data from it
      productId = productField['_id'] as String? ?? '';
      productName = productField['name'] as String? ?? 'Unknown Product';
      productSlug = productField['slug'] as String? ?? '';
      productPrice = (productField['price'] as num?)?.toDouble() ?? 0.0;
      productStock = (productField['stock'] as num?)?.toInt() ?? 0;
      
      // Handle images array
      final images = productField['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images[0];
        if (firstImage is Map<String, dynamic>) {
          imageUrl = firstImage['url'] as String? ?? '';
        } else if (firstImage is String) {
          imageUrl = firstImage;
        } else {
          imageUrl = '';
        }
      } else {
        imageUrl = '';
      }
    } else if (productField is String) {
      // Product is just an ID - use fields from json directly if available
      productId = productField;
      productName = json['name'] as String? ?? 'Unknown Product';
      productSlug = json['slug'] as String? ?? '';
      productPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
      productStock = (json['stock'] as num?)?.toInt() ?? 0;
      
      // Handle image field
      final dynamic imageField = json['image'];
      if (imageField is String) {
        imageUrl = imageField;
      } else if (imageField is Map<String, dynamic>) {
        imageUrl = imageField['url'] as String? ?? '';
      } else {
        imageUrl = '';
      }
    } else {
      productId = '';
      productName = 'Unknown Product';
      productSlug = '';
      productPrice = 0.0;
      productStock = 0;
      imageUrl = '';
    }

    // Handle variant field from backend (converts to selectedVariants)
    final dynamic variantField = json['variant'];
    Map<String, String>? selectedVariants;
    if (variantField is Map<String, dynamic>) {
      final variantName = variantField['name'] as String?;
      final variantValue = variantField['value'] as String?;
      if (variantName != null && variantValue != null) {
        selectedVariants = {variantName: variantValue};
      }
    }

    return CartItemModel(
      id: json['_id'] as String? ?? '',
      productId: productId,
      name: productName,
      slug: productSlug,
      sku: json['sku'] as String?,
      image: imageUrl,
      price: productPrice,
      comparePrice: json['comparePrice'] != null
          ? (json['comparePrice'] as num).toDouble()
          : null,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      stock: productStock,
      selectedVariants: selectedVariants,
      addedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': productId,
      'name': name,
      'slug': slug,
      'sku': sku,
      'image': image,
      'price': price,
      'comparePrice': comparePrice,
      'quantity': quantity,
      'stock': stock,
      'selectedVariants': selectedVariants,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      name: name,
      slug: slug,
      sku: sku,
      image: image,
      price: price,
      comparePrice: comparePrice,
      quantity: quantity,
      stock: stock,
      selectedVariants: selectedVariants,
      addedAt: addedAt,
    );
  }
}
