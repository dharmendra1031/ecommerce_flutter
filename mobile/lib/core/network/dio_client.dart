import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../utils/error_handler.dart';

import '../utils/secure_storage_service.dart';

class DioClient {
  final Dio _dio;
  final SecureStorageService _storage;

  Completer<bool>? _refreshCompleter;

  DioClient({
    required Dio dio,
    required SecureStorageService storage,
  })  : _dio = dio,
        _storage = storage {
    _configureDio();
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _configureDio() {
    _dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = ApiConstants.connectTimeout
      ..receiveTimeout = ApiConstants.receiveTimeout
      ..sendTimeout = ApiConstants.sendTimeout
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    print('DioClient configured with base URL: ${_dio.options.baseUrl}');
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            log('REQUEST: ${options.method} ${options.path}');
            log('Headers: ${options.headers}');
            log('Data: ${options.data}');
          }

          handler.next(options);
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (kDebugMode) {
            log('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
            log('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            log('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
            log('Message: ${error.message}');
            log('Data: ${error.response?.data}');
          }

          if (error.response?.statusCode == 401) {
            // Don't retry login requests - invalid credentials won't be fixed by token refresh
            if (error.requestOptions.path == ApiConstants.login) {
              handler.next(error);
              return;
            }

            final shouldRetry = await _handleUnauthorized(error);
            if (shouldRetry) {
              final token = await _storage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';

              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                handler.reject(e as DioException);
                return;
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _handleUnauthorized(DioException error) async {
    if (error.requestOptions.path == ApiConstants.refreshToken) {
      await _storage.clearAll();
      return false;
    }

    if (_refreshCompleter != null) {
      final success = await _refreshCompleter!.future;
      return success;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final success = await _refreshToken();
      _refreshCompleter?.complete(success);
      return success;
    } catch (e) {
      _refreshCompleter?.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await _storage.clearAll();
        return false;
      }

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _storage.setAccessToken(data['accessToken']);
        await _storage.setRefreshToken(data['refreshToken']);
        return true;
      }

      await _storage.clearAll();
      return false;
    } on DioException {
      await _storage.clearAll();
      return false;
    } catch (e) {
      await _storage.clearAll();
      return false;
    }
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
