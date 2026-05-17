import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'taji_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        size TEXT,
        price REAL NOT NULL DEFAULT 0,
        quantity INTEGER NOT NULL DEFAULT 1,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE wishlist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL UNIQUE,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL UNIQUE,
        user TEXT DEFAULT 'Guest',
        items_count INTEGER DEFAULT 0,
        status TEXT DEFAULT 'Pending',
        date TEXT,
        total TEXT DEFAULT '\$0.00',
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT DEFAULT 'General',
        price TEXT DEFAULT '\$0.00',
        description TEXT DEFAULT '',
        type TEXT DEFAULT '',
        image TEXT DEFAULT '',
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT DEFAULT 'Address',
        full_address TEXT DEFAULT '',
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT DEFAULT '',
        message TEXT DEFAULT '',
        time TEXT DEFAULT 'Just now',
        color TEXT DEFAULT 'yellow',
        icon TEXT DEFAULT 'notifications',
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT DEFAULT 'Guest',
        msg TEXT DEFAULT '',
        date TEXT DEFAULT 'Just now',
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE promo_data (
        key TEXT PRIMARY KEY,
        value TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE profile_data (
        key TEXT PRIMARY KEY,
        value TEXT DEFAULT ''
      )
    ''');

    // Insert default categories
    final defaultCategories = ['Merchant', 'Design', 'Brands', 'Projects'];
    for (final cat in defaultCategories) {
      await db.insert('categories', {'name': cat});
    }

    // Insert default notifications
    await db.insert('notifications', {
      'title': 'Order Shipped!',
      'message': 'Your vintage jacket is on the way. Track your delivery.',
      'time': '2 hours ago',
      'icon': 'local_shipping',
      'color': 'blue',
    });
    await db.insert('notifications', {
      'title': 'Flash Sale!',
      'message': 'Get 20% off all streetwear collections today only.',
      'time': '5 hours ago',
      'icon': 'local_offer',
      'color': 'yellow',
    });
    await db.insert('notifications', {
      'title': 'New Message',
      'message': 'The merchant responded to your query about the sneakers.',
      'time': '1 day ago',
      'icon': 'message',
      'color': 'green',
    });
    await db.insert('notifications', {
      'title': 'Welcome to Taji',
      'message': 'Thanks for joining us! Discover sustainable fashion today.',
      'time': '2 days ago',
      'icon': 'celebration',
      'color': 'purple',
    });

    // Insert default products
    final defaultProducts = [
      {"name": "Premium Store Display", "category": "Merchant", "price": r"$299.00", "description": "High-performance store display."},
      {"name": "Branding Kit", "category": "Merchant", "price": r"$150.00", "description": "Complete branding solution."},
      {"name": "Minimalist Logo", "category": "Design", "price": r"$450.00", "description": "Clean, modern logo design."},
      {"name": "Modern UI Kit", "category": "Design", "price": r"$200.00", "description": "Comprehensive UI design elements."},
      {"name": "Brand Guidelines", "category": "Brands", "price": r"$600.00", "description": "Professional brand consistency guide."},
      {"name": "Social Media Pack", "category": "Brands", "price": r"$120.00", "description": "Engaging social media assets."},
      {"name": "Architecture Plan", "category": "Projects", "price": r"$1,200.00", "description": "Detailed architectural blueprints."},
      {"name": "Interior Layout", "category": "Projects", "price": r"$800.00", "description": "Modern interior design schemes."},
      {"name": "Taji Heritage Tee", "category": "Merchant", "price": r"$45.00", "description": "Classic Taji branding."},
      {"name": "Creator Hoodie", "category": "Merchant", "price": r"$85.00", "description": "Premium comfort hoodie."},
      {"name": "Jordan 1 Retro", "category": "Merchant", "price": r"$190.00", "description": "Iconic footwear style."},
      {"name": "Taji Cap", "category": "Merchant", "price": r"$35.00", "description": "Stylish branded cap."},
    ];
    for (final p in defaultProducts) {
      await db.insert('products', p);
    }

    // Insert default profile data
    final defaultProfile = {
      'name': 'Sarah Jenkins',
      'firstName': 'Levis',
      'lastName': 'Barua',
      'email': 'barualevis@gmail.com',
      'phone': '0715773232',
      'image': '',
      'location': 'Nairobi City, Kenya',
      'birthday': 'Jan 12, 2000',
      'sex': 'Male',
    };
    for (final entry in defaultProfile.entries) {
      await db.insert('profile_data', {'key': entry.key, 'value': entry.value});
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations
  }

  static Future<void> clearDatabase() async {
    final db = await database;
    final tables = [
      'cart_items', 'wishlist_items', 'orders', 'products',
      'addresses', 'notifications', 'categories', 'requests',
      'user_settings', 'promo_data', 'profile_data',
    ];
    for (final table in tables) {
      await db.delete(table);
    }
  }

  // ── Cart Items ──
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return db.query('cart_items');
  }

  static Future<int> addCartItem(Map<String, dynamic> item) async {
    final db = await database;
    final existing = await db.query('cart_items',
      where: 'name = ? AND size = ?',
      whereArgs: [item['name'], item['size']],
    );
    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      final newQty = currentQty + (item['quantity'] as int? ?? 1);
      return db.update('cart_items', {'quantity': newQty},
        where: 'name = ? AND size = ?',
        whereArgs: [item['name'], item['size']],
      );
    }
    return db.insert('cart_items', {
      'name': item['name'],
      'size': item['size']?.toString(),
      'price': (item['price'] as num?)?.toDouble() ?? 0.0,
      'quantity': item['quantity'] as int? ?? 1,
    });
  }

  static Future<int> updateCartQuantity(String name, dynamic size, int newQuantity) async {
    final db = await database;
    if (newQuantity <= 0) {
      return db.delete('cart_items',
        where: 'name = ? AND size = ?',
        whereArgs: [name, size?.toString()],
      );
    }
    return db.update('cart_items', {'quantity': newQuantity},
      where: 'name = ? AND size = ?',
      whereArgs: [name, size?.toString()],
    );
  }

  static Future<int> removeCartItem(String name, dynamic size) async {
    final db = await database;
    return db.delete('cart_items',
      where: 'name = ? AND size = ?',
      whereArgs: [name, size?.toString()],
    );
  }

  static Future<int> removeCartItemByName(String name) async {
    final db = await database;
    return db.delete('cart_items', where: 'name = ?', whereArgs: [name]);
  }

  // ── Wishlist ──
  static Future<List<String>> getWishlist() async {
    final db = await database;
    final rows = await db.query('wishlist_items');
    return rows.map((r) => r['product_name'] as String).toList();
  }

  static Future<void> toggleWishlist(String productName) async {
    final db = await database;
    final existing = await db.query('wishlist_items',
      where: 'product_name = ?', whereArgs: [productName],
    );
    if (existing.isNotEmpty) {
      await db.delete('wishlist_items',
        where: 'product_name = ?', whereArgs: [productName],
      );
    } else {
      await db.insert('wishlist_items', {'product_name': productName});
    }
  }

  static Future<bool> isInWishlist(String productName) async {
    final db = await database;
    final result = await db.query('wishlist_items',
      where: 'product_name = ?', whereArgs: [productName],
    );
    return result.isNotEmpty;
  }

  static Future<void> removeFromWishlist(String productName) async {
    final db = await database;
    await db.delete('wishlist_items',
      where: 'product_name = ?', whereArgs: [productName],
    );
  }

  // ── Orders ──
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return db.query('orders', orderBy: 'created_at DESC');
  }

  static Future<int> addOrder(Map<String, dynamic> order) async {
    final db = await database;
    return db.insert('orders', {
      'order_id': order['id'],
      'user': order['user'] ?? 'Guest',
      'items_count': order['items_count'] ?? 0,
      'status': order['status'] ?? 'Pending',
      'date': order['date'] ?? 'Just now',
      'total': order['total'] ?? r'$0.00',
    });
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await database;
    await db.update('orders', {'status': status},
      where: 'order_id = ?', whereArgs: [orderId],
    );
  }

  // ── Products ──
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return db.query('products');
  }

  static Future<int> addProduct(Map<String, dynamic> product) async {
    final db = await database;
    return db.insert('products', {
      'name': product['name'],
      'category': product['category'] ?? 'General',
      'price': product['price'] ?? r'$0.00',
      'description': product['description'] ?? '',
      'type': product['type'] ?? '',
      'image': product['image'] ?? '',
    });
  }

  static Future<int> deleteProduct(String name) async {
    final db = await database;
    return db.delete('products', where: 'name = ?', whereArgs: [name]);
  }

  // ── Addresses ──
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    final db = await database;
    return db.query('addresses');
  }

  static Future<int> addAddress(Map<String, String> address) async {
    final db = await database;
    return db.insert('addresses', {
      'label': address['label'] ?? 'Address',
      'full_address': address['full_address'] ?? '',
    });
  }

  static Future<int> deleteAddress(int index) async {
    final db = await database;
    final addresses = await db.query('addresses', orderBy: 'created_at ASC');
    if (index >= 0 && index < addresses.length) {
      final id = addresses[index]['id'];
      return db.delete('addresses', where: 'id = ?', whereArgs: [id]);
    }
    return 0;
  }

  // ── Categories ──
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.query('categories');
  }

  static Future<int> addCategory(String name) async {
    final db = await database;
    try {
      return db.insert('categories', {'name': name});
    } catch (_) {
      return 0;
    }
  }

  static Future<int> deleteCategory(String name) async {
    final db = await database;
    return db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  // ── Notifications ──
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return db.query('notifications', orderBy: 'created_at DESC');
  }

  static Future<int> addNotification(Map<String, String> notif) async {
    final db = await database;
    return db.insert('notifications', {
      'title': notif['title'] ?? '',
      'message': notif['message'] ?? '',
      'time': notif['time'] ?? 'Just now',
      'color': notif['color'] ?? 'yellow',
      'icon': notif['icon'] ?? 'notifications',
    });
  }

  static Future<int> deleteNotification(int index) async {
    final db = await database;
    final notifs = await db.query('notifications', orderBy: 'created_at DESC');
    if (index >= 0 && index < notifs.length) {
      final id = notifs[index]['id'];
      return db.delete('notifications', where: 'id = ?', whereArgs: [id]);
    }
    return 0;
  }

  // ── Requests ──
  static Future<List<Map<String, dynamic>>> getRequests() async {
    final db = await database;
    return db.query('requests', orderBy: 'created_at DESC');
  }

  static Future<int> addRequest(Map<String, dynamic> request) async {
    final db = await database;
    return db.insert('requests', {
      'user': request['user'] ?? 'Guest',
      'msg': request['msg'] ?? '',
      'date': request['date'] ?? 'Just now',
    });
  }

  static Future<int> deleteRequest(int index) async {
    final db = await database;
    final requests = await db.query('requests', orderBy: 'created_at DESC');
    if (index >= 0 && index < requests.length) {
      final id = requests[index]['id'];
      return db.delete('requests', where: 'id = ?', whereArgs: [id]);
    }
    return 0;
  }

  // ── User Settings (Key-Value) ──
  static Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('user_settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isNotEmpty) return rows.first['value'] as String?;
    return null;
  }

  static Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('user_settings', {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> getSettingBool(String key, {bool defaultValue = false}) async {
    final val = await getSetting(key);
    if (val == null) return defaultValue;
    return val == 'true';
  }

  static Future<void> setSettingBool(String key, bool value) async {
    await setSetting(key, value.toString());
  }

  // ── Promo Data (Key-Value) ──
  static Future<String?> getPromoValue(String key) async {
    final db = await database;
    final rows = await db.query('promo_data', where: 'key = ?', whereArgs: [key]);
    if (rows.isNotEmpty) return rows.first['value'] as String?;
    return null;
  }

  static Future<void> setPromoValue(String key, String value) async {
    final db = await database;
    await db.insert('promo_data', {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Profile Data (Key-Value) ──
  static Future<String?> getProfileValue(String key) async {
    final db = await database;
    final rows = await db.query('profile_data', where: 'key = ?', whereArgs: [key]);
    if (rows.isNotEmpty) return rows.first['value'] as String?;
    return null;
  }

  static Future<void> setProfileValue(String key, String value) async {
    final db = await database;
    await db.insert('profile_data', {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, String>> getAllProfileData() async {
    final db = await database;
    final rows = await db.query('profile_data');
    final map = <String, String>{};
    for (final row in rows) {
      map[row['key'] as String] = row['value'] as String? ?? '';
    }
    return map;
  }
}
