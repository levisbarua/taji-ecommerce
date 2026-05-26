import 'package:flutter/material.dart';
import 'user_session.dart';
import 'database_service.dart';
import 'supabase_service.dart';
import '../utils/constants.dart';

bool get _isOnline => UserSession.hasSupabaseSession();
String? get _userId => UserSession.currentSupabaseUser?.id;

class WishlistManager {
  static Future<List<String>> getWishlist() async {
    if (_isOnline && _userId != null) {
      final rows = await SupabaseService.getWishlist(_userId!);
      return rows.map((r) => r['product_name'] as String).toList();
    }
    return DatabaseService.getWishlist();
  }

  static Future<void> toggleWishlist(String productName) async {
    if (_isOnline && _userId != null) {
      await SupabaseService.toggleWishlist(_userId!, productName);
    }
    await DatabaseService.toggleWishlist(productName);
  }

  static Future<bool> isLiked(String productName) async {
    return DatabaseService.isInWishlist(productName);
  }

  static Future<void> removePermanently(String productName) async {
    if (_isOnline && _userId != null) {
      await SupabaseService.removeFromWishlist(_userId!, productName);
    }
    await DatabaseService.removeFromWishlist(productName);
  }
}

class CartManager {
  static Future<List<Map<String, dynamic>>> getCart() async {
    return DatabaseService.getCartItems();
  }

  static Future<void> addToCart(Map<String, dynamic> item) async {
    if (_isOnline && _userId != null) {
      try {
        await SupabaseService.addCartItem({
          'user_id': _userId,
          'product_name': item['name'],
          'size': item['size']?.toString() ?? '',
          'price': (item['price'] as num?)?.toDouble() ?? 0,
          'quantity': item['quantity'] as int? ?? 1,
        });
      } catch (_) {}
    }
    await DatabaseService.addCartItem(item);
  }

  static Future<void> updateQuantity(String name, dynamic size, int newQuantity) async {
    if (_isOnline && _userId != null) {
      try {
        await SupabaseService.updateCartQuantity(name, _userId!, newQuantity);
      } catch (_) {}
    }
    await DatabaseService.updateCartQuantity(name, size, newQuantity);
  }

  static Future<void> removeFromCart(String name, dynamic size) async {
    if (_isOnline && _userId != null) {
      try {
        await SupabaseService.removeCartItem(name, _userId!);
      } catch (_) {}
    }
    await DatabaseService.removeCartItem(name, size);
  }

  static Future<void> removePermanently(String name) async {
    if (_isOnline && _userId != null) {
      try {
        await SupabaseService.removeCartItem(name, _userId!);
      } catch (_) {}
    }
    await DatabaseService.removeCartItemByName(name);
  }
}

class AddressManager {
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    if (_isOnline && _userId != null) {
      try {
        return await SupabaseService.getAddresses(_userId!);
      } catch (_) {}
    }
    return DatabaseService.getAddresses();
  }

  static Future<void> addAddress(Map<String, String> address) async {
    if (_isOnline && _userId != null) {
      try {
        await SupabaseService.addAddress(_userId!, address);
      } catch (_) {}
    }
    await DatabaseService.addAddress(address);
  }

  static Future<void> deleteAddress(int index) async {
    if (_isOnline && _userId != null) {
      try {
        await SupabaseService.deleteAddress(_userId!, index);
      } catch (_) {}
    }
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
    if (_isOnline && _userId != null) {
      try {
        final remote = await SupabaseService.getProfile(_userId!);
        if (remote != null) {
          return {
            'name': remote['name']?.toString() ?? '',
            'firstName': remote['first_name']?.toString() ?? '',
            'lastName': remote['last_name']?.toString() ?? '',
            'email': remote['email']?.toString() ?? '',
            'phone': remote['phone']?.toString() ?? '',
            'image': remote['avatar_url']?.toString() ?? '',
            'location': remote['location']?.toString() ?? '',
            'birthday': remote['birthday']?.toString() ?? '',
            'sex': remote['sex']?.toString() ?? '',
          };
        }
      } catch (_) {}
    }
    final data = await DatabaseService.getAllProfileData();
    return {
      'name': data['name'] ?? '',
      'firstName': data['firstName'] ?? '',
      'lastName': data['lastName'] ?? '',
      'email': data['email'] ?? '',
      'phone': data['phone'] ?? '',
      'image': data['image'] ?? '',
      'location': data['location'] ?? '',
      'birthday': data['birthday'] ?? '',
      'sex': data['sex'] ?? '',
    };
  }

  static Future<void> saveProfileData(String name, String email, String image) async {
    await DatabaseService.setProfileValue('name', name);
    await DatabaseService.setProfileValue('email', email);
    await DatabaseService.setProfileValue('image', image);
    await _syncProfileToSupabase();
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
    await _syncProfileToSupabase();
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
    await _syncProfileToSupabase();
  }

  static Future<void> updateName(String name) async {
    await DatabaseService.setProfileValue('name', name);
    await _syncProfileToSupabase();
  }

  static Future<void> _syncProfileToSupabase() async {
    if (!_isOnline || _userId == null) return;
    try {
      final data = await DatabaseService.getAllProfileData();
      await SupabaseService.upsertProfile({
        'id': _userId,
        'name': data['name'] ?? '',
        'first_name': data['firstName'] ?? '',
        'last_name': data['lastName'] ?? '',
        'email': data['email'] ?? '',
        'phone': data['phone'] ?? '',
        'avatar_url': data['image'] ?? '',
        'location': data['location'] ?? '',
        'birthday': data['birthday'] ?? '',
        'sex': data['sex'] ?? '',
      });
    } catch (_) {}
  }
}

class ProductManager {
  static Future<List<Map<String, String>>> getProducts() async {
    List<Map<String, dynamic>> dbProducts;
    if (_isOnline) {
      try {
        dbProducts = await SupabaseService.getProducts();
      } catch (_) {
        dbProducts = await DatabaseService.getProducts();
      }
    } else {
      dbProducts = await DatabaseService.getProducts();
    }
    if (dbProducts.isEmpty) return [];
    return dbProducts.map((item) {
      return {
        "name": item["name"]?.toString() ?? "Unnamed",
        "category": item["category"]?.toString() ?? "General",
        "price": item["price"]?.toString() ?? r"$0.00",
        "description": item["description"]?.toString() ?? "",
        "type": item["type"]?.toString() ?? "",
        "image": (item["image"] ?? item["image_url"] ?? "")?.toString() ?? "",
      };
    }).toList();
  }

  static Future<void> saveProduct(Map<String, String> product) async {
    if (_isOnline) {
      try {
        await SupabaseService.addProduct(product);
      } catch (_) {}
    }
    await DatabaseService.addProduct(product);
  }

  static Future<void> deleteProduct(String name) async {
    if (_isOnline) {
      try {
        await SupabaseService.deleteProduct(name);
      } catch (_) {}
    }
    await DatabaseService.deleteProduct(name);
    await WishlistManager.removePermanently(name);
    await CartManager.removePermanently(name);
  }
}

class GlobalSettingsManager {
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

  static Future<bool> isPremium() async {
    return DatabaseService.getSettingBool('global_premium_active', defaultValue: false);
  }

  static Future<void> setPremium(bool active) async {
    await DatabaseService.setSettingBool('global_premium_active', active);
  }

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
    if (_isOnline) {
      try {
        final rows = await SupabaseService.getCategories();
        if (rows.isNotEmpty) return rows.map((r) => r['name'] as String).toList();
      } catch (_) {}
    }
    final rows = await DatabaseService.getCategories();
    if (rows.isEmpty) return ['Merchant', 'Design', 'Brands', 'Projects'];
    return rows.map((r) => r['name'] as String).toList();
  }

  static Future<void> addCategory(String category) async {
    if (_isOnline) {
      try {
        await SupabaseService.addCategory(category);
      } catch (_) {}
    }
    await DatabaseService.addCategory(category);
  }

  static Future<void> deleteCategory(String category) async {
    if (_isOnline) {
      try {
        await SupabaseService.deleteCategory(category);
      } catch (_) {}
    }
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
    if (_isOnline && _userId != null) {
      try {
        return await SupabaseService.getOrders();
      } catch (_) {}
    }
    return DatabaseService.getOrders();
  }

  static Future<void> addOrder(Map<String, dynamic> order) async {
    if (_isOnline && _userId != null) {
      try {
        await SupabaseService.addOrder({
          'order_id': order['id'],
          'user_id': _userId,
          'user_email': order['user'] ?? '',
          'items_count': order['items_count'] ?? 0,
          'status': order['status'] ?? 'Pending',
          'total': order['total'] ?? r'$0.00',
        });
      } catch (_) {}
    }
    await DatabaseService.addOrder(order);
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    if (_isOnline) {
      try {
        await SupabaseService.updateOrderStatus(orderId, status);
      } catch (_) {}
    }
    await DatabaseService.updateOrderStatus(orderId, status);
  }
}
