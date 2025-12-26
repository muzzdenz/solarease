import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/service/service_plans_screen.dart';
import '../screens/service/service_order_screen.dart';
import '../screens/power_check/power_check_screen.dart';
import '../screens/power_check/power_check_result_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/purchase/purchase_history_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot_password';
  static const String home = '/home';
  static const String servicePlans = '/service_plans';
  static const String serviceOrder = '/service_order';
  static const String powerCheck = '/power_check';
  static const String powerCheckResult = '/power_check_result';
  static const String settings = '/settings';
  static const String purchaseHistory = '/purchase_history';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      home: (context) => const HomeScreen(),
      servicePlans: (context) => const ServicePlansScreen(),
      powerCheck: (context) => const PowerCheckScreen(),
      settings: (context) => const SettingsScreen(),
      purchaseHistory: (context) => const PurchaseHistoryScreen(),
    };
  }
}