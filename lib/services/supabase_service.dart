import 'package:supabase_flutter/supabase_flutter.dart';

const String _supabaseUrl = 'https://jkcegzquyhekepznqeob.supabase.co';
const String _supabaseAnonKey = 'sb_publishable_Vatw0B5bFEJrwl8bSUCyRg_GmghP-9b';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  // ── Auth ──
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;

  static Stream<AuthState> get onAuthChange => client.auth.onAuthStateChange;

  // ── OAuth ──
  static Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://callback',
    );
  }

  static Future<void> signInWithFacebook() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: 'io.supabase.flutter://callback',
    );
  }

  // ── Profiles ──
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  static Future<void> upsertProfile(Map<String, dynamic> profile) async {
    await client.from('profiles').upsert(profile);
  }

  // ── Products ──
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await client.from('products').select();
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addProduct(Map<String, dynamic> product) async {
    await client.from('products').insert(product);
  }

  static Future<void> deleteProduct(String name) async {
    await client.from('products').delete().eq('name', name);
  }

  // ── Categories ──
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await client.from('categories').select();
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addCategory(String name) async {
    await client.from('categories').insert({'name': name});
  }

  static Future<void> deleteCategory(String name) async {
    await client.from('categories').delete().eq('name', name);
  }

  // ── Orders ──
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await client.from('orders').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addOrder(Map<String, dynamic> order) async {
    await client.from('orders').insert(order);
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await client.from('orders').update({'status': status}).eq('order_id', orderId);
  }

  // ── Cart Items ──
  static Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final response = await client.from('cart_items').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addCartItem(Map<String, dynamic> item) async {
    await client.from('cart_items').insert(item);
  }

  static Future<void> updateCartQuantity(String name, String userId, int quantity) async {
    if (quantity <= 0) {
      await client.from('cart_items').delete().eq('user_id', userId).eq('product_name', name);
    } else {
      await client.from('cart_items').update({'quantity': quantity}).eq('user_id', userId).eq('product_name', name);
    }
  }

  static Future<void> removeCartItem(String name, String userId) async {
    await client.from('cart_items').delete().eq('user_id', userId).eq('product_name', name);
  }

  // ── Wishlist ──
  static Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    final response = await client.from('wishlist_items').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> toggleWishlist(String userId, String productName) async {
    final existing = await client.from('wishlist_items').select().eq('user_id', userId).eq('product_name', productName).maybeSingle();
    if (existing != null) {
      await client.from('wishlist_items').delete().eq('user_id', userId).eq('product_name', productName);
    } else {
      await client.from('wishlist_items').insert({'user_id': userId, 'product_name': productName});
    }
  }

  static Future<void> removeFromWishlist(String userId, String productName) async {
    await client.from('wishlist_items').delete().eq('user_id', userId).eq('product_name', productName);
  }

  // ── Notifications ──
  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final response = await client.from('notifications').select().eq('user_id', userId).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addNotification(Map<String, dynamic> notif) async {
    await client.from('notifications').insert(notif);
  }

  // ── Addresses ──
  static Future<List<Map<String, dynamic>>> getAddresses(String userId) async {
    final response = await client.from('addresses').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addAddress(String userId, Map<String, String> address) async {
    await client.from('addresses').insert({
      'user_id': userId,
      'label': address['label'] ?? 'Address',
      'full_address': address['full_address'] ?? '',
    });
  }

  static Future<void> deleteAddress(String userId, int index) async {
    final addresses = await getAddresses(userId);
    if (index >= 0 && index < addresses.length) {
      final id = addresses[index]['id'];
      await client.from('addresses').delete().eq('id', id);
    }
  }
}
