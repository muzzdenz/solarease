import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/dashboard.dart';
import '../../widgets/ui_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  
  String _userNameOrEmail = '';
  int _selectedIndex = 0;
  bool _isLive = true;
  
  // Dashboard data
  DashboardHome? _dashboardHome;
  DashboardStatistics? _dashboardStats;

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
      final home = await _dashboardService.getDashboardHome();
      final stats = await _dashboardService.getDashboardStatistics();
      await _dashboardService.getRecentCalculations(limit: 5);

      if (!mounted) return;
      setState(() {
        _dashboardHome = home;
        _dashboardStats = stats;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Dashboard load error: $e');
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
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text('Live',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Switch(
                    value: _isLive,
                    onChanged: (val) {
                      setState(() => _isLive = val);
                    },
                    activeColor: AppTheme.primaryGold,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified, size: 16, color: AppTheme.primaryGold),
                    SizedBox(width: 6),
                    Text('System OK',
                        style: TextStyle(
                            color: AppTheme.primaryGold,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEnergyOverview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Use dashboard data if available
    final totalProduction = _dashboardHome?.totalEnergyProduction ?? 30.2;
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
              Text('Total Energy',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
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
              Text('${totalProduction.toStringAsFixed(1)}',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
              const SizedBox(width: 6),
              Text('kWh',
                  style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppTheme.darkText2.withOpacity(0.6)
                          : Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Solar power generated',
              style: TextStyle(
                  color: isDark
                      ? AppTheme.darkText2.withOpacity(0.6)
                      : Colors.black54)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (totalProduction / 100).clamp(0.0, 1.0),
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
              _InfoChip(label: 'Total Savings', value: formatRupiah(costSavings.toInt())),
              _InfoChip(label: 'Calculations', value: '${_dashboardHome?.totalCalculations ?? 0}'),
              _InfoChip(label: 'Active Orders', value: '${_dashboardHome?.activeOrders ?? 0}'),
            ],
          ),
        ],
      ),
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
    
    // Use dashboard stats if available
    final monthlyProduction = _dashboardStats?.monthlyEnergyProduction ?? 36.2;
    final efficiency = _dashboardStats?.averageSystemEfficiency ?? 20;
    final totalPanels = _dashboardStats?.totalPanelsInUse ?? 42;
    final carbonAvoided = _dashboardStats?.carbonEmissionAvoided ?? 28.2;
    
    final cards = [
      _StatCard(
        title: 'Monthly energy',
        value: '${monthlyProduction.toStringAsFixed(1)} kWh',
        icon: Icons.solar_power,
        color: const Color(0xFFFFF4E5),
      ),
      _StatCard(
        title: 'Efficiency',
        value: '${efficiency.toStringAsFixed(1)}%',
        icon: Icons.lightbulb_circle,
        color: const Color(0xFFE9F4FF),
      ),
      _StatCard(
        title: 'Panels in use',
        value: '$totalPanels units',
        icon: Icons.battery_charging_full,
        color: const Color(0xFFEFF7EE),
      ),
      _StatCard(
        title: 'CO2 reduction',
        value: '${carbonAvoided.toStringAsFixed(1)} kg',
        icon: Icons.eco,
        color: const Color(0xFFF4EEFF),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map(
            (card) =>
                SizedBox(width: cardWidth, child: _GradientCard(card: card)),
          )
          .toList(),
    );
  }

  Widget _buildGenerationCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Solar generation',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
              Text('140.6 kWh',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [Colors.grey.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Interactive chart coming soon',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _LegendDot(color: AppTheme.primaryGold, label: 'Solar'),
                      _LegendDot(color: Colors.black54, label: 'Grid'),
                      _LegendDot(color: Colors.green, label: 'Battery'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
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
            color: isDark
                ? AppTheme.darkDivider
                : Colors.grey.shade200),
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
