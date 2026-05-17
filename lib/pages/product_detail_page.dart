import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/constants.dart';
import '../services/managers.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String name;
  final String category;
  final String price;
  final String? imagePath;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    this.imagePath,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  dynamic _selectedSize = 41;
  final List<dynamic> _shoeSizes = [40, 41, 42, 43, 44];
  final List<String> _tshirtSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _selectedSize = (widget.category == 'Merchant' || widget.category == 'Storefront' || widget.category == 'Marketing') ? 'M' : 41;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: widget.imagePath != null && widget.imagePath!.isNotEmpty
                  ? (widget.imagePath!.startsWith('http')
                      ? Image.network(
                          widget.imagePath!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : widget.imagePath!.startsWith('assets/')
                          ? Image.asset(
                              widget.imagePath!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(widget.imagePath!),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ))
                  : Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                        ),
                        child: Icon(Icons.shopping_bag_outlined, size: 120, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                      ),
                    ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tajiTextDark.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: tajiTextDark.withValues(alpha: 0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: const Icon(Icons.favorite, color: tajiError, size: 24),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.zero,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.category,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          widget.price,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.star, color: pureYellow, size: 20),
                        Icon(Icons.star, color: pureYellow, size: 20),
                        Icon(Icons.star, color: pureYellow, size: 20),
                        Icon(Icons.star, color: pureYellow, size: 20),
                        Icon(Icons.star, color: pureYellow, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "4.8 (124 Reviews)",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Description",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "High-performance design with ultimate comfort and support. Perfect for both athletic performance and casual everyday wear.",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    if (widget.category == 'Merchant' || widget.category == 'Storefront' || widget.category == 'Marketing') ...[
                      Text(
                        "Size",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.category == 'Merchant' ? _tshirtSizes.length : _shoeSizes.length,
                          itemBuilder: (context, index) {
                            final sizes = widget.category == 'Merchant' ? _tshirtSizes : _shoeSizes;
                            bool isSelected = _selectedSize == sizes[index];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = sizes[index]),
                              child: Container(
                                margin: const EdgeInsets.only(right: 15),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected ? pureBlack : pureWhite,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected ? pureBlack : pureBlack.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    sizes[index].toString(),
                                    style: TextStyle(
                                      color: isSelected ? pureWhite : pureBlack,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () async {
                        final priceValue = double.tryParse(widget.price.replaceAll(r'$', '').trim()) ?? 0.0;
                        await CartManager.addToCart({
                          'name': widget.name,
                          'size': _selectedSize,
                          'price': priceValue,
                          'quantity': 1,
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to Cart!")),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartPage()),
                          );
                        }
                      },
                      child: Container(
                        height: 65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: pureBlack,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, color: pureWhite, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: pureWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
