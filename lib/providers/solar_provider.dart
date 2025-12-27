import 'package:flutter/material.dart';
import '../services/solar_service.dart';
import '../models/solar_calculation.dart';

class SolarProvider extends ChangeNotifier {
  final SolarService _solarService = SolarService();

  List<SolarCalculation> _calculations = [];
  SolarCalculation? _currentCalculation;
  CalculationDetails? _currentDetails;
  FinancialMetrics? _currentMetrics;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;

  // Getters
  List<SolarCalculation> get calculations => _calculations;
  SolarCalculation? get currentCalculation => _currentCalculation;
  CalculationDetails? get currentDetails => _currentDetails;
  FinancialMetrics? get currentMetrics => _currentMetrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasError => _errorMessage != null;

  // Create Calculation
  Future<bool> createCalculation({
    required String address,
    required double landArea,
    required double latitude,
    required double longitude,
    required double solarIrradiance,
    int panelEfficiency = 20,
    int systemLosses = 14,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _solarService.createSolarCalculation(
        address: address,
        landArea: landArea,
        latitude: latitude,
        longitude: longitude,
        solarIrradiance: solarIrradiance,
        panelEfficiency: panelEfficiency,
        systemLosses: systemLosses,
      );
      _currentCalculation = result;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch All Calculations
  Future<bool> fetchAllCalculations({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _calculations = await _solarService.getAllCalculations(
        page: page,
        perPage: perPage,
      );
      _currentPage = page;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch Single Calculation
  Future<bool> fetchCalculation(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentCalculation = await _solarService.getCalculationById(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch Full Details
  Future<bool> fetchCalculationDetails(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _solarService.getCalculationDetails(id);
      _currentCalculation = result.calculation;
      _currentDetails = result.details;
      _currentMetrics = result.metrics;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update Calculation
  Future<bool> updateCalculation(
    int id, {
    String? address,
    double? landArea,
    double? latitude,
    double? longitude,
    double? solarIrradiance,
    int? panelEfficiency,
    int? systemLosses,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _solarService.updateCalculation(
        id,
        address: address,
        landArea: landArea,
        latitude: latitude,
        longitude: longitude,
        solarIrradiance: solarIrradiance,
        panelEfficiency: panelEfficiency,
        systemLosses: systemLosses,
      );
      _currentCalculation = result;
      // Update dalam list
      final index = _calculations.indexWhere((c) => c.id == id);
      if (index != -1) {
        _calculations[index] = result;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete Calculation
  Future<bool> deleteCalculation(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _solarService.deleteCalculation(id);
      if (success) {
        _calculations.removeWhere((calc) => calc.id == id);
        if (_currentCalculation?.id == id) {
          _currentCalculation = null;
          _currentDetails = null;
          _currentMetrics = null;
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper Methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentCalculation() {
    _currentCalculation = null;
    _currentDetails = null;
    _currentMetrics = null;
    notifyListeners();
  }
}
