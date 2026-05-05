import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, CartEntity>> addToCart({
    required String productId,
    required int quantity,
    Map<String, String>? selectedVariants,
  });

  Future<Either<Failure, CartEntity>> updateItem({
    required String itemId,
    required int quantity,
  });

  Future<Either<Failure, CartEntity>> removeItem(String itemId);

  Future<Either<Failure, void>> clearCart();
}
