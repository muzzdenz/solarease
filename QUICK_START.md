# 🚀 Quick Start - API Integration

## ⚡ 5 Menit Setup

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Update main.dart
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
        // ... other providers
      ],
      child: MaterialApp(
        title: 'SolarEase',
        home: HomeScreen(),
        routes: {
          '/create-calculation': (context) => CreateCalculationScreen(),
          '/calculations': (context) => CalculationsListScreen(),
        },
      ),
    );
  }
}
```

### Step 3: Use in Your Widget
```dart
// In any widget, fetch calculations:
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<SolarProvider>().fetchAllCalculations();
  });
}

// In your build method:
Consumer<SolarProvider>(
  builder: (context, solarProvider, _) {
    if (solarProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (solarProvider.hasError) {
      return Center(child: Text('Error: ${solarProvider.errorMessage}'));
    }

    return ListView(
      children: solarProvider.calculations
          .map((calc) => ListTile(
            title: Text(calc.address),
            subtitle: Text('Daya: ${calc.maxPowerCapacity} kW'),
          ))
          .toList(),
    );
  },
)
```

---

## 📝 Common Operations

### Create Calculation
```dart
await context.read<SolarProvider>().createCalculation(
  address: 'Jl. Sudirman No. 1, Jakarta Pusat',
  landArea: 100,
  latitude: -6.2088,
  longitude: 106.8456,
  solarIrradiance: 5.2,
);
```

### Get All
```dart
await context.read<SolarProvider>().fetchAllCalculations();
```

### Get Details
```dart
await context.read<SolarProvider>().fetchCalculationDetails(id);
// Then access: solarProvider.currentCalculation
//               solarProvider.currentDetails
//               solarProvider.currentMetrics
```

### Update
```dart
await context.read<SolarProvider>().updateCalculation(
  id,
  landArea: 150,
  panelEfficiency: 22,
);
```

### Delete
```dart
await context.read<SolarProvider>().deleteCalculation(id);
```

---

## 📁 Files Structure

```
lib/
├── models/
│   └── solar_calculation.dart    (5 classes)
├── services/
│   ├── api_service.dart          (HTTP client)
│   └── solar_service.dart        (Business logic)
├── providers/
│   └── solar_provider.dart       (State management)
├── screens/
│   └── power_check/
│       ├── create_calculation_screen.dart
│       └── calculations_list_screen.dart
└── config/
    └── routes.dart               (Update with new routes)
```

---

## ✅ Checklist

- [ ] Run `flutter pub get`
- [ ] Update `main.dart` with Provider
- [ ] Update `routes.dart` with new routes
- [ ] Verify backend URL in `api_service.dart`
- [ ] Test create calculation
- [ ] Test fetch all
- [ ] Test delete

---

## 🎯 Next

1. **Read Full Guide**: `API_INTEGRATION_GUIDE.dart`
2. **Check Setup**: `API_SETUP.md`
3. **View Checklist**: `SETUP_CHECKLIST.md`

---

## 💡 Pro Tips

1. Use `Consumer<SolarProvider>` for reactive updates
2. Check `solarProvider.isLoading` for busy states
3. Check `solarProvider.hasError` for error states
4. All API calls are async, use `await`
5. Provider automatically notifies listeners on state change

---

**Ready to integrate? Let's go! 🚀**
