import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';

class PaymentResult {
  final String transactionId;
  final String status;
  final String? cardLast4;
  final double amount;

  PaymentResult({
    required this.transactionId,
    required this.status,
    this.cardLast4,
    required this.amount,
  });
}

abstract class PaymentRepository {
  Future<Either<Failure, bool>> validateCard({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  });

  Future<Either<Failure, PaymentResult>> processPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
  });
}
