import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';

part 'payment_providers.g.dart';

@riverpod
PaymentRemoteDataSource paymentRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PaymentRemoteDataSourceImpl(dioClient);
}

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  final remoteDataSource = ref.watch(paymentRemoteDataSourceProvider);
  return PaymentRepositoryImpl(remoteDataSource);
}

@riverpod
class PaymentNotifier extends _$PaymentNotifier {
  @override
  AsyncValue<PaymentResult?> build() {
    return const AsyncValue.data(null);
  }

  Future<(Failure?, PaymentResult?)> processCardPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(paymentRepositoryProvider);

    // First validate the card
    final validationResult = await repository.validateCard(
      cardNumber: cardNumber,
      expiry: expiry,
      cvv: cvv,
      cardholderName: cardholderName,
    );

    if (validationResult.isLeft()) {
      final failure = validationResult.fold((l) => l, (r) => null);
      state = AsyncValue.error(failure!, StackTrace.current);
      return (failure, null);
    }

    // Then process the payment
    final paymentResult = await repository.processPayment(
      cardNumber: cardNumber,
      expiry: expiry,
      cvv: cvv,
      cardholderName: cardholderName,
      amount: amount,
    );

    if (paymentResult.isLeft()) {
      final failure = paymentResult.fold((l) => l, (r) => null);
      state = AsyncValue.error(failure!, StackTrace.current);
      return (failure, null);
    }

    final result = paymentResult.fold((l) => null, (r) => r);
    state = AsyncValue.data(result);
    return (null, result);
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
