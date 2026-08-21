import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Persists the logged-in user to device storage (SharedPreferences)
/// so the user doesn't have to log in again after a hot restart /
/// app relaunch.
class SessionService {
  static const String _userKey = 'logged_in_user';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Save the user after a successful login.
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Returns the saved user, or null if nobody is logged in / data missing.
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (!isLoggedIn) return null;

    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> data = json.decode(userJson);
      return User.fromJson(data);
    } catch (e) {
      // Corrupted data — clear it so we don't loop forever.
      await clearSession();
      return null;
    }
  }

  /// Quick check without decoding the whole user object.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Call this on logout.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_isLoggedInKey);
  }
}
