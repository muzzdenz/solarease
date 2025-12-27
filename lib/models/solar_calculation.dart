double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class SolarCalculation {
  final int? id;
  final String address;
  final double latitude;
  final double longitude;
  final double landArea;
  final double solarIrradiance;
  final int panelEfficiency;
  final int systemLosses;
  final double? maxPowerCapacity;
  final double? dailyEnergyProduction;
  final double? monthlyEnergyProduction;
  final double? yearlyEnergyProduction;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SolarCalculation({
    this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.landArea,
    required this.solarIrradiance,
    required this.panelEfficiency,
    required this.systemLosses,
    this.maxPowerCapacity,
    this.dailyEnergyProduction,
    this.monthlyEnergyProduction,
    this.yearlyEnergyProduction,
    this.createdAt,
    this.updatedAt,
  });

  factory SolarCalculation.fromJson(Map<String, dynamic> json) {
    return SolarCalculation(
      id: json['id'] as int?,
      address: json['address'] as String,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      landArea: _toDouble(json['land_area']),
      solarIrradiance: _toDouble(json['solar_irradiance']),
      panelEfficiency: _toInt(json['panel_efficiency']),
      systemLosses: _toInt(json['system_losses']),
      maxPowerCapacity: _toDoubleOrNull(json['max_power_capacity']),
      dailyEnergyProduction: _toDoubleOrNull(json['daily_energy_production']),
      monthlyEnergyProduction: _toDoubleOrNull(json['monthly_energy_production']),
      yearlyEnergyProduction: _toDoubleOrNull(json['yearly_energy_production']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'land_area': landArea,
      'solar_irradiance': solarIrradiance,
      'panel_efficiency': panelEfficiency,
      'system_losses': systemLosses,
      'max_power_capacity': maxPowerCapacity,
      'daily_energy_production': dailyEnergyProduction,
      'monthly_energy_production': monthlyEnergyProduction,
      'yearly_energy_production': yearlyEnergyProduction,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SolarCalculation copyWith({
    int? id,
    String? address,
    double? latitude,
    double? longitude,
    double? landArea,
    double? solarIrradiance,
    int? panelEfficiency,
    int? systemLosses,
    double? maxPowerCapacity,
    double? dailyEnergyProduction,
    double? monthlyEnergyProduction,
    double? yearlyEnergyProduction,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SolarCalculation(
      id: id ?? this.id,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landArea: landArea ?? this.landArea,
      solarIrradiance: solarIrradiance ?? this.solarIrradiance,
      panelEfficiency: panelEfficiency ?? this.panelEfficiency,
      systemLosses: systemLosses ?? this.systemLosses,
      maxPowerCapacity: maxPowerCapacity ?? this.maxPowerCapacity,
      dailyEnergyProduction: dailyEnergyProduction ?? this.dailyEnergyProduction,
      monthlyEnergyProduction: monthlyEnergyProduction ?? this.monthlyEnergyProduction,
      yearlyEnergyProduction: yearlyEnergyProduction ?? this.yearlyEnergyProduction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalculationDetails {
  final double usableArea;
  final double maxPowerCapacity;
  final double dailyEnergyProduction;
  final double monthlyEnergyProduction;
  final double yearlyEnergyProduction;
  final int panelEfficiency;
  final int systemLosses;
  final double performanceRatio;

  CalculationDetails({
    required this.usableArea,
    required this.maxPowerCapacity,
    required this.dailyEnergyProduction,
    required this.monthlyEnergyProduction,
    required this.yearlyEnergyProduction,
    required this.panelEfficiency,
    required this.systemLosses,
    required this.performanceRatio,
  });

  factory CalculationDetails.fromJson(Map<String, dynamic> json) {
    return CalculationDetails(
      usableArea: _toDouble(json['usable_area']),
      maxPowerCapacity: _toDouble(json['max_power_capacity']),
      dailyEnergyProduction: _toDouble(json['daily_energy_production']),
      monthlyEnergyProduction: _toDouble(json['monthly_energy_production']),
      yearlyEnergyProduction: _toDouble(json['yearly_energy_production']),
      panelEfficiency: _toInt(json['panel_efficiency']),
      systemLosses: _toInt(json['system_losses']),
      performanceRatio: _toDouble(json['performance_ratio']),
    );
  }
}

class FinancialMetrics {
  final double installationCost;
  final double yearlySavings;
  final double paybackPeriodYears;
  final double roi25Years;

  FinancialMetrics({
    required this.installationCost,
    required this.yearlySavings,
    required this.paybackPeriodYears,
    required this.roi25Years,
  });

  factory FinancialMetrics.fromJson(Map<String, dynamic> json) {
    return FinancialMetrics(
      installationCost: _toDouble(json['installation_cost']),
      yearlySavings: _toDouble(json['yearly_savings']),
      paybackPeriodYears: _toDouble(json['payback_period_years']),
      roi25Years: _toDouble(json['roi_25_years']),
    );
  }
}

class CalculationResponse {
  final bool success;
  final String message;
  final SolarCalculation? calculation;
  final CalculationDetails? details;
  final FinancialMetrics? financialMetrics;
  final Map<String, List<String>>? errors;

  CalculationResponse({
    required this.success,
    required this.message,
    this.calculation,
    this.details,
    this.financialMetrics,
    this.errors,
  });

  factory CalculationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CalculationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      calculation: data?['calculation'] != null
          ? SolarCalculation.fromJson(data!['calculation'] as Map<String, dynamic>)
          : null,
      details: data?['details'] != null
          ? CalculationDetails.fromJson(data!['details'] as Map<String, dynamic>)
          : null,
      financialMetrics: data?['financial_metrics'] != null
          ? FinancialMetrics.fromJson(data!['financial_metrics'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              (json['errors'] as Map).cast<String, dynamic>().map(
                    (key, value) => MapEntry(
                      key,
                      List<String>.from((value as List).cast<String>()),
                    ),
                  ),
            )
          : null,
    );
  }
}

class PaginatedResponse {
  final bool success;
  final String message;
  final List<SolarCalculation> data;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List)
        .map((item) => SolarCalculation.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: dataList,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
    );
  }
}
