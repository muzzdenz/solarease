import 'package:flutter/material.dart';

class AuthIllustration extends StatelessWidget {
  const AuthIllustration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 80,
            color: Colors.amber.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'SolarEase',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }
}