import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLoggedIn = 'logged_in';
  static const _keyPhone = 'user_phone';

  // Mock login: ganti dengan API call nyata nanti
  // contoh valid: phone == '081234' && password == 'password'
  static Future<bool> login(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    final ok = phone.isNotEmpty && password.isNotEmpty; // simple rule
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, true);
      await prefs.setString(_keyPhone, phone);
    }
    return ok;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyPhone);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<String?> currentPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }
}