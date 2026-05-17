import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../services/user_session.dart';
import '../services/managers.dart';
import '../services/mpesa_service.dart';
import 'order_success_page.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  const PaymentPage({super.key, this.totalAmount = 525.00});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedMethod = 0;
  final TextEditingController _phoneController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "Payment Methods",
                      style: TextStyle(color: pureWhite, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(0, "M-Pesa", "KES", Icons.phone_android),
                    const SizedBox(height: 12),
                    _buildPaymentMethod(1, "PayPal", "Pay", Icons.payment),
                    const SizedBox(height: 12),
                    _buildPaymentMethod(2, "Cash on Delivery", "Cash", Icons.money),
                    if (_selectedMethod == 0) ...[
                      const SizedBox(height: 24),
                      Text(
                        "M-Pesa Phone Number",
                        style: TextStyle(color: pureWhite.withValues(alpha: 0.7), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: pureWhite, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: "0715 000 000",
                          hintStyle: TextStyle(color: pureWhite.withValues(alpha: 0.3)),
                          prefixText: "+254 ",
                          prefixStyle: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold, fontSize: 18),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: pureYellow),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooterPay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface, size: 24),
              ),
            ),
          ),
          Text(
            "Payment",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(int index, String title, String tag, IconData icon) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? pureYellow : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: index == 0 ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : pureBlack.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: index == 0 ? const Color(0xFF4CAF50) : Theme.of(context).colorScheme.onSurface, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? pureYellow : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  width: 2,
                ),
                color: isSelected ? pureYellow : Colors.transparent,
              ),
              child: isSelected ? Icon(Icons.check, size: 16, color: pureBlack) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterPay() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: GestureDetector(
        onTap: _processing ? null : _handlePayment,
        child: Container(
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _processing ? pureYellow.withValues(alpha: 0.5) : pureYellow,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: _processing
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                : Text(
                    "Pay KES ${widget.totalAmount.toStringAsFixed(0)}",
                    style: const TextStyle(color: pureBlack, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_selectedMethod == 0) {
      // M-Pesa
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _showSnack('Enter your M-Pesa phone number');
        return;
      }

      setState(() => _processing = true);

      final result = await MpesaService.stkPush(
        phoneNumber: phone,
        amount: widget.totalAmount,
        accountReference: 'TAJI-${DateTime.now().millisecondsSinceEpoch}',
      );

      setState(() => _processing = false);

      if (!mounted) return;

      if (result['success'] == true) {
        // Show PIN dialog
        final entered = await _showPinDialog(result['message'] as String);
        if (entered == true && mounted) {
          _completeOrder();
        }
      } else {
        _showSnack(result['message'] as String);
      }
    } else {
      // PayPal or Cash — complete order directly
      _completeOrder();
    }
  }

  Future<bool?> _showPinDialog(String message) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A202C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_android, color: Color(0xFF4CAF50), size: 48),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: pureWhite), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Text("Enter M-Pesa PIN on your phone", style: TextStyle(color: tajiTextMutedDark, fontSize: 13)),
            const SizedBox(height: 8),
            const Text("Then tap 'Done' below", style: TextStyle(color: tajiTextMutedDark, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel', style: TextStyle(color: tajiTextMutedDark)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: pureWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done — Paid'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOrder() async {
    setState(() => _processing = true);

    final userEmail = await UserSession.getEmail();
    final orderId = "#TAJI-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";
    final paymentMethods = ['M-Pesa', 'PayPal', 'Cash on Delivery'];

    await OrderManager.addOrder({
      "id": orderId,
      "user": userEmail ?? "Guest",
      "items_count": 2,
      "status": "Pending",
      "date": "Just now",
      "total": "KES ${widget.totalAmount.toStringAsFixed(0)}",
      "payment": paymentMethods[_selectedMethod],
    });

    // Clear cart after order
    final cart = await CartManager.getCart();
    for (final item in cart) {
      await CartManager.removePermanently(item['name'] as String);
    }

    setState(() => _processing = false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OrderSuccessPage(orderId: orderId)),
      (route) => route.isFirst,
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: pureYellow, behavior: SnackBarBehavior.floating),
    );
  }
}
