import 'api_client.dart';
import '../models/solar_calculation.dart';

class PowerEstimationService {
  final ApiClient _apiClient = ApiClient();

  /// Get list of user's solar calculations
  Future<List<SolarCalculation>> getCalculations({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/powerestimation/solar-calculations',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response data type: ${response.data.runtimeType}');
      if (response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        print('🔍 Response keys: ${map.keys.toList()}');
        if (map['data'] != null) {
          print('🔍 data field type: ${map['data'].runtimeType}');
          if (map['data'] is List) {
            print('🔍 data list length: ${(map['data'] as List).length}');
          } else if (map['data'] is Map) {
            final dataMap = map['data'] as Map<String, dynamic>;
            print('🔍 data map keys: ${dataMap.keys.toList()}');
            // Check for nested list
            for (final key in ['data', 'items', 'calculations', 'list']) {
              if (dataMap[key] is List) {
                print('🔍 Found list at data.$key with ${(dataMap[key] as List).length} items');
              }
            }
          }
        }
        if (map['meta'] != null) {
          print('🔍 Pagination meta: ${map['meta']}');
        }
      }
      
      if (response.statusCode == 200 && response.data != null) {
        final root = response.data;
        List<dynamic>? items;

        if (root is List) {
          items = root;
        } else if (root is Map<String, dynamic>) {
          final data = root['data'];
          // Common shapes: data: [ ... ]
          if (data is List) {
            items = data;
          } else if (data is Map<String, dynamic>) {
            // Nested list under known keys - check data.data first (Laravel pagination)
            if (data['data'] is List) {
              items = data['data'] as List<dynamic>;
              print('✅ Found calculations at data.data');
            } else if (data['items'] is List) {
              items = data['items'] as List<dynamic>;
              print('✅ Found calculations at data.items');
            } else if (data['calculations'] is List) {
              items = data['calculations'] as List<dynamic>;
              print('✅ Found calculations at data.calculations');
            } else if (data['list'] is List) {
              items = data['list'] as List<dynamic>;
              print('✅ Found calculations at data.list');
            }
          } else {
            // Also try top-level common keys
            if (root['items'] is List) {
              items = root['items'] as List<dynamic>;
            } else if (root['calculations'] is List) {
              items = root['calculations'] as List<dynamic>;
            }
          }

          // If API indicates success but no list found, return empty list gracefully
          final success = root['success'] == true || root['status'] == 'success';
          if (items == null && success) {
            print('⚠️ API returned success but no calculations list found');
            return <SolarCalculation>[];
          }
        }

        if (items != null) {
          print('✅ Parsing ${items.length} calculation items');
          return items
              .whereType<Map<String, dynamic>>()
              .map((e) => SolarCalculation.fromJson(e))
              .toList();
        }

        throw Exception('Unexpected response format for calculations');
      }
      throw Exception('Failed to load calculations: ${response.statusCode}');
    } catch (e) {
      throw Exception('Get calculations error: $e');
    }
  }

  /// Create a new solar calculation
  Future<SolarCalculation> createCalculation({
    required String address,
    required double landArea,
    required double latitude,
    required double longitude,
    required double solarIrradiance,
    int panelEfficiency = 20,
    int systemLosses = 14,
  }) async {
    try {
      final response = await _apiClient.post(
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
      
      if (response.statusCode == 201 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        // API spec returns nested object: data.calculation
        final payload = data['data'];
        if (data['success'] == true && payload is Map<String, dynamic>) {
          final calcJson = payload['calculation'];
          if (calcJson is Map<String, dynamic>) {
            return SolarCalculation.fromJson(calcJson);
          }
        }
        throw Exception(data['message'] ?? 'Failed to create calculation');
      }
      throw Exception('Failed to create calculation: ${response.statusCode}');
    } catch (e) {
      throw Exception('Create calculation error: $e');
    }
  }

  /// Get calculation detail by ID
  Future<SolarCalculation> getCalculationDetail(int id) async {
    try {
      final response = await _apiClient.get('/powerestimation/solar-calculations/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return SolarCalculation.fromJson(data['data'] as Map<String, dynamic>);
        }
        throw Exception(data['message'] ?? 'Failed to load calculation');
      }
      throw Exception('Failed to load calculation: ${response.statusCode}');
    } catch (e) {
      throw Exception('Get calculation detail error: $e');
    }
  }

  /// Update a calculation
  Future<SolarCalculation> updateCalculation(
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
      final payload = <String, dynamic>{};
      if (address != null) payload['address'] = address;
      if (landArea != null) payload['land_area'] = landArea;
      if (latitude != null) payload['latitude'] = latitude;
      if (longitude != null) payload['longitude'] = longitude;
      if (solarIrradiance != null) payload['solar_irradiance'] = solarIrradiance;
      if (panelEfficiency != null) payload['panel_efficiency'] = panelEfficiency;
      if (systemLosses != null) payload['system_losses'] = systemLosses;

      final response = await _apiClient.put(
        '/powerestimation/solar-calculations/$id',
        data: payload,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return SolarCalculation.fromJson(data['data'] as Map<String, dynamic>);
        }
        throw Exception(data['message'] ?? 'Failed to update calculation');
      }
      throw Exception('Failed to update calculation: ${response.statusCode}');
    } catch (e) {
      throw Exception('Update calculation error: $e');
    }
  }

  /// Delete a calculation
  Future<void> deleteCalculation(int id) async {
    try {
      final response = await _apiClient.delete('/powerestimation/solar-calculations/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete calculation');
        }
      } else {
        throw Exception('Failed to delete calculation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete calculation error: $e');
    }
  }

  /// Get financial metrics for a calculation
  Future<Map<String, dynamic>> getFinancialMetrics(int id) async {
    try {
      final response = await _apiClient.get('/powerestimation/solar-calculations/$id/financial');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Failed to load financial metrics');
      }
      throw Exception('Failed to load financial metrics: ${response.statusCode}');
    } catch (e) {
      throw Exception('Get financial metrics error: $e');
    }
  }
}
