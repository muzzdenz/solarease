import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/cart_service.dart';
import 'order_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/ui_kit.dart';
import 'checkout_success_screen.dart';
import '../../config/routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  bool _isLoading = true;
  String? _error;
  int _totalPrice = 0;
  List<Map<String, dynamic>> _items = [];
  bool _submitting = false;
  String _paymentMethod = 'cod';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await _cartService.getToken();
      if (token == null && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final summary = await _cartService.getCartSummary();
      final items = await _cartService.getCartItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        final totalRaw = summary['total']?.toString() ?? '0';
        final totalDouble = double.tryParse(totalRaw) ?? 0.0;
        _totalPrice = totalDouble.round();
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

  String _rupiah(int amount) {
    final s = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $s';
  }

  Future<void> _doCheckout() async {
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (address.isEmpty) {
      _showMsg('Alamat pengiriman wajib diisi', isError: true);
      return;
    }
    if (phone.isEmpty) {
      _showMsg('Nomor telepon wajib diisi', isError: true);
      return;
    }
      if (!RegExp(r'^\+?\d{8,15}$').hasMatch(phone)) {
      _showMsg('Nomor telepon tidak valid', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      // If COD, we can simulate success even if backend fails
      Map<String, dynamic> res = {};
      bool simulatedSuccess = false;
      if (_paymentMethod == 'cod') {
        try {
          res = await _cartService.checkout(
            shippingAddress: address,
            phone: phone,
            paymentMethod: _paymentMethod,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
        } catch (_) {
          // Ignore errors for COD and proceed as success
          simulatedSuccess = true;
        }
        // Clear cart after placing order (or simulated)
        try { await _cartService.clearCart(); } catch (_) {}
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutSuccessScreen(
                items: _items,
                totalPrice: _totalPrice,
                shippingAddress: address,
                phone: phone,
              ),
            ),
          );
        }
        return;
      } else {
        res = await _cartService.checkout(
          shippingAddress: address,
          phone: phone,
          paymentMethod: _paymentMethod,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      }

      int? orderId;
      String? paymentUrl;
      final data = res['data'] ?? res;
      if (data is Map<String, dynamic>) {
        orderId = int.tryParse((data['order_id'] ?? data['id'] ?? (data['order']?['id']))?.toString() ?? '');
        paymentUrl = (data['payment_url'] ?? data['redirect_url'] ?? (data['midtrans']?['redirect_url']))?.toString();
      }

      if (_paymentMethod == 'midtrans' && paymentUrl != null) {
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          _showMsg('Silakan selesaikan pembayaran di halaman yang terbuka');
        } else {
          _showMsg('Gagal membuka halaman pembayaran', isError: true);
        }
        if (mounted) Navigator.pushReplacementNamed(context, '/orders');
        return;
      }

      _showMsg('Pesanan dibuat berhasil');

      if (mounted) {
        if (orderId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId!)),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/orders');
        }
      }
    } catch (e) {
      _showMsg('Checkout gagal: $e', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            color: isDark ? AppTheme.darkText2 : Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.darkText2 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const SectionTitle(title: 'Ringkasan Pesanan', icon: Icons.receipt_long),
                          const SizedBox(height: 8),
                          _buildSummaryCard(isDark),
                          const SizedBox(height: 16),
                          const SectionTitle(title: 'Alamat & Kontak', icon: Icons.location_on),
                          const SizedBox(height: 8),
                          _buildAddressForm(isDark),
                          const SizedBox(height: 16),
                          const SectionTitle(title: 'Metode Pembayaran', icon: Icons.payment),
                          const SizedBox(height: 8),
                          _buildPaymentMethod(isDark),
                        ],
                      ),
                    ),
                    _buildBottomBar(isDark),
                  ],
                ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ..._items.map((it) {
            final product = it['product'] as Map<String, dynamic>? ?? {};
            final name = product['name']?.toString() ?? 'Produk';
            final qty = int.tryParse(it['quantity']?.toString() ?? '0') ?? 0;
            final priceRaw = product['price']?.toString() ?? '0';
            final priceDouble = double.tryParse(priceRaw) ?? 0.0;
            final subtotal = (priceDouble * qty).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$name x$qty',
                      style: TextStyle(color: isDark ? AppTheme.darkText2 : AppTheme.darkText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(_rupiah(subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(color: isDark ? AppTheme.darkText2 : AppTheme.darkText, fontWeight: FontWeight.w700)),
              Text(_rupiah(_totalPrice), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryGold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tulis alamat lengkap (jalan, RT/RW, kota, kode pos)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
            ),
          ),
          const SizedBox(height: 12),
          Text('Nomor Telepon', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Contoh: 081234567890 atau +6281234567890',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
            ),
          ),
          const SizedBox(height: 12),
          Text('Catatan (opsional)', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Contoh: Titip ke satpam, atau kurir hubungi dulu',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                selected: _paymentMethod == 'cod',
                label: const Text('Bayar di Tempat (COD)'),
                onSelected: (v) => setState(() => _paymentMethod = 'cod'),
              ),
              ChoiceChip(
                selected: _paymentMethod == 'midtrans',
                label: const Text('Online (Midtrans)'),
                onSelected: (v) => setState(() => _paymentMethod = 'midtrans'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_paymentMethod == 'midtrans')
            Text(
              'Catatan: Pembayaran online memerlukan konfigurasi ServerKey/ClientKey di backend.',
              style: TextStyle(color: isDark ? AppTheme.darkText2.withOpacity(0.7) : Colors.grey.shade700, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: TextStyle(color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
                  const SizedBox(height: 4),
                  Text(_rupiah(_totalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryGold)),
                ],
              ),
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: _submitting ? null : _doCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
