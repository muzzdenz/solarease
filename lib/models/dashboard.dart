// Dashboard models for home screen metrics and statistics

class DashboardHome {
  final int totalCalculations;
  final int activeOrders;
  final double totalEnergyProduction; // kWh
  final double totalCostSavings; // Rupiah
  final String lastCalculationDate;
  final List<QuickCard> quickCards;

  DashboardHome({
    required this.totalCalculations,
    required this.activeOrders,
    required this.totalEnergyProduction,
    required this.totalCostSavings,
    required this.lastCalculationDate,
    required this.quickCards,
  });

  factory DashboardHome.fromJson(Map<String, dynamic> json) {
    return DashboardHome(
      totalCalculations: int.tryParse(json['total_calculations']?.toString() ?? '0') ?? 0,
      activeOrders: int.tryParse(json['active_orders']?.toString() ?? '0') ?? 0,
      totalEnergyProduction: double.tryParse(json['total_energy_production']?.toString() ?? '0') ?? 0.0,
      totalCostSavings: double.tryParse(json['total_cost_savings']?.toString() ?? '0') ?? 0.0,
      lastCalculationDate: json['last_calculation_date']?.toString() ?? 'N/A',
      quickCards: (json['quick_cards'] as List<dynamic>?)?.map((e) => QuickCard.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class QuickCard {
  final String label;
  final String value;
  final String unit;
  final String? icon; // Icon name or emoji

  QuickCard({
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
  });

  factory QuickCard.fromJson(Map<String, dynamic> json) {
    return QuickCard(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '0',
      unit: json['unit']?.toString() ?? '',
      icon: json['icon']?.toString(),
    );
  }
}

class DashboardStatistics {
  final double monthlyEnergyProduction; // kWh
  final double monthlyCostSavings; // Rupiah
  final double averageSystemEfficiency; // Percent
  final int totalPanelsInUse;
  final double carbonEmissionAvoided; // kg CO2
  final List<ChartData> productionTrend;

  DashboardStatistics({
    required this.monthlyEnergyProduction,
    required this.monthlyCostSavings,
    required this.averageSystemEfficiency,
    required this.totalPanelsInUse,
    required this.carbonEmissionAvoided,
    required this.productionTrend,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      monthlyEnergyProduction: double.tryParse(json['monthly_energy_production']?.toString() ?? '0') ?? 0.0,
      monthlyCostSavings: double.tryParse(json['monthly_cost_savings']?.toString() ?? '0') ?? 0.0,
      averageSystemEfficiency: double.tryParse(json['average_system_efficiency']?.toString() ?? '0') ?? 0.0,
      totalPanelsInUse: int.tryParse(json['total_panels_in_use']?.toString() ?? '0') ?? 0,
      carbonEmissionAvoided: double.tryParse(json['carbon_emission_avoided']?.toString() ?? '0') ?? 0.0,
      productionTrend: (json['production_trend'] as List<dynamic>?)?.map((e) => ChartData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class ChartData {
  final String date;
  final double production;

  ChartData({required this.date, required this.production});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: json['date']?.toString() ?? '',
      production: double.tryParse(json['production']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class RecentCalculation {
  final int id;
  final String address;
  final double estimatedAnnualProduction; // kWh
  final double estimatedAnnualSavings; // Rupiah
  final String createdAt;
  final String status;

  RecentCalculation({
    required this.id,
    required this.address,
    required this.estimatedAnnualProduction,
    required this.estimatedAnnualSavings,
    required this.createdAt,
    required this.status,
  });

  factory RecentCalculation.fromJson(Map<String, dynamic> json) {
    return RecentCalculation(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      address: json['address']?.toString() ?? '',
      estimatedAnnualProduction: double.tryParse(json['estimated_annual_production']?.toString() ?? '0') ?? 0.0,
      estimatedAnnualSavings: double.tryParse(json['estimated_annual_savings']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
    );
  }
}
