import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();

  Future<AddressModel> addAddress({
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

  Future<AddressModel> updateAddress({
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

  Future<void> deleteAddress(String id);

  Future<AddressModel> setDefaultAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final DioClient _dioClient;

  AddressRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.addresses,
    );

    final data = response['data'] as Map<String, dynamic>;
    final addresses = data['addresses'] as List<dynamic>;
    return addresses
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AddressModel> addAddress({
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
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.addresses,
      data: {
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'state': stateName,
        'postalCode': postalCode,
        'country': country,
        'isDefault': isDefault,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data['address'] as Map<String, dynamic>);
  }

  @override
  Future<AddressModel> updateAddress({
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
    final response = await _dioClient.put<Map<String, dynamic>>(
      '${ApiConstants.addresses}/$id',
      data: {
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'state': stateName,
        'postalCode': postalCode,
        'country': country,
        'isDefault': isDefault,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data['address'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _dioClient.delete<void>('${ApiConstants.addresses}/$id');
  }

  @override
  Future<AddressModel> setDefaultAddress(String id) async {
    final response = await _dioClient.patch<Map<String, dynamic>>(
      '${ApiConstants.addresses}/$id/default',
    );

    final data = response['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data['address'] as Map<String, dynamic>);
  }
}
