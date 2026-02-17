import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/phone.dart';

class HiveService {
  static const String _boxName = 'phones_box';
  static Box? _box;

  static Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
      debugPrint('📦 Hive box opened: ${_box!.name}, isOpen: ${_box!.isOpen}');
    }
    return _box!;
  }

  static Future<void> init() async {
    // Hive.initFlutter() should be called in main.dart
    await _getBox();
  }

  static Future<void> addPhone(Phone phone) async {
    try {
      final box = await _getBox();
      // Use box.add() to let Hive generate a valid 32-bit auto-incrementing key
      // This fixes "Integer keys need to be in range 0 - 0xFFFFFFFF" on Web
      final phoneMap = phone.toMap();
      phoneMap.remove('id'); // Remove null or temp ID to let Hive handle it
      
      debugPrint('➕ Adding phone to Hive: $phoneMap');
      final int id = await box.add(phoneMap);
      
      // Optional: Store the ID back in the object if needed, 
      // but retrieving it during getAllPhones is cleaner.
      debugPrint('✅ Phone added with ID: $id. Box length: ${box.length}');
    } catch (e) {
      debugPrint('❌ Error adding phone to Hive: $e');
      rethrow;
    }
  }

  static Future<List<Phone>> getAllPhones() async {
    try {
      final box = await _getBox();
      debugPrint('📖 Getting all phones from Hive. Box length: ${box.length}');

      final List<Phone> phones = [];
      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          final map = Map<String, dynamic>.from(data);
          // Ensure the Hive key is used as the ID
          map['id'] = key;
          phones.add(Phone.fromMap(map));
        }
      }

      debugPrint('✅ Returning ${phones.length} phones');
      return phones;
    } catch (e) {
      debugPrint('❌ Error getting phones from Hive: $e');
      return [];
    }
  }

  static Future<void> updatePhone(Phone phone) async {
    try {
      final box = await _getBox();
      if (phone.id != null) {
        debugPrint('✏️ Updating phone in Hive: ${phone.id}');
        await box.put(phone.id, phone.toMap());
      } else {
        debugPrint('⚠️ Cannot update phone without ID');
      }
    } catch (e) {
      debugPrint('❌ Error updating phone in Hive: $e');
      rethrow;
    }
  }

  static Future<void> deletePhone(int id) async {
    try {
      final box = await _getBox();
      debugPrint('🗑️ Deleting phone from Hive: $id');
      await box.delete(id);
    } catch (e) {
      debugPrint('❌ Error deleting phone from Hive: $id, error: $e');
      rethrow;
    }
  }
}
