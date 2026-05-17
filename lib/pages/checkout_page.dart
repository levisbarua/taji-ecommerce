import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/managers.dart';
import 'payment_page.dart';
import 'address_editing_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedDeliveryMethod = 0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotal();
  }

  Future<void> _loadTotal() async {
    final cart = await CartManager.getCart();
    double total = 0;
    for (final item in cart) {
      final priceStr = (item['price'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), '');
      final price = double.tryParse(priceStr) ?? 0;
      final qty = (item['quantity'] as int?) ?? 1;
      total += price * qty;
    }
    if (mounted) setState(() => _totalAmount = total);
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
            _buildStepIndicator(),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    "Shipping Address",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildAddressCard(),
                  const SizedBox(height: 32),
                  Text(
                    "Delivery Method",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                    const SizedBox(height: 16),
                    _buildDeliveryMethod(0, "Express Delivery", "1-2 Business Days", "\$15.00"),
                    const SizedBox(height: 16),
                    _buildDeliveryMethod(1, "Standard Delivery", "3-5 Business Days", "Free"),
                  ],
                ),
              ),
            ),
            _buildFooterSummary(),
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
            "Checkout",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          _stepCircle("1", true),
          Expanded(child: Container(height: 2, color: pureYellow)),
          _stepCircle("2", true),
          Expanded(child: Container(height: 2, color: pureWhite.withValues(alpha: 0.1))),
          _stepCircle("3", false),
        ],
      ),
    );
  }

  Widget _stepCircle(String step, bool active) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: active ? pureYellow : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(step,
            style: TextStyle(
              color: active ? pureBlack : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget _buildAddressCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddressEditingPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Home",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "123 Fashion Street, NY 10001\n+1 234 567 8900",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMethod(int index, String title, String subtitle, String price) {
    bool isSelected = _selectedDeliveryMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedDeliveryMethod = index),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSummary() {
    final deliveryFee = _selectedDeliveryMethod == 0 ? 15.0 : 0.0;
    final grandTotal = _totalAmount + deliveryFee;
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Payment",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "KES ${grandTotal.toStringAsFixed(0)}",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (_totalAmount > 0)
                    Text(
                      "Items: KES ${_totalAmount.toStringAsFixed(0)} + Delivery: KES ${deliveryFee.toStringAsFixed(0)}",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentPage(totalAmount: grandTotal)),
              );
            },
            child: Container(
              height: 65,
              width: double.infinity,
              decoration: BoxDecoration(
                color: pureYellow,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  "Continue to Payment",
                  style: TextStyle(color: pureBlack, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
