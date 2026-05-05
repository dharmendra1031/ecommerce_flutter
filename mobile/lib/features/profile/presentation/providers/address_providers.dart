import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../data/datasources/address_remote_datasource.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';

part 'address_providers.g.dart';

@riverpod
AddressRemoteDataSource addressRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AddressRemoteDataSourceImpl(dioClient);
}

@riverpod
AddressRepository addressRepository(Ref ref) {
  final remoteDataSource = ref.watch(addressRemoteDataSourceProvider);
  return AddressRepositoryImpl(remoteDataSource);
}

@riverpod
class AddressesNotifier extends _$AddressesNotifier {
  @override
  Future<List<AddressEntity>> build() async {
    final repository = ref.read(addressRepositoryProvider);
    final result = await repository.getAddresses();

    return result.fold(
      (failure) => throw failure,
      (addresses) => addresses,
    );
  }

  Future<Failure?> addAddress({
    required String label,
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String stateName,
    required String postalCode,
    required String country,
    required bool isDefault,
  }) async {
    final repository = ref.read(addressRepositoryProvider);
    final result = await repository.addAddress(
      label: label,
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      stateName: stateName,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault,
    );

    return result.fold(
      (failure) => failure,
      (newAddress) {
        final currentAddresses = state.valueOrNull ?? [];
        if (isDefault) {
          final updatedAddresses = currentAddresses.map((a) {
            if (a.isDefault) {
              return AddressEntity(
                id: a.id,
                label: a.label,
                fullName: a.fullName,
                phone: a.phone,
                address: a.address,
                city: a.city,
                state: a.state,
                postalCode: a.postalCode,
                country: a.country,
                isDefault: false,
                createdAt: a.createdAt,
                updatedAt: a.updatedAt,
              );
            }
            return a;
          }).toList();
          state = AsyncValue.data([...updatedAddresses, newAddress]);
        } else {
          state = AsyncValue.data([...currentAddresses, newAddress]);
        }
        return null;
      },
    );
  }

  Future<Failure?> updateAddress({
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
  }) async {
    final repository = ref.read(addressRepositoryProvider);
    final result = await repository.updateAddress(
      id: id,
      label: label,
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      stateName: stateName,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault,
    );

    return result.fold(
      (failure) => failure,
      (updatedAddress) {
        final currentAddresses = state.valueOrNull ?? [];
        final updatedAddresses = currentAddresses.map((a) {
          if (a.id == id) {
            return updatedAddress;
          }
          if (isDefault && a.isDefault) {
            return AddressEntity(
              id: a.id,
              label: a.label,
              fullName: a.fullName,
              phone: a.phone,
              address: a.address,
              city: a.city,
              state: a.state,
              postalCode: a.postalCode,
              country: a.country,
              isDefault: false,
              createdAt: a.createdAt,
              updatedAt: a.updatedAt,
            );
          }
          return a;
        }).toList();
        state = AsyncValue.data(updatedAddresses);
        return null;
      },
    );
  }

  Future<Failure?> deleteAddress(String id) async {
    final repository = ref.read(addressRepositoryProvider);
    final result = await repository.deleteAddress(id);

    return result.fold(
      (failure) => failure,
      (_) {
        final currentAddresses = state.valueOrNull ?? [];
        state = AsyncValue.data(
          currentAddresses.where((a) => a.id != id).toList(),
        );
        return null;
      },
    );
  }

  Future<Failure?> setDefaultAddress(String id) async {
    final repository = ref.read(addressRepositoryProvider);
    final result = await repository.setDefaultAddress(id);

    return result.fold(
      (failure) => failure,
      (defaultAddress) {
        final currentAddresses = state.valueOrNull ?? [];
        final updatedAddresses = currentAddresses.map((a) {
          if (a.id == id) {
            return defaultAddress;
          }
          if (a.isDefault) {
            return AddressEntity(
              id: a.id,
              label: a.label,
              fullName: a.fullName,
              phone: a.phone,
              address: a.address,
              city: a.city,
              state: a.state,
              postalCode: a.postalCode,
              country: a.country,
              isDefault: false,
              createdAt: a.createdAt,
              updatedAt: a.updatedAt,
            );
          }
          return a;
        }).toList();
        state = AsyncValue.data(updatedAddresses);
        return null;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}

@riverpod
AddressEntity? defaultAddress(Ref ref) {
  final addressesAsync = ref.watch(addressesNotifierProvider);
  return addressesAsync.whenOrNull(
    data: (addresses) {
      if (addresses.isEmpty) return null;
      return addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
    },
  );
}
