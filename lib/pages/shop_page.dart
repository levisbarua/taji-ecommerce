import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../services/managers.dart';
import 'product_list_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';
import 'admin_panel.dart';
import 'notifications_page.dart';
import 'product_detail_page.dart';

class ShopPage extends StatefulWidget {
  final bool isAdmin;
  const ShopPage({super.key, this.isAdmin = false});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 0;
  String _selectedCategory = 'Merchant';
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  String _userName = 'Sara Jenkins';
  XFile? _profileImage;
  bool _isBannerActive = false;
  String _bannerText = "";

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
    _loadGlobalBanner();
  }

  Future<void> _loadGlobalBanner() async {
    final active = await GlobalSettingsManager.isBannerActive();
    final text = await GlobalSettingsManager.getBannerText();
    if (mounted) {
      setState(() {
        _isBannerActive = active;
        _bannerText = text;
      });
    }
  }

  Future<void> _loadProfileInfo() async {
    final data = await ProfileManager.getProfileData();
    if (mounted) {
      setState(() {
        _userName = data['name']!;
        if (data['image']!.isNotEmpty) {
          _profileImage = XFile(data['image']!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNav(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Navigator(
            key: _homeNavigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isBannerActive) _buildGlobalBanner(),
                          const SizedBox(height: 20),
                          _buildHeader(),
                          const SizedBox(height: 30),
                          _buildSearchAndFilter(),
                          const SizedBox(height: 30),
                          _buildPromoBanner(),
                          const SizedBox(height: 30),
                          _buildCategories(),
                          const SizedBox(height: 30),
                          _buildPopularNow(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const ProductListPage(category: 'Search Results', showBackButton: false),
          const CartPage(showBackButton: false),
          const WishlistPage(showBackButton: false),
          const ProfilePage(),
          if (widget.isAdmin) AdminPanel(onProductDeleted: () {
            if (mounted) setState(() {});
          }),
        ],
      ),
    );
  }

  Widget _buildGlobalBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: pureYellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _bannerText,
              style: const TextStyle(color: pureBlack, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isBannerActive = false;
              });
            },
            child: const Icon(Icons.close, color: pureBlack, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 4;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: pureYellow,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 2),
              image: _profileImage != null 
                ? DecorationImage(image: FileImage(File(_profileImage!.path)), fit: BoxFit.cover)
                : null,
            ),
            child: _profileImage == null ? const Icon(Icons.person, color: pureBlack) : null,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
            ),
            Text(
              _userName,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsPage()),
            );
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface, size: 26),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: tajiError,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListPage(category: 'Search Results')),
              );
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 12),
                  Text(
                    'Search for clothes, shoes...',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductListPage(category: 'Search Results')),
            );
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: pureYellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search, color: tajiTextDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return FutureBuilder<Map<String, dynamic>>(
      future: DiscountManager.getPromoData(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {
          'title': 'New Collection',
          'discount': 'Discount up to 50%',
          'poster': '',
          'active': true,
        };
        final String title = data['title'] ?? 'New Collection';
        final String discount = data['discount'] ?? 'Discount up to 50%';
        final String poster = data['poster'] ?? '';
        final bool active = data['active'] ?? true;

        if (!active) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: pureBlack,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: pureYellow.withValues(alpha: 0.3)),
            image: poster.isNotEmpty 
              ? DecorationImage(
                  image: FileImage(File(poster)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(pureBlack.withValues(alpha: 0.4), BlendMode.darken),
                )
              : null,
          ),
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: pureWhite, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    discount,
                    style: TextStyle(color: pureWhite.withValues(alpha: 0.8), fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductListPage(category: 'New Collection')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: pureWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(color: pureBlack, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.shopping_bag_outlined, size: 140, color: pureYellow),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductListPage(category: 'Categories')),
                );
              },
              child: Text(
                'See All',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryIcon(Icons.storefront_outlined, 'Merchant'),
            _buildCategoryIcon(Icons.brush_outlined, 'Design'),
            _buildCategoryIcon(Icons.verified_outlined, 'Brands'),
            _buildCategoryIcon(Icons.auto_awesome_mosaic_outlined, 'Projects'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: isSelected ? pureYellow : (Theme.of(context).brightness == Brightness.dark ? pureBlack : pureWhite),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: isSelected ? pureBlack : Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isSelected ? 1.0 : 0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularNow() {
    return FutureBuilder<List<Map<String, String>>>(
      future: ProductManager.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final allProducts = snapshot.data ?? [];
        final items = allProducts.where((p) => p['category'] == _selectedCategory).toList();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular $_selectedCategory',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    _homeNavigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (context) => ProductListPage(category: _selectedCategory)),
                    );
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (items.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.7,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(items[index]['name']!, items[index]['category'] ?? items[index]['type'] ?? '', items[index]['price']!, imagePath: items[index]['image']);
                },
              ),
          ],
        );
      }
    );
  }

  Widget _buildProductCard(String name, String category, String price, {String? imagePath}) {
    return GestureDetector(
      onTap: () {
        _homeNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              name: name,
              category: category,
              price: price,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                if (imagePath != null && imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: imagePath.startsWith('assets/')
                      ? Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      : Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  )
                else
                  Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).colorScheme.onSurface, size: 60),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Added to Favorites!'),
                          backgroundColor: pureYellow,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(Icons.favorite_border, color: pureYellow, size: 24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            if (_selectedIndex == 0) {
              _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _selectedIndex = 0);
              _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
            }
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: pureYellow,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          if (widget.isAdmin)
            const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}
