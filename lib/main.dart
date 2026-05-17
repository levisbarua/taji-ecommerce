import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'database_service.dart';
import 'update_service.dart';

// ── Premium Golden Amber Palette ──
// Accent
const Color tajiAmber = Color(0xFFFFB800);
const Color tajiAmberDark = Color(0xFFE5A600);

// Dark mode surfaces
const Color tajiDarkBg = Color(0xFF000000); // True Black
const Color tajiDarkSurface = Color(0xFF151515); // Elevated True Black
const Color tajiDarkBorder = Color(0xFF333333); // Neutral Dark Border

// Light mode surfaces
const Color tajiLightBg = Color(0xFFF5F5F0);
const Color tajiLightSurface = Color(0xFFFFFFFF);
const Color tajiLightBorder = Color(0xFFE0E0D8);

// Text colors
const Color tajiTextLight = Color(0xFFF5F5F5);
const Color tajiTextDark = Color(0xFF000000); // True Black text on light backgrounds
const Color tajiTextMutedDark = Color(0xFFAAAAAA); // Neutral grey on dark
const Color tajiTextMutedLight = Color(0xFF666666); // Neutral grey on light

// Semantic colors
const Color tajiError = Color(0xFFD32F2F);
const Color tajiSuccess = Color(0xFF2E7D32);

// Legacy aliases — keep all existing references working
const Color pureBlack = tajiDarkBg;
const Color pureWhite = tajiLightSurface;
const Color pureYellow = tajiAmber;

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const TajiApp());
}

class UserSession {
  static const String _keyEmail = 'user_email';

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
  }

  static bool isAdmin(String? email) {
    return email?.toLowerCase().trim() == 'barualevis@gmail.com';
  }
}

class WishlistManager {
  static Future<List<String>> getWishlist() async {
    return DatabaseService.getWishlist();
  }

  static Future<void> toggleWishlist(String productName) async {
    await DatabaseService.toggleWishlist(productName);
  }

  static Future<bool> isLiked(String productName) async {
    return DatabaseService.isInWishlist(productName);
  }

  static Future<void> removePermanently(String productName) async {
    await DatabaseService.removeFromWishlist(productName);
  }
}

class CartManager {
  static Future<List<Map<String, dynamic>>> getCart() async {
    return DatabaseService.getCartItems();
  }

  static Future<void> addToCart(Map<String, dynamic> item) async {
    await DatabaseService.addCartItem(item);
  }

  static Future<void> updateQuantity(String name, dynamic size, int newQuantity) async {
    await DatabaseService.updateCartQuantity(name, size, newQuantity);
  }

  static Future<void> removeFromCart(String name, dynamic size) async {
    await DatabaseService.removeCartItem(name, size);
  }

  static Future<void> removePermanently(String name) async {
    await DatabaseService.removeCartItemByName(name);
  }
}

class AddressManager {
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    return DatabaseService.getAddresses();
  }

  static Future<void> addAddress(Map<String, String> address) async {
    await DatabaseService.addAddress(address);
  }

  static Future<void> deleteAddress(int index) async {
    await DatabaseService.deleteAddress(index);
  }
}

class DiscountManager {
  static Future<Map<String, dynamic>> getPromoData() async {
    return {
      'title': await DatabaseService.getPromoValue('promo_title') ?? 'New Collection',
      'discount': await DatabaseService.getPromoValue('promo_discount') ?? 'Discount up to 50%',
      'poster': await DatabaseService.getPromoValue('promo_poster') ?? '',
      'active': (await DatabaseService.getPromoValue('promo_active')) == 'true' || (await DatabaseService.getPromoValue('promo_active')) == null,
    };
  }

  static Future<void> savePromoData(String title, String discount, String poster, bool active) async {
    await DatabaseService.setPromoValue('promo_title', title);
    await DatabaseService.setPromoValue('promo_discount', discount);
    await DatabaseService.setPromoValue('promo_poster', poster);
    await DatabaseService.setPromoValue('promo_active', active.toString());
  }
}

class ProfileManager {
  static Future<Map<String, String>> getProfileData() async {
    final data = await DatabaseService.getAllProfileData();
    return {
      'name': data['name'] ?? 'Sarah Jenkins',
      'firstName': data['firstName'] ?? 'Levis',
      'lastName': data['lastName'] ?? 'Barua',
      'email': data['email'] ?? 'barualevis@gmail.com',
      'phone': data['phone'] ?? '0715773232',
      'image': data['image'] ?? '',
      'location': data['location'] ?? 'Nairobi City, Kenya',
      'birthday': data['birthday'] ?? 'Jan 12, 2000',
      'sex': data['sex'] ?? 'Male',
    };
  }

  static Future<void> saveProfileData(String name, String email, String image) async {
    await DatabaseService.setProfileValue('name', name);
    await DatabaseService.setProfileValue('email', email);
    await DatabaseService.setProfileValue('image', image);
  }

  static Future<void> savePersonalDetails({
    required String firstName,
    required String lastName,
    required String location,
    required String birthday,
    required String sex,
    String? image,
  }) async {
    await DatabaseService.setProfileValue('firstName', firstName);
    await DatabaseService.setProfileValue('lastName', lastName);
    await DatabaseService.setProfileValue('location', location);
    await DatabaseService.setProfileValue('birthday', birthday);
    await DatabaseService.setProfileValue('sex', sex);
    await DatabaseService.setProfileValue('name', "$firstName $lastName");
    if (image != null) await DatabaseService.setProfileValue('image', image);
  }

  static Future<void> saveSignupData({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    await DatabaseService.setProfileValue('firstName', firstName);
    await DatabaseService.setProfileValue('lastName', lastName);
    await DatabaseService.setProfileValue('email', email);
    await DatabaseService.setProfileValue('phone', phone);
    await DatabaseService.setProfileValue('name', "$firstName $lastName");
  }

  static Future<void> updateName(String name) async {
    await DatabaseService.setProfileValue('name', name);
  }
}

class ProductManager {
  static Future<List<Map<String, String>>> getProducts() async {
    final dbProducts = await DatabaseService.getProducts();
    if (dbProducts.isEmpty) return [];
    return dbProducts.map((item) {
      return {
        "name": item["name"]?.toString() ?? "Unnamed",
        "category": item["category"]?.toString() ?? "General",
        "price": item["price"]?.toString() ?? r"$0.00",
        "description": item["description"]?.toString() ?? "",
        "type": item["type"]?.toString() ?? "",
        "image": item["image"]?.toString() ?? "",
      };
    }).toList();
  }

  static Future<void> saveProduct(Map<String, String> product) async {
    await DatabaseService.addProduct(product);
  }

  static Future<void> deleteProduct(String name) async {
    await DatabaseService.deleteProduct(name);
    await WishlistManager.removePermanently(name);
    await CartManager.removePermanently(name);
  }
}

class GlobalSettingsManager {
  // Banner Settings
  static Future<bool> isBannerActive() async {
    return DatabaseService.getSettingBool('global_banner_active', defaultValue: false);
  }

  static Future<String> getBannerText() async {
    return await DatabaseService.getSetting('global_banner_text') ?? "Free shipping on orders over \$50!";
  }

  static Future<void> setBanner(bool active, String text) async {
    await DatabaseService.setSettingBool('global_banner_active', active);
    await DatabaseService.setSetting('global_banner_text', text);
  }

  // Premium Toggle
  static Future<bool> isPremium() async {
    return DatabaseService.getSettingBool('global_premium_active', defaultValue: false);
  }

  static Future<void> setPremium(bool active) async {
    await DatabaseService.setSettingBool('global_premium_active', active);
  }

  // Custom Notifications
  static Future<List<Map<String, String>>> getNotifications() async {
    final rows = await DatabaseService.getNotifications();
    return rows.map((r) => {
      "title": r['title']?.toString() ?? '',
      "message": r['message']?.toString() ?? '',
      "time": r['time']?.toString() ?? 'Just now',
      "icon": r['icon']?.toString() ?? 'notifications',
      "color": r['color']?.toString() ?? 'yellow',
    }).toList();
  }

  static IconData getIcon(String? name) {
    switch (name) {
      case 'local_shipping': return Icons.local_shipping;
      case 'local_offer': return Icons.local_offer;
      case 'message': return Icons.message;
      case 'celebration': return Icons.celebration;
      case 'campaign': return Icons.campaign;
      default: return Icons.notifications;
    }
  }

  static Color getColor(String? name) {
    switch (name) {
      case 'blue': return tajiAmber;
      case 'yellow': return tajiAmber;
      case 'green': return tajiSuccess;
      case 'purple': return tajiAmberDark;
      case 'red': return tajiError;
      default: return tajiAmber;
    }
  }

  static Future<void> addNotification(String title, String message, String colorName, String iconName) async {
    await DatabaseService.addNotification({
      "title": title,
      "message": message,
      "time": "Just now",
      "color": colorName,
      "icon": iconName,
    });
  }

  static Future<void> deleteNotification(int index) async {
    await DatabaseService.deleteNotification(index);
  }
}

class CategoryManager {
  static Future<List<String>> getCategories() async {
    final rows = await DatabaseService.getCategories();
    if (rows.isEmpty) return ['Merchant', 'Design', 'Brands', 'Projects'];
    return rows.map((r) => r['name'] as String).toList();
  }

  static Future<void> addCategory(String category) async {
    await DatabaseService.addCategory(category);
  }

  static Future<void> deleteCategory(String category) async {
    await DatabaseService.deleteCategory(category);
  }
}

class RequestManager {
  static Future<List<Map<String, dynamic>>> getRequests() async {
    return DatabaseService.getRequests();
  }

  static Future<void> addRequest(Map<String, dynamic> request) async {
    await DatabaseService.addRequest(request);
  }

  static Future<void> deleteRequest(int index) async {
    await DatabaseService.deleteRequest(index);
  }
}


class OrderManager {
  static Future<List<Map<String, dynamic>>> getOrders() async {
    return DatabaseService.getOrders();
  }

  static Future<void> addOrder(Map<String, dynamic> order) async {
    await DatabaseService.addOrder(order);
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await DatabaseService.updateOrderStatus(orderId, status);
  }
}

class TajiApp extends StatefulWidget {
  const TajiApp({super.key});

  @override
  State<TajiApp> createState() => _TajiAppState();
}

class _TajiAppState extends State<TajiApp> {
  bool _checkedUpdate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedUpdate) {
      _checkedUpdate = true;
      _checkForUpdate();
    }
  }

  Future<void> _checkForUpdate() async {
    const currentVersion = '0.1.0';
    final update = await UpdateService.checkForUpdate(currentVersion);
    if (update == null || !mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A202C),
        title: const Text('Update Available', style: TextStyle(color: pureWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v${update['version']}', style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(update['notes'] as String, style: const TextStyle(color: pureWhite)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: tajiTextMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UpdateService.downloadAndInstall(update['url'] as String, context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Taji App',
          themeMode: currentMode,
          theme: ThemeData(
            scaffoldBackgroundColor: tajiLightBg,
            cardColor: tajiLightSurface,
            colorScheme: const ColorScheme.light(
              primary: tajiAmber,
              onPrimary: tajiTextDark,
              secondary: tajiAmberDark,
              onSecondary: tajiTextDark,
              surface: tajiLightSurface,
              onSurface: tajiTextDark,
              error: tajiError,
              outline: tajiLightBorder,
              surfaceContainerHighest: tajiLightBg,
            ),
            dividerColor: tajiLightBorder,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            scaffoldBackgroundColor: tajiDarkBg,
            cardColor: tajiDarkSurface,
            colorScheme: const ColorScheme.dark(
              primary: tajiAmber,
              onPrimary: tajiTextDark,
              secondary: tajiAmberDark,
              onSecondary: tajiTextDark,
              surface: tajiDarkBg,
              onSurface: tajiTextLight,
              error: tajiError,
              outline: tajiDarkBorder,
              surfaceContainerHighest: tajiDarkSurface,
            ),
            dividerColor: tajiDarkBorder,
            useMaterial3: true,
          ),
          home: FutureBuilder<String?>(
            future: UserSession.getEmail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator(color: pureYellow)));
              }
              if (snapshot.hasData && snapshot.data != null) {
                return ShopPage(isAdmin: UserSession.isAdmin(snapshot.data));
              }
              return Theme(
                data: ThemeData(
                  scaffoldBackgroundColor: tajiDarkBg,
                  colorScheme: const ColorScheme.dark(
                    primary: tajiAmber,
                    onPrimary: tajiTextDark,
                    secondary: tajiAmberDark,
                    surface: tajiDarkBg,
                    onSurface: tajiTextLight,
                    error: tajiError,
                    outline: tajiDarkBorder,
                    surfaceContainerHighest: tajiDarkSurface,
                  ),
                  dividerColor: tajiDarkBorder,
                  
                  useMaterial3: true,
                ),
                child: const HomePage(),
              );
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _shineController;
  late final AnimationController _glowController;
  late final AnimationController _floatController;
  late final AnimationController _logoController;
  
  late final Animation<double> _shineOffset;
  late final Animation<double> _glowRadius;
  late final Animation<double> _floatOffset;
  
  final String _fullTitle = 'TAJI THE CREATOR';

  @override
  void initState() {
    super.initState();
    
    // EFFECT 1: Shine Sweep Animation (Linear Gradient movement)
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _shineOffset = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // EFFECT 2: Pulsing Glimmer Animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowRadius = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // EFFECT 3: Gentle Vertical Float
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatOffset = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // LOGO: Rotation animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header space
            const SizedBox(height: 30),
            
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_shineController, _glowController, _floatController]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatOffset.value), // Vertical Floating
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            pureYellow,
                            pureWhite.withValues(alpha: 0.9), // The "Shine"
                            pureYellow,
                          ],
                          stops: [
                            _shineOffset.value - 0.2, // Movement of the shine
                            _shineOffset.value,
                            _shineOffset.value + 0.2,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        _fullTitle,
                        style: TextStyle(
                          fontSize: 32, // Reduced to 32px as requested
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface, // Theme-aware color
                          letterSpacing: 2.0, 
                          fontFamily: 'monospace',
                          shadows: [
                            Shadow(
                              color: pureYellow.withValues(alpha: 0.6), 
                              blurRadius: _glowRadius.value, // Pulsing Glimmer
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40),

                // Logo Area with Layers
                Expanded(
                  flex: 6,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Layer (Static TAJI text)
                        Image.asset(
                          'assets/images/bg_layer.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        // Masking the ORIGINAL header text in the asset so we can replace it with our larger code version
                        Align(
                          alignment: const Alignment(0, -0.85), // Moved UP for better coverage
                          child: Container(
                            width: double.infinity,
                            height: 100, // Increased height for more robust coverage of the asset top
                            color: Theme.of(context).scaffoldBackgroundColor, // Seamlessly blends
                          ),
                        ),

                        // New, Larger Header Text (Increased as requested, replacing the original)
                        Align(
                          alignment: const Alignment(0, -0.77), 
                          child: Text(
                            'COVER ART - MERCH - BRAND DESIGN',
                            style: TextStyle(
                              fontSize: 22, // Increased size for impact
                              fontWeight: FontWeight.w600,
                              color: pureWhite,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // TOP EDGE SOFTENER (Gradient for seamless transition)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).scaffoldBackgroundColor,
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Red dot removed as requested in the annotations
                        // Masking the unwanted sparkle at the bottom right of the background asset
                        // We use pureBlack here because the asset's background is dark/black in both Light and Dark modes
                        Align(
                          alignment: const Alignment(0.85, 0.88), 
                          child: Container(
                            width: 60, 
                            height: 60,
                            decoration: BoxDecoration(
                              color: pureBlack.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: pureBlack,
                                  blurRadius: 20,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Spinning Person (Foreground Layer) - Silhouette mode
                        Center(
                          child: AnimatedBuilder(
                            animation: _logoController,
                            builder: (context, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001) // perspective
                                  ..rotateY(_logoController.value * 2 * 3.14159),
                                child: child,
                              );
                            },
                            child: ClipRect(
                              // Surgically trims the bottom noise/artifacts at the feet
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: 0.88, // Cuts off the bottom 12% which contains the noise boxes
                                child: ColorFiltered(
                                  // High-Clarity detailed filter
                                  // Less aggressive on highlights (preserves face detail)
                                  // Boosts overall brightness for "clearer" features
                                  colorFilter: const ColorFilter.matrix([
                                    1.3, 0, 0, 0, 10,  // R' (Boosted for clarity)
                                    0, 1.3, 0, 0, 10,  // G'
                                    0, 0, 1.3, 0, 10,  // B'
                                    -4, -4, -4, 11, 0, // A (Surgical background removal: Preserves up to 90% brightness)
                                  ]),
                                  child: Image.asset(
                                    'assets/images/person_layer.png',
                                    height: 500, // Keeps original scale but clipped
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.person, color: tajiTextLight.withValues(alpha: 0.12), size: 200);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Bottom Shadow Gradient (Fade to black as requested)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120, // Height of the shadow area
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0), // Transparent top
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.4), // Subtle middle
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95), // Dark bottom
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 30),

            // Welcome Text area - Updated to Arts & Graphic Design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    'Elevating Digital Art\n& Graphic Design',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 44, // Increased from 38 for more impact
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Discover a new era of artistic expression through\ncurated concepts and innovative culture-driven design.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18, // Increased from 16 for better legibility
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Responsive Swipe Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SwipeButton(
                onSwipe: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AuthPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwipeButton extends StatefulWidget {
  final VoidCallback onSwipe;
  const SwipeButton({super.key, required this.onSwipe});

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // We want the yellow button to take exactly 50% of width initially (flex 1 of 2)
        // And slide to the right.
        double buttonWidth = constraints.maxWidth / 2;
        double maxSlide = constraints.maxWidth - buttonWidth - 12; // 6px padding on each side

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            children: [
              // Arrow indicators (Static Background)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: buttonWidth),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_right, color: tajiTextLight.withValues(alpha: 0.3), size: 28),
                          Icon(Icons.chevron_right, color: tajiTextLight.withValues(alpha: 0.6), size: 28),
                          const Icon(Icons.chevron_right, color: tajiTextLight, size: 28),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),

              // Draggable Swipe Action
              Positioned(
                left: _dragValue * maxSlide,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue += details.delta.dx / maxSlide;
                      _dragValue = _dragValue.clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragValue > 0.8) {
                      HapticFeedback.heavyImpact();
                      widget.onSwipe();
                    }
                    setState(() {
                      _dragValue = 0.0;
                    });
                  },
                  child: Container(
                    width: buttonWidth,
                    height: 68,
                    decoration: BoxDecoration(
                      color: pureYellow,
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: const Center(
                      child: Text(
                        'Swipe to start',
                        style: TextStyle(
                          color: pureBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showFields = false;
  bool _obscurePassword = true;
  bool _isLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _showPolicyDialog(String title, String content) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tajiDarkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: tajiTextLight, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(color: tajiTextLight.withValues(alpha: 0.8), fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const SizedBox(height: 20),

                if (!_showFields) ...[
                  // 2. Branding Case (Smaller in selection screen)
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: pureYellow,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/taji.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => const Center(child: Text("TAJI", style: TextStyle(color: pureBlack, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Welcome to Taji",
                          style: TextStyle(
                            color: tajiTextLight,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Elevate your space with curated art and design",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: pureWhite.withValues(alpha: 0.7),
                            fontSize: 18,
                            
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 350),

                  // 3. Social Buttons
                  _buildSimplifiedSocialButton(
                    "Continue with Google",
                    Image.asset('assets/images/google_logo.png', width: 24, height: 24),
                    pureWhite,
                    pureBlack,
                    () => _handleSocialAuth(_isLogin ? 'Google Login' : 'Google Signup'),
                  ),
                  const SizedBox(height: 16),
                  _buildSimplifiedSocialButton(
                    "Continue with Facebook",
                    const Icon(Icons.facebook, color: tajiTextLight, size: 28),
                    const Color(0xFF1877F2),
                    tajiTextLight,
                    () => _handleSocialAuth(_isLogin ? 'Facebook Login' : 'Facebook Signup'),
                  ),
                  const SizedBox(height: 16),

                  // 4. Primary Email/Phone Action
                  _buildSimplifiedSocialButton(
                    _isLogin ? "Log in with email or phone" : "Create an account with email or phone",
                    null,
                    pureYellow,
                    pureBlack,
                    () => setState(() => _showFields = true),
                  ),

                  const SizedBox(height: 40),

                  // 5. Toggle link
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: pureWhite, fontSize: 16),
                        children: [
                          TextSpan(text: _isLogin ? "Don't have an account? " : "Already registered? "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                _isLogin ? "Create one now" : "Log in",
                                style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Form Fields (Visible when _showFields is true)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _showFields = false),
                        icon: const Icon(Icons.arrow_back, color: pureWhite),
                      ),
                      Text(
                        _isLogin ? "Log in" : "Create an account",
                        style: const TextStyle(color: pureWhite, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Social Buttons in Form View (Signup only as per image)
                  if (!_isLogin) ...[
                    _buildSimplifiedSocialButton(
                      "Continue with Google",
                      Image.asset('assets/images/google_logo.png', width: 20, height: 20),
                      pureWhite,
                      pureBlack,
                      () => _handleSocialAuth('Google Signup'),
                    ),
                    const SizedBox(height: 12),
                    _buildSimplifiedSocialButton(
                      "Continue with Facebook",
                      const Icon(Icons.facebook, color: tajiTextLight, size: 24),
                      const Color(0xFF1877F2),
                      tajiTextLight,
                      () => _handleSocialAuth('Facebook Signup'),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_isLogin) ...[
                    _buildRefinedOutlinedField(
                      label: 'Email address*',
                      pureWhite: pureWhite,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Password*',
                      isPassword: true,
                      obscure: _obscurePassword,
                      pureWhite: pureWhite,
                      controller: _passwordController,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ] else ...[
                    // Signup Fields
                    _buildRefinedOutlinedField(
                      label: 'Email address*',
                      pureWhite: pureWhite,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Password*',
                      isPassword: true,
                      obscure: _obscurePassword,
                      pureWhite: pureWhite,
                      controller: _passwordController,
                      helperText: "Avoid disclosing your password to anyone",
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'First name*',
                      pureWhite: pureWhite,
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Last name*',
                      pureWhite: pureWhite,
                      controller: _lastNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Phone number*',
                      pureWhite: pureWhite,
                      controller: _phoneController,
                      showClearIcon: true,
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handlePrimaryAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pureYellow,
                        foregroundColor: pureBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isLogin ? "Log in" : "Create an account",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 60),
                
                // Footer Policy Text
                Center(
                  child: Text(
                    "By continuing you agree to the",
                    style: TextStyle(color: pureWhite.withValues(alpha: 0.5), fontSize: 16),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showPolicyDialog(
                          "Terms and Conditions",
                          "Welcome to Taji. By using our service, you agree to these terms... [Placeholder for full Terms content]",
                        ),
                        child: Text(
                          "Terms and Conditions",
                          style: TextStyle(
                            color: pureWhite.withValues(alpha: 0.7),
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(" and ", style: TextStyle(color: pureWhite.withValues(alpha: 0.5), fontSize: 16)),
                      GestureDetector(
                        onTap: () => _showPolicyDialog(
                          "Privacy Policy",
                          "Your privacy is important to us. This policy explains how we collect and use your data... [Placeholder for full Privacy content]",
                        ),
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            color: pureWhite.withValues(alpha: 0.7),
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrimaryAuth() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    
    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return;
    }
    
    if (!_isLogin) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();

      if (password.length < 8) {
        _showErrorSnackBar('Password must be at least 8 characters long');
        return;
      }
      if (firstName.isEmpty || lastName.isEmpty) {
        _showErrorSnackBar('Please enter your full name');
        return;
      }
      if (phone.isEmpty) {
        _showErrorSnackBar('Please enter your phone number');
        return;
      }
    } else {
      if (password.isEmpty) {
        _showErrorSnackBar('Please enter your password');
        return;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLogin ? 'Logging in...' : 'Creating account...', style: const TextStyle(fontFamily: 'Calibri')),
        backgroundColor: pureYellow,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
      ),
    );
    
    final isAdmin = UserSession.isAdmin(email);
    await UserSession.saveEmail(email);
    
    // Save signup details if not login
    if (!_isLogin) {
      await ProfileManager.saveSignupData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: email,
        phone: _phoneController.text.trim(),
      );
    }

    if (!context.mounted) return;
    
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!context.mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ShopPage(isAdmin: isAdmin)),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Calibri')),
        backgroundColor: pureYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSocialAuth(String method) async {
    final isSignup = method.toLowerCase().contains('signup');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSignup ? 'Fetching $method profile...' : '$method successful!', style: const TextStyle(fontFamily: 'Calibri')),
        backgroundColor: pureYellow,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
    
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    if (isSignup) {
      setState(() {
        _firstNameController.text = 'Taji'; 
        _lastNameController.text = 'User'; 
        _emailController.text = 'user@example.com'; 
        _showFields = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile linked! Please verify your details to complete.', style: TextStyle(fontFamily: 'Calibri')),
          backgroundColor: pureYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ShopPage(isAdmin: false)),
        (route) => false,
      );
    }
  }



  Widget _buildSimplifiedSocialButton(String label, Widget? icon, Color bgColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefinedOutlinedField({
    required String label,
    required Color pureWhite,
    bool isPassword = false,
    bool obscure = false,
    String? helperText,
    bool showClearIcon = false,
    VoidCallback? onToggleVisibility,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(primaryColor: pureYellow),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: tajiTextLight, fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: tajiTextLight.withValues(alpha: 0.5), fontSize: 14),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: tajiTextLight.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: pureYellow, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: onToggleVisibility,
                      icon: Icon(
                        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: tajiTextLight.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    )
                  : (showClearIcon
                      ? IconButton(
                          onPressed: () => controller?.clear(),
                          icon: Icon(Icons.cancel, color: tajiTextLight.withValues(alpha: 0.3), size: 20),
                        )
                      : null),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: TextStyle(color: tajiTextLight.withValues(alpha: 0.4), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

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
          const ProductListPage(category: 'Search Results', showBackButton: false), // Search (index 1)
          const CartPage(showBackButton: false), // Cart (index 2)
          const WishlistPage(showBackButton: false), // Wishlist (index 3)
          const ProfilePage(), // Profile (index 4)
          if (widget.isAdmin) AdminPanel(onProductDeleted: () {
            if (mounted) setState(() {});
          }), // Admin (index 5)
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
              _selectedIndex = 4; // Navigate to Profile tab (correct index)
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
              // Already on home, pop everything to go back to main shop screen
              _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _selectedIndex = 0);
              // Also ensure it's at root when switching back
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
              const SizedBox(width: 48), // Balance spacer
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
                            (context as Element).markNeedsBuild(); // Refresh this item
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
          // Top Image Section
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
          
          // Sticky Header
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

          // Bottom Info Sheet
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

class CartPage extends StatefulWidget {
  final bool showBackButton;
  const CartPage({super.key, this.showBackButton = true});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Removed _cartItems, _isLoading, initState, _loadCart, _subtotal, _shipping, _total

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: CartManager.getCart(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: pureYellow));
            }
            final cartItems = snapshot.data ?? [];
            final double subtotal = cartItems.fold(0, (sum, item) => sum + ((item['price'] ?? 0.0) * (item['quantity'] ?? 1)));
            const double shipping = 15.00;
            final double total = subtotal + shipping;

            return Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 24),
                cartItems.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            Text(
                              "Your cart is empty",
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) => _buildCartItem(cartItems, index),
                      ),
                    ),
                if (cartItems.isNotEmpty) ...[
                  _buildPromoCode(),
                  _buildSummary(subtotal: subtotal, shipping: shipping, total: total),
                ],
              ],
            );
          }
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
            "My Cart",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(List<Map<String, dynamic>> cartItems, int index) {
    final item = cartItems[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).colorScheme.onSurface, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Product',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Size: ${item['size'] ?? 'N/A'}",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${(item['price'] ?? 0.0).toStringAsFixed(2)}",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await CartManager.updateQuantity(item['name'], item['size'], 0);
                    setState(() {}); // Trigger FutureBuilder rebuild
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item removed from cart")),
                      );
                    }
                  },
                  child: Icon(Icons.delete_outline, color: tajiError.withValues(alpha: 0.7), size: 20),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    if ((item['quantity'] ?? 1) > 1) {
                      await CartManager.updateQuantity(item['name'], item['size'], (item['quantity'] ?? 1) - 1);
                      setState(() {});
                    }
                  },
                  child: Icon(Icons.remove, size: 20, color: Theme.of(context).colorScheme.onSurface),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "${item['quantity'] ?? 1}",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await CartManager.updateQuantity(item['name'], item['size'], (item['quantity'] ?? 1) + 1);
                    setState(() {});
                  },
                  child: Icon(Icons.add, size: 20, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCode() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter promo code",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: pureYellow,
              foregroundColor: pureBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary({required double subtotal, required double shipping, required double total}) {
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
              Text("Subtotal", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 16)),
              Text("\$${subtotal.toStringAsFixed(2)}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Shipping", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 16)),
              Text("\$${shipping.toStringAsFixed(2)}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
              Text("\$${total.toStringAsFixed(2)}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutPage()),
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
                  "Checkout",
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

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedDeliveryMethod = 0; // 0 for Express, 1 for Standard

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
              Text(
                "\$525.00",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentPage()),
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

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedMethod = 0; // 0 for PayPal, 1 for Apple Pay

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
                    _buildPaymentMethod(0, "PayPal", "Pay", null),
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


  Widget _buildPaymentMethod(int index, String title, String tag, String? iconPath) {
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: pureBlack.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        onTap: () async {
          // Save real order
          final userEmail = await UserSession.getEmail();
          final orderId = "#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
          await OrderManager.addOrder({
            "id": orderId,
            "user": userEmail ?? "Guest",
            "items_count": 2, // Mocked for now, in a real app this would be the actual cart count
            "status": "Pending",
            "date": "Just now",
            "total": "\$525.00",
          });

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderSuccessPage(orderId: orderId)),
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
              "Pay \$525.00",
              style: TextStyle(color: pureBlack, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userEmail;
  String _userName = 'Sarah Jenkins';
  XFile? _profileImage;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }


  Future<void> _loadProfileData() async {
    final sessionEmail = await UserSession.getEmail();
    final data = await ProfileManager.getProfileData();
    final premium = await GlobalSettingsManager.isPremium();
    setState(() {
      _userEmail = sessionEmail ?? data['email']!;
      final fName = data['firstName'] ?? '';
      final lName = data['lastName'] ?? '';
      _userName = (fName.isEmpty && lName.isEmpty) ? data['name']! : "$fName $lName";
      _isPremium = premium;
      if (data['image']!.isNotEmpty) {
        _profileImage = XFile(data['image']!);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Black background
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? pureBlack : pureBlack.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          Text(
                            "Profile",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Overlapping Profile Avatar
            Transform.translate(
              offset: const Offset(0, -60),
              child: Column(
                children: [
                  Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        image: _profileImage != null
                          ? DecorationImage(image: FileImage(File(_profileImage!.path)), fit: BoxFit.cover)
                          : null,
                      ),
                      child: _profileImage == null
                        ? Center(
                            child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onSurface),
                          )
                        : null,
                    ),
                  const SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: pureYellow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "PRO",
                                  style: TextStyle(color: pureBlack, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _userEmail ?? "Loading...",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Settings List
            Transform.translate(
              offset: const Offset(0, -30),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.shopping_bag_outlined, "My Orders"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressListPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.location_on_outlined, "Shipping Addresses"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.favorite_border, "Wishlist"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      ).then((_) => _loadProfileData());
                    },
                    child: _buildProfileItem(context, Icons.settings_outlined, "Settings"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactSupportPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.support_agent_outlined, "Contact Support"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InfoPage(title: "Help Center")), 
                      );
                    },
                    child: _buildProfileItem(context, Icons.help_outline, "Help Center"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InfoPage(title: "Privacy Policy")),
                      );
                    },
                    child: _buildProfileItem(context, Icons.privacy_tip_outlined, "Privacy Policy"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileItem(BuildContext context, IconData icon, String title, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.01)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLogout ? pureYellow.withValues(alpha: 0.2) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isLogout ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (!isLogout)
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = "English";
  String _phone = "0715773232";
  String _email = "barualevis@gmail.com";
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsData();
  }

  Future<void> _loadSettingsData() async {
    final data = await ProfileManager.getProfileData();
    setState(() {
      _phone = data['phone'] ?? "0715773232";
      _email = data['email'] ?? "barualevis@gmail.com";
    });
  }

  void _showLanguagePicker(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: pureBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: pureWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text(
                          "Change language",
                          style: TextStyle(
                            color: pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: pureWhite),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: pureWhite.withValues(alpha: 0.1)),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildLanguageItem(
                          "English",
                          "English",
                          selectedLanguage == "English",
                          () {
                            setState(() => selectedLanguage = "English");
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                        ),
                        _buildLanguageItem(
                          "Swahili",
                          "Kiswahili",
                          selectedLanguage == "Swahili",
                          () {
                            setState(() => selectedLanguage = "Swahili");
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildLanguageItem(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return ListTile(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? pureYellow : pureWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: tajiTextLight.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? pureYellow : pureWhite.withValues(alpha: 0.24),
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: pureYellow,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Settings",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section 1: Identity
          _buildSettingGroup([
            _buildSettingItem(
              "Personal info",
              Icons.person_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalDetailsPage())),
            ),

          ]),
          const SizedBox(height: 24),

          // Section 2: Contact
          _buildSettingGroup([
            _buildSettingItem(
              "Phone numbers",
              Icons.phone_rounded,
              pureYellow,
              value: _phone,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumbersPage())),
            ),
            _buildSettingItem(
              "Change email",
              Icons.alternate_email_rounded,
              pureYellow,
              value: _email,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeEmailPage())),
            ),
            _buildSettingItem(
              "Change language",
              Icons.language_rounded,
              pureYellow,
              value: selectedLanguage,
              onTap: () => _showLanguagePicker(context),
            ),
          ]),
          const SizedBox(height: 24),

          // Section 3: Preferences & Actions
          _buildSettingGroup([
            _buildSettingItem(
              "Disable chats",
              Icons.chat_bubble_rounded,
              pureYellow,
              value: "Enabled",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatSettingsPage())),
            ),

            _buildSettingItem(
              "Manage notifications",
              Icons.notifications_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsPage())),
            ),
          ]),
          const SizedBox(height: 24),

          // Section 4: System/Company
          _buildSettingGroup([
            _buildSettingItem(
              "About Taji",
              Icons.info_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoPage(title: "About Taji"))),
            ),

            _buildSettingItem(
              "Dark mode",
              Icons.dark_mode_rounded,
              pureYellow,
              value: themeNotifier.value == ThemeMode.dark 
                  ? "On" 
                  : themeNotifier.value == ThemeMode.light 
                      ? "Off" 
                      : "System (default)",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DarkModePage())),
            ),
            _buildSettingItem(
              "Check for updates",
              Icons.system_update_rounded,
              pureYellow,
              value: _checkingUpdate ? "Checking..." : null,
              trailing: _checkingUpdate
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: pureYellow, strokeWidth: 2))
                  : null,
              onTap: _checkForUpdateManually,
            ),
          ]),
          const SizedBox(height: 24),

          // Section 5: Security/Account
          _buildSettingGroup([
            _buildSettingItem(
              "Change password",
              Icons.lock_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage())),
            ),
            _buildSettingItem(
              "Delete my account permanently",
              Icons.delete_forever_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteAccountPage())),
            ),
            _buildSettingItem(
              "Log out",
              Icons.logout_rounded,
              pureYellow,
              onTap: () => _showLogoutConfirmation(context),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _checkForUpdateManually() async {
    setState(() => _checkingUpdate = true);
    const currentVersion = '0.1.0';
    final update = await UpdateService.checkForUpdate(currentVersion);
    if (!mounted) return;
    setState(() => _checkingUpdate = false);

    if (update == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have the latest version'), backgroundColor: Color(0xFF22C55E)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A202C),
        title: const Text('Update Available', style: TextStyle(color: pureWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v${update['version']}', style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(update['notes'] as String, style: const TextStyle(color: pureWhite)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: tajiTextMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UpdateService.downloadAndInstall(update['url'] as String, context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: pureBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: pureWhite, size: 24),
                ),
              ],
            ),
            const Text(
              "Are you sure you want to log out?",
              style: TextStyle(
                color: pureWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You won't receive any messages or notifications",
              style: TextStyle(
                color: pureWhite.withValues(alpha: 0.5),
                fontSize: 14,
                
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await UserSession.clearSession();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF87171),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Log out",
                  style: TextStyle(
                    color: tajiTextLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF87171)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "I changed my mind",
                  style: TextStyle(
                    color: Color(0xFFF87171),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) return children[index];
          return Column(
            children: [
              children[index],
              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color iconBgColor, {
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: tajiTextLight, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                
              ),
            ),
          const SizedBox(width: 8),
          trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }


}

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "My Orders",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: pureYellow,
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList("Active"),
            _buildOrdersList("Completed"),
            _buildOrdersList("Cancelled"),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(String type) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: OrderManager.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final allOrders = snapshot.data ?? [];
        final orders = allOrders.where((o) {
          if (type == "Active") return o["status"] != "Completed" && o["status"] != "Cancelled";
          return o["status"] == type;
        }).toList();

        if (orders.isEmpty) {
          return Center(child: Text("No $type orders", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: pureYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.shopping_bag, color: pureYellow, size: 30),
                  ),
                  const SizedBox(width: 15),
                  // Order Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order["id"]!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: order["status"] == "Cancelled"
                                    ? tajiError.withValues(alpha: 0.1)
                                    : pureYellow.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                order["status"]!,
                                style: TextStyle(
                                  color: order["status"] == "Cancelled" ? tajiError : pureYellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${order["items_count"]} Items",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order["date"]!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              order["total"] ?? "\$0.00",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AdminPanel extends StatefulWidget {
  final VoidCallback? onProductDeleted;
  const AdminPanel({super.key, this.onProductDeleted});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _promoTitleController = TextEditingController();
  final TextEditingController _promoDiscountController = TextEditingController();
  final TextEditingController _subheadingController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'Merchant';
  List<String> _categories = ['Merchant', 'Design', 'Brands', 'Projects'];
  XFile? _promoPoster;
  bool _isPromoActive = true;
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Global Settings state
  bool _isBannerActive = false;
  final TextEditingController _bannerTextController = TextEditingController();
  bool _isPremiumActive = false;
  final TextEditingController _notifTitleController = TextEditingController();
  final TextEditingController _notifMessageController = TextEditingController();
  List<Map<String, String>> _customNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadPromoData();
    _loadGlobalSettings();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryManager.getCategories();
    setState(() {
      _categories = cats;
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.isNotEmpty ? _categories.first : '';
      }
    });
  }

  Future<void> _loadGlobalSettings() async {
    final bannerActive = await GlobalSettingsManager.isBannerActive();
    final bannerText = await GlobalSettingsManager.getBannerText();
    final premiumActive = await GlobalSettingsManager.isPremium();
    final notifications = await GlobalSettingsManager.getNotifications();
    setState(() {
      _isBannerActive = bannerActive;
      _bannerTextController.text = bannerText;
      _isPremiumActive = premiumActive;
      _customNotifications = notifications;
    });
  }

  Future<void> _loadPromoData() async {
    final data = await DiscountManager.getPromoData();
    setState(() {
      _promoTitleController.text = data['title']!;
      _promoDiscountController.text = data['discount']!;
      if (data['poster']!.isNotEmpty) {
        _promoPoster = XFile(data['poster']!);
      }
      _isPromoActive = data['active'] ?? true;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (selected != null) {
        setState(() {
          _imageFile = selected;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e"), backgroundColor: tajiError),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            "Admin Console",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: pureYellow,
            labelColor: pureYellow,
            unselectedLabelColor: tajiTextMutedDark,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.add_photo_alternate), text: "Upload"),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: "Products"),
              Tab(icon: Icon(Icons.campaign), text: "Promos"),
              Tab(icon: Icon(Icons.shopping_cart), text: "Orders"),
              Tab(icon: Icon(Icons.message), text: "Requests"),
              Tab(icon: Icon(Icons.settings), text: "Global"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUploadSection(),
            _buildProductsListSection(),
            _buildPromosSection(),
            _buildOrdersSection(),
            _buildRequestsSection(),
            _buildGlobalSettingsSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _showReplyDialog(String userName, int index) async {
    final TextEditingController replyController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Reply to $userName", style: const TextStyle(color: pureWhite)),
        content: TextField(
          controller: replyController,
          maxLines: 4,
          style: const TextStyle(color: pureWhite),
          decoration: InputDecoration(
            hintText: "Type your response...",
            hintStyle: TextStyle(color: pureWhite.withValues(alpha: 0.3)),
            filled: true,
            fillColor: tajiTextLight.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (replyController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Reply sent to $userName"), backgroundColor: tajiSuccess),
                );
              }
            }, 
            child: const Text("Send", style: TextStyle(color: pureYellow)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminSectionTitle("Update Portfolio / Products"),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 50, color: pureYellow.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text("Tap to select image", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Category", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _selectedCategory = newValue);
                },
                isExpanded: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Subheading / Type", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _subheadingController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "e.g., Premium Store Display",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Price", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: r"e.g., $299.00",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Description", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Enter item description...",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_subheadingController.text.isEmpty || _priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in subheading and price"), backgroundColor: tajiError),
                  );
                  return;
                }
                
                await ProductManager.saveProduct({
                  'name': _subheadingController.text,
                  'type': _selectedCategory,
                  'price': _priceController.text,
                  'description': _descController.text,
                  'category': _selectedCategory,
                  'image': _imageFile?.path ?? '',
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Content successfully updated!"), backgroundColor: tajiSuccess),
                );
                
                _subheadingController.clear();
                _priceController.clear();
                _descController.clear();
                setState(() => _imageFile = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pureYellow,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Deploy Update", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromosSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAdminSectionTitle("Update Selection Promotion"),
              Switch(
                value: _isPromoActive,
                activeThumbColor: pureYellow,
                onChanged: (val) {
                  setState(() => _isPromoActive = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Promotion Poster", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickPromoPoster,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: _promoPoster == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: pureYellow.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text("Select Banner Poster", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(_promoPoster!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Collection Title", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _promoTitleController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "e.g. Summer Collection",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
            ),
          ),
          const SizedBox(height: 24),
          Text("Discount Description", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _promoDiscountController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "e.g. Discount up to 70%",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _updatePromoData,
              style: ElevatedButton.styleFrom(
                backgroundColor: pureYellow,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Save Promotion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPromoPoster() async {
    try {
      final XFile? selected = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (selected != null) setState(() => _promoPoster = selected);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking poster: $e"), backgroundColor: tajiError));
    }
  }

  Future<void> _updatePromoData() async {
    await DiscountManager.savePromoData(
      _promoTitleController.text,
      _promoDiscountController.text,
      _promoPoster?.path ?? '',
      _isPromoActive,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promotion updated! Restart app or go home to see changes."), backgroundColor: tajiSuccess),
      );
    }
  }

  Widget _buildOrdersSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: OrderManager.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(child: Text("No orders found", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: pureYellow.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_bag, color: pureYellow),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order["id"]!, style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
                        Text(order["user"] ?? "Unkown User", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(order["items_count"]?.toString() ?? "0 Items", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) async {
                      await OrderManager.updateOrderStatus(order["id"], val);
                      setState(() {});
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "Pending", child: Text("Pending")),
                      const PopupMenuItem(value: "Processing", child: Text("Processing")),
                      const PopupMenuItem(value: "Shipped", child: Text("Shipped")),
                      const PopupMenuItem(value: "Delivered", child: Text("Delivered")),
                      const PopupMenuItem(value: "Cancelled", child: Text("Cancelled")),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (order["status"] == "Cancelled" ? tajiError : tajiAmber).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(order["status"]!, style: TextStyle(color: order["status"] == "Cancelled" ? tajiError : tajiAmber, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: RequestManager.getRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(child: Text("No requests found", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(request["user"] ?? "Unkown", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(request["date"] ?? "Just now", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(request["msg"] ?? "", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showReplyDialog(request["user"] ?? "User", index);
                        }, 
                        child: const Text("Reply", style: TextStyle(color: pureYellow)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              title: const Text("Archive Request?", style: TextStyle(color: pureWhite)),
                              content: Text("This will remove the request from the list.", style: TextStyle(color: tajiTextLight.withValues(alpha: 0.7))),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true), 
                                  child: const Text("Archive", style: TextStyle(color: tajiError)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await RequestManager.deleteRequest(index);
                            setState(() {}); // Refresh list
                          }
                        }, 
                        child: Text("Archive", style: TextStyle(color: tajiTextLight.withValues(alpha: 0.38))),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlobalSettingsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminSectionTitle("App-Wide Settings"),
          const SizedBox(height: 24),
          
          // BANNER SETTINGS
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Announcement Banner", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                    Switch(
                      value: _isBannerActive,
                      activeThumbColor: pureYellow,
                      onChanged: (val) async {
                        setState(() => _isBannerActive = val);
                        await GlobalSettingsManager.setBanner(val, _bannerTextController.text);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Banner state updated")));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bannerTextController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Enter banner text...",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) async {
                    await GlobalSettingsManager.setBanner(_isBannerActive, val);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Banner text updated")));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // PREMIUM TOGGLE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Premium Member Status", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Toggle your mock PRO badge", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13)),
                  ],
                ),
                Switch(
                  value: _isPremiumActive,
                  activeThumbColor: pureYellow,
                  onChanged: (val) async {
                    setState(() => _isPremiumActive = val);
                    await GlobalSettingsManager.setPremium(val);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Premium status toggled")));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // CUSTOM NOTIFICATIONS
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Push Custom Notification", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                TextField(
                  controller: _notifTitleController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Notification Title",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notifMessageController,
                  maxLines: 2,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Notification Message",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_notifTitleController.text.isEmpty || _notifMessageController.text.isEmpty) return;
                      await GlobalSettingsManager.addNotification(
                        _notifTitleController.text, 
                        _notifMessageController.text,
                        "yellow", "campaign"
                      );
                      setState(() {
                        _notifTitleController.clear();
                        _notifMessageController.clear();
                      });
                      _loadGlobalSettings(); // Refresh list after pushing
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification pushed!", style: TextStyle(color: pureBlack)), backgroundColor: pureYellow));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pureYellow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Push Notification", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_customNotifications.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Divider(color: tajiTextLight.withValues(alpha: 0.1)),
                  const SizedBox(height: 24),
                  Text("Active Notifications", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _customNotifications.length,
                    itemBuilder: (context, index) {
                      final notif = _customNotifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tajiTextLight.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: GlobalSettingsManager.getColor(notif["color"]).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                GlobalSettingsManager.getIcon(notif["icon"]),
                                color: GlobalSettingsManager.getColor(notif["color"]),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif["title"] ?? "", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                  Text(notif["message"] ?? "", style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                                  if (notif["time"] != null)
                                    Text(notif["time"]!, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: tajiError, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    title: const Text("Delete Notification?"),
                                    content: const Text("This notification will be removed for all users."),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete", style: TextStyle(color: tajiError)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await GlobalSettingsManager.deleteNotification(index);
                                  _loadGlobalSettings();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsListSection() {
    return FutureBuilder<List<Map<String, String>>>(
      future: ProductManager.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return Center(child: Text("No custom products found", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: pureYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: (product['image'] != null && product['image']!.startsWith('http'))
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(product['image']!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.inventory_2_outlined, color: pureYellow, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? "Unnamed Item",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          product['category'] ?? "General",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    product['price'] ?? r"$0.00",
                    style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: tajiError),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).cardColor,
                          title: const Text("Delete Product?"),
                          content: const Text("This will permanently remove the product from the store."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: tajiError)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ProductManager.deleteProduct(product['name']!);
                        widget.onProductDeleted?.call();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }
}

class WishlistPage extends StatefulWidget {
  final bool showBackButton;
  const WishlistPage({super.key, this.showBackButton = true});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<String> _wishlistNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final list = await WishlistManager.getWishlist();
    if (mounted) {
      setState(() {
        _wishlistNames = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, String>>>(
          future: ProductManager.getProducts(),
          builder: (context, snapshot) {
            final allProducts = snapshot.data ?? [];
            final likedProducts = allProducts.where((p) => _wishlistNames.contains(p["name"])).toList();
            
            return Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: pureYellow))
                      : likedProducts.isEmpty
                          ? _buildEmptyState()
                          : _buildWishlistGrid(likedProducts),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Text(
            "My Wishlist",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Text(
            "Your wishlist is empty",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 18),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                color: pureYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Explore Products", style: TextStyle(color: pureBlack, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(List<Map<String, String>> products) {
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
                      Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(Icons.shopping_bag_outlined, size: 60, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () async {
                            await WishlistManager.toggleWishlist(product["name"]!);
                            _loadWishlist();
                          },
                          child: const Icon(Icons.favorite, color: tajiError, size: 22),
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
      },
    );
  }
}

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final list = await AddressManager.getAddresses();
    if (mounted) {
      setState(() {
        _addresses = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          );
          if (result == true) _loadAddresses();
        },
        backgroundColor: pureYellow,
        child: const Icon(Icons.add, color: pureBlack),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: pureYellow))
                  : _addresses.isEmpty
                      ? _buildEmptyState()
                      : _buildAddressList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Text(
            "Shipping Addresses",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Text(
            "No addresses saved yet",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pureYellow.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: pureYellow, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address["label"] ?? "Address",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address["full_address"] ?? "",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: tajiError, size: 22),
                onPressed: () async {
                  await AddressManager.deleteAddress(index);
                  _loadAddresses();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField("Label (e.g. Home, Office)", _labelController),
                    const SizedBox(height: 20),
                    _buildInputField("Full Address", _addressController, maxLines: 3),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        if (_labelController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                          await AddressManager.addAddress({
                            "label": _labelController.text,
                            "full_address": _addressController.text,
                          });
                          if (!context.mounted) return;
                          Navigator.pop(context, true);
                        }
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
                            "Save Address",
                            style: TextStyle(color: pureBlack, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Text(
            "Add Address",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class AddressEditingPage extends StatefulWidget {
  const AddressEditingPage({super.key});

  @override
  State<AddressEditingPage> createState() => _AddressEditingPageState();
}

class _AddressEditingPageState extends State<AddressEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate with dummy data for now, ideally fetch from backend/SharedPreferences
    _streetController.text = "123 Main Street";
    _cityController.text = "New York";
    _stateController.text = "NY";
    _zipController.text = "10001";
    _phoneController.text = "+1 234 567 8900";
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // Logic to actually save the address locally or to cloud
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Address successfully updated!'),
          backgroundColor: pureYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Street Address"),
                      _buildInputField("e.g. 123 Main St", _streetController),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("City"),
                                _buildInputField("e.g. New York", _cityController),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("State"),
                                _buildInputField("e.g. NY", _stateController),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("Zip Code"),
                                _buildInputField("e.g. 10001", _zipController),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("Phone"),
                                _buildInputField("e.g. +1 234 567", _phoneController),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      GestureDetector(
                        onTap: _saveAddress,
                        child: Container(
                          height: 65,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: pureYellow,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Center(
                            child: Text(
                              "Update Address",
                              style: TextStyle(color: pureBlack, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Text(
            "Edit Delivery Address",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48), // Balancing space
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}

class SettingsDetailPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const SettingsDetailPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Text(
                    title,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "$title Page",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "This feature will be available in\nthe next major update.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          color: pureYellow,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "Go Back",
                          style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final allNotifs = await GlobalSettingsManager.getNotifications();
    
    final parsed = allNotifs.map((n) => {
      "title": n['title'],
      "message": n['message'],
      "time": n['time'],
      "icon": GlobalSettingsManager.getIcon(n['icon']),
      "color": GlobalSettingsManager.getColor(n['color']),
    }).toList();

    if (mounted) {
      setState(() {
        _notifications = parsed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Text(
                    "Notifications",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48), // Balancing space
                ],
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: pureYellow))
                : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        "No new notifications",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (notif["color"] as Color).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  notif["icon"] as IconData,
                                  color: notif["color"] as Color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          notif["title"] as String,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          notif["time"] as String,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notif["message"] as String,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  final String title;
  final String? content;
  const InfoPage({super.key, required this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContent(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (content != null) {
      return Text(content!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 16, height: 1.6));
    }

    switch (title) {
      case "Privacy Policy":
        return _buildPrivacyPolicy(context);
      case "Help Center":
        return _buildHelpCenter(context);
      case "Terms of Service":
        return _buildTermsOfService(context);
      case "About Taji":
        return _buildAboutTaji(context);
      default:
        return Text("Information not found.", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)));
    }
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15, height: 1.6)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "1. Data Collection", "We collect personal information that you provide to us, such as your name, email address, phone number, and shipping data when you create an account or make a purchase."),
        _buildSection(context, "2. Usage Data", "We automatically collect certain information when you visit the app, including IP address, device type, and app usage patterns to improve your experience."),
        _buildSection(context, "3. Data Security", "We implement industry-standard security measures to protect your personal data from unauthorized access, alteration, or disclosure."),
        _buildSection(context, "4. Your Rights", "You have the right to access, correct, or delete your personal data. You can request account deletion at any time via the Settings page."),
      ],
    );
  }

  Widget _buildHelpCenter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "Track Your Order", "Go to 'My Orders' in your profile to see the real-time status of your purchases."),
        _buildSection(context, "Returns & Refunds", "We offer a 30-day return policy on all unworn items. Refunds are processed within 5-7 business days."),
        _buildSection(context, "Contact Support", "Need help? Email us at support@taji.com or use the 'Contact Support' button in your profile."),
        _buildSection(context, "Payment Methods", "We accept major credit cards, M-Pesa, and digital wallets for all transactions."),
      ],
    );
  }

  Widget _buildTermsOfService(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "1. Acceptance of Terms", "By accessing or using the Taji mobile application, you agree to be bound by these terms and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using this app."),
        _buildSection(context, "2. User Accounts", "When you create an account, you must provide accurate and complete information. You are solely responsible for the activity that occurs on your account and must keep your account password secure."),
        _buildSection(context, "3. Products and Pricing", "We strive to display products as accurately as possible. However, we do not guarantee that product descriptions or prices are error-free. We reserve the right to correct any errors and to change or update information at any time."),
        _buildSection(context, "4. User Conduct", "You agree not to use the platform for any unlawful purpose, to transmit any harmful code, or to interfere with the proper working of the application."),
        _buildSection(context, "5. Intellectual Property", "All content, logos, graphics, and trademarks displayed on this app are the exclusive property of Taji or its licensors and are protected by copyright and trademark laws."),
        _buildSection(context, "6. Limitation of Liability", "Taji shall not be liable for any indirect, incidental, special, or consequential damages resulting from the use or the inability to use our services."),
        _buildSection(context, "7. Termination", "We may terminate or suspend your account and access to the service immediately, without prior notice or liability, for any reason whatsoever, including breach of terms."),
        _buildSection(context, "8. Governing Law", "These terms shall be governed and construed in accordance with the laws of Kenya, without regard to its conflict of law provisions."),
      ],
    );
  }

  Widget _buildAboutTaji(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "Our Mission", "Taji is dedicated to making sustainable fashion accessible to everyone while promoting ethical shopping practices."),
        _buildSection(context, "Sustainability First", "We partner with local artisans and eco-conscious brands to bring you high-quality, long-lasting apparel."),
        _buildSection(context, "Join the Movement", "Discover a new way to shop that respects both style and the planet."),
      ],
    );
  }
}

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final TextEditingController _firstNameController = TextEditingController(text: "Levis");
  final TextEditingController _lastNameController = TextEditingController(text: "Barua");
  
  String _location = "Nairobi City, Kenya";
  String _birthday = "Jan 12, 2000";
  String _sex = "Male";
  bool _isGoogleConnected = true;
  bool _isFacebookConnected = false;
  
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ProfileManager.getProfileData();
    setState(() {
      _firstNameController.text = data['firstName']!;
      _lastNameController.text = data['lastName']!;
      _location = data['location']!;
      _birthday = data['birthday']!;
      _sex = data['sex']!;
      if (data['image']!.isNotEmpty) {
        _imageFile = XFile(data['image']!);
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  void _showLocationPicker() {
    final cities = ["Nairobi City, Kenya", "Mombasa, Kenya", "Kisumu, Kenya", "Nakuru, Kenya", "Eldoret, Kenya"];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: cities.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(cities[index], style: const TextStyle(color: tajiTextLight)),
          onTap: () {
            setState(() => _location = cities[index]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showSexPicker() {
    final genders = ["Male", "Female", "Other"];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: genders.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(genders[index], style: const TextStyle(color: tajiTextLight)),
          onTap: () {
            setState(() => _sex = genders[index]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 12),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: pureYellow,
              onPrimary: pureBlack,
              surface: Color(0xFF1A202C),
              onSurface: pureWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      setState(() {
        _birthday = "${months[picked.month - 1]} ${picked.day}, ${picked.year}";
      });
    }
  }

  Future<void> _saveAll() async {
    await ProfileManager.savePersonalDetails(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      location: _location,
      birthday: _birthday,
      sex: _sex,
      image: _imageFile?.path,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All changes saved successfully!", style: TextStyle( color: pureBlack)),
        backgroundColor: pureYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Personal details",
          style: TextStyle(color: pureWhite, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: const Text("Save", style: TextStyle(color: pureYellow, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Photo Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: tajiDarkSurface,
                          backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                          child: _imageFile == null ? Icon(Icons.person, size: 60, color: tajiTextMutedDark) : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: pureYellow, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: pureBlack, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Form Fields
            _buildDetailField("First Name", _firstNameController),
            const SizedBox(height: 24),
            _buildDetailField("Last Name", _lastNameController),
            const SizedBox(height: 24),
            _buildSelectableField("Location", _location, onTap: _showLocationPicker),
            const SizedBox(height: 24),
            _buildSelectableField("Birthday", _birthday, onTap: _showDatePicker),
            const SizedBox(height: 24),
            _buildSelectableField("Sex", _sex, onTap: _showSexPicker),
            const SizedBox(height: 32),

            // Trust Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: pureWhite.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👍", style: TextStyle(fontSize: 24)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rest assured, your data is protected.",
                          style: TextStyle(color: pureWhite, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "We value your privacy and only use this information to personalize your experience.",
                          style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Social Connections
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "CONNECTED ACCOUNTS",
                style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 16),
            _buildSocialSwitch(
              "Google", 
              Image.asset('assets/images/google_logo.png', width: 20, height: 20), 
              _isGoogleConnected,
              onChanged: (v) => setState(() => _isGoogleConnected = v),
            ),
            _buildSocialSwitch(
              "Facebook", 
              const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 24), 
              _isFacebookConnected,
              onChanged: (v) => setState(() => _isFacebookConnected = v),
            ),
            
            const SizedBox(height: 40),
            
            // Large Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pureYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "SAVE ALL CHANGES",
                  style: TextStyle(color: pureBlack, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: pureWhite, fontSize: 16),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: pureWhite.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: pureYellow),
            ),
            filled: true,
            fillColor: pureWhite.withValues(alpha: 0.02),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableField(String label, String value, {VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: pureWhite.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pureWhite.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(color: pureWhite, fontSize: 16)),
                const Icon(Icons.chevron_right, color: Color(0x66FFFFFF), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSwitch(String name, Widget icon, bool value, {required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: pureWhite.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
            child: icon,
          ),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(color: pureWhite, fontSize: 16)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: pureYellow,
            activeThumbColor: pureBlack,
          ),
        ],
      ),
    );
  }
}

class PhoneNumbersPage extends StatefulWidget {
  const PhoneNumbersPage({super.key});

  @override
  State<PhoneNumbersPage> createState() => _PhoneNumbersPageState();
}

class _PhoneNumbersPageState extends State<PhoneNumbersPage> {
  String _phone = "0715773232";

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final data = await ProfileManager.getProfileData();
    setState(() {
      _phone = data['phone'] ?? "0715773232";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Phone numbers", style: TextStyle(color: pureWhite, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: pureWhite.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _phone,
                        style: const TextStyle(color: pureWhite, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: pureYellow, size: 22),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, color: pureYellow, size: 28),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PhoneNumberChangeMethodPage()),
                          );
                        },
                      ),
                    ],
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

class PhoneNumberChangeMethodPage extends StatelessWidget {
  const PhoneNumberChangeMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Change phone number", style: TextStyle(color: pureWhite, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMethodTile(
            context,
            Icons.call_outlined,
            "Answer a call",
            "on 0715773232",
            () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumberActionPage(method: "Call")));
            },
          ),
          const SizedBox(height: 16),
          _buildMethodTile(
            context,
            Icons.message_outlined,
            "Receive SMS",
            "on 0715773232",
            () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumberActionPage(method: "SMS")));
            },
          ),
          const SizedBox(height: 16),
          _buildMethodTile(
            context,
            Icons.attach_file_outlined,
            "Attach your ID",
            "if you lost the number",
            () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyIdentityPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: pureWhite.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(icon, color: pureYellow, size: 30),
            title: Text(title, style: const TextStyle(color: pureWhite, fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: TextStyle(color: pureWhite.withValues(alpha: 0.6), fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: pureWhite, size: 28),
          ),
        ),
      ),
    );
  }
}

class PhoneNumberActionPage extends StatefulWidget {
  final String method;
  const PhoneNumberActionPage({super.key, required this.method});

  @override
  State<PhoneNumberActionPage> createState() => _PhoneNumberActionPageState();
}

class _PhoneNumberActionPageState extends State<PhoneNumberActionPage> {
  final TextEditingController _numberController = TextEditingController();
  bool _showContinue = false;
  bool _isLoading = false;

  Future<void> _handleAction(VoidCallback onDone) async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      onDone();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCall = widget.method == "Call";
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Change phone number", style: TextStyle(color: pureWhite, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (isCall || _showContinue) ...[
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: pureWhite, fontSize: 20),
                decoration: InputDecoration(
                  labelText: "New phone number",
                  labelStyle: const TextStyle(color: pureYellow, fontSize: 18),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: pureYellow, width: 2)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: pureYellow, width: 2.5)),
                  suffixIcon: IconButton(icon: const Icon(Icons.cancel, color: tajiTextMutedDark), onPressed: () => _numberController.clear()),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            if (isCall && !_showContinue) ...[
              const Text(
                "We'll call you on your current number – 0715773232. It'll help us verify that there is no threat to your account",
                textAlign: TextAlign.center,
                style: TextStyle(color: pureWhite, fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleAction(() => setState(() => _showContinue = true)),
                  style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                    : const Text("Call me on 0715773232", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("It's free of charge", style: TextStyle(color: tajiTextMutedDark, fontSize: 16)),
            ] else if (widget.method == "SMS" && !_showContinue) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "We need to ensure that your account is safe",
                  style: TextStyle(color: pureWhite, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We'll send an SMS confirmation code to your current number – 0715773232. It'll help us verify that the number currently linked to your account is still in your possession",
                textAlign: TextAlign.left,
                style: TextStyle(color: pureWhite, fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleAction(() => setState(() => _showContinue = true)),
                  style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                    : const Text("Send SMS code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text("It's free of charge", style: TextStyle(color: tajiTextMutedDark, fontSize: 16))),
            ] else if (_showContinue) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleAction(() {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification started..."), backgroundColor: pureYellow));
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                    : const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VerifyIdentityPage extends StatefulWidget {
  final bool isEmailChange;
  const VerifyIdentityPage({super.key, this.isEmailChange = false});

  @override
  State<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends State<VerifyIdentityPage> {
  String selectedDocType = "Passport";
  final TextEditingController _docIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  DateTime? selectedDate;
  bool _isLoading = false;
  File? _docPhoto;

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _docPhoto = File(image.path));
    }
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID Verification submitted..."), backgroundColor: pureYellow));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _docIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _showDocTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A202C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final docTypes = ["Passport", "Passport international", "Alien Card / Foreigner Certificate", "National ID", "Drivers Licence"];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: RadioGroup<String>(
                groupValue: selectedDocType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selectedDocType = val);
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...docTypes.map((type) => ListTile(
                          title: Text(type, style: const TextStyle(color: pureWhite)),
                          trailing: Radio<String>(
                            value: type,
                            activeColor: pureYellow,
                          ),
                          onTap: () {
                            setState(() => selectedDocType = type);
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ),
              ),
        );
      },
    );
  }

  void _showDocIdHelp() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A202C),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text("Where to find Document ID?", style: TextStyle(color: pureWhite, fontSize: 14)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: pureWhite), 
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  }
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  decoration: BoxDecoration(color: tajiTextLight, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Icon(Icons.image, size: 50, color: tajiTextMutedDark)), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Verify your identity with ID", style: TextStyle(color: pureWhite, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(widget.isEmailChange ? "To change your email" : "To change your phone number", style: TextStyle(color: pureWhite.withValues(alpha: 0.6), fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPickerField("Choose doc type*", selectedDocType, _showDocTypePicker),
            const SizedBox(height: 16),
            _buildTextField("Document ID*", _docIdController, keyboardType: TextInputType.text, counter: "0/9"),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showDocIdHelp,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF1E2A1E), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: pureYellow, size: 24),
                    SizedBox(width: 8),
                    Text("Where to find Document ID?", style: TextStyle(color: pureYellow, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField("First Name*", _firstNameController, counter: "0/100"),
            const SizedBox(height: 16),
            _buildTextField("Last Name*", _lastNameController, counter: "0/100"),
            const SizedBox(height: 16),
            _buildTextField(widget.isEmailChange ? "New E-mail address*" : "New phone number*", _numberController, keyboardType: widget.isEmailChange ? TextInputType.emailAddress : TextInputType.phone),
            const SizedBox(height: 16),
            _buildPickerField("Date of birth*", selectedDate == null ? "" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}", _selectDate),
            const SizedBox(height: 24),
            Text("Attach photo of your $selectedDocType*", style: const TextStyle(color: pureWhite, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tajiTextLight.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: pureWhite.withValues(alpha: 0.1)),
                  ),
                  child: _docPhoto != null
                      ? Image.file(_docPhoto!, fit: BoxFit.cover)
                      : const Icon(Icons.add, color: pureYellow, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text("Use .jpg, .jpeg, .png, .heic", style: TextStyle(color: tajiTextMutedDark, fontSize: 12)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                  : const Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Please note, by submitting any information and documents to our customer support you consent to the processing of such data for use in identification and authentication and you acknowledge that such processing is also required to continue providing our services to you",
              style: TextStyle(color: pureWhite.withValues(alpha: 0.5), fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, String? counter}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: pureWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: pureWhite.withValues(alpha: 0.5)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: pureWhite.withValues(alpha: 0.15), width: 1.5)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: pureYellow, width: 2)),
        helperText: counter,
        helperStyle: const TextStyle(color: tajiTextMutedDark, fontSize: 14),
      ),
    );
  }

  Widget _buildPickerField(String label, String value, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: pureWhite.withValues(alpha: 0.15), width: 1.5), 
            borderRadius: BorderRadius.circular(4)
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: pureWhite.withValues(alpha: 0.6), fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(value, style: const TextStyle(color: pureWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: tajiTextMutedDark),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  String _email = "barualevis@gmail.com";

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final data = await ProfileManager.getProfileData();
    setState(() {
      _email = data['email'] ?? "barualevis@gmail.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Change email", style: TextStyle(color: pureWhite, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: pureWhite.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _email,
                        style: const TextStyle(color: pureWhite, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: pureYellow, size: 22),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, color: pureYellow, size: 28),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VerifyIdentityPage(isEmailChange: true)),
                          );
                        },
                      ),
                    ],
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

class ChatSettingsPage extends StatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  bool _receiveMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tajiDarkBg, // Deep dark background
      appBar: AppBar(
        backgroundColor: tajiDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tajiTextLight),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Chat settings",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ListTile(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _receiveMessages = !_receiveMessages);
            },
            title: const Text(
              "Receive messages",
              style: TextStyle(color: tajiTextLight, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Switch(
              value: _receiveMessages,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _receiveMessages = val);
              },
              activeThumbColor: tajiSuccess,
              activeTrackColor: tajiSuccess.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: tajiTextLight.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Chats help your customers to get in touch with you through messages on Taji platform.\n\nDisable this option if you don't want to reply to the messages (Your existed chats stay active).",
              style: TextStyle(
                color: tajiTextLight.withValues(alpha: 0.6),
                fontSize: 14,
                
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: tajiTextLight.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "If you don't reply to your customers for a while, chats will be turn Off automatically (Your existed chats stay active).",
              style: TextStyle(
                color: tajiTextLight.withValues(alpha: 0.6),
                fontSize: 14,
                
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Map<String, bool> _settings = {
    "push_deals": true,
    "push_messages": true,
    "push_ads": true,
    "push_premium": true,
    "push_alerts": true,
    "push_viewed": true,
    "email_deals": true,
    "email_ads": true,
    "email_premium": true,
    "email_subs": true,
    "email_messages": true,
    "email_feedback": true,
    "sms_info": true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tajiDarkBg,
      appBar: AppBar(
        backgroundColor: tajiDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tajiTextLight),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Manage notifications",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Push notifications"),
          _buildToggleItem("Hot deals, recommendations, news", "push_deals"),
          _buildToggleItem("Incoming messages from other users", "push_messages"),
          _buildToggleItem("Important information about your Ads, call to action", "push_ads"),
          _buildToggleItem("Premium package activation/expiration", "push_premium"),
          _buildToggleItem("Job alerts", "push_alerts"),
          _buildToggleItem("Viewed Ads", "push_viewed"),
          const SizedBox(height: 24),
          _buildSectionHeader("Email notifications"),
          _buildToggleItem("Hot deals and recommendations", "email_deals"),
          _buildToggleItem("Info about your Ads", "email_ads"),
          _buildToggleItem("Premium packages", "email_premium"),
          _buildToggleItem("Your subscriptions", "email_subs"),
          _buildToggleItem("Messages", "email_messages"),
          _buildToggleItem("Feedback", "email_feedback"),
          const SizedBox(height: 24),
          _buildToggleItem("SMS info notification", "sms_info"),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: tajiTextLight,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, String key) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _settings[key] = !(_settings[key] ?? false));
          },
          title: Text(
            title,
            style: TextStyle(
              color: tajiTextLight.withValues(alpha: 0.8),
              fontSize: 14,
              
            ),
          ),
          trailing: Switch(
            value: _settings[key] ?? false,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _settings[key] = val);
            },
            activeThumbColor: tajiSuccess,
            activeTrackColor: tajiSuccess.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: tajiTextLight.withValues(alpha: 0.05), height: 1),
        ),
      ],
    );
  }
}

class DarkModePage extends StatefulWidget {
  const DarkModePage({super.key});

  @override
  State<DarkModePage> createState() => _DarkModePageState();
}

class _DarkModePageState extends State<DarkModePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return Scaffold(
          backgroundColor: tajiDarkBg,
          appBar: AppBar(
            backgroundColor: tajiDarkBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: tajiTextLight),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "Dark mode",
              style: TextStyle(color: tajiTextLight, fontSize: 18),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModeOption("On", ThemeMode.dark, currentMode),
                const SizedBox(height: 12),
                _buildModeOption("Off", ThemeMode.light, currentMode),
                const SizedBox(height: 12),
                _buildModeOption("System (default)", ThemeMode.system, currentMode),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "Choose a color mode above to change the system default appearance in the app",
                    style: TextStyle(
                      color: tajiTextLight.withValues(alpha: 0.5),
                      fontSize: 13,
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeOption(String label, ThemeMode mode, ThemeMode currentMode) {
    bool isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        themeNotifier.value = mode;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: tajiTextLight,
                fontSize: 16,
                
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? tajiSuccess : tajiTextLight.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: tajiSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tajiDarkBg,
      appBar: AppBar(
        backgroundColor: tajiDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tajiTextLight),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Change password",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildPasswordField("Current password*", _currentPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("New password*", _newPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("Confirm new password*", _confirmPasswordController),
            const SizedBox(height: 16),
            Text(
              "Avoid disclosing your password to anyone",
              style: TextStyle(
                color: tajiTextLight.withValues(alpha: 0.5),
                fontSize: 13,
                
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Change",
                  style: TextStyle(
                    color: tajiTextLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                },
                child: const Text(
                  "Forgot your password?",
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 14,
                    
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: tajiTextLight),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: tajiTextLight.withValues(alpha: 0.4), fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tajiTextLight.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF22C55E)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  String _selectedReason = "I get too many notifications";

  final List<String> _reasons = [
    "I want to change phone number",
    "I want to change email address",
    "I've already sold my items",
    "I have a duplicate account",
    "I haven't found anything interesting on Jiji",
    "I get too many notifications",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tajiDarkBg,
      appBar: AppBar(
        backgroundColor: tajiDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tajiTextLight),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Delete my account permanently",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Oh no... Why would you like to delete your account?",
                  style: TextStyle(
                    color: tajiTextLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "If you delete your account now, you'll lose access to all data, including your profile, chat and ad history, followers, and reviews. There is no way to recover it after completing this action",
                  style: TextStyle(
                    color: tajiTextLight.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.4,
                    
                  ),
                ),
                const SizedBox(height: 24),
                ..._reasons.map((reason) => _buildReasonItem(reason)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                },
                icon: const Icon(Icons.heart_broken_rounded, color: tajiTextDark, size: 20),
                label: const Text(
                  "Delete my account permanently",
                  style: TextStyle(
                    color: tajiTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF87171),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonItem(String reason) {
    bool isSelected = _selectedReason == reason;
    return Column(
      children: [
        ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedReason = reason);
          },
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? tajiSuccess : tajiTextLight.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: tajiSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          title: Text(
            reason,
            style: TextStyle(
              color: tajiTextLight.withValues(alpha: 0.9),
              fontSize: 15,
              
            ),
          ),
        ),
        Divider(color: tajiTextLight.withValues(alpha: 0.05), height: 1),
      ],
    );
  }
}

class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Contact Support",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "How can we help you?",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose your preferred contact method",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              _buildContactCard(
                context,
                icon: FontAwesomeIcons.whatsapp,
                title: "WhatsApp",
                subtitle: "Chat with us instantly",
                color: const Color(0xFF25D366),
                onTap: () => _launchURL("https://wa.me/254701234567"), // Placeholder
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                context,
                icon: FontAwesomeIcons.instagram,
                title: "Instagram",
                subtitle: "Follow us & send a DM",
                color: const Color(0xFFE4405F),
                onTap: () => _launchURL("https://instagram.com/taji_app"), // Placeholder
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                context,
                icon: FontAwesomeIcons.facebook,
                title: "Facebook",
                subtitle: "Message us on Messenger",
                color: const Color(0xFF1877F2),
                onTap: () => _launchURL("https://facebook.com/tajiapp"), // Placeholder
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required dynamic icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: icon is IconData 
                ? Icon(icon, color: color, size: 28)
                : FaIcon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
