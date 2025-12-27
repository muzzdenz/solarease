// Auth Models
class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final DateTime? createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: data?['token'] as String?,
      user: data?['user'] != null
          ? User.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

// Product Models
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String? sku;
  final int stock;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.sku,
    required this.stock,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      sku: json['sku'] as String?,
      stock: json['stock'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

class ProductsResponse {
  final bool success;
  final String message;
  final List<Product> data;
  final PaginationMeta? meta;

  ProductsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List?)
            ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return ProductsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: dataList,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
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

// Cart Models
class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String productImage;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.productImage,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      productImage: json['product_image'] as String,
    );
  }
}

class CartResponse {
  final bool success;
  final String message;
  final List<CartItem> items;
  final double totalPrice;

  CartResponse({
    required this.success,
    required this.message,
    required this.items,
    required this.totalPrice,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final itemsList = (data['items'] as List?)
            ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return CartResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      items: itemsList,
      totalPrice: (data['total_price'] as num).toDouble(),
    );
  }
}

// Order Models
class Order {
  final int id;
  final String invoiceNumber;
  final double totalAmount;
  final String status; // pending, paid, shipped, delivered, cancelled
  final DateTime orderDate;
  final DateTime? paidDate;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.paidDate,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Order(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'] as String)
          : null,
      items: itemsList,
    );
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

class OrdersResponse {
  final bool success;
  final String message;
  final List<Order> data;
  final PaginationMeta? meta;

  OrdersResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List?)
            ?.map((item) => Order.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return OrdersResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: dataList,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}
