import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/service_plan.dart';
import '../../widgets/service_plan_card.dart';
import 'service_plan_detail_screen.dart';

class ServicePlansScreen extends StatelessWidget {
  const ServicePlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plans = ServicePlan.getPlans();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Plans',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGold.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            return ServicePlanCard(
              plan: plans[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServicePlanDetailScreen(plan: plans[index]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}