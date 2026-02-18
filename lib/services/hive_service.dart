import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/phone.dart';

class HiveService {
  static const String _boxName = 'phones_v2';
  static Box? _box;

  static Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
      debugPrint('📦 Hive box opened: ${_box!.name}, length: ${_box!.length}');
    }
    return _box!;
  }

  static Future<void> init() async {
    await _getBox();
  }

  static Future<void> addPhone(Phone phone) async {
    try {
      final box = await _getBox();
      
      // Store each field individually to avoid Map casting issues on web
      final phoneMap = <String, dynamic>{
        'brand': phone.brand,
        'model': phone.model,
        'price': phone.price,
        'condition': phone.condition,
        'description': phone.description,
        'stock': phone.stock,
        'imei1': phone.imei1 ?? '',
        'imei2': phone.imei2 ?? '',
      };

      debugPrint('➕ Adding phone: ${phone.brand} ${phone.model}');
      final int id = await box.add(phoneMap);
      debugPrint('✅ Phone added with ID: $id. Total: ${box.length}');
    } catch (e, st) {
      debugPrint('❌ Error adding phone: $e\n$st');
      rethrow;
    }
  }

  static Future<List<Phone>> getAllPhones() async {
    try {
      final box = await _getBox();
      debugPrint('📖 Reading box. Length: ${box.length}');

      final List<Phone> phones = [];
      for (final key in box.keys) {
        try {
          final raw = box.get(key);
          if (raw == null) continue;

          // Handle both Map<dynamic,dynamic> and Map<String,dynamic>
          final Map<String, dynamic> data = {};
          if (raw is Map) {
            raw.forEach((k, v) => data[k.toString()] = v);
          } else {
            debugPrint('⚠️ Unexpected data type for key $key: ${raw.runtimeType}');
            continue;
          }

          final phone = Phone(
            id: key is int ? key : int.tryParse(key.toString()),
            brand: (data['brand'] ?? '').toString(),
            model: (data['model'] ?? '').toString(),
            price: _parseDouble(data['price']),
            condition: (data['condition'] ?? 'New').toString(),
            description: (data['description'] ?? '').toString(),
            stock: _parseInt(data['stock']),
            imei1: _parseNullableString(data['imei1']),
            imei2: _parseNullableString(data['imei2']),
          );
          phones.add(phone);
          debugPrint('  ✅ Loaded: ${phone.brand} ${phone.model} (id: ${phone.id})');
        } catch (e) {
          debugPrint('⚠️ Error parsing phone at key $key: $e');
        }
      }

      debugPrint('✅ Total phones loaded: ${phones.length}');
      return phones;
    } catch (e) {
      debugPrint('❌ Error getting phones: $e');
      return [];
    }
  }

  static Future<void> updatePhone(Phone phone) async {
    try {
      final box = await _getBox();
      if (phone.id == null) {
        debugPrint('⚠️ Cannot update phone without ID');
        return;
      }

      final phoneMap = <String, dynamic>{
        'brand': phone.brand,
        'model': phone.model,
        'price': phone.price,
        'condition': phone.condition,
        'description': phone.description,
        'stock': phone.stock,
        'imei1': phone.imei1 ?? '',
        'imei2': phone.imei2 ?? '',
      };

      debugPrint('✏️ Updating phone ID: ${phone.id}');
      await box.put(phone.id, phoneMap);
      debugPrint('✅ Phone updated');
    } catch (e) {
      debugPrint('❌ Error updating phone: $e');
      rethrow;
    }
  }

  static Future<void> deletePhone(int id) async {
    try {
      final box = await _getBox();
      debugPrint('🗑️ Deleting phone ID: $id');
      await box.delete(id);
      debugPrint('✅ Phone deleted');
    } catch (e) {
      debugPrint('❌ Error deleting phone: $e');
      rethrow;
    }
  }

  // Helper parsers
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }
}
