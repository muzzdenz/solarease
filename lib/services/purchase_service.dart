import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/purchase.dart';

class PurchaseService {
  static const String _key = 'purchase_history';

  Future<void> savePurchase(Purchase purchase) async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> history = prefs.getStringList(_key) ?? [];
    history.insert(0, jsonEncode(purchase.toJson())); // Add to beginning (newest first)
    
    await prefs.setStringList(_key, history);
  }

  Future<List<Purchase>> getPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> history = prefs.getStringList(_key) ?? [];
    return history.map((item) => Purchase.fromJson(jsonDecode(item))).toList();
  }

  Future<void> deletePurchase(String id) async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> history = prefs.getStringList(_key) ?? [];
    history.removeWhere((item) {
      final purchase = Purchase.fromJson(jsonDecode(item));
      return purchase.id == id;
    });
    
    await prefs.setStringList(_key, history);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<int> getPurchaseCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    return history.length;
  }

  Future<int> getTotalRevenue() async {
    final purchases = await getPurchaseHistory();
    int total = 0;
    for (var purchase in purchases) {
      total += purchase.grandTotal;
    }
    return total;
  }
}
