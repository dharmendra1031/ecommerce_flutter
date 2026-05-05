import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../../../core/utils/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late final AuthRepository _repository;
  late final SecureStorageService _storage;

  @override
  Future<UserEntity?> build() async {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(secureStorageServiceProvider);

    final token = await _storage.getAccessToken();
    if (token == null) return null;

    final result = await _repository.getCurrentUser();
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  Future<Failure?> login(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _repository.login(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure;
      },
      (authResult) async {
        await _storage.setAccessToken(authResult.accessToken);
        await _storage.setRefreshToken(authResult.refreshToken);
        state = AsyncValue.data(authResult.user);
        return null;
      },
    );
  }

  Future<Failure?> register(String name, String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure;
      },
      (authResult) async {
        await _storage.setAccessToken(authResult.accessToken);
        await _storage.setRefreshToken(authResult.refreshToken);
        state = AsyncValue.data(authResult.user);
        return null;
      },
    );
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore network errors during logout — still clear local state
    }
    await _storage.clearAll();
    state = const AsyncValue.data(null);
  }

  Future<Failure?> forgotPassword(String email) async {
    final result = await _repository.forgotPassword(email);
    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }

  Future<Failure?> resetPassword(String token, String password) async {
    final result = await _repository.resetPassword(
      token: token,
      password: password,
    );
    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }

  Future<Failure?> updatePassword(
      String currentPassword, String newPassword) async {
    final result = await _repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }

  Future<Failure?> sendVerificationEmail() async {
    final result = await _repository.sendVerificationEmail();
    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }

  Future<Failure?> refreshUser() async {
    final result = await _repository.getCurrentUser();
    return result.fold(
      (failure) => failure,
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  Future<Failure?> updateProfile({
    required String name,
    String? phone,
  }) async {
    final result = await _repository.updateProfile(
      name: name,
      phone: phone,
    );

    return result.fold(
      (failure) => failure,
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull != null;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isEmailVerified ?? false;
});
