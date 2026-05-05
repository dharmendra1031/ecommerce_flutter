import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/utils/failures.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({super.key});

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadCard();
    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).refreshUser();
    });
  }

  Future<void> _loadCard() async {
    final dioClient = ref.read(dioClientProvider);
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        ApiConstants.savedCard,
      );
      final data = response['data'] as Map<String, dynamic>?;
      final card = data?['card'] as Map<String, dynamic>?;

      if (card != null && mounted) {
        setState(() {
          _cardholderNameController.text =
              card['cardholderName'] as String? ?? '';
          _expiryController.text = card['expiry'] as String? ?? '';
          _cvvController.text = card['cvv'] as String? ?? '';
          // Don't show full card number, just placeholder with last 4
          final last4 = card['last4'] as String? ?? '';
          if (last4.isNotEmpty) {
            _cardNumberController.text = '•••• •••• •••• $last4';
          }
        });
      }
    } catch (e) {
      // Card not found or error - that's ok, user will add new card
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if card number contains masked characters (• or …)
    final cardNumber = _cardNumberController.text.trim();
    if (cardNumber.contains('•') ||
        cardNumber.contains('…') ||
        cardNumber.contains('*')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full card number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final dioClient = ref.read(dioClientProvider);
    try {
      // Detect card type based on card number
      final cardType = _detectCardType(cardNumber);

      await dioClient.put<Map<String, dynamic>>(
        ApiConstants.savedCard,
        data: {
          'cardNumber': cardNumber.replaceAll(' ', ''),
          'cardholderName': _cardholderNameController.text.trim(),
          'expiry': _expiryController.text.trim(),
          'cvv': _cvvController.text.trim(),
          'cardType': cardType,
        },
      );

      // Refresh user data to get updated card
      await ref.read(authNotifierProvider.notifier).refreshUser();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card saved successfully')),
        );
      }
    } on Failure catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save card: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteCard() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Card'),
        content: const Text('Are you sure you want to remove your saved card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final dioClient = ref.read(dioClientProvider);
    try {
      await dioClient.delete<void>(ApiConstants.savedCard);

      // Refresh user data
      await ref.read(authNotifierProvider.notifier).refreshUser();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _cardNumberController.clear();
          _cardholderNameController.clear();
          _expiryController.clear();
          _cvvController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card removed successfully')),
        );
      }
    } on Failure catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove card: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _detectCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s|-'), '');
    if (cleaned.startsWith('4')) return 'visa';
    if (cleaned.startsWith('5')) return 'mastercard';
    if (cleaned.startsWith('3')) return 'amex';
    if (cleaned.startsWith('6')) return 'discover';
    return 'visa';
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    }
    final cleaned = value.replaceAll(RegExp(r'\s|-'), '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Invalid card number';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regex.hasMatch(value)) {
      return 'MM/YY format';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length < 3 || value.length > 4) {
      return '3-4 digits';
    }
    return null;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedCard = ref.watch(currentUserProvider)?.savedCard;
    final hasCard = savedCard != null && savedCard.last4.isNotEmpty;

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Card')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card'),
        actions: [
          if (hasCard && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() {
                _isEditing = true;
                // Always clear the card number when editing - user must re-enter for security
                _cardNumberController.clear();
                _cvvController.clear();
              }),
            ),
          if (hasCard && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isLoading ? null : _deleteCard,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: hasCard && !_isEditing
            ? _buildCardView(savedCard)
            : _buildForm(hasCard),
      ),
    );
  }

  Widget _buildCardView(dynamic savedCard) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card visualization
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    _getCardIcon(savedCard.cardType),
                    color: Colors.white,
                    size: 48,
                  ),
                  Text(
                    savedCard.cardType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '•••• •••• •••• ${savedCard.last4}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARDHOLDER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        savedCard.cardholderName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        savedCard.expiry,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Cardholder Name', savedCard.cardholderName),
        _buildInfoRow('Card Number', '•••• •••• •••• ${savedCard.last4}'),
        _buildInfoRow('Expiry Date', savedCard.expiry),
        _buildInfoRow('CVV', '•••'),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: () => setState(() {
              _isEditing = true;
              // Always clear the card number and CVV when editing - user must re-enter for security
              _cardNumberController.clear();
              _cvvController.clear();
            }),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Card'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Widget _buildForm(bool hasCard) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasCard)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Add your card details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              prefixIcon: Icon(Icons.credit_card),
              hintText: '1234 5678 9012 3456',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            validator: _validateCardNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardholderNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'JOHN DOE',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expiry (MM/YY)',
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: '12/28',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateFormatter(),
                  ],
                  validator: _validateExpiry,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    counterText: '',
                    hintText: '123',
                  ),
                  validator: _validateCvv,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(hasCard ? 'Update Card' : 'Save Card'),
            ),
          ),
          if (hasCard) const SizedBox(height: 12),
          if (hasCard)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _isEditing = false),
                child: const Text('Cancel'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formats card number with spaces every 4 digits
/// e.g., "4111111111111111" -> "4111 1111 1111 1111"
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    // Limit to 19 digits
    if (text.length > 19) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats expiry date with slash
/// e.g., "1228" -> "12/28"
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    // Limit to 4 digits
    if (text.length > 4) {
      return oldValue;
    }

    String formatted = text;
    if (text.length >= 2) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
