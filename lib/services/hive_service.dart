import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/phone.dart';

class HiveService {
  static const String _boxName = 'phones_v3';
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

  /// Check if an IMEI already exists in inventory
  static Future<bool> isDuplicateImei(String imei, {int? excludeId}) async {
    final phones = await getAllPhones();
    return phones.any((p) =>
        (p.imei1 == imei || p.imei2 == imei) &&
        p.id != excludeId);
  }

  static Future<void> addPhone(Phone phone) async {
    try {
      final box = await _getBox();

      // Duplicate IMEI check
      if (await isDuplicateImei(phone.imei1)) {
        throw Exception('IMEI ${phone.imei1} already exists in inventory');
      }
      if (phone.imei2 != null && await isDuplicateImei(phone.imei2!)) {
        throw Exception('IMEI ${phone.imei2} already exists in inventory');
      }

      final phoneMap = <String, dynamic>{
        'brand': phone.brand,
        'model': phone.model,
        'imei1': phone.imei1,
        'imei2': phone.imei2 ?? '',
        'condition': phone.condition,
        'color': phone.color ?? '',
        'storage': phone.storage ?? '',
        'batteryHealth': phone.batteryHealth ?? '',
        'purchasePrice': phone.purchasePrice,
        'sellingPrice': phone.sellingPrice,
        'status': phone.status,
        'dateAdded': phone.dateAdded.toIso8601String(),
        'dateSold': phone.dateSold?.toIso8601String() ?? '',
        'description': phone.description ?? '',
        'syncStatus': 'pending',
        'lastModified': DateTime.now().toIso8601String(),
      };

      debugPrint('➕ Adding phone: ${phone.brand} ${phone.model} IMEI: ${phone.imei1}');
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
      final List<Phone> phones = [];

      for (final key in box.keys) {
        try {
          final raw = box.get(key);
          if (raw == null) continue;

          final Map<String, dynamic> data = {};
          if (raw is Map) {
            raw.forEach((k, v) => data[k.toString()] = v);
          } else {
            continue;
          }

          final phone = Phone(
            id: key is int ? key : int.tryParse(key.toString()),
            brand: (data['brand'] ?? '').toString(),
            model: (data['model'] ?? '').toString(),
            imei1: (data['imei1'] ?? '').toString(),
            imei2: _parseNullableString(data['imei2']),
            condition: (data['condition'] ?? 'New').toString(),
            color: _parseNullableString(data['color']),
            storage: _parseNullableString(data['storage']),
            batteryHealth: _parseNullableString(data['batteryHealth']),
            purchasePrice: _parseDouble(data['purchasePrice']),
            sellingPrice: _parseDouble(data['sellingPrice'] ?? data['price']),
            status: (data['status'] ?? 'available').toString(),
            dateAdded: DateTime.tryParse(data['dateAdded']?.toString() ?? '') ?? DateTime.now(),
            dateSold: DateTime.tryParse(data['dateSold']?.toString() ?? ''),
            description: _parseNullableString(data['description']),
          );
          phones.add(phone);
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

      // Duplicate IMEI check (exclude current phone)
      if (await isDuplicateImei(phone.imei1, excludeId: phone.id)) {
        throw Exception('IMEI ${phone.imei1} already exists in inventory');
      }
      if (phone.imei2 != null && await isDuplicateImei(phone.imei2!, excludeId: phone.id)) {
        throw Exception('IMEI ${phone.imei2} already exists in inventory');
      }

      final phoneMap = <String, dynamic>{
        'brand': phone.brand,
        'model': phone.model,
        'imei1': phone.imei1,
        'imei2': phone.imei2 ?? '',
        'condition': phone.condition,
        'color': phone.color ?? '',
        'storage': phone.storage ?? '',
        'batteryHealth': phone.batteryHealth ?? '',
        'purchasePrice': phone.purchasePrice,
        'sellingPrice': phone.sellingPrice,
        'status': phone.status,
        'dateAdded': phone.dateAdded.toIso8601String(),
        'dateSold': phone.dateSold?.toIso8601String() ?? '',
        'description': phone.description ?? '',
        'syncStatus': 'pending',
        'lastModified': DateTime.now().toIso8601String(),
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

  /// Get all phones that haven't been synced to Firestore yet
  static Future<List<Map<String, dynamic>>> getPendingPhones() async {
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

  /// Mark a phone as synced after successful Firestore upload
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

  /// Get all phone records as raw maps (for sync)
  static Future<List<Map<String, dynamic>>> getAllPhoneRawMaps() async {
    final box = await _getBox();
    final List<Map<String, dynamic>> results = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      final Map<String, dynamic> data = {};
      if (raw is Map) {
        raw.forEach((k, v) => data[k.toString()] = v);
      }
      data['_hiveKey'] = key;
      results.add(data);
    }
    return results;
  }

  /// Upsert a phone from Firestore (cloud → local)
  static Future<void> upsertFromCloud(Map<String, dynamic> cloudData) async {
    final box = await _getBox();
    final imei1 = cloudData['imei1']?.toString() ?? '';
    if (imei1.isEmpty) return;

    // Find existing by IMEI
    int? existingKey;
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map && raw['imei1']?.toString() == imei1) {
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

  // Helper parsers
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }
}
