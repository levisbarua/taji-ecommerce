import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSession {
  static const _storage = FlutterSecureStorage();
  static const String _keyEmail = 'user_email';
  static const String _keyUserId = 'user_id';

  static Future<String?> getEmail() async {
    try { return await _storage.read(key: _keyEmail); } catch (_) { return null; }
  }

  static Future<String?> getUserId() async {
    try { return await _storage.read(key: _keyUserId); } catch (_) { return null; }
  }

  static Future<void> saveSession(String email, String userId) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyUserId, value: userId);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyUserId);
  }

  static bool hasSupabaseSession() {
    return Supabase.instance.client.auth.currentSession != null;
  }

  static User? get currentSupabaseUser => Supabase.instance.client.auth.currentUser;

  /// Check admin via server-side role, not hardcoded email
  static Future<bool> isAdminAsync(String? userId) async {
    if (userId == null) return false;
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return profile?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }
}
