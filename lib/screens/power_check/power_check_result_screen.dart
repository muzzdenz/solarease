import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/location_model.dart';
import '../../services/power_estimation_service.dart';
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
  final PowerEstimationService _estimationService = PowerEstimationService();
  
  late AnimationController _controller;

  // Calculation data
  late double estimatedCapacity;
  late double estimatedOutput;
  late double estimatedCost;
  late double savingsPerYear;
  
  int? _createdCalculationId;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Payload controllers to align with request body
  late final TextEditingController _addressController;
  late final TextEditingController _landAreaController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _solarIrradianceController;
  late final TextEditingController _panelEfficiencyController;
  late final TextEditingController _systemLossesController;

  

  void _calculateEstimates() {
    estimatedCapacity = widget.area * 0.15; // kW per m²
    estimatedOutput = estimatedCapacity * 4.5; // kWh per day estimate
    estimatedCost = estimatedCapacity * 1500000; // Rp per kW (1.5M Rp/kW)
    savingsPerYear = estimatedOutput * 365 * 1500; // Rp per year
  }

  Future<void> _submitCalculation() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Read payload from inputs (aligns with request body)
      final address = _addressController.text.trim();
      if (address.isEmpty) {
        throw Exception('Alamat wajib diisi');
      }

      final landArea = double.tryParse(_landAreaController.text.trim());
      final latitude = double.tryParse(_latitudeController.text.trim());
      final longitude = double.tryParse(_longitudeController.text.trim());
      final solarIrradiance = double.tryParse(_solarIrradianceController.text.trim());
      final panelEfficiency = int.tryParse(_panelEfficiencyController.text.trim());
      final systemLosses = int.tryParse(_systemLossesController.text.trim());

      if (landArea == null) {
        throw Exception('Luas lahan tidak valid');
      }
      if (latitude != null && (latitude < -90 || latitude > 90)) {
        throw Exception('Latitude harus antara -90 s.d 90');
      }
      if (longitude != null && (longitude < -180 || longitude > 180)) {
        throw Exception('Longitude harus antara -180 s.d 180');
      }
      if (panelEfficiency != null && (panelEfficiency < 1 || panelEfficiency > 100)) {
        throw Exception('Efisiensi panel harus 1-100%');
      }
      if (systemLosses != null && (systemLosses < 0 || systemLosses > 100)) {
        throw Exception('System losses harus 0-100%');
      }

      final calculation = await _estimationService.createCalculation(
        address: address,
        landArea: landArea,
        latitude: latitude ?? widget.location.latitude,
        longitude: longitude ?? widget.location.longitude,
        solarIrradiance: solarIrradiance ?? 4.5,
        panelEfficiency: panelEfficiency ?? 20,
        systemLosses: systemLosses ?? 14,
      );

      if (!mounted) return;
      setState(() {
        _createdCalculationId = calculation.id;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculation saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landAreaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _solarIrradianceController.dispose();
    _panelEfficiencyController.dispose();
    _systemLossesController.dispose();
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
              const SizedBox(height: 16),
              // Payload Form (align with request body)
              _buildPayloadForm(isDark),
              const SizedBox(height: 32),
              // Error message if any
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              // Action Buttons
              CustomButton(
                label: _createdCalculationId != null ? '✓ Tersimpan' : 'Simpan Kalkulasi',
                onPressed: _isSubmitting || _createdCalculationId != null ? null : _submitCalculation,
              ),
              const SizedBox(height: 12),
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();
    _calculateEstimates();

    // Initialize controllers with defaults
    _addressController = TextEditingController(text: widget.location.address);
    _landAreaController = TextEditingController(text: widget.area.toStringAsFixed(0));
    _latitudeController = TextEditingController(text: widget.location.latitude.toString());
    _longitudeController = TextEditingController(text: widget.location.longitude.toString());
    _solarIrradianceController = TextEditingController(text: '4.5');
    _panelEfficiencyController = TextEditingController(text: '20');
    _systemLossesController = TextEditingController(text: '14');
  }

  Widget _buildPayloadForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parameter Kalkulasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Alamat', controller: _addressController, isDark: isDark),
          const SizedBox(height: 10),
          _buildTextField(label: 'Luas Lahan (m²)', controller: _landAreaController, keyboardType: TextInputType.number, isDark: isDark),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Latitude', controller: _latitudeController, keyboardType: TextInputType.number, isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: 'Longitude', controller: _longitudeController, keyboardType: TextInputType.number, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Solar Irradiance (kWh/m²/day)', controller: _solarIrradianceController, keyboardType: TextInputType.number, isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: 'Efisiensi Panel (%)', controller: _panelEfficiencyController, keyboardType: TextInputType.number, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField(label: 'System Losses (%)', controller: _systemLossesController, keyboardType: TextInputType.number, isDark: isDark),
          const SizedBox(height: 6),
          Text(
            'Semua field mengikuti request body: address, land_area, latitude, longitude, solar_irradiance, panel_efficiency, system_losses.',
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkText2.withOpacity(0.6) : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.darkText2.withOpacity(0.7) : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
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
