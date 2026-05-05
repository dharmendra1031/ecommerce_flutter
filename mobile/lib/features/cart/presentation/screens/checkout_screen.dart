// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_providers.dart';
import '../../../payment/presentation/providers/payment_providers.dart';
import '../../../profile/domain/entities/address_entity.dart';
import '../../../profile/presentation/providers/address_providers.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  bool _isPlacingOrder = false;

  AddressEntity? _selectedAddress;
  bool _isAddingNewAddress = false;

  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _setAsDefault = false;

  bool _useCod = true;
  bool _useSavedCard = false;
  bool _isLoadingSavedCard = false;
  String? _savedCardNumber;
  String? _savedCardExpiry;
  String? _savedCardHolderName;
  String? _savedCardType;
  String? _savedCardLast4;

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  void _fillFormWithAddress(AddressEntity address) {
    _fullNameController.text = address.fullName;
    _phoneController.text = address.phone;
    _addressController.text = address.address;
    _cityController.text = address.city;
    _postalCodeController.text = address.postalCode;
  }

  Future<void> _loadSavedCardForCheckout() async {
    if (!mounted) return;
    setState(() => _isLoadingSavedCard = true);

    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.get<Map<String, dynamic>>(
        ApiConstants.savedCardCheckout,
      );

      if (!mounted) return;

      final data = response['data'] as Map<String, dynamic>?;
      final card = data?['card'] as Map<String, dynamic>?;

      if (card != null) {
        setState(() {
          _savedCardNumber = card['cardNumber'] as String?;
          _savedCardExpiry = card['expiry'] as String?;
          _savedCardHolderName = card['cardholderName'] as String?;
          _savedCardType = card['cardType'] as String?;
          _savedCardLast4 = card['last4'] as String?;
          _useSavedCard = true;
        });
      } else {
        setState(() => _useSavedCard = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _useSavedCard = false);
    } finally {
      if (mounted) {
        setState(() => _isLoadingSavedCard = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final addressesAsync = ref.watch(addressesNotifierProvider);
    final defaultAddress = ref.watch(defaultAddressProvider);
    final currentUser = ref.watch(currentUserProvider);
    final savedCard = currentUser?.savedCard;
    final hasSavedCard = savedCard != null && savedCard.last4.isNotEmpty;

    if (_selectedAddress == null && defaultAddress != null) {
      _selectedAddress = defaultAddress;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fillFormWithAddress(defaultAddress);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              FilledButton(
                onPressed: () => ref.invalidate(cartNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return const Center(
              child: Text('Your cart is empty'),
            );
          }
          return _buildCheckoutSteps(
              cart, addressesAsync, hasSavedCard, savedCard);
        },
      ),
    );
  }

  Widget _buildCheckoutSteps(
    CartEntity cart,
    AsyncValue<List<AddressEntity>> addressesAsync,
    bool hasSavedCard,
    dynamic savedCard,
  ) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _isPlacingOrder ? null : _onContinue,
      onStepCancel: _isPlacingOrder ? null : _onCancel,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: details.onStepContinue,
                  child: _isPlacingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_currentStep == 2 ? 'Place Order' : 'Continue'),
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      steps: [
        Step(
          title: const Text('Address'),
          content: _buildAddressStep(addressesAsync),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Payment'),
          content: _buildPaymentStep(hasSavedCard, savedCard),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Review'),
          content: _buildReviewStep(cart, hasSavedCard),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  Widget _buildAddressStep(AsyncValue<List<AddressEntity>> addressesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        addressesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (addresses) {
            if (addresses.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Addresses',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...addresses.map((address) => _buildAddressCard(address)),
                const SizedBox(height: 16),
                if (!_isAddingNewAddress)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAddingNewAddress = true;
                        _selectedAddress = null;
                        _clearForm();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                  ),
                if (_isAddingNewAddress) ...[
                  const Divider(),
                  Text(
                    'New Address',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
        if (addressesAsync.valueOrNull?.isEmpty ?? true)
          Form(
            key: _formKey,
            child: _buildAddressFormFields(),
          )
        else if (_isAddingNewAddress)
          Form(
            key: _formKey,
            child: _buildAddressFormFields(),
          ),
      ],
    );
  }

  Widget _buildAddressCard(AddressEntity address) {
    final isSelected = _selectedAddress?.id == address.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: RadioListTile<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) {
          setState(() {
            _selectedAddress = address;
            _isAddingNewAddress = false;
            _fillFormWithAddress(address);
          });
        },
        title: Row(
          children: [
            Text(address.label),
            if (address.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${address.fullName} | ${address.phone}'),
            Text(address.address),
            Text('${address.city}, ${address.postalCode}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAddressFormFields() {
    return Column(
      children: [
        if (_isAddingNewAddress) ...[
          TextFormField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label (e.g., Home, Work) *',
              prefixIcon: Icon(Icons.label_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a label';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            final phoneRegex = RegExp(r'^[0-9+\-\s()]{6,20}$');
            if (!phoneRegex.hasMatch(value.trim())) {
              return 'Please enter a valid phone number (e.g. 012 345 678)';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address *',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        if (_isAddingNewAddress) ...[
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _setAsDefault,
            onChanged: (value) {
              setState(() => _setAsDefault = value ?? false);
            },
            title: const Text('Set as default address'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentStep(bool hasSavedCard, dynamic savedCard) {
    return Column(
      children: [
        Card(
          child: RadioListTile<bool>(
            value: true,
            groupValue: _useCod,
            onChanged: (_) => setState(() => _useCod = true),
            title: const Row(
              children: [
                Icon(Icons.money),
                SizedBox(width: 12),
                Text('Cash on Delivery (COD)'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: RadioListTile<bool>(
            value: false,
            groupValue: _useCod,
            onChanged: (_) async {
              setState(() => _useCod = false);
              if (hasSavedCard) {
                await _loadSavedCardForCheckout();
              }
            },
            title: const Row(
              children: [
                Icon(Icons.credit_card),
                SizedBox(width: 12),
                Text('Credit/Debit Card'),
              ],
            ),
          ),
        ),
        if (!_useCod) ...[
          const SizedBox(height: 16),
          if (_isLoadingSavedCard)
            const Center(child: CircularProgressIndicator()),
          if (!_isLoadingSavedCard && _useSavedCard && _savedCardNumber != null)
            _buildSavedCardForm(),
          if (!_isLoadingSavedCard && _useSavedCard && _savedCardNumber == null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Could not load saved card. Please re-save your card in Profile.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _useSavedCard = false;
                          _cardNumberController.clear();
                          _expiryController.clear();
                          _cvvController.clear();
                          _cardholderNameController.clear();
                        });
                      },
                      child: const Text('Use a different card'),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isLoadingSavedCard && !_useSavedCard) _buildCardForm(),
        ],
      ],
    );
  }

  Widget _buildCardForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter card details',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number *',
                prefixIcon: Icon(Icons.credit_card),
                hintText: '1234 5678 9012 3456',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                final cleaned = value.replaceAll(' ', '');
                if (cleaned.length < 13 || cleaned.length > 19) {
                  return 'Invalid card number (13-19 digits)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY) *',
                      hintText: '12/28',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpiryDateFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return 'MM/YY format';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV *',
                      hintText: '123',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter CVV';
                      }
                      if (value.length < 3 || value.length > 4) {
                        return '3-4 digits';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardholderNameController,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cardholder name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCardForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 32,
                      ),
                      Text(
                        _savedCardType?.toUpperCase() ?? 'CARD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '•••• •••• •••• ${_savedCardLast4 ?? '****'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                            (_savedCardHolderName ?? '').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
                            _savedCardExpiry ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _cvvController,
              decoration: const InputDecoration(
                labelText: 'CVV *',
                hintText: '123',
                prefixIcon: Icon(Icons.security),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter CVV from back of card';
                }
                if (value.length < 3 || value.length > 4) {
                  return '3-4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _useSavedCard = false;
                  _savedCardNumber = null;
                  _cvvController.clear();
                });
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Use a different card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(CartEntity cart, bool hasSavedCard) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items (${cart.itemCount})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...cart.items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: item.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, size: 50),
                      ),
                    )
                  : const Icon(Icons.image, size: 50),
              title: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Qty: ${item.quantity}'),
              trailing: Text(
                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
        const Divider(),
        Text(
          'Shipping Address',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullNameController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_phoneController.text),
                const SizedBox(height: 4),
                Text(_addressController.text),
                Text('${_cityController.text}, ${_postalCodeController.text}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(_useCod ? Icons.money : Icons.credit_card),
            title: Text(_useCod ? 'Cash on Delivery' : 'Credit/Debit Card'),
            subtitle: !_useCod
                ? (_useSavedCard && _savedCardLast4 != null
                    ? Text(
                        'Saved ${_savedCardType?.toUpperCase()} •••• $_savedCardLast4')
                    : (_cardNumberController.text.isNotEmpty
                        ? Text(
                            '**** ${_cardNumberController.text.substring(_cardNumberController.text.length > 4 ? _cardNumberController.text.length - 4 : 0)}')
                        : null))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Order Summary',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildSummaryRow(
            context, 'Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
        _buildSummaryRow(
          context,
          'Shipping',
          cart.subtotal > ApiConstants.freeShippingThreshold
              ? 'FREE'
              : '\$${ApiConstants.shippingCost.toStringAsFixed(2)}',
        ),
        _buildSummaryRow(context, 'Tax',
            '\$${(cart.subtotal * ApiConstants.taxRate).toStringAsFixed(2)}'),
        const Divider(),
        _buildSummaryRow(
          context,
          'Total',
          '\$${_calculateTotal(cart).toStringAsFixed(2)}',
          isTotal: true,
        ),
        if (cart.subtotal <= ApiConstants.freeShippingThreshold) ...[
          const SizedBox(height: 8),
          Text(
            'Add \$${(ApiConstants.freeShippingThreshold - cart.subtotal).toStringAsFixed(2)} more for free shipping!',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  double _calculateTotal(CartEntity cart) {
    final shipping = cart.subtotal > ApiConstants.freeShippingThreshold
        ? 0.0
        : ApiConstants.shippingCost;
    final tax = cart.subtotal * ApiConstants.taxRate;
    return cart.subtotal + shipping + tax;
  }

  void _clearForm() {
    _labelController.clear();
    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _postalCodeController.clear();
    _setAsDefault = false;
  }

  void _onContinue() async {
    if (_currentStep == 0) {
      if (_isAddingNewAddress) {
        if (_formKey.currentState?.validate() ?? false) {
          final failure =
              await ref.read(addressesNotifierProvider.notifier).addAddress(
                    label: _labelController.text,
                    fullName: _fullNameController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                    city: _cityController.text,
                    stateName: '',
                    postalCode: _postalCodeController.text,
                    country: 'Cambodia',
                    isDefault: _setAsDefault,
                  );
          if (failure != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
            return;
          }
          setState(() => _isAddingNewAddress = false);
        }
        return;
      } else if (_selectedAddress == null) {
        if (_formKey.currentState?.validate() ?? false) {
          setState(() => _currentStep++);
        }
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      if (!_useCod) {
        if (_useSavedCard) {
          if (_savedCardNumber == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Could not load saved card. Please use a different card.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (_cvvController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter CVV'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (_cvvController.text.length < 3 ||
              _cvvController.text.length > 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('CVV must be 3-4 digits'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } else {
          if (_cardNumberController.text.isEmpty ||
              _expiryController.text.isEmpty ||
              _cvvController.text.isEmpty ||
              _cardholderNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill in all card details'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        if (_cvvController.text.length < 3 || _cvvController.text.length > 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CVV must be 3-4 digits'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      setState(() => _currentStep++);
    } else {
      await _placeOrder();
    }
  }

  void _onCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveCardToProfile({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      final dioClient = ref.read(dioClientProvider);
      final cardType = _detectCardType(cardNumber);

      final data = <String, dynamic>{
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'expiry': expiry,
        'cvv': cvv,
      };
      if (cardType != 'unknown') {
        data['cardType'] = cardType;
      }

      await dioClient.put<Map<String, dynamic>>(
        ApiConstants.savedCard,
        data: data,
      );

      await ref.read(authNotifierProvider.notifier).refreshUser();
    } catch (e) {
      debugPrint('[Checkout] Error in _saveCardToProfile: $e');
    }
  }

  String _detectCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.startsWith('4')) {
      return 'visa';
    } else if (RegExp(r'^5[1-5]').hasMatch(cleaned)) {
      return 'mastercard';
    } else if (RegExp(r'^3[47]').hasMatch(cleaned)) {
      return 'amex';
    } else if (RegExp(r'^6(?:011|5)').hasMatch(cleaned)) {
      return 'discover';
    }
    return 'unknown';
  }

  Future<void> _placeOrder() async {
    final cartState = ref.read(cartNotifierProvider);
    final cart = cartState.valueOrNull;
    if (cart == null || cart.items.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    String? transactionId;
    String? cardLast4;
    String paymentStatus = 'pending';

    String cardNumber = '';
    String expiry = '';
    String cvv = '';
    String cardholderName = '';

    if (!_useCod) {
      final total = _calculateTotal(cart);

      if (_useSavedCard && _savedCardNumber != null) {
        cardNumber = _savedCardNumber!;
        expiry = _savedCardExpiry!;
        cardholderName = _savedCardHolderName!;
        cvv = _cvvController.text;
      } else {
        cardNumber = _cardNumberController.text.replaceAll(' ', '');
        expiry = _expiryController.text;
        cvv = _cvvController.text;
        cardholderName = _cardholderNameController.text;
      }

      if (cardNumber.length < 13 || cardNumber.length > 19) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid card number'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final (paymentFailure, paymentResult) =
          await ref.read(paymentNotifierProvider.notifier).processCardPayment(
                cardNumber: cardNumber,
                expiry: expiry,
                cvv: cvv,
                cardholderName: cardholderName,
                amount: total,
              );

      if (paymentFailure != null && mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${paymentFailure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      transactionId = paymentResult?.transactionId;
      cardLast4 = paymentResult?.cardLast4;
      paymentStatus = paymentResult?.status ?? 'pending';

      // Saving card to user profile is handled in post-order flow
    }

    final orderItems = cart.items
        .map((item) => OrderItemEntity(
              productId: item.productId,
              name: item.name,
              image: item.image,
              price: item.price,
              quantity: item.quantity,
              variant: item.selectedVariants?.entries.firstOrNull?.value,
            ))
        .toList();

    final shippingAddress = ShippingAddressEntity(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: '',
      postalCode: _postalCodeController.text,
      country: '',
    );

    final paymentInfo = PaymentInfoEntity(
      method: _useCod ? 'cod' : 'card',
      transactionId: transactionId,
      status: paymentStatus,
      cardLast4: cardLast4,
    );

    final itemsPrice = cart.subtotal;
    final shippingPrice = itemsPrice > ApiConstants.freeShippingThreshold
        ? 0.0
        : ApiConstants.shippingCost;
    final taxPrice = itemsPrice * ApiConstants.taxRate;
    final totalPrice = itemsPrice + shippingPrice + taxPrice;

    final (failure, order) =
        await ref.read(createOrderNotifierProvider.notifier).createOrder(
              orderItems: orderItems,
              shippingAddress: shippingAddress,
              paymentInfo: paymentInfo,
              itemsPrice: itemsPrice,
              shippingPrice: shippingPrice,
              taxPrice: taxPrice,
              totalPrice: totalPrice,
            );

    setState(() => _isPlacingOrder = false);

    if (failure != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (order != null && mounted) {
      try {
        bool shouldRefreshProfile = false;

        if (_selectedAddress == null) {
          final phone = _phoneController.text.trim();
          final fullName = _fullNameController.text.trim();
          final address = _addressController.text.trim();
          final city = _cityController.text.trim();

          debugPrint(
              '[Checkout] Saving address to profile: fullName=$fullName, phone=$phone, address=$address, city=$city');

          final phoneRegex = RegExp(r'^[0-9+\-\s()]{6,20}$');
          if (fullName.isNotEmpty &&
              phone.isNotEmpty &&
              address.isNotEmpty &&
              city.isNotEmpty &&
              phoneRegex.hasMatch(phone)) {
            final addressesAsync = ref.read(addressesNotifierProvider);
            final result =
                await ref.read(addressesNotifierProvider.notifier).addAddress(
                      label: _labelController.text.trim().isNotEmpty
                          ? _labelController.text.trim()
                          : 'Default',
                      fullName: fullName,
                      phone: phone,
                      address: address,
                      city: city,
                      stateName: '',
                      postalCode: _postalCodeController.text.trim().isNotEmpty
                          ? _postalCodeController.text.trim()
                          : '00000',
                      country: 'Cambodia',
                      isDefault: addressesAsync.valueOrNull?.isEmpty ?? true,
                    );

            if (result == null) {
              debugPrint('[Checkout] Address saved successfully');
              shouldRefreshProfile = true;
            } else {
              debugPrint(
                  '[Checkout] Address save returned failure: ${result.message}');
            }
          } else {
            debugPrint(
                '[Checkout] Skipping address save – invalid or missing fields. phone regex match: ${phoneRegex.hasMatch(phone)}');
          }
        }

        if (!_useCod && paymentStatus == 'success') {
          if (!_useSavedCard || (cardNumber.isNotEmpty && cvv.isNotEmpty)) {
            debugPrint(
                '[Checkout] Saving card to profile: cardNumber=${cardNumber.length} digits');
            await _saveCardToProfile(
              cardNumber: cardNumber,
              expiry: expiry,
              cvv: cvv,
              cardholderName: cardholderName,
            );
            shouldRefreshProfile = true;
          }
        }

        if (shouldRefreshProfile && mounted) {
          ref.invalidate(addressesNotifierProvider);
          await ref.read(authNotifierProvider.notifier).refreshUser();
        }
      } catch (e) {
        debugPrint('[Checkout] Error saving checkout data to profile: $e');
      }

      if (!mounted) return;

      try {
        await ref.read(cartNotifierProvider.notifier).clearCart();
      } catch (e) {
        debugPrint('[Checkout] Error clearing cart: $e');
        if (mounted) {
          ref.invalidate(cartNotifierProvider);
        }
      }

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/checkout/success', extra: {
              'orderId': order.id,
              'orderNumber': order.orderNumber,
            });
          }
        });
      }
    }
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
