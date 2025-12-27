import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';

/// Screen untuk test koneksi ke API Backend
class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiClient _apiClient = ApiClient();
  String _result = 'Belum ada test';
  bool _isLoading = false;

  // Test Health Check
  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing health check...';
    });

    try {
      final response = await _apiClient.healthCheck();
      setState(() {
        _result = '✅ Health Check: ${response.toString()}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Health Check Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test Register
  Future<void> _testRegister() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing register...';
    });

    try {
      final response = await _apiClient.register(
        name: 'Test User',
        email: 'test${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password12345678',
      );
      setState(() {
        _result = '✅ Register: ${response['message']}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Register Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test Login
  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing login...';
    });

    try {
      final response = await _apiClient.login(
        email: 'test@test.com',
        password: 'password123',
      );
      if (response['success'] == true) {
        setState(() {
          _result = '✅ Login Success!\nToken: ${response['data']['token']?.toString().substring(0, 20)}...';
        });
      } else {
        setState(() {
          _result = '⚠️ Login Response: ${response['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _result = '❌ Login Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test Get Products
  Future<void> _testGetProducts() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing get products...';
    });

    try {
      final response = await _apiClient.getProducts();
      final products = response['data'] as List?;
      setState(() {
        _result = '✅ Get Products:\nTotal: ${products?.length ?? 0} products\n${response['message']}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Get Products Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test Forgot Password
  Future<void> _testForgotPassword() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing forgot password...';
    });

    try {
      final response = await _apiClient.forgotPassword('test@test.com');
      setState(() {
        _result = '✅ Forgot Password: ${response['message']}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Forgot Password Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test Get Current User (Protected)
  Future<void> _testGetCurrentUser() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing get current user (protected)...';
    });

    try {
      final response = await _apiClient.getCurrentUser();
      setState(() {
        _result = '✅ Current User:\n${response['data'].toString()}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Get Current User Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Backend Test'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Box
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backend URL: http://localhost:8000/api',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pastikan backend sudah berjalan di localhost:8000',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Test Buttons - Public Endpoints
              Text(
                '🟡 PUBLIC ENDPOINTS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildTestButton(
                label: 'Health Check',
                onPressed: _testHealthCheck,
                color: Colors.green,
              ),
              SizedBox(height: 8),
              _buildTestButton(
                label: 'Register User',
                onPressed: _testRegister,
                color: Colors.green,
              ),
              SizedBox(height: 8),
              _buildTestButton(
                label: 'Login',
                onPressed: _testLogin,
                color: Colors.green,
              ),
              SizedBox(height: 8),
              _buildTestButton(
                label: 'Forgot Password',
                onPressed: _testForgotPassword,
                color: Colors.green,
              ),
              SizedBox(height: 8),
              _buildTestButton(
                label: 'Get Products',
                onPressed: _testGetProducts,
                color: Colors.green,
              ),

              SizedBox(height: 20),

              // Test Buttons - Protected Endpoints
              Text(
                '🔴 PROTECTED ENDPOINTS (Perlu Token)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildTestButton(
                label: 'Get Current User',
                onPressed: _testGetCurrentUser,
                color: Colors.red,
              ),

              SizedBox(height: 24),

              // Result Box
              Text(
                'Response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: _isLoading
                    ? Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading...'),
                        ],
                      )
                    : Text(
                        _result,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
              ),

              SizedBox(height: 20),

              // Info
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 Petunjuk:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('1. Pastikan backend berjalan di localhost:8000'),
                      Text('2. Test Health Check terlebih dahulu'),
                      Text('3. Untuk protected endpoints, login dulu'),
                      Text('4. Cek console untuk log detail'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
