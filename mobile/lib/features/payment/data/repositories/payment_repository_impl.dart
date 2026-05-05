import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, bool>> validateCard({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      final isValid = await _remoteDataSource.validateCard(
        cardNumber: cardNumber,
        expiry: expiry,
        cvv: cvv,
        cardholderName: cardholderName,
      );
      return Right(isValid);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Card validation failed',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(UnknownFailure(message: 'Invalid response format'));
    }
  }

  @override
  Future<Either<Failure, PaymentResult>> processPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
  }) async {
    try {
      final result = await _remoteDataSource.processPayment(
        cardNumber: cardNumber,
        expiry: expiry,
        cvv: cvv,
        cardholderName: cardholderName,
        amount: amount,
      );
      return Right(PaymentResult(
        transactionId: result.id,
        status: result.status,
        cardLast4: result.cardLast4,
        amount: result.amount,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Payment processing failed',
        statusCode: e.response?.statusCode,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(UnknownFailure(message: 'Invalid response format'));
    }
  }
}
