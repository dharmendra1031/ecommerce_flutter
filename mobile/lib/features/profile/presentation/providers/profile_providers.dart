import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileRemoteDataSourceImpl(dioClient);
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
}

@riverpod
class ProfileStatsNotifier extends _$ProfileStatsNotifier {
  @override
  Future<ProfileStats> build() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getProfileStats();

    return result.fold(
      (failure) => throw failure,
      (stats) => stats,
    );
  }

  Future<Failure?> updateProfile({
    required String name,
    String? phone,
  }) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.updateProfile(name: name, phone: phone);

    return result.fold(
      (failure) => failure,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<Failure?> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }

  Future<Failure?> deleteAccount() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.deleteAccount();

    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }

  Future<Failure?> uploadAvatar(File imageFile) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.uploadAvatar(imageFile);

    return result.fold(
      (failure) => failure,
      (avatar) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<Failure?> deleteAvatar() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.deleteAvatar();

    return result.fold(
      (failure) => failure,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }
}
