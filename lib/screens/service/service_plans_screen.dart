import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/ui_kit.dart';
import '../../services/api_client.dart';
import 'service_plan_detail_screen.dart';

class ServicePlansScreen extends StatefulWidget {
  const ServicePlansScreen({Key? key}) : super(key: key);

  @override
  State<ServicePlansScreen> createState() => _ServicePlansScreenState();
}

class _ServicePlansScreenState extends State<ServicePlansScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _error;
  final filters = ['Semua', 'Efisiensi', 'Daya Tinggi', 'Harga Terjangkau'];
  String activeFilter = 'Semua';
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) {
      final name = p['name']?.toString() ?? '';
      final efficiency = double.tryParse(p['efficiency']?.toString() ?? '0') ?? 0.0;
      final powerOutput = int.tryParse(p['power_output']?.toString() ?? '0') ?? 0;
      final price = int.tryParse(p['price']?.toString() ?? '0') ?? 0;
      final matchQuery =
          query.isEmpty || name.toLowerCase().contains(query.toLowerCase());
      bool matchFilter = true;
      switch (activeFilter) {
        case 'Efisiensi':
          matchFilter = efficiency >= 20.0;
          break;
        case 'Daya Tinggi':
          matchFilter = powerOutput >= 150;
          break;
        case 'Harga Terjangkau':
          matchFilter = price <= 1800000;
          break;
        default:
          matchFilter = true;
      }
      return matchQuery && matchFilter;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Paket Solar',
          style: TextStyle(
              color: isDark ? AppTheme.darkText2 : Colors.black,
              fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppTheme.darkText2 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppTheme.primaryGold.withOpacity(0.3),
                          AppTheme.darkCard.withOpacity(0.5)
                        ]
                      : [
                          AppTheme.primaryGold.withOpacity(0.9),
                          const Color(0xFFF9E7D2)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildHero(),
                const SizedBox(height: 14),
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildFilterRow(),
                const SizedBox(height: 14),
                _buildListSection(filtered),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag,
                color: AppTheme.primaryGold, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih paket sesuai kebutuhan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
                const SizedBox(height: 6),
                Text(
                    'Bandingkan harga, fitur, dan garansi seperti di marketplace.',
                    style: TextStyle(
                        color: isDark
                            ? AppTheme.darkText2.withOpacity(0.6)
                            : Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (c) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  selected: activeFilter == c,
                  backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                  checkmarkColor: AppTheme.primaryGold,
                  selectedColor: AppTheme.primaryGold.withOpacity(0.18),
                  label: Text(
                    c,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: activeFilter == c
                          ? AppTheme.primaryGold
                          : (isDark ? AppTheme.darkText2 : AppTheme.darkText),
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => activeFilter = c);
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      style: TextStyle(color: isDark ? AppTheme.darkText2 : AppTheme.darkText),
      decoration: InputDecoration(
        hintText: 'Cari paket atau fitur...',
        hintStyle: TextStyle(
            color: isDark
                ? AppTheme.darkText2.withOpacity(0.5)
                : Colors.grey),
        prefixIcon: Icon(Icons.search,
            color: isDark ? AppTheme.darkText2 : Colors.grey),
        filled: true,
        fillColor: isDark ? AppTheme.darkCard : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (val) => setState(() => query = val),
    );
  }

  Widget _buildListSection(List<Map<String, dynamic>> filtered) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gagal memuat paket',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
            const SizedBox(height: 6),
            Text(_error!,
                style: TextStyle(
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.6)
                        : Colors.black54)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _loadProducts,
              child: const Text('Coba lagi'),
            )
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: filtered.isEmpty
          ? Container(
              key: const ValueKey('empty'),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Center(
                child: Text('Tidak ada paket yang cocok',
                    style: TextStyle(
                        color:
                            isDark ? AppTheme.darkText2 : AppTheme.darkText)),
              ),
            )
          : Column(
              key: const ValueKey('list'),
              children: filtered
                  .map((product) => _buildProductCard(product, isDark))
                  .toList(),
            ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    final id = product['id']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'Solar Panel';
    final description = product['description']?.toString() ?? '';
    final efficiency = double.tryParse(product['efficiency']?.toString() ?? '0') ?? 0.0;
    final powerOutput = int.tryParse(product['power_output']?.toString() ?? '0') ?? 0;
    final priceDouble = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
    final price = priceDouble.round();
    final stock = int.tryParse(product['stock']?.toString() ?? '0') ?? 0;
    
    // Determine badge based on efficiency or power output
    String badge = '';
    Color badgeColor = AppTheme.primaryGold;
    if (efficiency >= 21.0) {
      badge = 'High Eff';
      badgeColor = const Color(0xFFFF6B35);
    } else if (powerOutput >= 150) {
      badge = 'High Power';
      badgeColor = const Color(0xFF4ECDC4);
    } else {
      badge = 'Standard';
      badgeColor = AppTheme.primaryGold;
    }
    
    final priceStr = 'Rp ${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';

    return AppCard(
      child: InkWell(
        onTap: () {
          // Navigate to detail screen with product ID
          if (id.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServicePlanDetailScreen(productId: id),
              ),
            );
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2C5F6F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.solar_power,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(children: [
                              InfoChip(label: '$efficiency%', icon: Icons.speed),
                              const SizedBox(width: 8),
                              InfoChip(label: '${powerOutput}W', icon: Icons.bolt),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatRupiah(price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.darkText2.withOpacity(0.7)
                          : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock: $stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: stock > 0
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                        ),
                      ),
                      Row(children: [
                        TextButton.icon(
                          onPressed: () {
                            if (id.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServicePlanDetailScreen(productId: id),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Detail'),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ])
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.getProducts(page: 1, perPage: 50);
      if (!mounted) return;
      
      // Debug: print response untuk lihat struktur
      print('📦 Products Response: $response');
      
      List<Map<String, dynamic>> products = [];
      
      // Handle berbagai format response
      dynamic listData;
      
      if (response is List) {
        // Format: [...]
        listData = response;
      } else if (response is Map<String, dynamic>) {
        // Coba ambil dari response['data'] dulu (format Laravel standard)
        final data = response['data'];
        
        if (data is List) {
          // Format: {data: [...]}
          listData = data;
        } else if (data is Map && data['data'] is List) {
          // Format: {data: {data: [...], meta: ...}} (paginated)
          listData = data['data'];
        }
      }
      
      if (listData is List) {
        products = List<Map<String, dynamic>>.from(listData);
      }
      
      print('✅ Parsed ${products.length} products');
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
      
    } catch (e, stackTrace) {
      print('❌ Error loading products: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
