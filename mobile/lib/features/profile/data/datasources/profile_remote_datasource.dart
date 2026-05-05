import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class ProfileStats {
  final int ordersCount;
  final int wishlistCount;
  final int reviewsCount;

  const ProfileStats({
    required this.ordersCount,
    required this.wishlistCount,
    required this.reviewsCount,
  });
}

abstract class ProfileRemoteDataSource {
  Future<ProfileStats> getProfileStats();
  Future<void> updateProfile({required String name, String? phone});
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> deleteAccount();
  Future<Map<String, dynamic>> uploadAvatar(File imageFile);
  Future<void> deleteAvatar();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ProfileStats> getProfileStats() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.profile,
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;

    return ProfileStats(
      ordersCount: user['ordersCount'] as int? ?? 0,
      wishlistCount: (user['wishlist'] as List?)?.length ?? 0,
      reviewsCount: user['reviewsCount'] as int? ?? 0,
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.profile,
      data: {
        'name': name,
        if (phone != null) 'phone': phone,
      },
    );
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.updatePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<void> deleteAccount() async {
    await _dioClient.delete<Map<String, dynamic>>(
      ApiConstants.profile,
    );
  }

  @override
  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.avatar,
      data: formData,
    );

    return response['data']['avatar'] as Map<String, dynamic>;
  }

  @override
  Future<void> deleteAvatar() async {
    await _dioClient.delete<Map<String, dynamic>>(
      ApiConstants.avatar,
    );
  }
}
