import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String password,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<RefreshTokenResponseModel> refreshToken(String refreshToken);

  Future<UserModel> uploadAvatar(File file);

  Future<void> sendVerificationEmail();

  Future<UserModel> updateProfile({
    required String name,
    String? phone,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _dioClient.post<void>(ApiConstants.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response =
        await _dioClient.get<Map<String, dynamic>>(ApiConstants.me);
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(user);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.post<void>(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _dioClient.put<void>(
      '${ApiConstants.resetPassword}/$token',
      data: {'password': password},
    );
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dioClient.put<void>(
      ApiConstants.updatePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<RefreshTokenResponseModel> refreshToken(String refreshToken) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    final data = response['data'] as Map<String, dynamic>;
    return RefreshTokenResponseModel.fromJson(data);
  }

  @override
  Future<UserModel> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(file.path),
    });

    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.avatar,
      data: formData,
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(user);
  }

  @override
  Future<void> sendVerificationEmail() async {
    await _dioClient.post<void>(ApiConstants.sendVerification);
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (phone != null) {
      body['phone'] = phone;
    }

    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.profile,
      data: body,
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(user);
  }
}
