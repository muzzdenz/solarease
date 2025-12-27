import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import '../../services/cart_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ui_kit.dart';
import '../purchase/cart_screen.dart';

class ServicePlanDetailScreen extends StatefulWidget {
  final String productId;

  const ServicePlanDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ServicePlanDetailScreen> createState() => _ServicePlanDetailScreenState();
}

class _ServicePlanDetailScreenState extends State<ServicePlanDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  final CartService _cartService = CartService();
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.getProduct(int.parse(widget.productId));
      if (!mounted) return;

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _product = response['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message']?.toString() ?? 'Gagal memuat data';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    // Check if user is authenticated
    final token = await _apiClient.getToken();
    if (token == null) {
      if (!mounted) return;
      
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text('Anda harus login untuk menambahkan produk ke keranjang.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      if (shouldLogin == true) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final productId = int.parse(_product!['id']?.toString() ?? '0');
      await _cartService.addToCart(productId: productId, quantity: 1);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produk ditambahkan ke keranjang'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Lihat',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Gagal menambahkan ke keranjang';
      if (e.toString().contains('Unauthenticated')) {
        errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else {
        errorMessage = 'Gagal menambahkan ke keranjang: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark ? AppTheme.darkText2 : Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark ? AppTheme.darkText2 : Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProductDetail,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final name = product['name']?.toString() ?? '';
    final description = product['description']?.toString() ?? '';
    final efficiency = double.tryParse(product['efficiency']?.toString() ?? '0') ?? 0.0;
    final powerOutput = int.tryParse(product['power_output']?.toString() ?? '0') ?? 0;
    final priceDouble = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
    final price = priceDouble.round();
    final stock = int.tryParse(product['stock']?.toString() ?? '0') ?? 0;
    
    final priceStr = formatRupiah(price);
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppTheme.darkText2 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.favorite_border,
                color: isDark ? AppTheme.darkText2 : Colors.black87),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 12),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C5F6F),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Hero(
                      tag: 'plan-icon-${product['id']}',
                      child: const Icon(
                        Icons.solar_power,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 16, color: AppTheme.primaryGold),
                            SizedBox(width: 6),
                            Text('${powerOutput}W',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                size: 16, color: AppTheme.primaryGold),
                            SizedBox(width: 6),
                            Text('Sertifikasi PLN',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priceStr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InfoChip(label: '${efficiency}% Efisiensi', icon: Icons.speed),
                      const SizedBox(width: 8),
                      InfoChip(
                        label: 'Stok: $stock',
                        icon: Icons.inventory_2,
                        color: stock > 0 ? const Color(0xFF4CAF50) : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(context, 'Deskripsi', description),
                          const SizedBox(height: 16),
                          _buildSpecsGrid(context, efficiency, powerOutput, stock),
                          const SizedBox(height: 24),
                          _BenefitList(isDark: isDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: _isAddingToCart ? 'Menambahkan...' : 'Tambah ke Keranjang',
                    onPressed: _isAddingToCart ? null : _addToCart,
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: 'Lihat Keranjang',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Butuh konsultasi? Hubungi kami',
                      style: TextStyle(
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppTheme.darkText2.withOpacity(0.7) : Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsGrid(BuildContext context, double efficiency, int powerOutput, int stock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spesifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecRow(
            icon: Icons.bolt,
            label: 'Daya Output',
            value: '${powerOutput}W',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildSpecRow(
            icon: Icons.electric_bolt,
            label: 'Efisiensi',
            value: '$efficiency%',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildSpecRow(
            icon: Icons.inventory_2,
            label: 'Stok Tersedia',
            value: stock.toString(),
            isDark: isDark,
            valueColor: stock > 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryGold,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkText2.withOpacity(0.7)
                  : Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? (isDark ? AppTheme.darkText2 : AppTheme.darkText),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryGold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _BenefitList extends StatelessWidget {
  final bool isDark;
  
  const _BenefitList({required this.isDark});
  
  @override
  Widget build(BuildContext context) {
    final benefits = [
      'Gratis survei dan instalasi standar',
      'Monitoring performa via aplikasi',
      'Dukungan teknis 24/7',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kenapa pilih paket ini?',
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 16,
            color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 10),
        ...benefits.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGold.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.check,
                      size: 16, color: AppTheme.primaryGold),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _FeatureWrap extends StatelessWidget {
  const _FeatureWrap({required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Termasuk dalam paket',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: features
              .map(
                (f) => Chip(
                  label: Text(
                    f,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppTheme.primaryGold.withOpacity(0.14),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
