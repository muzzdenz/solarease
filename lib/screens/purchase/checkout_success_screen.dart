import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/ui_kit.dart';
import '../../config/routes.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final String shippingAddress;
  final String phone;

  const CheckoutSuccessScreen({
    Key? key,
    required this.items,
    required this.totalPrice,
    required this.shippingAddress,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Checkout Berhasil',
          style: TextStyle(
            color: isDark ? AppTheme.darkText2 : Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? AppTheme.darkText2 : Colors.black87),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Pesanan COD dibuat',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan siapkan pembayaran di tempat saat paket diantar. Tim kami akan menghubungi Anda untuk konfirmasi.',
                        style: TextStyle(color: isDark ? AppTheme.darkText2.withOpacity(0.7) : Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const SectionTitle(title: 'Ringkasan Pesanan', icon: Icons.receipt_long),
                AppCard(
                  child: Column(
                    children: [
                      ...items.map((it) {
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
                                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              Text('x$qty'),
                              const SizedBox(width: 8),
                              Text(formatRupiah(subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(formatRupiah(totalPrice), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryGold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SectionTitle(title: 'Alamat & Kontak', icon: Icons.location_on),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [const Icon(Icons.home_outlined), const SizedBox(width: 8), Expanded(child: Text(shippingAddress))]),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.phone_outlined), const SizedBox(width: 8), Text(phone)]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                      icon: const Icon(Icons.home),
                      label: const Text('Beranda'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.orders, arguments: {'shouldRefresh': true});
                      },
                      icon: const Icon(Icons.list_alt, color: Colors.white),
                      label: const Text('Lihat Pesanan'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
