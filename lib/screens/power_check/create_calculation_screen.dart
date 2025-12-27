import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/solar_provider.dart';
import '../../config/theme.dart';

class CreateCalculationScreen extends StatefulWidget {
  const CreateCalculationScreen({Key? key}) : super(key: key);

  @override
  State<CreateCalculationScreen> createState() => _CreateCalculationScreenState();
}

class _CreateCalculationScreenState extends State<CreateCalculationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _addressController;
  late TextEditingController _landAreaController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _solarIrradianceController;
  late TextEditingController _panelEfficiencyController;
  late TextEditingController _systemLossesController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _landAreaController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _solarIrradianceController = TextEditingController();
    _panelEfficiencyController = TextEditingController(text: '20');
    _systemLossesController = TextEditingController(text: '14');
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
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final solarProvider = context.read<SolarProvider>();

    final success = await solarProvider.createCalculation(
      address: _addressController.text,
      landArea: double.parse(_landAreaController.text),
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      solarIrradiance: double.parse(_solarIrradianceController.text),
      panelEfficiency: int.parse(_panelEfficiencyController.text),
      systemLosses: int.parse(_systemLossesController.text),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kalkulasi berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );

      // Optionally, navigate back or to detail screen
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${solarProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Kalkulasi Baru'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SolarProvider>(
        builder: (context, solarProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lokasi',
                      hintText: 'Jl. Sudirman No. 1, Jakarta Pusat',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Land Area Field
                  TextFormField(
                    controller: _landAreaController,
                    decoration: InputDecoration(
                      labelText: 'Luas Lahan (m²)',
                      hintText: '100',
                      prefixIcon: Icon(Icons.aspect_ratio),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Luas lahan tidak boleh kosong';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (parsed <= 0) {
                        return 'Luas lahan harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Latitude & Longitude
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: InputDecoration(
                            labelText: 'Latitude',
                            hintText: '-6.2088',
                            prefixIcon: Icon(Icons.public),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Latitude diperlukan';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null || parsed < -90 || parsed > 90) {
                              return 'Invalid latitude';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          decoration: InputDecoration(
                            labelText: 'Longitude',
                            hintText: '106.8456',
                            prefixIcon: Icon(Icons.public),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Longitude diperlukan';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null || parsed < -180 || parsed > 180) {
                              return 'Invalid longitude';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Solar Irradiance
                  TextFormField(
                    controller: _solarIrradianceController,
                    decoration: InputDecoration(
                      labelText: 'Radiasi Matahari (kWh/m²/day)',
                      hintText: '5.2',
                      prefixIcon: Icon(Icons.wb_sunny),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Radiasi matahari tidak boleh kosong';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (parsed <= 0) {
                        return 'Radiasi harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Panel Efficiency
                  TextFormField(
                    controller: _panelEfficiencyController,
                    decoration: InputDecoration(
                      labelText: 'Efisiensi Panel (%)',
                      hintText: '20',
                      prefixIcon: Icon(Icons.assessment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Efisiensi panel tidak boleh kosong';
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (parsed < 1 || parsed > 100) {
                        return 'Efisiensi harus antara 1-100%';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // System Losses
                  TextFormField(
                    controller: _systemLossesController,
                    decoration: InputDecoration(
                      labelText: 'System Losses (%)',
                      hintText: '14',
                      prefixIcon: Icon(Icons.power_settings_new),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'System losses tidak boleh kosong';
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (parsed < 0 || parsed > 100) {
                        return 'System losses harus antara 0-100%';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: solarProvider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: solarProvider.isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              'Buat Kalkulasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
