import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/cart_service.dart';
import '../../config/routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  String? _error;
  int _totalPrice = 0;

  String _formatRupiah(int amount) {
    final s = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $s';
  }

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadCart();
  }

  Future<void> _checkAuthAndLoadCart() async {
    // Check if user is authenticated
    final token = await _cartService.getToken();
    if (token == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await _cartService.getCartSummary();
      final items = await _cartService.getCartItems();

      if (!mounted) return;

      setState(() {
        _cartItems = items;
        final totalRaw = summary['total']?.toString() ?? '0';
        final totalDouble = double.tryParse(totalRaw) ?? 0.0;
        _totalPrice = totalDouble.round();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      // Handle authentication error
      if (e.toString().contains('Unauthenticated') || e.toString().contains('401')) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _incrementItem(int cartId) async {
    try {
      await _cartService.incrementItem(cartId);
      _loadCart();
    } catch (e) {
      _showError('Gagal menambah jumlah: $e');
    }
  }

  Future<void> _decrementItem(int cartId) async {
    try {
      await _cartService.decrementItem(cartId);
      _loadCart();
    } catch (e) {
      _showError('Gagal mengurangi jumlah: $e');
    }
  }

  Future<void> _removeItem(int cartId) async {
    try {
      await _cartService.removeItem(cartId);
      _loadCart();
      _showSuccess('Item dihapus dari keranjang');
    } catch (e) {
      _showError('Gagal menghapus item: $e');
    }
  }

  Future<void> _clearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Yakin ingin menghapus semua item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _cartService.clearCart();
        _loadCart();
        _showSuccess('Keranjang dikosongkan');
      } catch (e) {
        _showError('Gagal mengosongkan keranjang: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _checkout() {
    if (_cartItems.isEmpty) {
      _showError('Keranjang masih kosong');
      return;
    }
    Navigator.pushNamed(context, AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: isDark ? AppTheme.darkText2 : Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.darkText2 : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: isDark ? AppTheme.darkText2 : Colors.black87,
              ),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCart,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 100,
                            color: isDark
                                ? AppTheme.darkText2.withOpacity(0.3)
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Keranjang Kosong',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yuk, mulai belanja panel solar!',
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.darkText2.withOpacity(0.6)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGold,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                            ),
                            child: const Text(
                              'Mulai Belanja',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              return _buildCartItem(_cartItems[index], isDark);
                            },
                          ),
                        ),
                        _buildBottomBar(isDark),
                      ],
                    ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, bool isDark) {
    final cartId = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
    final product = item['product'] as Map<String, dynamic>? ?? {};
    final name = product['name']?.toString() ?? 'Product';
    final priceRaw = product['price']?.toString() ?? '0';
    final priceDouble = double.tryParse(priceRaw) ?? 0.0;
    final price = priceDouble.round();
    final quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
    final subtotal = (priceDouble * quantity).round();

    final priceStr = _formatRupiah(price);
    final subtotalStr = _formatRupiah(subtotal);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Product Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2C5F6F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.solar_power,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  priceStr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkText2.withOpacity(0.3)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1 ? () => _decrementItem(cartId) : null,
                            icon: const Icon(Icons.remove, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _incrementItem(cartId),
                            icon: const Icon(Icons.add, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      subtotalStr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Delete Button
          IconButton(
            onPressed: () => _removeItem(cartId),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final totalStr = _formatRupiah(_totalPrice);
    final itemCount = _cartItems.fold<int>(0, (sum, it) => sum + (int.tryParse(it['quantity']?.toString() ?? '0') ?? 0));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$itemCount item',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkText2.withOpacity(0.7) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Text(
                  totalStr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
