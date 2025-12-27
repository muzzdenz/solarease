# 🔧 Troubleshooting Guide

## ❌ Common Issues & Solutions

### 1. "Failed to resolve flutter package"

**Error:**
```
E/flutter ( 1234): [ERROR:flutter/runtime/dart_isolate.cc(71)] Unhandled 
Exception: MissingPluginException(No implementation found for method ...)
```

**Solution:**
```bash
flutter pub get
flutter pub upgrade
flutter clean
flutter pub get
```

---

### 2. "Cannot find api_service.dart"

**Problem:** Import path tidak benar

**Solution:**
```dart
// ✅ Benar
import 'package:solarease/services/api_service.dart';
import 'package:solarease/services/solar_service.dart';

// ❌ Salah
import '../../services/api_service.dart'; // Jika struktur folder berbeda
```

---

### 3. "Cannot find SolarProvider"

**Problem:** Provider belum di-setup di main.dart

**Solution:**
Di `lib/main.dart`:
```dart
import 'package:provider/provider.dart';
import 'providers/solar_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SolarProvider()),
        // ... provider lainnya
      ],
      child: MaterialApp(...),
    );
  }
}
```

---

### 4. "Network error: Connection failed"

**Problem:** Backend tidak berjalan atau URL salah

**Checklist:**
- [ ] Backend server running di `http://localhost:8000`
- [ ] Database sudah initialized
- [ ] API endpoint accessible
- [ ] Network connectivity OK

**Test:**
```bash
# Dari terminal
curl http://localhost:8000/api/powerestimation/solar-calculations

# Dari Postman
GET http://localhost:8000/api/powerestimation/solar-calculations
```

---

### 5. "API returns 404 Not Found"

**Problem:** Endpoint tidak ada di backend

**Check:**
```dart
// Di api_service.dart
static const String baseUrl = 'http://localhost:8000/api/powerestimation';

// Endpoint yang dipanggil
// POST /solar-calculations
// GET /solar-calculations
// GET /solar-calculations/{id}
// PATCH /solar-calculations/{id}
// DELETE /solar-calculations/{id}
```

**Verifikasi:**
- Backend routes sudah defined dengan benar
- URL path exact match

---

### 6. "Validation error: The land area field is required"

**Problem:** Request body tidak lengkap

**Solution:**
Pastikan semua required fields ada:
```dart
await solarProvider.createCalculation(
  address: 'Alamat', // ✅ Required
  landArea: 100,     // ✅ Required
  latitude: -6.2088, // ✅ Required
  longitude: 106.8456, // ✅ Required
  solarIrradiance: 5.2, // ✅ Required
  // Optional dengan default:
  panelEfficiency: 20,
  systemLosses: 14,
);
```

---

### 7. "Provider not found in context"

**Error:**
```
Error: Could not find the correct Provider<SolarProvider> above this...
```

**Solution:**
- Wrap widget dengan `Consumer<SolarProvider>`
- Atau gunakan `context.read<SolarProvider>()`
- Pastikan MultiProvider di main.dart sudah ada

```dart
// ✅ Benar
Consumer<SolarProvider>(
  builder: (context, solarProvider, _) {
    return Text(solarProvider.calculations.length.toString());
  },
)

// ❌ Salah
Text(context.read<SolarProvider>().calculations.length.toString());
// ^ Hanya di dalam Consumer atau after build
```

---

### 8. "Timeout: Request took too long"

**Problem:** Backend lambat atau network issue

**Solution:**
Ubah timeout di `lib/services/api_service.dart`:
```dart
_dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30), // ← Ubah dari 10s
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);
```

---

### 9. "CORS error"

**Error:**
```
Access to XMLHttpRequest at 'http://localhost:8000/api/powerestimation/...' 
from origin... has been blocked by CORS policy
```

**Solution:**
Backend harus accept Flutter client. Pastikan header di backend:
```php
// Laravel example
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

---

### 10. "setState() called after dispose()"

**Error:**
```
setState() called after dispose() of _MyScreenState.
```

**Solution:**
```dart
// ❌ Salah
Future<void> _loadData() async {
  await _solarService.fetchAll();
  setState(() { /* ... */ }); // Bisa error jika screen disposed
}

// ✅ Benar
Future<void> _loadData() async {
  final data = await _solarService.fetchAll();
  if (!mounted) return; // ← Cek apakah widget masih ada
  setState(() {
    _data = data;
  });
}
```

---

### 11. "Widget not showing data after API call"

**Problem:** Data tidak update di UI

**Causes & Solutions:**

1. **Forgot to call setState()**
   ```dart
   // Jika tidak pakai Provider:
   final result = await _solarService.fetchAll();
   if (!mounted) return;
   setState(() {
     _data = result; // ← Penting!
   });
   ```

2. **Using Consumer but data tidak berubah**
   ```dart
   // Pastikan Provider call notifyListeners()
   // Cek di solar_provider.dart:
   void _setLoading(bool value) {
     _isLoading = value;
     notifyListeners(); // ← Must have this
   }
   ```

3. **Data ada tapi tidak rebuild**
   ```dart
   // Gunakan Consumer, bukan context.read
   Consumer<SolarProvider>(
     builder: (context, provider, _) {
       return Text(provider.calculations.toString());
     },
   )
   ```

---

### 12. "JSON parsing error"

**Error:**
```
FormatException: Unexpected character ...
type '_InternalLinkedHashMap<String, dynamic>' is not a subtype of type 'Map<String, dynamic>'
```

**Solution:**
```dart
// Di model, ensure proper JSON handling:
factory SolarCalculation.fromJson(Map<String, dynamic> json) {
  return SolarCalculation(
    // ✅ Proper type casting
    latitude: (json['latitude'] as num).toDouble(),
    landArea: (json['land_area'] as num).toDouble(),
    // ✅ Check null before cast
    maxPowerCapacity: json['max_power_capacity'] != null
        ? (json['max_power_capacity'] as num).toDouble()
        : null,
  );
}
```

---

### 13. "null check operator used on null value"

**Error:**
```
NoSuchMethodError: The getter 'id' was called on null.
```

**Solution:**
```dart
// ❌ Salah
final id = calculation.id;

// ✅ Benar
final id = calculation.id ?? 0;
final id = calculation.id!; // Jika pasti tidak null

// Atau cek dulu:
if (calculation.id != null) {
  _doSomething(calculation.id!);
}
```

---

## 🔍 Debugging Tips

### Enable Verbose Logging
```bash
flutter run -v
```

### View API Logs
Semua API calls di-log otomatis:
```
🌐 API Request: POST /solar-calculations
📤 Body: {...}
✅ API Response: 201
📥 Data: {...}
```

### Test with Postman
1. Open Postman
2. Create request: `POST http://localhost:8000/api/powerestimation/solar-calculations`
3. Set headers: `Content-Type: application/json`
4. Send test body
5. Check response

### Use Flutter DevTools
```bash
flutter pub global activate devtools
devtools
```

---

## ✅ Verification Checklist

- [ ] `flutter pub get` completed
- [ ] SolarProvider in main.dart with MultiProvider
- [ ] Routes configured in main.dart or routes.dart
- [ ] Backend running at correct URL
- [ ] Database tables created
- [ ] API endpoints implemented
- [ ] API tests passed in Postman
- [ ] No import errors in IDE
- [ ] App compiles without errors
- [ ] Can create calculation
- [ ] Can fetch calculations
- [ ] Can update calculation
- [ ] Can delete calculation
- [ ] Error messages display correctly

---

## 📊 Debug Checklist

If something not working:

1. **Check Imports**
   - All imports correct?
   - Package paths valid?

2. **Check Configuration**
   - API URL correct?
   - Backend running?
   - Routes defined?

3. **Check Code**
   - Provider setup in main?
   - Consumer wrapping widgets?
   - await used for async calls?

4. **Check Network**
   - Internet connection OK?
   - Backend accessible?
   - API endpoints exist?

5. **Check Logs**
   - Console logs visible?
   - Error messages helpful?
   - Stack trace clear?

---

## 🆘 Still Need Help?

1. Check `API_INTEGRATION_GUIDE.dart` - Complete examples
2. Check `API_SETUP.md` - Setup instructions
3. Check `QUICK_START.md` - Quick reference
4. Review example screens:
   - `create_calculation_screen.dart`
   - `calculations_list_screen.dart`

---

**Happy debugging! 🐛✨**
