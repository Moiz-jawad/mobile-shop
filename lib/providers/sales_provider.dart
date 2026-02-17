import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/sales_service.dart';

class SalesProvider with ChangeNotifier {
  List<Sale> _sales = [];
  bool _isLoading = false;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    _sales = await SalesService.getAllSales();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logSale(Sale sale) async {
    await SalesService.addSale(sale);
    await loadSales(); // Reload to update UI
  }

  double get todayTotalSales {
    final today = DateTime.now();
    return _sales.where((sale) {
      return sale.timestamp.year == today.year &&
             sale.timestamp.month == today.month &&
             sale.timestamp.day == today.day;
    }).fold(0.0, (sum, sale) => sum + sale.totalPrice);
  }
}
