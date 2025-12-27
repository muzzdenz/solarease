import 'api_client.dart';
import '../models/dashboard.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  /// Get home dashboard summary with cards and metrics
  Future<DashboardHome> getDashboardHome() async {
    try {
      final response = await _apiClient.get('/dashboard/home');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return DashboardHome.fromJson(data['data'] as Map<String, dynamic>);
        }
        throw Exception(data['message'] ?? 'Failed to load dashboard home');
      }
      throw Exception('Failed to load dashboard home: ${response.statusCode}');
    } catch (e) {
      throw Exception('Dashboard home error: $e');
    }
  }

  /// Get dashboard statistics (aggregated metrics)
  Future<DashboardStatistics> getDashboardStatistics() async {
    try {
      final response = await _apiClient.get('/dashboard/statistics');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return DashboardStatistics.fromJson(data['data'] as Map<String, dynamic>);
        }
        throw Exception(data['message'] ?? 'Failed to load dashboard statistics');
      }
      throw Exception('Failed to load dashboard statistics: ${response.statusCode}');
    } catch (e) {
      throw Exception('Dashboard statistics error: $e');
    }
  }

  /// Get user's recent calculations
  Future<List<RecentCalculation>> getRecentCalculations({
    int limit = 5,
  }) async {
    try {
      final response = await _apiClient.get('/dashboard/recent-calculations', queryParameters: {'limit': limit});
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List<dynamic>)
              .map((e) => RecentCalculation.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        throw Exception(data['message'] ?? 'Failed to load recent calculations');
      }
      throw Exception('Failed to load recent calculations: ${response.statusCode}');
    } catch (e) {
      throw Exception('Recent calculations error: $e');
    }
  }
}
