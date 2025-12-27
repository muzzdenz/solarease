// CONTOH INTEGRASI API DI HOME SCREEN
// File: lib/screens/home/home_screen_example_with_api.dart
// 
// Ini adalah contoh bagaimana mengintegrasikan API ke HomeScreen
// yang sudah ada. Salin/adaptasi kode ini ke home_screen.dart Anda.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/solar_provider.dart';

class HomeScreenWithAPIExample extends StatefulWidget {
  const HomeScreenWithAPIExample({Key? key}) : super(key: key);

  @override
  State<HomeScreenWithAPIExample> createState() => _HomeScreenWithAPIExampleState();
}

class _HomeScreenWithAPIExampleState extends State<HomeScreenWithAPIExample> {
  String userPhone = '';
  int _selectedIndex = 0;
  bool _isLive = true;

  String get _formattedDate {
    final now = DateTime.now();
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}, ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCalculations();
  }

  Future<void> _loadUser() async {
    final phone = await AuthService.currentPhone();
    if (!mounted) return;
    setState(() {
      userPhone = phone ?? '';
    });
  }

  // ✨ TAMBAHAN: Load calculations dari API
  Future<void> _loadCalculations() async {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolarProvider>().fetchAllCalculations();
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.servicePlans);
    } else if (index == 2) {
      // ✨ UBAH: Navigate ke calculations list
      Navigator.pushNamed(context, '/calculations');
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        title: Text('SolarEase',
            style: TextStyle(
                color: isDark ? AppTheme.darkText2 : Colors.black,
                fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          // ✨ TAMBAHAN: Refresh button
          Consumer<SolarProvider>(
            builder: (context, solarProvider, _) {
              return IconButton(
                icon: Icon(Icons.refresh,
                    color: isDark ? AppTheme.darkText2 : Colors.black87),
                onPressed: () {
                  solarProvider.fetchAllCalculations();
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: isDark ? AppTheme.darkText2 : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout,
                color: isDark ? AppTheme.darkText2.withOpacity(0.7) : Colors.black54),
            onPressed: _logout,
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppTheme.primaryGold.withOpacity(0.3),
                          AppTheme.darkCard.withOpacity(0.5)
                        ]
                      : [
                          AppTheme.primaryGold.withOpacity(0.85),
                          const Color(0xFFF9E7D2)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingCard(size),
                  const SizedBox(height: 16),

                  // ✨ TAMBAHAN: Recent Calculations Widget
                  _buildRecentCalculations(),
                  const SizedBox(height: 14),

                  _buildEnergyOverview(),
                  const SizedBox(height: 14),
                  _buildQuickActions(),
                  const SizedBox(height: 18),
                  _buildStatsGrid(size),
                  const SizedBox(height: 18),
                  _buildGenerationCard(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Power'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // ✨ WIDGET BARU: Recent Calculations
  Widget _buildRecentCalculations() {
    return Consumer<SolarProvider>(
      builder: (context, solarProvider, _) {
        // Jika loading atau error, tampilkan placeholder
        if (solarProvider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (solarProvider.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    solarProvider.errorMessage ?? 'Error loading calculations',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }

        // Jika tidak ada data
        if (solarProvider.calculations.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.folder_open, color: Colors.grey, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Belum Ada Kalkulasi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai dengan membuat kalkulasi baru',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-calculation');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Buat Kalkulasi',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Tampilkan 3 kalkulasi terakhir
        final recentCalcs = solarProvider.calculations.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kalkulasi Terakhir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/calculations');
                    },
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...recentCalcs.map((calc) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            calc.address,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Daya: ${calc.maxPowerCapacity?.toStringAsFixed(2) ?? 'N/A'} kW',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // Placeholder untuk widget lainnya
  Widget _buildGreetingCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello, $userPhone'),
          Text(_formattedDate),
        ],
      ),
    );
  }

  Widget _buildEnergyOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Energy Overview'),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Quick Actions'),
    );
  }

  Widget _buildStatsGrid(Size size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Stats Grid'),
    );
  }

  Widget _buildGenerationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Generation Card'),
    );
  }
}

/* 
PERUBAHAN YANG DIBUAT:

1. ✨ Import SolarProvider:
   - import '../../providers/solar_provider.dart';

2. ✨ Di initState(), tambahkan:
   - _loadCalculations();

3. ✨ Method baru _loadCalculations():
   - Fetch all calculations dari API

4. ✨ Di _onNavTap(), ubah route untuk index 2:
   - Ganti ke '/calculations'

5. ✨ Di AppBar, tambahkan refresh button:
   - Memungkinkan manual refresh data

6. ✨ Widget baru _buildRecentCalculations():
   - Menampilkan 3 kalkulasi terakhir
   - Handle loading, error, dan empty states
   - Navigasi ke detail atau list penuh

7. ✨ Consumer<SolarProvider> untuk reactivity:
   - Otomatis update saat data berubah

CARA MENGGUNAKAN:
- Copy kode di section _buildRecentCalculations() ke home_screen.dart
- Tambahkan _loadCalculations() ke initState
- Update Provider import
- Update routing untuk Power Check button
*/
