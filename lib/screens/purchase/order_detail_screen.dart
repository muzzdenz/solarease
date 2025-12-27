import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await _orderService.getOrderDetail(widget.orderId);
      if (!mounted) return;

      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Sedang Diproses';
      case 'completed':
        return 'Pesanan Selesai';
      case 'cancelled':
        return 'Pesanan Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Detail Pesanan',
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
                        onPressed: _loadOrderDetail,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _order == null
                  ? const Center(child: Text('Pesanan tidak ditemukan'))
                  : RefreshIndicator(
                      onRefresh: _loadOrderDetail,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOrderInfo(isDark),
                            const SizedBox(height: 16),
                            _buildShippingInfo(isDark),
                            const SizedBox(height: 16),
                            _buildOrderItems(isDark),
                            const SizedBox(height: 16),
                            _buildPriceSummary(isDark),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildOrderInfo(bool isDark) {
    final orderNumber = _order!['order_number']?.toString() ?? 'N/A';
    final status = _order!['status']?.toString() ?? 'pending';
    final createdAt = _order!['created_at']?.toString() ?? '';

    String dateStr = '';
    try {
      final date = DateTime.parse(createdAt);
      dateStr = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      dateStr = createdAt;
    }

    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nomor Pesanan', orderNumber, isDark),
          const SizedBox(height: 8),
          _buildInfoRow('Tanggal', dateStr, isDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(bool isDark) {
    final shippingAddress = _order!['shipping_address']?.toString() ?? '-';
    final notes = _order!['notes']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            shippingAddress,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Catatan:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notes,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItems(bool isDark) {
    final items = _order!['items'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildOrderItem(item, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item, bool isDark) {
    final product = item['product'] as Map<String, dynamic>? ?? {};
    final name = product['name']?.toString() ?? 'Product';
    final quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
    final price = int.tryParse(item['price']?.toString() ?? '0') ?? 0;
    final subtotal = int.tryParse(item['subtotal']?.toString() ?? '0') ?? 0;

    final priceStr = 'Rp ${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
    final subtotalStr = 'Rp ${subtotal.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2C5F6F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.solar_power,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$priceStr x $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.6)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtotalStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(bool isDark) {
    final total = int.tryParse(_order!['total']?.toString() ?? '0') ?? 0;
    final totalStr = 'Rp ${total.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';

    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
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
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppTheme.darkText2.withOpacity(0.6)
                : Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
          ),
        ),
      ],
    );
  }
}
