# 🌞 API Integration Setup - SolarEase

## ✅ Langkah Instalasi

### 1. Install Dependencies
Jalankan perintah berikut di terminal:

```bash
flutter pub get
```

Atau jika menggunakan Dart:
```bash
dart pub get
```

Dependencies yang ditambahkan:
- `http: ^1.1.0` - HTTP client
- `dio: ^5.3.0` - Advanced HTTP client dengan interceptors

### 2. File-File yang Sudah Dibuat

#### Models
- **`lib/models/solar_calculation.dart`** - Model untuk semua response dari backend
  - `SolarCalculation` - Data kalkulasi
  - `CalculationDetails` - Detail teknis kalkulasi
  - `FinancialMetrics` - Metrik finansial
  - `CalculationResponse` - Response single calculation
  - `PaginatedResponse` - Response untuk list calculations

#### Services
- **`lib/services/api_service.dart`** - Low-level API service
  - Handle HTTP requests/responses
  - Error handling
  - Logging & debugging
  
- **`lib/services/solar_service.dart`** - High-level business logic
  - Wrapper untuk api_service
  - Business logic untuk solar calculations

#### Providers
- **`lib/providers/solar_provider.dart`** - State management dengan Provider
  - State untuk calculations
  - Loading & error handling
  - Pagination support

#### Documentation
- **`lib/API_INTEGRATION_GUIDE.dart`** - Panduan lengkap penggunaan API

---

## 🚀 Cara Menggunakan

### Option 1: Direct Service Usage

```dart
import 'package:solarease/services/solar_service.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final SolarService _solarService = SolarService();
  bool _isLoading = false;

  Future<void> _createCalculation() async {
    setState(() => _isLoading = true);

    try {
      final calculation = await _solarService.createSolarCalculation(
        address: 'Jl. Sudirman No. 1, Jakarta Pusat',
        landArea: 100,
        latitude: -6.2088,
        longitude: 106.8456,
        solarIrradiance: 5.2,
        panelEfficiency: 20,
        systemLosses: 14,
      );

      print('Kalkulasi dibuat: ${calculation.id}');
      print('Daya maksimal: ${calculation.maxPowerCapacity} kW');
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: ElevatedButton(
                onPressed: _createCalculation,
                child: Text('Buat Kalkulasi'),
              ),
            ),
    );
  }
}
```

### Option 2: Provider Pattern (Recommended)

#### Setup di main.dart:
```dart
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
        // ... konfigurasi
        home: HomeScreen(),
      ),
    );
  }
}
```

#### Gunakan di Widget:
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SolarProvider>(
      builder: (context, solarProvider, _) {
        if (solarProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (solarProvider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${solarProvider.errorMessage}'),
                ElevatedButton(
                  onPressed: () => solarProvider.clearError(),
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: solarProvider.calculations.length,
          itemBuilder: (context, index) {
            final calc = solarProvider.calculations[index];
            return Card(
              child: ListTile(
                title: Text(calc.address),
                subtitle: Text('Daya: ${calc.maxPowerCapacity} kW'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  solarProvider.fetchCalculationDetails(calc.id ?? 0);
                },
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## 📋 API Endpoints Reference

### Base URL
```
http://localhost:8000/api/powerestimation
```

### 1. Create Calculation
```dart
await solarProvider.createCalculation(
  address: 'Jl. Sudirman No. 1, Jakarta Pusat',
  landArea: 100,
  latitude: -6.2088,
  longitude: 106.8456,
  solarIrradiance: 5.2,
  panelEfficiency: 20,
  systemLosses: 14,
);
```

### 2. Get All Calculations
```dart
await solarProvider.fetchAllCalculations(
  page: 1,
  perPage: 10,
);
// Access with: solarProvider.calculations
```

### 3. Get Single Calculation
```dart
await solarProvider.fetchCalculation(calculationId);
// Access with: solarProvider.currentCalculation
```

### 4. Get Full Details
```dart
await solarProvider.fetchCalculationDetails(calculationId);
// Access with:
// - solarProvider.currentCalculation
// - solarProvider.currentDetails
// - solarProvider.currentMetrics
```

### 5. Update Calculation
```dart
await solarProvider.updateCalculation(
  calculationId,
  landArea: 150,
  panelEfficiency: 22,
);
```

### 6. Delete Calculation
```dart
await solarProvider.deleteCalculation(calculationId);
```

---

## 📊 Response Models

### SolarCalculation
```dart
SolarCalculation(
  id: 1,
  address: 'Jl. Sudirman No. 1, Jakarta Pusat',
  latitude: -6.2088,
  longitude: 106.8456,
  landArea: 100,
  solarIrradiance: 5.2,
  panelEfficiency: 20,
  systemLosses: 14,
  maxPowerCapacity: 15.00,
  dailyEnergyProduction: 66.90,
  monthlyEnergyProduction: 2007.00,
  yearlyEnergyProduction: 24421.50,
  createdAt: DateTime(...),
  updatedAt: DateTime(...),
)
```

### CalculationDetails
```dart
CalculationDetails(
  usableArea: 75.00,
  maxPowerCapacity: 15.00,
  dailyEnergyProduction: 66.90,
  monthlyEnergyProduction: 2007.00,
  yearlyEnergyProduction: 24421.50,
  panelEfficiency: 20,
  systemLosses: 14,
  performanceRatio: 86.00,
)
```

### FinancialMetrics
```dart
FinancialMetrics(
  installationCost: 225000000.00,
  yearlySavings: 35284751.55,
  paybackPeriodYears: 6.38,
  roi25Years: 291.49,
)
```

---

## 🐛 Error Handling

Semua error akan ditangani dengan graceful:

```dart
if (solarProvider.hasError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(solarProvider.errorMessage ?? 'Unknown error'),
      backgroundColor: Colors.red,
    ),
  );
}
```

Error messages yang mungkin:
- `Permintaan tidak valid` (400)
- `Tidak terautentikasi` (401)
- `Akses ditolak` (403)
- `Data tidak ditemukan` (404)
- `Validasi gagal` (422)
- `Terjadi kesalahan pada server` (500)
- `Timeout koneksi`
- `Periksa koneksi internet Anda`

---

## 🔧 Debugging

### Enable API Logging
API Service sudah memiliki built-in logging. Cek console untuk:
- Request details
- Response data
- Error messages

Output example:
```
🌐 API Request: POST /solar-calculations
📤 Body: {address: ..., land_area: ...}
✅ API Response: 201
📥 Data: {success: true, data: {...}}
```

---

## 📱 Contoh Implementasi di HomeScreen

```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load calculations when screen opens
      context.read<SolarProvider>().fetchAllCalculations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SolarEase'),
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
            return Center(child: CircularProgressIndicator());
          }

          if (solarProvider.hasError) {
            return Center(
              child: Text('Error: ${solarProvider.errorMessage}'),
            );
          }

          return ListView.builder(
            itemCount: solarProvider.calculations.length,
            itemBuilder: (context, index) {
              final calc = solarProvider.calculations[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(calc.address),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daya: ${calc.maxPowerCapacity} kW'),
                      Text('Produksi: ${calc.dailyEnergyProduction} kWh/hari'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('Detail'),
                        onTap: () {
                          solarProvider.fetchCalculationDetails(calc.id ?? 0);
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Hapus'),
                        onTap: () {
                          solarProvider.deleteCalculation(calc.id ?? 0);
                        },
                      ),
                    ],
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
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## ✨ Next Steps

1. **Setup Backend** - Pastikan backend server berjalan di `http://localhost:8000`
2. **Integrate into Screens** - Gunakan SolarProvider di screens yang membutuhkan
3. **Add UI Components** - Buat form untuk create/update calculations
4. **Testing** - Test semua endpoints dengan Postman atau Thunder Client
5. **Error Handling** - Customize error messages sesuai kebutuhan

---

## 📞 Support

Untuk pertanyaan atau issues:
1. Cek API_INTEGRATION_GUIDE.dart untuk contoh lengkap
2. Lihat console logging untuk debug info
3. Pastikan backend server berjalan dengan baik
4. Verifikasi URL endpoint di api_service.dart

Selamat mengintegrasikan! 🚀
