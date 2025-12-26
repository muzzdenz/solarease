import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/purchase.dart';
import '../../services/purchase_service.dart';
import '../../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final _purchaseService = PurchaseService();
  late Future<List<Purchase>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    _purchasesFuture = _purchaseService.getPurchaseHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Riwayat Pembelian',
          style: TextStyle(
            color: isDark ? AppTheme.darkText2 : Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppTheme.darkText2 : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Purchase>>(
        future: _purchasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGold,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan',
                style: TextStyle(
                  color: isDark ? AppTheme.darkText2 : Colors.black,
                ),
              ),
            );
          }

          final purchases = snapshot.data ?? [];

          if (purchases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.3)
                        : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pembelian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkText2.withOpacity(0.6)
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai jelajahi paket layanan kami',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.darkText2.withOpacity(0.5)
                          : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Lihat Paket Layanan',
                    onPressed: () {
                      Navigator.pushNamed(context, '/service_plans');
                    },
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              return _buildPurchaseCard(
                context,
                purchases[index],
                isDark,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPurchaseCard(
    BuildContext context,
    Purchase purchase,
    bool isDark,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    final formattedDate = dateFormat.format(purchase.purchaseDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppTheme.darkDivider
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showPurchaseDetail(context, purchase, isDark);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchase.planName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkText2
                                  : AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            purchase.invoiceNumber,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.darkText2.withOpacity(0.5)
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: purchase.status == 'completed'
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        purchase.status == 'completed' ? 'Selesai' : 'Tertunda',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: purchase.status == 'completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: isDark ? AppTheme.darkDivider : Colors.grey.shade200,
                  height: 1,
                ),
                const SizedBox(height: 12),
                // Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.darkText2.withOpacity(0.6)
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.darkText2
                                : AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kuantitas',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.darkText2.withOpacity(0.6)
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${purchase.quantity}x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.darkText2
                                : AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.darkText2.withOpacity(0.6)
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${purchase.grandTotal}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseDetail(
    BuildContext context,
    Purchase purchase,
    bool isDark,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    final formattedDate = dateFormat.format(purchase.purchaseDate);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Pembelian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.darkText2
                            : AppTheme.darkText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: isDark
                            ? AppTheme.darkText2
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  isDark,
                  'Paket',
                  purchase.planName,
                ),
                _buildDetailRow(
                  isDark,
                  'Kategori',
                  purchase.planCategory,
                ),
                _buildDetailRow(
                  isDark,
                  'Invoice',
                  purchase.invoiceNumber,
                ),
                _buildDetailRow(
                  isDark,
                  'Tanggal',
                  formattedDate,
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? AppTheme.darkDivider : Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                Text(
                  'Rincian Harga',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.darkText2
                        : AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  isDark,
                  'Harga per Unit',
                  'Rp ${purchase.pricePerUnit}',
                ),
                _buildDetailRow(
                  isDark,
                  'Kuantitas',
                  '${purchase.quantity}x',
                ),
                _buildDetailRow(
                  isDark,
                  'Subtotal',
                  'Rp ${purchase.totalPrice}',
                ),
                _buildDetailRow(
                  isDark,
                  'Pajak (10%)',
                  'Rp ${purchase.tax}',
                ),
                const SizedBox(height: 8),
                Divider(
                  color: isDark ? AppTheme.darkDivider : Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  isDark,
                  'Total',
                  'Rp ${purchase.grandTotal}',
                  isBold: true,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  isDark,
                  'Metode Pembayaran',
                  purchase.paymentMethod,
                ),
                _buildDetailRow(
                  isDark,
                  'Status',
                  purchase.status == 'completed' ? 'Selesai' : 'Tertunda',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.darkText2
                                : AppTheme.darkText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _deletePurchase(purchase.id);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Hapus'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    bool isDark,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isDark
                  ? AppTheme.darkText2.withOpacity(isBold ? 1 : 0.7)
                  : (isBold ? Colors.black : Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppTheme.primaryGold : (isDark ? AppTheme.darkText2 : AppTheme.darkText),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePurchase(String id) async {
    await _purchaseService.deletePurchase(id);
    setState(() {
      _purchasesFuture = _purchaseService.getPurchaseHistory();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat pembelian dihapus'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
