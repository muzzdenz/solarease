import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/location_model.dart';
import '../../widgets/custom_button.dart';

class PowerCheckResultScreen extends StatefulWidget {
  final LocationModel location;
  final double area;

  const PowerCheckResultScreen({
    Key? key,
    required this.location,
    required this.area,
  }) : super(key: key);

  @override
  State<PowerCheckResultScreen> createState() =>
      _PowerCheckResultScreenState();
}

class _PowerCheckResultScreenState extends State<PowerCheckResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  // Mock calculation
  late double estimatedCapacity;
  late double estimatedOutput;
  late double estimatedCost;
  late double savingsPerYear;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();
    _calculateEstimates();
  }

  void _calculateEstimates() {
    estimatedCapacity = widget.area * 0.15; // kW per m²
    estimatedOutput = estimatedCapacity * 4.5; // kWh per day estimate
    estimatedCost = estimatedCapacity * 1500; // Rp per kW
    savingsPerYear = estimatedOutput * 365 * 1500 / 1000; // Rp per year
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark ? AppTheme.darkText2 : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Hasil Power Check',
            style: TextStyle(
              color: isDark ? AppTheme.darkText2 : Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Success Badge
              ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0)
                    .animate(_controller),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.green,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Analisis Selesai!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kami menemukan solusi terbaik untuk Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.darkText2.withOpacity(0.6)
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              // Location Summary
              _buildLocationCard(isDark),
              const SizedBox(height: 16),
              // Results Grid
              _buildResultsGrid(isDark),
              const SizedBox(height: 24),
              // Details Card
              _buildDetailsCard(isDark),
              const SizedBox(height: 32),
              // Action Buttons
              CustomButton(
                label: 'Lihat Paket Rekomendasi',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/service_plans');
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Analisis Ulang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppTheme.primaryGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkText2.withOpacity(0.6)
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.location.address,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(bool isDark) {
    final items = [
      {
        'title': 'Luas Atap',
        'value': '${widget.area.toStringAsFixed(1)} m²',
        'icon': Icons.home,
      },
      {
        'title': 'Kapasitas',
        'value': '${estimatedCapacity.toStringAsFixed(1)} kW',
        'icon': Icons.flash_on,
      },
      {
        'title': 'Output/Hari',
        'value': '${estimatedOutput.toStringAsFixed(1)} kWh',
        'icon': Icons.trending_up,
      },
      {
        'title': 'Estimasi Biaya',
        'value': 'Rp ${(estimatedCost / 1e6).toStringAsFixed(1)}jt',
        'icon': Icons.attach_money,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.darkDivider : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'] as IconData,
                color: AppTheme.primaryGold,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                item['title'].toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppTheme.darkText2.withOpacity(0.6)
                      : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                item['value'].toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Benefit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitRow(
            isDark,
            'Penghematan/Tahun',
            'Rp ${(savingsPerYear / 1e6).toStringAsFixed(1)}jt',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildBenefitRow(
            isDark,
            'Pengurangan CO₂',
            '${(estimatedOutput * 365 * 0.5).toStringAsFixed(0)} kg/tahun',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildBenefitRow(
            isDark,
            'ROI Diperkirakan',
            '6-8 tahun',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(
    bool isDark,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.darkText2.withOpacity(0.7)
                    : Colors.black54,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
          ),
        ),
      ],
    );
  }
}
