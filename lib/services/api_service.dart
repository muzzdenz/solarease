import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/solar_calculation.dart';

/// DEPRECATED: Use ApiClient from api_client.dart instead
/// This file is kept for backward compatibility with existing SolarService
class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  String? _authToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor untuk logging dan token injection
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _clearTokenSync();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ========== TOKEN MANAGEMENT ==========
  
  Future<void> saveToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    return _authToken;
  }

  void _clearTokenSync() {
    _authToken = null;
    _secureStorage.delete(key: 'auth_token');
  }

  Future<void> logoutUser() async {
    _authToken = null;
    await _secureStorage.delete(key: 'auth_token');
  }

  // ========== SOLAR CALCULATIONS ==========

  // CREATE - Membuat kalkulasi baru
  Future<CalculationResponse> createCalculation({
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

      return CalculationResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // READ ALL - Mendapatkan semua kalkulasi (paginated)
  Future<PaginatedResponse> getAllCalculations({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/powerestimation/solar-calculations',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // READ ONE - Mendapatkan detail kalkulasi
  Future<CalculationResponse> getCalculation(int id) async {
    try {
      final response = await _dio.get('/powerestimation/solar-calculations/$id');
      return CalculationResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // UPDATE - Update kalkulasi
  Future<CalculationResponse> updateCalculation(
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

      return CalculationResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE - Hapus kalkulasi
  Future<Map<String, dynamic>> deleteCalculation(int id) async {
    try {
      final response = await _dio.delete('/powerestimation/solar-calculations/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    String errorMessage = 'Terjadi kesalahan';

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] ?? 'Terjadi kesalahan';
      }

      switch (statusCode) {
        case 400:
          errorMessage = 'Permintaan tidak valid';
          break;
        case 401:
          errorMessage = 'Tidak terautentikasi';
          break;
        case 403:
          errorMessage = 'Akses ditolak';
          break;
        case 404:
          errorMessage = 'Data tidak ditemukan';
          break;
        case 422:
          errorMessage = 'Validasi gagal';
          break;
        case 500:
          errorMessage = 'Terjadi kesalahan pada server';
          break;
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Timeout koneksi';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Timeout menerima data';
    } else if (error.type == DioExceptionType.unknown) {
      errorMessage = 'Periksa koneksi internet Anda';
    }

    return errorMessage;
  }
}

