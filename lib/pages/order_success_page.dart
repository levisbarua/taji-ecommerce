import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'my_orders_page.dart';

class OrderSuccessPage extends StatelessWidget {
  final String orderId;
  const OrderSuccessPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Positioned(top: 40, left: 60, child: _confettiShape(pureYellow, 12, true)),
                  Positioned(top: 30, right: 70, child: _confettiShape(Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), 15, false)),
                  Positioned(bottom: 50, left: 80, child: _confettiShape(pureYellow.withValues(alpha: 0.5), 10, true)),
                  Positioned(top: 100, right: 40, child: _confettiShape(Theme.of(context).colorScheme.onSurface, 8, false)),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: pureBlack,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: pureYellow.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface, size: 50),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Text(
                "Order Successful!",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "Your order has been placed successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Order ID: $orderId",
                style: TextStyle(
                  color: pureYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                  );
                },
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pureYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "Track Order",
                      style: TextStyle(color: pureBlack, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pureBlack,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: Center(
                    child: Text(
                      "Back to Home",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confettiShape(Color color, double size, bool isCircle) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(2),
      ),
    );
  }
}
