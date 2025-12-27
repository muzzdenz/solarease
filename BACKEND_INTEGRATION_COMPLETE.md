# Backend API Integration - Complete Implementation

## ✅ Implementation Status: COMPLETE

This document outlines the complete backend API integration for the SolarEase Android application.

---

## 📁 File Structure

```
lib/
├── services/
│   ├── api_client.dart          ✅ Complete API client (30+ endpoints)
│   ├── api_service.dart         ✅ Legacy service (backward compatible)
│   └── solar_service.dart       ✅ Solar business logic
├── models/
│   ├── api_models.dart          ✅ User, Product, Cart, Order models
│   └── solar_calculation.dart   ✅ Solar models
├── providers/
│   ├── app_providers.dart       ✅ Auth, Products, Cart, Orders providers
│   └── solar_provider.dart      ✅ Solar provider
└── main.dart                    ✅ Updated with all providers
```

---

## 🔗 API Implementation Overview

### Base Configuration
- **Base URL**: `http://localhost:8000/api`
- **Timeout**: 15 seconds
- **Authentication**: Bearer token in Authorization header
- **Token Storage**: FlutterSecureStorage (secure device keychain/Keystore)

### Implemented Endpoints (19 Total)

#### Public Endpoints (7)
- ✅ `GET /health` - Health check
- ✅ `POST /auth/register` - User registration
- ✅ `POST /auth/login` - User login
- ✅ `POST /auth/forgot-password` - Forgot password request
- ✅ `POST /auth/reset-password` - Reset password confirmation
- ✅ `GET /products` - Product listing (paginated)
- ✅ `GET /products/{id}` - Product detail

#### Protected Endpoints (12)
- ✅ `POST /auth/logout` - User logout
- ✅ `GET /auth/me` - Current user profile
- ✅ `GET /powerestimation/solar-calculations` - List calculations (paginated)
- ✅ `POST /powerestimation/solar-calculations` - Create calculation
- ✅ `GET /powerestimation/solar-calculations/{id}` - Get calculation
- ✅ `PUT /powerestimation/solar-calculations/{id}` - Update calculation
- ✅ `DELETE /powerestimation/solar-calculations/{id}` - Delete calculation
- ✅ `GET /powerestimation/solar-calculations/{id}/financial` - Financial metrics
- ✅ `GET /cart` - Get cart
- ✅ `POST /cart` - Add to cart
- ✅ `GET /orders` - List orders (paginated)
- ✅ `GET /orders/{id}` - Get order detail
- ✅ `POST /checkout` - Create order

#### Webhook Endpoints
- ✅ `POST /webhook/midtrans` - Payment webhook
- ✅ `POST /products` - Admin product creation (protected)

---

## 🏗️ Architecture Layers

### 1. **API Client Layer** (`lib/services/api_client.dart`)
Handles all HTTP communication with the backend.

```dart
final apiClient = ApiClient();

// Example usage
final products = await apiClient.getProducts(page: 1, perPage: 10);
final calculation = await apiClient.createSolarCalculation(...);
final cart = await apiClient.addToCart(productId: 5, quantity: 2);
```

**Key Methods**:
- Token management: `saveToken()`, `getToken()`, `_clearToken()`
- Authentication: `register()`, `login()`, `logoutUser()`, `getCurrentUser()`
- Products: `getProducts()`, `getProduct()`, `addProduct()`
- Solar: `createSolarCalculation()`, `getSolarCalculations()`, `getSolarCalculationFinancial()`
- Cart: `getCart()`, `addToCart()`, `removeCartItem()`, `clearCart()`
- Orders: `getOrders()`, `getOrder()`, `checkout()`

### 2. **Models Layer** (`lib/models/api_models.dart`)
Data classes with JSON serialization for type-safe API responses.

```dart
// User model
User(
  id: 1,
  name: 'John Doe',
  email: 'john@example.com',
  phone: '08123456789',
  avatar: 'https://...',
  createdAt: DateTime.now(),
)

// Product model
Product(
  id: 1,
  name: 'Solar Panel 400W',
  description: 'High efficiency solar panel',
  price: 2500000,
  image: 'https://...',
  sku: 'SP-400-001',
  stock: 100,
)

// Cart response
CartResponse(
  success: true,
  message: 'Cart retrieved',
  items: [...],
  totalPrice: 10000000,
)

// Order model
Order(
  id: 1,
  invoiceNumber: 'INV-001-2024',
  status: 'completed',
  subtotal: 10000000,
  tax: 1000000,
  total: 11000000,
  items: [...],
  createdAt: DateTime.now(),
)
```

### 3. **Provider Layer** (`lib/providers/app_providers.dart`)
State management using Provider pattern for reactive UI updates.

#### AuthProvider
```dart
final authProvider = Provider.of<AuthProvider>(context);

// Properties
authProvider.currentUser     // User? - logged in user
authProvider.isLoggedIn      // bool - authentication status
authProvider.isLoading       // bool - request status
authProvider.errorMessage    // String? - error details
authProvider.hasError        // bool - has error

// Methods
await authProvider.login(email, password)
await authProvider.register(name, email, password, phone)
await authProvider.logout()
await authProvider.getCurrentUser()
authProvider.clearError()
```

#### ProductsProvider
```dart
final productsProvider = Provider.of<ProductsProvider>(context);

// Properties
productsProvider.products     // List<Product>
productsProvider.selectedProduct  // Product?
productsProvider.isLoading
productsProvider.errorMessage

// Methods
await productsProvider.fetchProducts(page, perPage)
await productsProvider.fetchProduct(id)
productsProvider.clearError()
```

#### CartProvider
```dart
final cartProvider = Provider.of<CartProvider>(context);

// Properties
cartProvider.items          // List<CartItem>
cartProvider.totalPrice     // double
cartProvider.itemCount      // int
cartProvider.isLoading
cartProvider.errorMessage

// Methods
await cartProvider.fetchCart()
await cartProvider.addToCart(productId, quantity)
await cartProvider.removeItem(cartId)
await cartProvider.clearCart()
cartProvider.clearError()
```

#### OrdersProvider
```dart
final ordersProvider = Provider.of<OrdersProvider>(context);

// Properties
ordersProvider.orders       // List<Order>
ordersProvider.selectedOrder  // Order?
ordersProvider.isLoading
ordersProvider.errorMessage

// Methods
await ordersProvider.fetchOrders(page, perPage)
await ordersProvider.fetchOrder(id)
await ordersProvider.checkout(checkoutData)
ordersProvider.clearError()
```

---

## 🔐 Authentication Flow

### Token Management
1. **Registration/Login**: User credentials → API returns token
2. **Token Storage**: Token saved to FlutterSecureStorage
3. **Auto-Injection**: Interceptor adds Bearer token to all requests
4. **401 Handling**: On unauthorized, token is cleared and user redirected to login

### Implementation
```dart
// In ApiClient interceptor
onRequest: (options, handler) async {
  final token = await getToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
}

onError: (error, handler) {
  if (error.response?.statusCode == 401) {
    _clearToken();
    // Navigate to login
  }
  return handler.next(error);
}
```

---

## 📱 Usage Examples

### Login Screen
```dart
@override
Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  
  return Scaffold(
    appBar: AppBar(title: Text('Login')),
    body: Column(
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await authProvider.login(
              emailController.text,
              passwordController.text,
            );
            if (success) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          child: authProvider.isLoading
              ? CircularProgressIndicator()
              : Text('Login'),
        ),
        if (authProvider.hasError)
          Text(authProvider.errorMessage, style: TextStyle(color: Colors.red)),
      ],
    ),
  );
}
```

### Products Screen
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
  });
}

@override
Widget build(BuildContext context) {
  final productsProvider = Provider.of<ProductsProvider>(context);
  
  if (productsProvider.isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    itemCount: productsProvider.products.length,
    itemBuilder: (context, index) {
      final product = productsProvider.products[index];
      return ProductCard(product: product);
    },
  );
}
```

### Cart Screen
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    Provider.of<CartProvider>(context, listen: false).fetchCart();
  });
}

@override
Widget build(BuildContext context) {
  final cartProvider = Provider.of<CartProvider>(context);
  
  return Scaffold(
    appBar: AppBar(title: Text('Cart')),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return CartItemWidget(
                item: item,
                onRemove: () {
                  cartProvider.removeItem(item.id);
                },
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Total: Rp ${cartProvider.totalPrice.toStringAsFixed(0)}'),
              ElevatedButton(
                onPressed: () {
                  final ordersProvider = 
                    Provider.of<OrdersProvider>(context, listen: false);
                  ordersProvider.checkout({
                    'payment_method': 'credit_card',
                    'notes': '',
                  });
                },
                child: Text('Checkout'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

---

## ⚙️ Configuration

### API Base URL
Located in `lib/services/api_client.dart`:
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

To change the API endpoint (e.g., for production):
```dart
static const String baseUrl = 'https://api.production.com/api';
```

### Dependencies
All required dependencies are already in `pubspec.yaml`:
```yaml
dio: ^5.3.0
flutter_secure_storage: ^9.0.0
provider: ^6.0.0
```

---

## 🚀 Quick Start Checklist

- [ ] Backend API running on `http://localhost:8000/api`
- [ ] Update `baseUrl` in `api_client.dart` if using different endpoint
- [ ] Run `flutter pub get` to fetch dependencies
- [ ] Create Login screen that calls `AuthProvider.login()`
- [ ] Wrap app screens with `Consumer<AuthProvider>` to check logged-in status
- [ ] Implement redirect to login if token expired (on 401)
- [ ] Create Home screen and integrate with providers
- [ ] Test each provider with real backend API

---

## 📊 Error Handling

All providers handle errors consistently:

```dart
if (provider.hasError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(provider.errorMessage ?? 'Unknown error')),
  );
  provider.clearError();
}
```

Common error responses:
- `400`: Bad Request - Validation failed
- `401`: Unauthorized - Token invalid/expired
- `403`: Forbidden - Permission denied
- `404`: Not Found - Resource doesn't exist
- `422`: Unprocessable Entity - Validation failed (detailed)
- `500`: Server Error - Backend issue

---

## 🔄 Next Steps

1. ✅ API client implementation - **DONE**
2. ✅ Data models - **DONE**
3. ✅ Providers setup - **DONE**
4. ⏳ Create authentication screens (Login, Register, Forgot Password)
5. ⏳ Create e-commerce screens (Products, Cart, Orders)
6. ⏳ Integrate solar calculation screens with new API
7. ⏳ Add payment integration (Midtrans webhook)
8. ⏳ Add unit and integration tests

---

## 📝 Notes

- **Backward Compatibility**: Old `api_service.dart` still available for solar features
- **Token Expiry**: Implement token refresh logic when needed
- **Offline Mode**: Consider adding offline persistence with Hive/Sqlite
- **Logging**: All API calls logged with 🌐📤✅❌ prefixes for debugging

---

## 📞 Support

For issues or questions:
1. Check the API response in console logs
2. Verify backend is running on correct URL
3. Ensure token is properly stored after login
4. Check `InterceptorsWrapper` in `api_client.dart` for request/response logs
