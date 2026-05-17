import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSession {
  static const String _keyEmail = 'user_email';
  static const String _keyUserId = 'user_id';

  // Load email from SharedPreferences cache
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // Load user ID from SharedPreferences cache
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Save auth data to local cache
  static Future<void> saveSession(String email, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyUserId, userId);
  }

  // Clear local session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUserId);
  }

  // Check if user has a valid Supabase session
  static bool hasSupabaseSession() {
    return Supabase.instance.client.auth.currentSession != null;
  }

  // Get current Supabase user
  static User? get currentSupabaseUser => Supabase.instance.client.auth.currentUser;

  static bool isAdmin(String? email) => email == 'barualevis@gmail.com';
}
