import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? comparePrice;
  final CategoryEntity category;
  final String? brand;
  final List<ProductImageEntity> images;
  final int stock;
  final int sold;
  final double ratings;
  final int numReviews;
  final bool isFeatured;
  final bool isFlashSale;
  final DateTime? flashSaleEndTime;
  final bool isActive;
  final List<ProductVariantEntity> variants;
  final List<ProductSpecificationEntity> specifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.comparePrice,
    required this.category,
    this.brand,
    this.images = const [],
    required this.stock,
    this.sold = 0,
    this.ratings = 0,
    this.numReviews = 0,
    this.isFeatured = false,
    this.isFlashSale = false,
    this.flashSaleEndTime,
    this.isActive = true,
    this.variants = const [],
    this.specifications = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        price,
        comparePrice,
        category,
        brand,
        images,
        stock,
        sold,
        ratings,
        numReviews,
        isFeatured,
        isFlashSale,
        flashSaleEndTime,
        isActive,
        variants,
        specifications,
        createdAt,
        updatedAt,
      ];

  int? get discountPercentage {
    if (comparePrice == null || comparePrice! <= price) return null;
    return ((comparePrice! - price) / comparePrice! * 100).round();
  }

  bool get isOnSale => comparePrice != null && comparePrice! > price;
}

class ProductImageEntity extends Equatable {
  final String publicId;
  final String url;

  const ProductImageEntity({
    required this.publicId,
    required this.url,
  });

  @override
  List<Object?> get props => [publicId, url];
}

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final CategoryImageEntity? image;
  final String? parentId;
  final bool isActive;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.parentId,
    this.isActive = true,
  });

  @override
  List<Object?> get props =>
      [id, name, slug, description, image, parentId, isActive];
}

class CategoryImageEntity extends Equatable {
  final String publicId;
  final String url;

  const CategoryImageEntity({
    required this.publicId,
    required this.url,
  });

  @override
  List<Object?> get props => [publicId, url];
}

class ProductVariantEntity extends Equatable {
  final String name;
  final List<VariantOptionEntity> options;

  const ProductVariantEntity({
    required this.name,
    this.options = const [],
  });

  @override
  List<Object?> get props => [name, options];
}

class VariantOptionEntity extends Equatable {
  final String value;
  final double priceModifier;
  final int stock;

  const VariantOptionEntity({
    required this.value,
    this.priceModifier = 0,
    this.stock = 0,
  });

  @override
  List<Object?> get props => [value, priceModifier, stock];
}

class ProductSpecificationEntity extends Equatable {
  final String key;
  final String value;

  const ProductSpecificationEntity({
    required this.key,
    required this.value,
  });

  @override
  List<Object?> get props => [key, value];
}
