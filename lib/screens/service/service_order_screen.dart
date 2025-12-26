import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/service_plan.dart';
import '../../models/purchase.dart';
import '../../widgets/custom_button.dart';
import '../../services/purchase_service.dart';
import 'dart:async';

class ServiceOrderScreen extends StatefulWidget {
  final ServicePlan plan;

  const ServiceOrderScreen({Key? key, required this.plan}) : super(key: key);

  @override
  State<ServiceOrderScreen> createState() => _ServiceOrderScreenState();
}

class _ServiceOrderScreenState extends State<ServiceOrderScreen> {
  int quantity = 1;
  String selectedPayment = 'Credit Card';
  final _purchaseService = PurchaseService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Parse price from string format "Rp X,X jt" or similar
    int priceValue = _parsePriceToInt(widget.plan.price);
    final total = priceValue * quantity;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Konfirmasi Pesanan',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Summary
            _buildProductCard(isDark),
            const SizedBox(height: 20),
            // Quantity Selector
            _buildQuantitySelector(isDark),
            const SizedBox(height: 20),
            // Features List
            _buildFeaturesList(isDark),
            const SizedBox(height: 20),
            // Payment Method
            _buildPaymentMethod(isDark),
            const SizedBox(height: 24),
            // Price Breakdown
            _buildPriceBreakdown(isDark, total),
            const SizedBox(height: 32),
            // Order Button
            CustomButton(
              label: 'Lanjutkan ke Pembayaran',
              onPressed: () {
                _showOrderConfirmation(context, total);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: BorderSide(
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.plan.badge,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            widget.plan.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            widget.plan.category,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.darkText2.withOpacity(0.6)
                  : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${widget.plan.rating} (${widget.plan.reviews} reviews)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.darkText2.withOpacity(0.6)
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Jumlah Paket',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppTheme.darkDivider : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                  color: AppTheme.primaryGold,
                ),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      quantity.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => setState(() => quantity++),
                  color: AppTheme.primaryGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitur Unggulan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...(widget.plan.features)
              .take(3)
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkText2.withOpacity(0.7)
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(bool isDark) {
    final methods = ['Credit Card', 'Bank Transfer', 'E-Wallet'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...methods.map((method) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  method,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                  ),
                ),
                value: method,
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value!);
                },
                activeColor: AppTheme.primaryGold,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(bool isDark, int total) {
    final subtotal = _parsePriceToInt(widget.plan.price);
    final tax = (total * 0.1).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            isDark,
            'Subtotal',
            'Rp ${subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            isDark,
            'Pajak (10%)',
            'Rp ${tax.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? AppTheme.darkDivider : Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            isDark,
            'Total',
            'Rp ${(total + tax).toStringAsFixed(0)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    bool isDark,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppTheme.primaryGold : Colors.black54,
          ),
        ),
      ],
    );
  }

  void _showOrderConfirmation(BuildContext context, int total) async {
    final subtotal = _parsePriceToInt(widget.plan.price) * quantity;
    final tax = (subtotal * 0.1).toInt();
    final grandTotal = subtotal + tax;

    // Create Purchase object
    final purchase = Purchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      planName: widget.plan.name,
      planCategory: widget.plan.category,
      quantity: quantity,
      pricePerUnit: _parsePriceToInt(widget.plan.price),
      totalPrice: subtotal,
      tax: tax,
      grandTotal: grandTotal,
      paymentMethod: selectedPayment,
      status: 'completed',
      purchaseDate: DateTime.now(),
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
    );

    // Save purchase to service
    await _purchaseService.savePurchase(purchase);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor:
              isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pesanan Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Invoice: ${purchase.invoiceNumber}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkText2.withOpacity(0.6) : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: Rp ${(grandTotal).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGold,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Lihat Riwayat Pembelian',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/purchase_history');
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _parsePriceToInt(String priceStr) {
    // Parse "Rp X,X jt" or "Rp X jt" format to integer
    if (priceStr.toLowerCase().contains('hubungi')) {
      return 0;
    }
    try {
      // Remove "Rp " and " jt"
      String cleaned = priceStr.replaceAll('Rp', '').replaceAll('jt', '').trim();
      // Replace comma with empty string for parsing
      cleaned = cleaned.replaceAll(',', '');
      // Convert to integer (in millions)
      double value = double.parse(cleaned);
      return (value * 1000000).toInt();
    } catch (e) {
      return 0;
    }
  }
}
