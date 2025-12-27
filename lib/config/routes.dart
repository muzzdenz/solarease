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
import '../screens/purchase/cart_screen.dart';
import '../screens/purchase/orders_screen.dart';
import '../screens/purchase/checkout_screen.dart';
import '../screens/purchase/checkout_success_screen.dart';
import '../screens/test/api_test_screen.dart';

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
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout_success';
  static const String apiTest = '/api_test';

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
      cart: (context) => const CartScreen(),
      orders: (context) => const OrdersScreen(),
      checkout: (context) => const CheckoutScreen(),
      checkoutSuccess: (context) => const CheckoutSuccessScreen(
        items: const [], totalPrice: 0, shippingAddress: '', phone: '',
      ),
      apiTest: (context) => ApiTestScreen(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    
    switch (settings.name) {
      case orders:
        return MaterialPageRoute(
          builder: (context) => OrdersScreen(
            shouldRefresh: args['shouldRefresh'] as bool? ?? false,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => routes[settings.name]?.call(context) ?? const SplashScreen(),
        );
    }
  }
}
