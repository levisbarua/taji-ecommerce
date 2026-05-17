import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/constants.dart';
import '../services/managers.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final String category;
  final bool showBackButton;
  const ProductListPage({super.key, required this.category, this.showBackButton = true});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Merchant', 'Design', 'Brands', 'Projects'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomProducts();
  }

  Future<void> _loadCustomProducts() async {
    final products = await ProductManager.getProducts();
    if (mounted) {
      setState(() {
        _allProducts = products;
      });
    }
  }

  List<Map<String, String>> _allProducts = [];

  List<Map<String, String>> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesSearch = p['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedFilterIndex == 0 || p['category'] == _filters[_selectedFilterIndex];
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilterChips(),
            const SizedBox(height: 24),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showBackButton)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                    ),
                    child: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface, size: 24),
                  ),
                ),
              if (!widget.showBackButton) const SizedBox(width: 20),
              Text(
                widget.category,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search products...",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? pureYellow : (Theme.of(context).brightness == Brightness.dark ? pureBlack : pureWhite),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isSelected ? pureBlack : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              "No items found",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductItem(index, products);
      },
    );
  }

  Widget _buildProductItem(int index, List<Map<String, String>> products) {
    final product = products[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              name: product["name"]!,
              category: product["category"] ?? "Category",
              price: product["price"]!,
              imagePath: product["image"],
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Stack(
                children: [
                  if (product["image"] != null && product["image"]!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: product["image"]!.startsWith('http')
                        ? Image.network(
                            product["image"]!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : product["image"]!.startsWith('assets/')
                          ? Image.asset(
                              product["image"]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(product["image"]!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    )
                  else
                    Center(
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.shopping_bag_outlined, size: 60, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FutureBuilder<bool>(
                      future: WishlistManager.isLiked(product["name"]!),
                      builder: (context, snapshot) {
                        final isLiked = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () async {
                            await WishlistManager.toggleWishlist(product["name"]!);
                            if (!context.mounted) return;
                            (context as Element).markNeedsBuild();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isLiked ? 'Removed from Wishlist' : 'Added to Wishlist!'),
                                backgroundColor: pureYellow,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? tajiError : pureYellow,
                            size: 22,
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product["name"]!,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            product["price"]!,
            style: TextStyle(color: pureYellow, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
