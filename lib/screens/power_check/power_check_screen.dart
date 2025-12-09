import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/custom_button.dart';
import '../../models/location_model.dart';
import 'map_picker_screen.dart';

class PowerCheckScreen extends StatefulWidget {
  const PowerCheckScreen({Key? key}) : super(key: key);

  @override
  State<PowerCheckScreen> createState() => _PowerCheckScreenState();
}

class _PowerCheckScreenState extends State<PowerCheckScreen> {
  final TextEditingController _areaController = TextEditingController();
  String selectedLocation = 'Select Location';
  LocationModel? pickedLocation;
  bool _showResult = false;

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null) {
      setState(() {
        pickedLocation = result;
        selectedLocation = result.address;
      });
    }
  }

  void _verifyDetails() {
    if (_areaController.text.isEmpty || pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    setState(() {
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGold,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Power Check',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.location_on_outlined, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Select Location',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _openMapPicker,
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedLocation,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to select on map',
                                      style: TextStyle(
                                        color: AppTheme.primaryGold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Icon(Icons.home_outlined, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Area',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _areaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter the roof area you want to use (e.g. 20 m²)',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primaryGold, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        label: 'Verify Details',
                        onPressed: _verifyDetails,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Or ',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'click here',
                                style: const TextStyle(
                                  color: AppTheme.primaryGold,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' to scan barcode to connect(check it on inverter)',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (_showResult)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showResult = false;
                });
              },
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Power Check Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.flash_on, color: Colors.grey, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Capacity (watts or Kilowatts)',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          label: 'Confirm',
                          onPressed: () {
                            setState(() {
                              _showResult = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Power check confirmed!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}