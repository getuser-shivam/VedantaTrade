import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/models/payment_models.dart';

class PaymentMethodWidget extends StatefulWidget {
  final List<PaymentMethod> availableMethods;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;
  final Function(PaymentResult) onPaymentProcessed;
  final double amount;

  const PaymentMethodWidget({
    Key? key,
    required this.availableMethods,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.onPaymentProcessed,
    required this.amount,
  }) : super(key: key);

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _processingStates = {};
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
    _initializeControllers();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _initializeControllers() {
    for (final method in widget.availableMethods) {
      _controllers[method.id] = TextEditingController();
      _processingStates[method.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.payment_outlined,
                color: PremiumGlassmorphicTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'NPR ${widget.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Payment Methods
        ...widget.availableMethods.map((method) => _buildPaymentMethodCard(method)),
        
        const SizedBox(height: 24),
        
        // Payment Form
        if (_selectedMethod != null) _buildPaymentForm(),
        
        const SizedBox(height: 24),
        
        // Process Payment Button
        if (_selectedMethod != null) _buildProcessPaymentButton(),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedMethod?.id == method.id;
    final isAvailable = method.isEnabled && method.isAvailableForAmount(widget.amount);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? PremiumGlassmorphicTheme.primaryColor 
              : (isAvailable ? Colors.grey[300]! : Colors.grey[200]!),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected 
            ? PremiumGlassmorphicTheme.primaryColor.withOpacity(0.05)
            : (isAvailable ? Colors.white : Colors.grey[100]),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isAvailable ? () => _selectPaymentMethod(method) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Payment Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected 
                      ? PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey[200],
                ),
                child: Icon(
                  _getPaymentIcon(method.type),
                  color: isSelected 
                      ? PremiumGlassmorphicTheme.primaryColor
                      : Colors.grey[600],
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Payment Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAvailable 
                            ? PremiumGlassmorphicTheme.textPrimary
                            : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable 
                            ? PremiumGlassmorphicTheme.textSecondary
                            : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Processing time: ${method.processingTimeText}',
                          style: TextStyle(
                            fontSize: 11,
                            color: PremiumGlassmorphicTheme.textSecondary,
                          ),
                        ),
                        if (method.fee > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• Fee: ${method.feeType == FeeType.percentage ? '${method.fee}%' : 'NPR ${method.fee.toStringAsFixed(2)}'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Radio Button
              Radio<PaymentMethod>(
                value: method,
                groupValue: _selectedMethod,
                onChanged: isAvailable ? (value) => _selectPaymentMethod(value!) : null,
                activeColor: PremiumGlassmorphicTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PremiumGlassmorphicTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment form based on method type
            _buildPaymentFormFields(),
            
            // Fee Information
            if (_selectedMethod!.fee > 0)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Processing fee: ${_selectedMethod!.feeType == FeeType.percentage ? 'NPR ${_selectedMethod!.calculateFee(widget.amount).toStringAsFixed(2)}' : 'NPR ${_selectedMethod!.fee.toStringAsFixed(2)}'}',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentFormFields() {
    switch (_selectedMethod!.type) {
      case PaymentType.digital:
        return _buildDigitalWalletForm();
      case PaymentType.card:
        return _buildCardForm();
      case PaymentType.bank:
        return _buildBankTransferForm();
      case PaymentType.cod:
        return _buildCashOnDeliveryForm();
      default:
        return Container();
    }
  }

  Widget _buildDigitalWalletForm() {
    return Column(
      children: [
        // Phone Number
        TextFormField(
          controller: _controllers[_selectedMethod!.id]!,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '98XXXXXXXX',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Wallet Selection (for multiple wallets)
        if (_selectedMethod!.id == 'digital')
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Wallet',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'khalti', child: Text('Khalti')),
              DropdownMenuItem(value: 'esewa', child: Text('eSewa')),
            ],
            onChanged: (value) {
              // Handle wallet selection
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a wallet';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        // Card Number
        TextFormField(
          controller: _controllers['card_number'] ??= TextEditingController(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: 'XXXX XXXX XXXX XXXX',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            prefixIcon: Icon(Icons.credit_card_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Card number is required';
            }
            if (value.replaceAll(' ', '').length != 16) {
              return 'Please enter a valid 16-digit card number';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CardNumberFormatter(),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            // Expiry Date
            Expanded(
              child: TextFormField(
                controller: _controllers['expiry'] ??= TextEditingController(),
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Expiry date is required';
                  }
                  return null;
                },
                inputFormatters: [
                  CardExpiryFormatter(),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // CVV
            Expanded(
              child: TextFormField(
                controller: _controllers['cvv'] ??= TextEditingController(),
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  prefixIcon: Icon(Icons.security_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CVV is required';
                  }
                  if (value.length < 3) {
                    return 'Please enter a valid CVV';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Cardholder Name
        TextFormField(
          controller: _controllers['cardholder'] ??= TextEditingController(),
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Cardholder name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      children: [
        // Bank Name
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Bank',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            prefixIcon: Icon(Icons.account_balance_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'nabil', child: Text('Nabil Bank')),
            DropdownMenuItem(value: 'nic_asia', child: Text('NIC Asia')),
            DropdownMenuItem(value: 'global', child: Text('Global IME')),
            DropdownMenuItem(value: 'siddhartha', child: Text('Siddhartha')),
          ],
          onChanged: (value) {
            // Handle bank selection
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a bank';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 12),
        
        // Account Number
        TextFormField(
          controller: _controllers['account_number'] ??= TextEditingController(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Account Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Account number is required';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Account Holder Name
        TextFormField(
          controller: _controllers['account_holder'] ??= TextEditingController(),
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Account holder name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCashOnDeliveryForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: Colors.blue,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Cash on Delivery',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pay when you receive your order. Please keep the exact amount ready for smooth delivery.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessPaymentButton() {
    final isProcessing = _processingStates[_selectedMethod!.id] ?? false;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: PremiumGlassmorphicTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : Text(
                'Pay NPR ${widget.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _selectPaymentMethod(PaymentMethod method) {
    setState(() {
      _selectedMethod = method;
      widget.onMethodSelected(method);
    });
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _processingStates[_selectedMethod!.id] = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Create payment details based on method
      final paymentDetails = _createPaymentDetails();
      
      // Create mock payment result
      final result = PaymentResult(
        success: true,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        paymentMethodId: _selectedMethod!.id,
        amount: widget.amount,
        currency: 'NPR',
        status: PaymentStatus.completed,
        processedAt: DateTime.now(),
        metadata: paymentDetails,
      );
      
      widget.onPaymentProcessed(result);
    } catch (e) {
      // Handle payment error
      final result = PaymentResult(
        success: false,
        paymentMethodId: _selectedMethod!.id,
        amount: widget.amount,
        currency: 'NPR',
        status: PaymentStatus.failed,
        processedAt: DateTime.now(),
        failureReason: 'Payment processing failed: $e',
        metadata: {},
      );
      
      widget.onPaymentProcessed(result);
    } finally {
      setState(() {
        _processingStates[_selectedMethod!.id] = false;
      });
    }
  }

  Map<String, dynamic> _createPaymentDetails() {
    switch (_selectedMethod!.type) {
      case PaymentType.digital:
        return {
          'phoneNumber': _controllers[_selectedMethod!.id]!.text,
          'walletId': _selectedMethod!.id,
        };
      case PaymentType.card:
        return {
          'cardNumber': _controllers['card_number']!.text,
          'expiry': _controllers['expiry']!.text,
          'cvv': _controllers['cvv']!.text,
          'cardholderName': _controllers['cardholder']!.text,
        };
      case PaymentType.bank:
        return {
          'bankName': _controllers['bank']!.text,
          'accountNumber': _controllers['account_number']!.text,
          'accountHolderName': _controllers['account_holder']!.text,
        };
      case PaymentType.cod:
        return {
          'deliveryType': 'cash_on_delivery',
        };
      default:
        return {};
    }
  }

  IconData _getPaymentIcon(PaymentType type) {
    switch (type) {
      case PaymentType.digital:
        return Icons.account_balance_wallet;
      case PaymentType.card:
        return Icons.credit_card;
      case PaymentType.bank:
        return Icons.account_balance;
      case PaymentType.cod:
        return Icons.local_shipping;
      default:
        return Icons.payment;
    }
  }
}

// Input Formatters
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
