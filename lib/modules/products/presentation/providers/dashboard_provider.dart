// lib/modules/products/presentation/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';

class DashboardProvider extends ChangeNotifier {
  bool _showExpiringSoon = false;
  bool _showLowStock = false;

  bool get showExpiringSoon => _showExpiringSoon;
  bool get showLowStock => _showLowStock;

  void toggleExpiringSoonFilter(bool value) {
    _showExpiringSoon = value;
    notifyListeners();
  }

  void toggleLowStockFilter(bool value) {
    _showLowStock = value;
    notifyListeners();
  }

  List<ProductModel> applyFilters(List<ProductModel> products) {
    return products.where((product) {
      final now = DateTime.now();
      final isExpiringSoon = product.expirationDate
          .isBefore(now.add(const Duration(days: 5)));
      
      final isLowStock = product.quantity < product.minStock;

      if (_showExpiringSoon && _showLowStock) return isExpiringSoon && isLowStock;
      if (_showExpiringSoon) return isExpiringSoon;
      if (_showLowStock) return isLowStock;
      
      return true;
    }).toList();
  }
}