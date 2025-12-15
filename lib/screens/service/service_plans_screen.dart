import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/service_plan.dart';
import '../../widgets/service_plan_card.dart';
import 'service_plan_detail_screen.dart';

class ServicePlansScreen extends StatefulWidget {
  const ServicePlansScreen({Key? key}) : super(key: key);

  @override
  State<ServicePlansScreen> createState() => _ServicePlansScreenState();
}

class _ServicePlansScreenState extends State<ServicePlansScreen> {
  List<ServicePlan> _plans = [];
  bool _isLoading = true;
  String? _error;
  final filters = [
    'Semua',
    'Terlaris',
    'On-Grid',
    'Hybrid',
    'Garansi panjang',
    'Kustom'
  ];
  String activeFilter = 'Semua';
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _plans.where((p) {
      final matchQuery =
          query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
      bool matchFilter = true;
      switch (activeFilter) {
        case 'Terlaris':
          matchFilter = p.badge == 'Terlaris' || p.rating >= 4.7;
          break;
        case 'On-Grid':
        case 'Hybrid':
        case 'Kustom':
          matchFilter = p.category == activeFilter || p.badge == activeFilter;
          break;
        case 'Garansi panjang':
          matchFilter = p.warranty.toLowerCase().contains('garansi');
          break;
        default:
          matchFilter = true;
      }
      return matchQuery && matchFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'Paket Solar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                  colors: [
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
              children: const [
                Text('Pilih paket sesuai kebutuhan',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                    'Bandingkan harga, fitur, dan garansi seperti di marketplace.',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (c) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  selected: activeFilter == c,
                  backgroundColor: Colors.white,
                  checkmarkColor: AppTheme.primaryGold,
                  selectedColor: AppTheme.primaryGold.withOpacity(0.18),
                  label: Text(
                    c,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: activeFilter == c
                          ? AppTheme.primaryGold
                          : AppTheme.darkText,
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
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari paket atau fitur...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (val) => setState(() => query = val),
    );
  }

  Widget _buildListSection(List<ServicePlan> filtered) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gagal memuat paket',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(_error!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _loadPlans,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Center(
                child: Text('Tidak ada paket yang cocok'),
              ),
            )
          : Column(
              key: const ValueKey('list'),
              children: filtered
                  .map(
                    (plan) => ServicePlanCard(
                      plan: plan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServicePlanDetailScreen(plan: plan),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final data = ServicePlan.getPlans();
      if (!mounted) return;
      setState(() {
        _plans = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat data.';
        _isLoading = false;
      });
    }
  }
}
