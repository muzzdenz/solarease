// ===================================================================
// PANDUAN INTEGRASI API BACKEND - SOLAREASE
// ===================================================================

// CARA MENGGUNAKAN API SERVICE DI APLIKASI
// ===================================================================

// 1. BASIC USAGE - Import Service
// -------------------------------------------------------------------
import 'package:solarease/services/solar_service.dart';
import 'package:solarease/models/solar_calculation.dart';

// 2. INSTANTIATE SERVICE
// -------------------------------------------------------------------
final SolarService _solarService = SolarService();

// 3. CONTOH PENGGUNAAN DALAM STATE
// -------------------------------------------------------------------

/*
class _MyScreenState extends State<MyScreen> {
  final SolarService _solarService = SolarService();
  SolarCalculation? _calculation;
  bool _isLoading = false;
  String? _errorMessage;

  // CREATE - Membuat Kalkulasi Baru
  Future<void> _createCalculation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _solarService.createSolarCalculation(
        address: 'Jl. Sudirman No. 1, Jakarta Pusat',
        landArea: 100,
        latitude: -6.2088,
        longitude: 106.8456,
        solarIrradiance: 5.2,
        panelEfficiency: 20,
        systemLosses: 14,
      );

      setState(() {
        _calculation = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kalkulasi berhasil dibuat: ${result.id}')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // READ ALL - Mendapatkan Semua Kalkulasi
  Future<void> _loadAllCalculations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final calculations = await _solarService.getAllCalculations(
        page: 1,
        perPage: 10,
      );

      setState(() {
        _calculations = calculations;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // READ ONE - Mendapatkan Detail Kalkulasi
  Future<void> _loadCalculationDetail(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final calculation = await _solarService.getCalculationById(id);

      setState(() {
        _calculation = calculation;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // GET FULL DETAILS - Mendapatkan Detail Lengkap dengan Metrics
  Future<void> _loadCalculationFullDetails(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _solarService.getCalculationDetails(id);

      setState(() {
        _calculation = result.calculation;
        _calculationDetails = result.details;
        _financialMetrics = result.metrics;
      });

      // Akses data
      print('Daya Maksimal: ${result.metrics.installationCost}');
      print('ROI 25 Tahun: ${result.metrics.roi25Years}%');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // UPDATE - Update Kalkulasi
  Future<void> _updateCalculation(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _solarService.updateCalculation(
        id,
        landArea: 150,
        panelEfficiency: 22,
      );

      setState(() {
        _calculation = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kalkulasi berhasil diupdate')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // DELETE - Hapus Kalkulasi
  Future<void> _deleteCalculation(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _solarService.deleteCalculation(id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kalkulasi berhasil dihapus')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text('Error: $_errorMessage'),
                )
              : Center(
                  child: _calculation != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Alamat: ${_calculation!.address}'),
                            Text('Daya: ${_calculation!.maxPowerCapacity} kW'),
                            Text(
                              'Produksi Harian: ${_calculation!.dailyEnergyProduction} kWh',
                            ),
                          ],
                        )
                      : Text('Tidak ada data'),
                ),
    );
  }
}
*/

// ===================================================================
// RESPONSE MODELS REFERENCE
// ===================================================================

/*
SolarCalculation:
  - id: int? (ID kalkulasi)
  - address: String (Alamat lokasi)
  - latitude: double (Latitude)
  - longitude: double (Longitude)
  - landArea: double (Luas lahan m²)
  - solarIrradiance: double (Radiasi matahari kWh/m²/day)
  - panelEfficiency: int (Efisiensi panel %)
  - systemLosses: int (System losses %)
  - maxPowerCapacity: double? (Daya maksimal kW)
  - dailyEnergyProduction: double? (Produksi harian kWh)
  - monthlyEnergyProduction: double? (Produksi bulanan kWh)
  - yearlyEnergyProduction: double? (Produksi tahunan kWh)
  - createdAt: DateTime? (Waktu dibuat)
  - updatedAt: DateTime? (Waktu diupdate)

CalculationDetails:
  - usableArea: double (Area yang dapat digunakan m²)
  - maxPowerCapacity: double (Daya maksimal kW)
  - dailyEnergyProduction: double (Produksi harian kWh)
  - monthlyEnergyProduction: double (Produksi bulanan kWh)
  - yearlyEnergyProduction: double (Produksi tahunan kWh)
  - panelEfficiency: int (Efisiensi panel %)
  - systemLosses: int (System losses %)
  - performanceRatio: double (Performa ratio %)

FinancialMetrics:
  - installationCost: double (Biaya instalasi)
  - yearlySavings: double (Penghematan tahunan)
  - paybackPeriodYears: double (Periode balik modal tahun)
  - roi25Years: double (ROI 25 tahun %)
*/

// ===================================================================
// ERROR HANDLING
// ===================================================================

/*
API Service akan mengembalikan error messages yang user-friendly:

400 - "Permintaan tidak valid"
401 - "Tidak terautentikasi"
403 - "Akses ditolak"
404 - "Data tidak ditemukan"
422 - "Validasi gagal"
500 - "Terjadi kesalahan pada server"
Timeout - "Timeout koneksi" atau "Timeout menerima data"
No Connection - "Periksa koneksi internet Anda"

Semua error akan dicatch dan di-print di console untuk debugging.
*/

// ===================================================================
// DENGAN PROVIDER PATTERN (RECOMMENDED)
// ===================================================================

/*
Jika Anda ingin menggunakan Provider untuk state management:

1. Buat file: lib/providers/solar_provider.dart

import 'package:flutter/material.dart';
import '../services/solar_service.dart';
import '../models/solar_calculation.dart';

class SolarProvider extends ChangeNotifier {
  final SolarService _solarService = SolarService();

  List<SolarCalculation> _calculations = [];
  SolarCalculation? _currentCalculation;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SolarCalculation> get calculations => _calculations;
  SolarCalculation? get currentCalculation => _currentCalculation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create
  Future<void> createCalculation({
    required String address,
    required double landArea,
    required double latitude,
    required double longitude,
    required double solarIrradiance,
    int panelEfficiency = 20,
    int systemLosses = 14,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _solarService.createSolarCalculation(
        address: address,
        landArea: landArea,
        latitude: latitude,
        longitude: longitude,
        solarIrradiance: solarIrradiance,
        panelEfficiency: panelEfficiency,
        systemLosses: systemLosses,
      );
      _currentCalculation = result;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get All
  Future<void> fetchAllCalculations({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _calculations = await _solarService.getAllCalculations(
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get One
  Future<void> fetchCalculation(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentCalculation = await _solarService.getCalculationById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update
  Future<void> updateCalculation(int id, {
    String? address,
    double? landArea,
    double? latitude,
    double? longitude,
    double? solarIrradiance,
    int? panelEfficiency,
    int? systemLosses,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _solarService.updateCalculation(
        id,
        address: address,
        landArea: landArea,
        latitude: latitude,
        longitude: longitude,
        solarIrradiance: solarIrradiance,
        panelEfficiency: panelEfficiency,
        systemLosses: systemLosses,
      );
      _currentCalculation = result;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Delete
  Future<bool> deleteCalculation(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _solarService.deleteCalculation(id);
      if (success) {
        _calculations.removeWhere((calc) => calc.id == id);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

2. Di main.dart, tambahkan:

import 'package:provider/provider.dart';
import 'providers/solar_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SolarProvider()),
        // ... provider lainnya
      ],
      child: MaterialApp(
        // ... konfigurasi lainnya
      ),
    );
  }
}

3. Gunakan di Widget:

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SolarProvider>(
      builder: (context, solarProvider, _) {
        if (solarProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (solarProvider.errorMessage != null) {
          return Center(child: Text('Error: ${solarProvider.errorMessage}'));
        }

        return ListView.builder(
          itemCount: solarProvider.calculations.length,
          itemBuilder: (context, index) {
            final calc = solarProvider.calculations[index];
            return ListTile(
              title: Text(calc.address),
              subtitle: Text('Daya: ${calc.maxPowerCapacity} kW'),
            );
          },
        );
      },
    );
  }
}
*/

// ===================================================================
// TESTING API DENGAN POSTMAN/THUNDER CLIENT
// ===================================================================

/*
Base URL: http://localhost:8000/api/powerestimation

1. CREATE (POST)
   URL: http://localhost:8000/api/powerestimation/solar-calculations
   Method: POST
   Headers: Content-Type: application/json
   Body:
   {
     "address": "Jl. Sudirman No. 1, Jakarta Pusat",
     "land_area": 100,
     "latitude": -6.2088,
     "longitude": 106.8456,
     "solar_irradiance": 5.2,
     "panel_efficiency": 20,
     "system_losses": 14
   }

2. GET ALL (GET)
   URL: http://localhost:8000/api/powerestimation/solar-calculations?page=1&per_page=10
   Method: GET

3. GET ONE (GET)
   URL: http://localhost:8000/api/powerestimation/solar-calculations/1
   Method: GET

4. UPDATE (PATCH)
   URL: http://localhost:8000/api/powerestimation/solar-calculations/1
   Method: PATCH
   Headers: Content-Type: application/json
   Body:
   {
     "land_area": 120,
     "panel_efficiency": 22
   }

5. DELETE (DELETE)
   URL: http://localhost:8000/api/powerestimation/solar-calculations/1
   Method: DELETE
*/
