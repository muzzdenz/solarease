// COMPREHENSIVE API SERVICE - ALL ENDPOINTS
// File: lib/services/api.dart

import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Use emulator loopback on Android, localhost elsewhere. Avoid const to allow platform check.
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }
  
  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  String? _authToken;

  ApiClient() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Log full URL to confirm base endpoint used on device.
          print('🌐 [${options.method}] ${options.uri}');
          print('📤 Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Error: ${error.message}');
          if (error.response?.statusCode == 401) {
            _clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // TOKEN MANAGEMENT
  Future<void> saveToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    return _authToken;
  }

  void _clearToken() {
    _authToken = null;
    _secureStorage.delete(key: 'auth_token');
  }

  Future<void> clearAllData() async {
    _clearToken();
  }

  String _getErrorMessage(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    
    // Error message based on exception type
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Koneksi timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Timeout menerima data';
    } else if (error.type == DioExceptionType.badResponse) {
      return 'Error ${error.response?.statusCode}';
    } else {
      return error.message ?? 'Error tidak diketahui';
    }
  }

  // ============== PUBLIC ENDPOINTS ==============

  // Health Check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // AUTH: Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        // Many Laravel auth scaffolds require confirmation
        'password_confirmation': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // AUTH: Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final data = response.data as Map<String, dynamic>;
      if (data['data'] != null && data['data']['token'] != null) {
        await saveToken(data['data']['token']);
      }
      return data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // AUTH: Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // AUTH: Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'email': email,
        'token': token,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // PRODUCTS: Get All
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // PRODUCTS: Get Detail
  Future<Map<String, dynamic>> getProduct(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // WEBHOOK: Midtrans
  Future<Map<String, dynamic>> processMidtransWebhook(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/webhook/midtrans', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ============== PROTECTED ENDPOINTS ==============

  // AUTH: Logout
  Future<void> logoutUser() async {
    try {
      await _dio.post('/auth/logout');
      await clearAllData();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // AUTH: Get Current User
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // SOLAR: Get All Calculations
  Future<Map<String, dynamic>> getSolarCalculations({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/powerestimation/solar-calculations',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // SOLAR: Create Calculation
  Future<Map<String, dynamic>> createSolarCalculation({
    required String address,
    required double landArea,
    required double latitude,
    required double longitude,
    required double solarIrradiance,
    int panelEfficiency = 20,
    int systemLosses = 14,
  }) async {
    try {
      final response = await _dio.post(
        '/powerestimation/solar-calculations',
        data: {
          'address': address,
          'land_area': landArea,
          'latitude': latitude,
          'longitude': longitude,
          'solar_irradiance': solarIrradiance,
          'panel_efficiency': panelEfficiency,
          'system_losses': systemLosses,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // SOLAR: Get Detail
  Future<Map<String, dynamic>> getSolarCalculation(int id) async {
    try {
      final response = await _dio.get('/powerestimation/solar-calculations/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // SOLAR: Update
  Future<Map<String, dynamic>> updateSolarCalculation(
    int id, {
    String? address,
    double? landArea,
    double? latitude,
    double? longitude,
    double? solarIrradiance,
    int? panelEfficiency,
    int? systemLosses,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (address != null) data['address'] = address;
      if (landArea != null) data['land_area'] = landArea;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (solarIrradiance != null) data['solar_irradiance'] = solarIrradiance;
      if (panelEfficiency != null) data['panel_efficiency'] = panelEfficiency;
      if (systemLosses != null) data['system_losses'] = systemLosses;

      final response = await _dio.patch(
        '/powerestimation/solar-calculations/$id',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // SOLAR: Delete
  Future<Map<String, dynamic>> deleteSolarCalculation(int id) async {
    try {
      final response = await _dio.delete(
        '/powerestimation/solar-calculations/$id',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // SOLAR: Get Financial Metrics
  Future<Map<String, dynamic>> getSolarCalculationFinancial(int id) async {
    try {
      final response = await _dio.get(
        '/powerestimation/solar-calculations/$id/financial',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ADMIN: Add Product
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    required String image,
    String? sku,
    int? stock,
  }) async {
    try {
      final response = await _dio.post('/products', data: {
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'sku': sku,
        'stock': stock,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CART: Get
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _dio.get('/cart');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CART: Add Item
  Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post('/cart', data: {
        'product_id': productId,
        'quantity': quantity,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CART: Update Item
  Future<Map<String, dynamic>> updateCartItem(int cartId, int quantity) async {
    try {
      final response = await _dio.put('/cart/$cartId', data: {
        'quantity': quantity,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CART: Increment Item
  Future<Map<String, dynamic>> incrementCartItem(int cartId) async {
    try {
      final response = await _dio.post('/cart/$cartId/increment');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CART: Decrement Item
  Future<Map<String, dynamic>> decrementCartItem(int cartId) async {
    try {
      final response = await _dio.post('/cart/$cartId/decrement');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CART: Remove Item
  Future<Map<String, dynamic>> removeCartItem(int cartId) async {
    try {
      final response = await _dio.delete('/cart/$cartId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CART: Clear All
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await _dio.delete('/cart');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ORDERS: Get All
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get('/orders', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ORDERS: Get Detail
  Future<Map<String, dynamic>> getOrder(int id) async {
    try {
      final response = await _dio.get('/orders/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // CHECKOUT
  Future<Map<String, dynamic>> checkout({
    required Map<String, dynamic> checkoutData,
  }) async {
    try {
      final response = await _dio.post('/checkout', data: checkoutData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
