import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/sale.dart';

class SalesService {
  static const String _boxName = 'sales_box';
  static Box? _box;

  static Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
      debugPrint('📦 Sales Hive box opened: ${_box!.name}, isOpen: ${_box!.isOpen}');
    }
    return _box!;
  }

  static Future<void> init() async {
    // Hive.initFlutter() should be called in main.dart
    await _getBox();
    debugPrint('💰 Sales Storage initialized with Hive');
  }

  static Future<void> addSale(Sale sale) async {
    try {
      final box = await _getBox();
      
      final saleMap = sale.toMap();
      saleMap.remove('id'); // Let Hive handle the key
      
      debugPrint('💰 Logging sale to Hive: ${sale.phoneBrand} ${sale.phoneModel} IMEI: ${sale.phoneImei}');
      await box.add(saleMap); 
    } catch (e) {
      debugPrint('❌ Error logging sale to Hive: $e');
      rethrow;
    }
  }

  static Future<List<Sale>> getAllSales() async {
    try {
      final box = await _getBox();
      
      if (box.isEmpty) {
        return [];
      }
      
      final List<Sale> sales = [];
      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          final map = Map<String, dynamic>.from(data);
          map['id'] = key; // Use Hive key as ID
          sales.add(Sale.fromMap(map));
        }
      }
      
      // Return sorted by timestamp descending (newest first)
      sales.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      debugPrint('✅ Retrieved ${sales.length} sales records');
      return sales;
    } catch (e) {
      debugPrint('❌ Error loading sales from Hive: $e');
      return [];
    }
  }

  static Future<void> clearSales() async {
    try {
      final box = await _getBox();
      await box.clear();
      debugPrint('✨ Sales history cleared');
    } catch (e) {
      debugPrint('❌ Error clearing sales: $e');
      rethrow;
    }
  }
}
