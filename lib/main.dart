import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/theme_service.dart';
import 'services/api_client.dart';
import 'providers/solar_provider.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  final apiClient = ApiClient();
  
  await Future.delayed(const Duration(milliseconds: 100)); // Give time to initialize
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        // API Client (singleton)
        Provider<ApiClient>.value(value: apiClient),
        // Authentication
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient),
        ),
        // Products
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(apiClient),
        ),
        // Cart
        ChangeNotifierProvider(
          create: (_) => CartProvider(apiClient),
        ),
        // Orders
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(apiClient),
        ),
        // Solar (legacy)
        ChangeNotifierProvider(
          create: (_) => SolarProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          title: 'SolarEase',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}