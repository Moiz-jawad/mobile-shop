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
    await _getBox();
    debugPrint('💰 Sales Storage initialized with Hive');
  }

  static Future<void> addSale(Sale sale) async {
    try {
      final box = await _getBox();
      
      final saleMap = sale.toMap();
      saleMap.remove('id');
      saleMap['syncStatus'] = 'pending';
      saleMap['lastModified'] = DateTime.now().toIso8601String();
      
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
          map['id'] = key;
          sales.add(Sale.fromMap(map));
        }
      }
      
      sales.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      debugPrint('✅ Retrieved ${sales.length} sales records');
      return sales;
    } catch (e) {
      debugPrint('❌ Error loading sales from Hive: $e');
      return [];
    }
  }

  /// Get all sales that haven't been synced to Firestore
  static Future<List<Map<String, dynamic>>> getPendingSales() async {
    final box = await _getBox();
    final List<Map<String, dynamic>> pending = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      final Map<String, dynamic> data = {};
      if (raw is Map) {
        raw.forEach((k, v) => data[k.toString()] = v);
      }
      if (data['syncStatus'] != 'synced') {
        data['_hiveKey'] = key;
        pending.add(data);
      }
    }
    return pending;
  }

  /// Mark a sale as synced after successful Firestore upload
  static Future<void> markAsSynced(int hiveKey) async {
    final box = await _getBox();
    final raw = box.get(hiveKey);
    if (raw == null) return;
    final Map<String, dynamic> data = {};
    if (raw is Map) {
      raw.forEach((k, v) => data[k.toString()] = v);
    }
    data['syncStatus'] = 'synced';
    await box.put(hiveKey, data);
  }

  /// Upsert a sale from Firestore (cloud → local)
  static Future<void> upsertFromCloud(Map<String, dynamic> cloudData) async {
    final box = await _getBox();
    final phoneImei = cloudData['phoneImei']?.toString() ?? '';
    final timestamp = cloudData['timestamp']?.toString() ?? '';
    if (phoneImei.isEmpty) return;

    // Find existing by IMEI + timestamp (unique sale identifier)
    int? existingKey;
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map &&
          raw['phoneImei']?.toString() == phoneImei &&
          raw['timestamp']?.toString() == timestamp) {
        existingKey = key is int ? key : int.tryParse(key.toString());
        break;
      }
    }

    cloudData['syncStatus'] = 'synced';
    if (existingKey != null) {
      await box.put(existingKey, cloudData);
    } else {
      await box.add(cloudData);
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
