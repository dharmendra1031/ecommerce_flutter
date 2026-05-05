import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';
import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();

  Future<Either<Failure, AddressEntity>> addAddress({
    required String label,
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String stateName,
    required String postalCode,
    required String country,
    required bool isDefault,
  });

  Future<Either<Failure, AddressEntity>> updateAddress({
    required String id,
    required String label,
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String stateName,
    required String postalCode,
    required String country,
    required bool isDefault,
  });

  Future<Either<Failure, void>> deleteAddress(String id);

  Future<Either<Failure, AddressEntity>> setDefaultAddress(String id);
}
