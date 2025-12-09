import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/service_plan.dart';
import '../../widgets/custom_button.dart';

class ServicePlanDetailScreen extends StatelessWidget {
  final ServicePlan plan;

  const ServicePlanDetailScreen({Key? key, required this.plan}) : super(key: key);

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
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(int.parse(plan.iconColor)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.solar_power,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            plan.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Daya Ideal', plan.capacity),
                    const SizedBox(height: 16),
                    _buildSection('', plan.system),
                    const SizedBox(height: 16),
                    _buildSection('', plan.warranty),
                    const SizedBox(height: 16),
                    _buildSection('', plan.support),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'Confirm',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${plan.name} confirmed!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}