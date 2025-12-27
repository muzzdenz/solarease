import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/solar_provider.dart';
import '../../config/theme.dart';

class CalculationsListScreen extends StatefulWidget {
  const CalculationsListScreen({Key? key}) : super(key: key);

  @override
  State<CalculationsListScreen> createState() => _CalculationsListScreenState();
}

class _CalculationsListScreenState extends State<CalculationsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load calculations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolarProvider>().fetchAllCalculations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kalkulasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<SolarProvider>().fetchAllCalculations();
            },
          ),
        ],
      ),
      body: Consumer<SolarProvider>(
        builder: (context, solarProvider, _) {
          if (solarProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (solarProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    solarProvider.errorMessage ?? 'Unknown error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      solarProvider.clearError();
                      solarProvider.fetchAllCalculations();
                    },
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (solarProvider.calculations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Kalkulasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat kalkulasi baru untuk memulai',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: solarProvider.calculations.length,
            itemBuilder: (context, index) {
              final calculation = solarProvider.calculations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigate to detail screen
                    _showCalculationDetail(context, calculation.id ?? 0);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Address & Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    calculation.address,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (calculation.createdAt != null)
                                    Text(
                                      _formatDate(calculation.createdAt!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Detail'),
                                    ],
                                  ),
                                  onTap: () {
                                    _showCalculationDetail(context, calculation.id ?? 0);
                                  },
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                  onTap: () {
                                    // Navigate to edit screen
                                  },
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  onTap: () {
                                    _showDeleteConfirmation(context, calculation.id ?? 0);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats Row 1: Power & Area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatTile(
                              icon: Icons.power,
                              label: 'Daya',
                              value: '${calculation.maxPowerCapacity?.toStringAsFixed(2) ?? 'N/A'} kW',
                            ),
                            _buildStatTile(
                              icon: Icons.aspect_ratio,
                              label: 'Luas',
                              value: '${calculation.landArea.toStringAsFixed(0)} m²',
                            ),
                            _buildStatTile(
                              icon: Icons.wb_sunny,
                              label: 'Radiasi',
                              value: '${calculation.solarIrradiance.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stats Row 2: Production
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatTile(
                              icon: Icons.calendar_today,
                              label: 'Harian',
                              value: '${calculation.dailyEnergyProduction?.toStringAsFixed(2) ?? 'N/A'} kWh',
                            ),
                            _buildStatTile(
                              icon: Icons.date_range,
                              label: 'Bulanan',
                              value: '${calculation.monthlyEnergyProduction?.toStringAsFixed(0) ?? 'N/A'} kWh',
                            ),
                            _buildStatTile(
                              icon: Icons.event_note,
                              label: 'Tahunan',
                              value: '${calculation.yearlyEnergyProduction?.toStringAsFixed(0) ?? 'N/A'} kWh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create calculation screen
          Navigator.pushNamed(context, '/create-calculation');
        },
        backgroundColor: AppTheme.primaryGold,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGold),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCalculationDetail(BuildContext context, int id) {
    final solarProvider = context.read<SolarProvider>();
    
    showDialog(
      context: context,
      builder: (context) => FutureBuilder(
        future: Future.delayed(
          Duration(milliseconds: 500),
          () => solarProvider.fetchCalculationDetails(id),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (solarProvider.currentCalculation == null) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Gagal memuat data'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup'),
                ),
              ],
            );
          }

          final calc = solarProvider.currentCalculation!;
          final details = solarProvider.currentDetails;
          final metrics = solarProvider.currentMetrics;

          return AlertDialog(
            title: Text('Detail Kalkulasi'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Alamat', calc.address),
                  _buildDetailRow('Luas Lahan', '${calc.landArea} m²'),
                  _buildDetailRow('Latitude', '${calc.latitude}'),
                  _buildDetailRow('Longitude', '${calc.longitude}'),
                  const Divider(),
                  _buildDetailRow('Daya Maksimal', '${calc.maxPowerCapacity} kW'),
                  _buildDetailRow('Produksi Harian', '${calc.dailyEnergyProduction} kWh'),
                  _buildDetailRow('Produksi Bulanan', '${calc.monthlyEnergyProduction?.toStringAsFixed(0)} kWh'),
                  _buildDetailRow('Produksi Tahunan', '${calc.yearlyEnergyProduction?.toStringAsFixed(0)} kWh'),
                  if (metrics != null) ...[
                    const Divider(),
                    _buildDetailRow('Biaya Instalasi', 'Rp ${metrics.installationCost.toStringAsFixed(0)}'),
                    _buildDetailRow('Penghematan/Tahun', 'Rp ${metrics.yearlySavings.toStringAsFixed(0)}'),
                    _buildDetailRow('Balik Modal', '${metrics.paybackPeriodYears.toStringAsFixed(1)} tahun'),
                    _buildDetailRow('ROI 25 Tahun', '${metrics.roi25Years.toStringAsFixed(1)}%'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Kalkulasi?'),
        content: Text('Apakah Anda yakin ingin menghapus kalkulasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<SolarProvider>().deleteCalculation(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kalkulasi berhasil dihapus')),
              );
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
