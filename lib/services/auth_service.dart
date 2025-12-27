import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// AuthService sekarang memanggil backend API sungguhan
/// melalui ApiClient. Token disimpan di secure storage oleh ApiClient.
class AuthService {
  static const _keyLoggedIn = 'logged_in';
  static const _keyUserEmail = 'user_email';
  static const _keyUserName = 'user_name';

  static final ApiClient _api = ApiClient();

  /// Login ke backend. Mengembalikan true jika sukses.
  static Future<bool> login(String email, String password) async {
    try {
      final resp = await _api.login(email: email, password: password);
      if (resp['success'] == true) {
        final user = resp['data']?['user'] as Map? ?? {};
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyLoggedIn, true);
        await prefs.setString(_keyUserEmail, user['email']?.toString() ?? email);
        await prefs.setString(_keyUserName, user['name']?.toString() ?? '');
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Register user baru.
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _api.register(
        name: name,
        email: email,
        password: password,
      );
      return resp['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Forgot password.
  static Future<bool> forgotPassword(String email) async {
    try {
      final resp = await _api.forgotPassword(email);
      return resp['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Reset password.
  static Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      final resp = await _api.resetPassword(
        email: email,
        token: token,
        password: password,
      );
      return resp['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Logout dari backend + bersihkan token.
  static Future<void> logout() async {
    try {
      await _api.logoutUser();
    } catch (_) {
      // ignore
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
  }

  /// Cek apakah sudah login berdasarkan token secure storage.
  static Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Ambil email user yang tersimpan (cached), atau fetch dari /auth/me.
  static Future<String?> currentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_keyUserEmail);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final resp = await _api.getCurrentUser();
      final user = resp['data'] as Map?;
      final email = user?['email']?.toString();
      if (email != null) {
        await prefs.setString(_keyUserEmail, email);
      }
      return email;
    } catch (_) {
      return null;
    }
  }

  /// Ambil nama user (cached), fallback ke fetch /auth/me.
  static Future<String?> currentName() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_keyUserName);
    if (cached != null && cached.isNotEmpty) return cached;
    try {
      final resp = await _api.getCurrentUser();
      final user = resp['data'] as Map?;
      final name = user?['name']?.toString();
      if (name != null) {
        await prefs.setString(_keyUserName, name);
      }
      return name;
    } catch (_) {
      return null;
    }
  }
}