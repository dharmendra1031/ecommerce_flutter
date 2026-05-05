import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../../../product/domain/entities/product_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<ProductEntity>>> getWishlist();
  Future<Either<Failure, void>> addToWishlist(String productId);
  Future<Either<Failure, void>> removeFromWishlist(String productId);
  Future<Either<Failure, bool>> checkWishlist(String productId);
}
