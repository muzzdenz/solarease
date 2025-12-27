// QUICK REFERENCE: Using Backend API in Your Screens
// Copy and paste these snippets to start using the API

// ============================================================
// 1. LOGIN SCREEN
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_providers.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
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
                ),
                if (authProvider.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      authProvider.errorMessage ?? 'Login failed',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

// ============================================================
// 2. PRODUCTS LIST SCREEN
// ============================================================
class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when screen loads
    Future.microtask(() {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, _) {
          if (productsProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (productsProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(productsProvider.errorMessage ?? 'Error'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productsProvider.fetchProducts(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: productsProvider.products.length,
            itemBuilder: (context, index) {
              final product = productsProvider.products[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            color: Colors.grey[300],
            child: product.image != null
                ? Image.network(product.image!, fit: BoxFit.cover)
                : Icon(Icons.image),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    cartProvider.addToCart(product.id, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to cart')),
                    );
                  },
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3. CART SCREEN
// ============================================================
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (cartProvider.items.isEmpty) {
            return Center(
              child: Text('Cart is empty'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text(
                        'Rp ${item.subtotal.toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onLongPress: () {
                        cartProvider.removeItem(item.id);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide()),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:'),
                        Text(
                          'Rp ${cartProvider.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<OrdersProvider>(context, listen: false)
                              .checkout({
                            'payment_method': 'credit_card',
                            'notes': '',
                          });
                          Navigator.pushNamed(context, '/checkout');
                        },
                        child: Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// 4. ORDERS HISTORY SCREEN
// ============================================================
class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, _) {
          if (ordersProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (ordersProvider.orders.isEmpty) {
            return Center(
              child: Text('No orders yet'),
            );
          }

          return ListView.builder(
            itemCount: ordersProvider.orders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.orders[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Order #${order.invoiceNumber}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${order.status}'),
                      Text('Total: Rp ${order.total.toStringAsFixed(0)}'),
                      Text(order.createdAt.toString().split('.')[0]),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/order-detail',
                      arguments: order.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// 5. PROFILE SCREEN (using AuthProvider)
// ============================================================
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final user = authProvider.currentUser;
          if (user == null) {
            return Center(child: Text('Not logged in'));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.avatar != null
                    ? NetworkImage(user.avatar!)
                    : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Name'),
                subtitle: Text(user.name),
              ),
              ListTile(
                title: Text('Email'),
                subtitle: Text(user.email),
              ),
              ListTile(
                title: Text('Phone'),
                subtitle: Text(user.phone ?? 'Not set'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// 6. SAMPLE PROVIDER USAGE IN STATELESS WIDGET
// ============================================================
class BalanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Read provider without listening (one-time)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        // Make API call
        authProvider.getCurrentUser();
      },
      child: Consumer<AuthProvider>(
        // Listen to changes
        builder: (context, authProvider, _) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Logged in as:'),
                  Text(
                    authProvider.currentUser?.name ?? 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// 7. PROVIDER USAGE PATTERNS
// ============================================================
/*
PATTERN 1: Consumer with full rebuild
═════════════════════════════════════════════════════════════
Consumer<ProductsProvider>(
  builder: (context, provider, child) {
    return Text(provider.products.length.toString());
  },
)

PATTERN 2: Provider.of with listen:false (one-time)
═════════════════════════════════════════════════════════════
final provider = Provider.of<ProductsProvider>(context, listen: false);
await provider.fetchProducts();

PATTERN 3: Nested Consumers
═════════════════════════════════════════════════════════════
Consumer2<AuthProvider, CartProvider>(
  builder: (context, authProvider, cartProvider, _) {
    return Text('User: ${authProvider.currentUser?.name}, Cart items: ${cartProvider.itemCount}');
  },
)

PATTERN 4: Select specific property (rebuild only if changed)
═════════════════════════════════════════════════════════════
Selector<CartProvider, int>(
  selector: (context, cart) => cart.itemCount,
  builder: (context, itemCount, _) {
    return Badge(label: Text(itemCount.toString()));
  },
)
*/

// ============================================================
// 8. ERROR HANDLING PATTERN
// ============================================================
/*
try {
  final success = await provider.someMethod();
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Success!')),
    );
  } else if (provider.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? 'Error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unexpected error: $e')),
  );
}
*/

// ============================================================
// IMPORTS TO USE IN YOUR SCREENS
// ============================================================
/*
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'models/api_models.dart';
import 'providers/app_providers.dart';
*/

// ============================================================
// NAVIGATION SETUP IN main.dart routes
// ============================================================
/*
routes: {
  '/login': (context) => LoginScreen(),
  '/home': (context) => HomeScreen(),
  '/products': (context) => ProductsScreen(),
  '/cart': (context) => CartScreen(),
  '/orders': (context) => OrdersScreen(),
  '/profile': (context) => ProfileScreen(),
}
*/
