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

  Map<String, double> get salesByBrand {
    final Map<String, double> data = {};
    for (var sale in _sales) {
      data[sale.phoneBrand] = (data[sale.phoneBrand] ?? 0.0) + sale.totalPrice;
    }
    return data;
  }

  Map<DateTime, double> get last7DaysSales {
    final Map<DateTime, double> data = {};
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      data[date] = 0.0;
    }

    for (var sale in _sales) {
      final saleDate = DateTime(sale.timestamp.year, sale.timestamp.month, sale.timestamp.day);
      if (data.containsKey(saleDate)) {
        data[saleDate] = (data[saleDate] ?? 0.0) + sale.totalPrice;
      }
    }
    return data;
  }
}
