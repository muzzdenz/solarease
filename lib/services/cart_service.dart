import 'api_client.dart';

class CartService {
  final ApiClient _apiClient = ApiClient();

  // Auth token helper
  Future<String?> getToken() async {
    return _apiClient.getToken();
  }

  // Get cart items
  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final response = await _apiClient.getCart();
      if (response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else if (response['data'] is Map && response['data']['items'] is List) {
        return List<Map<String, dynamic>>.from(response['data']['items']);
      }
      return [];
    } catch (e) {
      print('❌ Error getting cart: $e');
      return [];
    }
  }

  // Get cart summary (total price, item count, etc)
  Future<Map<String, dynamic>> getCartSummary() async {
    try {
      final response = await _apiClient.getCart();
      if (response['data'] is Map) {
        return Map<String, dynamic>.from(response['data']);
      }
      return {};
    } catch (e) {
      print('❌ Error getting cart summary: $e');
      return {};
    }
  }

  // Add item to cart
  Future<bool> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      await _apiClient.addToCart(productId: productId, quantity: quantity);
      return true;
    } catch (e) {
      print('❌ Error adding to cart: $e');
      rethrow;
    }
  }

  // Update cart item quantity
  Future<bool> updateQuantity(int cartId, int quantity) async {
    try {
      await _apiClient.updateCartItem(cartId, quantity);
      return true;
    } catch (e) {
      print('❌ Error updating cart: $e');
      rethrow;
    }
  }

  // Increment item quantity
  Future<bool> incrementItem(int cartId) async {
    try {
      await _apiClient.incrementCartItem(cartId);
      return true;
    } catch (e) {
      print('❌ Error incrementing item: $e');
      rethrow;
    }
  }

  // Decrement item quantity
  Future<bool> decrementItem(int cartId) async {
    try {
      await _apiClient.decrementCartItem(cartId);
      return true;
    } catch (e) {
      print('❌ Error decrementing item: $e');
      rethrow;
    }
  }

  // Remove item from cart
  Future<bool> removeItem(int cartId) async {
    try {
      await _apiClient.removeCartItem(cartId);
      return true;
    } catch (e) {
      print('❌ Error removing item: $e');
      rethrow;
    }
  }

  // Clear all cart items
  Future<bool> clearCart() async {
    try {
      await _apiClient.clearCart();
      return true;
    } catch (e) {
      print('❌ Error clearing cart: $e');
      rethrow;
    }
  }

  // Checkout
  Future<Map<String, dynamic>> checkout({
    required String shippingAddress,
    required String phone,
    String paymentMethod = 'cod',
    String? notes,
  }) async {
    try {
      final response = await _apiClient.checkout(
        checkoutData: {
          'shipping_address': shippingAddress,
          'phone': phone,
          'payment_method': paymentMethod,
          if (notes != null) 'notes': notes,
        },
      );
      return response;
    } catch (e) {
      print('❌ Error during checkout: $e');
      rethrow;
    }
  }
}
