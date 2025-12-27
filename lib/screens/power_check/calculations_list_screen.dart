import 'package:flutter/material.dart';
import '../../services/power_estimation_service.dart';
import '../../models/solar_calculation.dart';

class CalculationsListScreen extends StatefulWidget {
  const CalculationsListScreen({Key? key}) : super(key: key);

  @override
  State<CalculationsListScreen> createState() => _CalculationsListScreenState();
}

class _CalculationsListScreenState extends State<CalculationsListScreen> {
  final PowerEstimationService _estimationService = PowerEstimationService();
  
  List<SolarCalculation> _calculations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCalculations();
  }

  Future<void> _loadCalculations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final calculations = await _estimationService.getCalculations(page: 1, perPage: 50);
      if (!mounted) return;
      setState(() {
        _calculations = calculations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kalkulasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCalculations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Terjadi Kesalahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(_errorMessage ?? 'Unknown error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: null, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : _calculations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum Ada Kalkulasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Text('Buat kalkulasi baru untuk memulai', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => Future.sync(_loadCalculations),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _calculations.length,
                        itemBuilder: (context, index) {
                          final calc = _calculations[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/calculation-detail', arguments: {'id': calc.id});
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                calc.address,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDateTime(calc.createdAt),
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton(
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              child: const Row(
                                                children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))],
                                              ),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Hapus Kalkulasi?'),
                                                    content: const Text('Kalkulasi ini akan dihapus permanen.'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(ctx);
                                                          _deleteCalculation(calc.id ?? 0);
                                                        },
                                                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStatTile('Luas', '${calc.landArea.toStringAsFixed(0)} m²'),
                                        _buildStatTile('Daya', '${(calc.maxPowerCapacity ?? 0).toStringAsFixed(1)} kW'),
                                        _buildStatTile('Radiasi', '${calc.solarIrradiance.toStringAsFixed(1)}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _deleteCalculation(int id) async {
    try {
      await _estimationService.deleteCalculation(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kalkulasi dihapus')),
      );
      _loadCalculations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildStatTile(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
