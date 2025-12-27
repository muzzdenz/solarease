import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/power_estimation_service.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/dashboard.dart';
import '../../models/solar_calculation.dart';
import '../../widgets/ui_kit.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  final PowerEstimationService _estimationService = PowerEstimationService();

  String _userNameOrEmail = '';
  int _selectedIndex = 0;
  bool _isLive = true;

  // Dashboard data
  DashboardHome? _dashboardHome;
  List<SolarCalculation> _recentCalculations = [];
  SolarCalculation? _latestCalculation;

  String get _formattedDate {
    final now = DateTime.now();
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}, ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDashboardData();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.currentName();
    final email = await AuthService.currentEmail();
    if (!mounted) return;
    setState(() {
      _userNameOrEmail =
          (name != null && name.isNotEmpty) ? name : (email ?? '');
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    try {
      // First: compute local dashboard from calculations
      final calcs =
          await _estimationService.getCalculations(page: 1, perPage: 100);
      debugPrint('📊 Fetched ${calcs.length} calculations from backend');

      // Calculate average daily production instead of total yearly
      double totalDailyEnergy = 0.0;
      double totalMonthlyEnergy = 0.0;
      int countWithDaily = 0;
      String lastCalcDate = 'N/A';

      if (calcs.isNotEmpty) {
        calcs.sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        lastCalcDate = calcs.first.createdAt?.toIso8601String() ?? 'N/A';
      }

      for (final c in calcs) {
        if (c.dailyEnergyProduction != null && c.dailyEnergyProduction! > 0) {
          totalDailyEnergy += c.dailyEnergyProduction!;
          totalMonthlyEnergy +=
              (c.monthlyEnergyProduction ?? c.dailyEnergyProduction! * 30);
          countWithDaily++;
        }
      }

      // Use average daily production for display
      final avgDailyProduction =
          countWithDaily > 0 ? totalDailyEnergy / countWithDaily : 0.0;
      final avgMonthlyProduction =
          countWithDaily > 0 ? totalMonthlyEnergy / countWithDaily : 0.0;

      if (!mounted) return;
      setState(() {
        _dashboardHome = DashboardHome(
          totalCalculations: calcs.length,
          activeOrders: 0,
          totalEnergyProduction: avgDailyProduction, // Changed to daily average
          totalCostSavings: 0.0,
          lastCalculationDate: lastCalcDate,
          quickCards: const [],
        );
        _recentCalculations = calcs.take(5).toList();
        _latestCalculation = calcs.isNotEmpty ? calcs.first : null;
      });

      // Then: try to overlay with server dashboard (ignore 404)
      try {
        final home = await _dashboardService.getDashboardHome();
        if (!mounted) return;
        // Only overlay if dashboard has meaningful data (not all zeros)
        if (home.totalCalculations > 0 || home.totalEnergyProduction > 0) {
          debugPrint('✅ Using server dashboard data');
          setState(() {
            _dashboardHome = home;
          });
        } else {
          debugPrint(
              '⚠️ Server dashboard has no data, keeping computed fallback');
        }
      } catch (e) {
        debugPrint('Dashboard load error (using fallback): $e');
      }
    } catch (e) {
      debugPrint('Dashboard overall load error: $e');
    }
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
      Navigator.pushNamed(context, AppRoutes.powerCheck);
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
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: isDark ? AppTheme.darkText2 : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout,
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.7)
                    : Colors.black54),
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
                  if (_latestCalculation != null) ...[
                    _buildLatestCalculationHero(),
                    const SizedBox(height: 16),
                    _buildProductionMetrics(),
                    const SizedBox(height: 16),
                    _buildSystemSpecs(),
                    const SizedBox(height: 16),
                    _buildLocationInfo(),
                  ] else
                    _buildEmptyCalculations(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: Colors.grey,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Power Check'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(Size size) {
    final name = _userNameOrEmail.isNotEmpty ? _userNameOrEmail : 'Charlie';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGold,
                  AppTheme.primaryGold.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, $name',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppTheme.darkText2 : AppTheme.darkText)),
                const SizedBox(height: 4),
                Text(_formattedDate,
                    style: TextStyle(
                        color: isDark
                            ? AppTheme.darkText2.withOpacity(0.6)
                            : Colors.black54,
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildEnergyOverview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use dashboard data if available - now showing DAILY average
    final avgDailyProduction = _dashboardHome?.totalEnergyProduction ?? 0.0;
    final costSavings = _dashboardHome?.totalCostSavings ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)]
              : [Colors.white, Colors.white.withOpacity(0.92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average Daily Energy',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppTheme.darkText2 : AppTheme.darkText)),
                  const SizedBox(height: 2),
                  Text('Per installation',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.darkText2.withOpacity(0.5)
                              : Colors.black45)),
                ],
              ),
              GestureDetector(
                onTap: _loadDashboardData,
                child: Icon(Icons.refresh,
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.5)
                        : Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${avgDailyProduction.toStringAsFixed(1)}',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
              const SizedBox(width: 6),
              Text('kWh/day',
                  style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppTheme.darkText2.withOpacity(0.6)
                          : Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Solar power potential',
              style: TextStyle(
                  color: isDark
                      ? AppTheme.darkText2.withOpacity(0.6)
                      : Colors.black54)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (avgDailyProduction / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                  label: 'Total Savings',
                  value: formatRupiah(costSavings.toInt())),
              _InfoChip(
                  label: 'Calculations',
                  value: '${_dashboardHome?.totalCalculations ?? 0}'),
              _InfoChip(
                  label: 'Monthly Avg',
                  value: '${(avgDailyProduction * 30).toStringAsFixed(0)} kWh'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardQuickCards() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cards = _dashboardHome?.quickCards ?? [];
    if (cards.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.map((qc) {
        return Container(
          width: (MediaQuery.of(context).size.width - 52) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (qc.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.info_outline,
                          size: 18, color: AppTheme.primaryGold),
                    ),
                  Text(qc.label,
                      style: TextStyle(
                          color: isDark
                              ? AppTheme.darkText2.withOpacity(0.7)
                              : Colors.black54,
                          fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Text('${qc.value} ${qc.unit}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    final items = [
      _QuickAction(
        icon: Icons.shopping_bag,
        label: 'Service Plans',
        onTap: () => Navigator.pushNamed(context, AppRoutes.servicePlans),
      ),
      _QuickAction(
        icon: Icons.shopping_cart,
        label: 'Cart',
        onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
      ),
      _QuickAction(
        icon: Icons.receipt_long,
        label: 'Orders',
        onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
      ),
      _QuickAction(
        icon: Icons.bolt,
        label: 'Power Check',
        onTap: () => Navigator.pushNamed(context, AppRoutes.powerCheck),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 100,
                  child: _ActionCard(item: item),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStatsGrid(Size size) {
    final cardWidth = (size.width - 52) / 2;

    return const SizedBox.shrink();
  }

  Widget _buildGenerationCard() {
    return const SizedBox.shrink();
  }

  Widget _buildLatestCalculationHero() {
    if (_latestCalculation == null) return const SizedBox.shrink();
    final calc = _latestCalculation!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGold,
            AppTheme.primaryGold.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.solar_power_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Calculation',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(calc.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  calc.address,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeroStat(
                  'Max Power',
                  '${calc.maxPowerCapacity?.toStringAsFixed(2) ?? '0'} kW',
                  Icons.flash_on,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildHeroStat(
                  'Land Area',
                  '${calc.landArea.toStringAsFixed(0)} m²',
                  Icons.grid_on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProductionMetrics() {
    if (_latestCalculation == null) return const SizedBox.shrink();
    final calc = _latestCalculation!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Energy Production',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProductionCard(
                'Daily',
                calc.dailyEnergyProduction ?? 0,
                'kWh',
                Icons.wb_sunny,
                Colors.orange,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProductionCard(
                'Monthly',
                calc.monthlyEnergyProduction ?? 0,
                'kWh',
                Icons.calendar_month,
                Colors.blue,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildProductionCard(
          'Yearly Production',
          calc.yearlyEnergyProduction ?? 0,
          'kWh',
          Icons.calendar_today,
          Colors.green,
          isDark,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildProductionCard(
    String label,
    double value,
    String unit,
    IconData icon,
    Color color,
    bool isDark, {
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkText2.withOpacity(0.7)
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              unit,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppTheme.darkText2.withOpacity(0.6)
                                    : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.7)
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.6)
                        : Colors.black45,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSystemSpecs() {
    if (_latestCalculation == null) return const SizedBox.shrink();
    final calc = _latestCalculation!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'System Specifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecRow(
            'Solar Irradiance',
            '${calc.solarIrradiance.toStringAsFixed(2)} kWh/m²/day',
            Icons.wb_sunny_outlined,
            Colors.orange,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildSpecRow(
            'Panel Efficiency',
            '${calc.panelEfficiency}%',
            Icons.speed,
            Colors.green,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildSpecRow(
            'System Losses',
            '${calc.systemLosses}%',
            Icons.trending_down,
            Colors.red,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildSpecRow(
            'Net Efficiency',
            '${(calc.panelEfficiency * (100 - calc.systemLosses) / 100).toStringAsFixed(1)}%',
            Icons.check_circle,
            Colors.blue,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? AppTheme.darkText2.withOpacity(0.8) : Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    if (_latestCalculation == null) return const SizedBox.shrink();
    final calc = _latestCalculation!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.darkCard,
                  AppTheme.darkCard.withOpacity(0.8),
                ]
              : [
                  Colors.blue.shade50,
                  Colors.blue.shade50.withOpacity(0.5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Location Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationRow(
            'Address',
            calc.address,
            Icons.home,
            isDark,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLocationRow(
                  'Latitude',
                  calc.latitude.toStringAsFixed(6),
                  Icons.explore,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLocationRow(
                  'Longitude',
                  calc.longitude.toStringAsFixed(6),
                  Icons.explore_outlined,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.map, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap to view on map',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 14,
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.5)
                    : Colors.black45),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.6)
                    : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

  Widget _buildCalculationsChart() {
    if (_recentCalculations.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Energy Production',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Last 5',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: _buildEnergyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxEnergy = _recentCalculations
        .map((c) => c.dailyEnergyProduction ?? 0.0)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _recentCalculations.asMap().entries.map((entry) {
        final calc = entry.value;
        final energy = calc.dailyEnergyProduction ?? 0.0;
        final height = maxEnergy > 0 ? (energy / maxEnergy) * 100 : 10.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${energy.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.7)
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGold,
                        AppTheme.primaryGold.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.circle,
                  size: 6,
                  color: isDark
                      ? AppTheme.darkText2.withOpacity(0.5)
                      : Colors.black38,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentCalculations() {
    if (_recentCalculations.isEmpty) {
      return _buildEmptyCalculations();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Calculations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/calculations-list'),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._recentCalculations
            .map((calc) => _buildCalculationCard(calc, isDark))
            .toList(),
      ],
    );
  }

  Widget _buildCalculationCard(SolarCalculation calc, bool isDark) {
    final dailyEnergy = calc.dailyEnergyProduction ?? 0.0;
    final monthlyEnergy = calc.monthlyEnergyProduction ?? 0.0;
    final power = calc.maxPowerCapacity ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGold,
                      AppTheme.primaryGold.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                      calc.address,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(calc.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkText2.withOpacity(0.5)
                            : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.3)
                    : Colors.black26,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricChip(
                icon: Icons.bolt,
                label: 'Power',
                value: '${power.toStringAsFixed(1)} kW',
                color: Colors.orange,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                icon: Icons.wb_sunny,
                label: 'Daily',
                value: '${dailyEnergy.toStringAsFixed(1)} kWh',
                color: Colors.amber,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                icon: Icons.calendar_month,
                label: 'Monthly',
                value: '${monthlyEnergy.toStringAsFixed(0)} kWh',
                color: Colors.blue,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.primaryGold,
                ),
                const SizedBox(width: 4),
                Text(
                  '${calc.landArea.toStringAsFixed(0)} m² • ${calc.solarIrradiance.toStringAsFixed(1)} kWh/m²',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.6)
                    : Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCalculations() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.solar_power,
              size: 48,
              color: AppTheme.primaryGold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Calculations Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by checking solar power potential\nfor your location',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? AppTheme.darkText2.withOpacity(0.6) : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.powerCheck),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('New Calculation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.6)
                    : Colors.black54,
                fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item});

  final _QuickAction item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 10),
            Text(item.label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
          ],
        ),
      ),
    );
  }
}

class _StatCard {
  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _GradientCard extends StatelessWidget {
  const _GradientCard({required this.card});

  final _StatCard card;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: isDark
              ? [card.color.withOpacity(0.2), AppTheme.darkCard]
              : [card.color, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
            color: isDark ? AppTheme.darkDivider : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.darkBg : Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Icon(card.icon, color: AppTheme.primaryGold),
          ),
          const SizedBox(height: 10),
          Text(card.title,
              style: TextStyle(
                  color: isDark
                      ? AppTheme.darkText2.withOpacity(0.6)
                      : Colors.black54,
                  fontSize: 12)),
          const SizedBox(height: 6),
          Text(card.value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
