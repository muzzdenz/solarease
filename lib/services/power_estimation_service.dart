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
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List<dynamic>)
              .map((e) => SolarCalculation.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        throw Exception(data['message'] ?? 'Failed to load calculations');
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
        if (data['success'] == true && data['data'] != null) {
          return SolarCalculation.fromJson(data['data'] as Map<String, dynamic>);
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
