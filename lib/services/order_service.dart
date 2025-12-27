import 'api_client.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  // Auth token helper
  Future<String?> getToken() async {
    return _apiClient.getToken();
  }

  // Get all orders
  Future<List<Map<String, dynamic>>> getOrders({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.getOrders(page: page, perPage: perPage);
      if (response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else if (response['data'] is Map && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']['data']);
      }
      return [];
    } catch (e) {
      print('❌ Error getting orders: $e');
      return [];
    }
  }

  // Get order detail
  Future<Map<String, dynamic>?> getOrderDetail(int orderId) async {
    try {
      final response = await _apiClient.getOrder(orderId);
      if (response['data'] is Map) {
        return Map<String, dynamic>.from(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ Error getting order detail: $e');
      return null;
    }
  }
}
