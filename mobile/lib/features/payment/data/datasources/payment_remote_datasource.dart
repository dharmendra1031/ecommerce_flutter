import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

abstract class PaymentRemoteDataSource {
  Future<bool> validateCard({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  });

  Future<PaymentResultModel> processPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
  });
}

class PaymentResultModel {
  final String id;
  final String status;
  final String? cardLast4;
  final double amount;

  PaymentResultModel({
    required this.id,
    required this.status,
    this.cardLast4,
    required this.amount,
  });

  factory PaymentResultModel.fromJson(Map<String, dynamic> json) {
    final paymentResult = json['paymentResult'] as Map<String, dynamic>?;
    return PaymentResultModel(
      id: paymentResult?['id'] as String? ?? '',
      status: paymentResult?['status'] as String? ?? 'failed',
      cardLast4: paymentResult?['cardLast4'] as String?,
      amount: (paymentResult?['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient _dioClient;

  PaymentRemoteDataSourceImpl(this._dioClient);

  @override
  Future<bool> validateCard({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) async {
    await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.validateCard,
      data: {
        'cardNumber': cardNumber,
        'expiry': expiry,
        'cvv': cvv,
        'cardholderName': cardholderName,
      },
    );
    return true;
  }

  @override
  Future<PaymentResultModel> processPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.processPayment,
      data: {
        'cardNumber': cardNumber,
        'expiry': expiry,
        'cvv': cvv,
        'cardholderName': cardholderName,
        'amount': amount,
      },
    );
    
    final data = response['data'] as Map<String, dynamic>;
    return PaymentResultModel.fromJson(data);
  }
}
