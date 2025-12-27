import 'api_service.dart';
import '../models/solar_calculation.dart';

// Result class untuk return multiple values
class CalculationDetailsResult {
  final SolarCalculation calculation;
  final CalculationDetails details;
  final FinancialMetrics metrics;

  CalculationDetailsResult({
    required this.calculation,
    required this.details,
    required this.metrics,
  });
}

class SolarService {
  final ApiService _apiService = ApiService();

  // Create calculation
  Future<SolarCalculation> createSolarCalculation({
    required String address,
    required double landArea,
    required double latitude,
    required double longitude,
    required double solarIrradiance,
    int panelEfficiency = 20,
    int systemLosses = 14,
  }) async {
    final response = await _apiService.createCalculation(
      address: address,
      landArea: landArea,
      latitude: latitude,
      longitude: longitude,
      solarIrradiance: solarIrradiance,
      panelEfficiency: panelEfficiency,
      systemLosses: systemLosses,
    );

    if (!response.success || response.calculation == null) {
      throw Exception(response.message);
    }

    return response.calculation!;
  }

  // Get all calculations
  Future<List<SolarCalculation>> getAllCalculations({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _apiService.getAllCalculations(
      page: page,
      perPage: perPage,
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    return response.data;
  }

  // Get calculation by ID
  Future<SolarCalculation> getCalculationById(int id) async {
    final response = await _apiService.getCalculation(id);

    if (!response.success || response.calculation == null) {
      throw Exception(response.message);
    }

    return response.calculation!;
  }

  // Get calculation with full details
  Future<CalculationDetailsResult> getCalculationDetails(int id) async {
    final response = await _apiService.getCalculation(id);

    if (!response.success ||
        response.calculation == null ||
        response.details == null ||
        response.financialMetrics == null) {
      throw Exception(response.message);
    }

    return CalculationDetailsResult(
      calculation: response.calculation!,
      details: response.details!,
      metrics: response.financialMetrics!,
    );
  }

  // Update calculation
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
    final response = await _apiService.updateCalculation(
      id,
      address: address,
      landArea: landArea,
      latitude: latitude,
      longitude: longitude,
      solarIrradiance: solarIrradiance,
      panelEfficiency: panelEfficiency,
      systemLosses: systemLosses,
    );

    if (!response.success || response.calculation == null) {
      throw Exception(response.message);
    }

    return response.calculation!;
  }

  // Delete calculation
  Future<bool> deleteCalculation(int id) async {
    final response = await _apiService.deleteCalculation(id);
    return response['success'] as bool? ?? false;
  }
}
