import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cart/cart_service.dart';
import '../../services/order_service.dart';

enum PaymentMethodType {
  card,
  cash,
  payAtTable,
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isPaying = false;
  PaymentMethodType _selectedMethod = PaymentMethodType.card;

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool get _isCardPayment => _selectedMethod == PaymentMethodType.card;

  Future<void> _completePayment() async {
    if (_isCardPayment) {
      if (!_formKey.currentState!.validate()) return;
    }

    final cartItems = List<CartItem>.from(CartService.instance.cartItems.value);

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sepet boş, sipariş oluşturulamadı."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPaying = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      await OrderService.createOrder(
        items: cartItems,
        totalPrice: CartService.instance.totalPrice,
        paymentMethod: _selectedMethod,
      );

      if (!mounted) return;

      CartService.instance.clearCart();

      setState(() {
        _isPaying = false;
      });

      String successText;
      switch (_selectedMethod) {
        case PaymentMethodType.card:
          successText = "Ödeme tamamlandı ve sipariş mutfağa iletildi.";
          break;
        case PaymentMethodType.cash:
          successText = "Sipariş oluşturuldu. Ödeme yöntemi: Nakit.";
          break;
        case PaymentMethodType.payAtTable:
          successText = "Sipariş oluşturuldu. Ödeme masada alınacak.";
          break;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("İşlem Başarılı"),
            content: Text(successText),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(this.context).pop();
                },
                child: const Text("Tamam"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sipariş kaydedilemedi: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return "$label zorunludur";
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    final required = _validateRequired(value, "Kart numarası");
    if (required != null) return required;

    final cleaned = value!.replaceAll(" ", "");
    if (cleaned.length != 16) {
      return "Kart numarası 16 haneli olmalı";
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    final required = _validateRequired(value, "Son kullanma tarihi");
    if (required != null) return required;

    if (value!.length != 5 || !value.contains("/")) {
      return "Geçerli format: AA/YY";
    }

    final parts = value.split("/");
    if (parts.length != 2) return "Geçerli format: AA/YY";

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return "Geçerli format: AA/YY";
    }

    if (month < 1 || month > 12) {
      return "Ay 01 ile 12 arasında olmalı";
    }

    return null;
  }

  String? _validateCvv(String? value) {
    final required = _validateRequired(value, "CVV");
    if (required != null) return required;

    if ((value ?? "").length < 3) {
      return "CVV hatalı";
    }
    return null;
  }

  String? _getCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(" ", "");
    if (cleaned.isEmpty) return null;

    final firstDigit = cleaned[0];
    if (firstDigit == '4') return 'Visa';
    if (firstDigit == '5') return 'Mastercard';

    return null;
  }

  IconData _getCardIcon(String? cardType) {
    switch (cardType) {
      case 'Visa':
        return Icons.credit_card;
      case 'Mastercard':
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethodType value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFF97316) : const Color(0xFFE9E2EC),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFEDD5)
                    : const Color(0xFFF7F4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFF97316)
                    : const Color(0xFF6B6670),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F2A33),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF6B6670),
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethodType>(
              value: value,
              groupValue: _selectedMethod,
              activeColor: const Color(0xFFF97316),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _selectedMethod = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = CartService.instance.totalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F4FA),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Ödeme",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Color(0xFF2F2A33),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: Color(0xFFF97316),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Toplam Tutar",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B6670),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₺$total",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Ödeme Yöntemi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2F2A33),
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              value: PaymentMethodType.card,
              icon: Icons.credit_card_outlined,
              title: "Kredi / Banka Kartı",
              subtitle: "Kart bilgilerini girerek ödemenizi tamamlayın.",
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              value: PaymentMethodType.payAtTable,
              icon: Icons.table_restaurant_outlined,
              title: "Masada Ödeme",
              subtitle: "Sipariş oluşturulur, ödeme restoranda alınır.",
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              value: PaymentMethodType.cash,
              icon: Icons.payments_outlined,
              title: "Nakit",
              subtitle: "Sipariş oluşturulur, ödeme nakit olarak yapılır.",
            ),
            const SizedBox(height: 18),
            if (_isCardPayment)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        validator: (value) =>
                            _validateRequired(value, "Kart sahibi adı"),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "Kart Sahibi",
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: const Color(0xFFF7F4FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        validator: _validateCardNumber,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          CardNumberInputFormatter(),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: "Kart Numarası",
                          hintText: "1234 5678 9012 3456",
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                          suffixText: _getCardType(_cardNumberController.text),
                          suffixStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                _getCardType(_cardNumberController.text) != null
                                    ? const Color(0xFFF97316)
                                    : Colors.transparent,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F4FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              validator: _validateExpiry,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                ExpiryDateInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: "Son Kullanma",
                                hintText: "AA/YY",
                                prefixIcon:
                                    const Icon(Icons.calendar_today_outlined),
                                filled: true,
                                fillColor: const Color(0xFFF7F4FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              validator: _validateCvv,
                              obscureText: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: InputDecoration(
                                labelText: "CVV",
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: const Color(0xFFF7F4FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (!_isCardPayment)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _selectedMethod == PaymentMethodType.cash
                            ? Icons.payments_outlined
                            : Icons.table_restaurant_outlined,
                        color: const Color(0xFFF97316),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _selectedMethod == PaymentMethodType.cash
                            ? "Sipariş oluşturulacak, ödeme restoranda nakit alınacak."
                            : "Sipariş oluşturulacak, ödeme masada veya kasada tamamlanacak.",
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Color(0xFF5B5560),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _isPaying ? null : _completePayment,
                child: _isPaying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isCardPayment
                            ? "Ödemeyi Tamamla • ₺$total"
                            : "Siparişi Oluştur • ₺$total",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(" ", "");

    if (digits.length > 16) {
      digits = digits.substring(0, 16);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digits.length) {
        buffer.write(" ");
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll("/", "");

    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    String formatted = digits;
    if (digits.length >= 3) {
      formatted = "${digits.substring(0, 2)}/${digits.substring(2)}";
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
