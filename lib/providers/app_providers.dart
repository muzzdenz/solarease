import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/api_models.dart';

// AUTH PROVIDER
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  AuthProvider(this._apiClient);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasError => _errorMessage != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.login(
        email: email,
        password: password,
      );

      if (response['success'] == true && response['data'] != null) {
        _currentUser = User.fromJson(response['data']['user']);
        _isLoggedIn = true;
        return true;
      }
      _errorMessage = response['message'] ?? 'Login failed';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.register(
        name: name,
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        return true;
      }
      _errorMessage = response['message'] ?? 'Registration failed';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.logoutUser();
    } catch (e) {
      print('Logout error: $e');
    }
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> getCurrentUser() async {
    _setLoading(true);
    try {
      final response = await _apiClient.getCurrentUser();
      if (response['data'] != null) {
        _currentUser = User.fromJson(response['data'] as Map<String, dynamic>);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// PRODUCTS PROVIDER
class ProductsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;

  ProductsProvider(this._apiClient);

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<bool> fetchProducts({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.getProducts(page: page, perPage: perPage);
      final productsResponse = ProductsResponse.fromJson(response);
      
      if (productsResponse.success) {
        _products = productsResponse.data;
        _currentPage = page;
        return true;
      }
      _errorMessage = productsResponse.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> fetchProduct(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.getProduct(id);
      if (response['data'] != null) {
        _selectedProduct = Product.fromJson(response['data']);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// CART PROVIDER
class CartProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  List<CartItem> _items = [];
  double _totalPrice = 0;
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider(this._apiClient);

  List<CartItem> get items => _items;
  double get totalPrice => _totalPrice;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<bool> fetchCart() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.getCart();
      final cartResponse = CartResponse.fromJson(response);
      
      if (cartResponse.success) {
        _items = cartResponse.items;
        _totalPrice = cartResponse.totalPrice;
        return true;
      }
      _errorMessage = cartResponse.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    try {
      final response = await _apiClient.addToCart(
        productId: productId,
        quantity: quantity,
      );
      
      if (response['success'] == true) {
        await fetchCart();
        return true;
      }
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(int cartId) async {
    try {
      final response = await _apiClient.removeCartItem(cartId);
      if (response['success'] == true) {
        await fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      final response = await _apiClient.clearCart();
      if (response['success'] == true) {
        _items = [];
        _totalPrice = 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// ORDERS PROVIDER
class OrdersProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  OrdersProvider(this._apiClient);

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<bool> fetchOrders({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.getOrders(page: page, perPage: perPage);
      final ordersResponse = OrdersResponse.fromJson(response);
      
      if (ordersResponse.success) {
        _orders = ordersResponse.data;
        return true;
      }
      _errorMessage = ordersResponse.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> fetchOrder(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.getOrder(id);
      if (response['data'] != null) {
        _selectedOrder = Order.fromJson(response['data']);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkout(Map<String, dynamic> checkoutData) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiClient.checkout(checkoutData: checkoutData);
      
      if (response['success'] == true) {
        await fetchOrders();
        return true;
      }
      _errorMessage = response['message'];
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
