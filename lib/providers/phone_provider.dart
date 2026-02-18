import 'package:flutter/foundation.dart';
import '../models/phone.dart';
import '../services/hive_service.dart';

class PhoneProvider with ChangeNotifier {
  List<Phone> _phones = [];
  List<Phone> _filteredPhones = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Phone> get phones => _searchQuery.isEmpty ? _phones : _filteredPhones;
  List<Phone> get allPhones => _phones;
  bool get isLoading => _isLoading;

  Future<void> loadPhones({bool showLoading = false}) async {
    debugPrint('🔄 loadPhones called. Current phones: ${_phones.length}');
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _phones = await HiveService.getAllPhones();
      debugPrint('📱 Loaded ${_phones.length} phones from Hive');
      _applyFilter();
    } catch (e) {
      debugPrint('❌ Error loading phones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('✅ notifyListeners called. phones.length: ${phones.length}');
    }
  }

  Future<void> addPhone(Phone phone) async {
    debugPrint('➕ addPhone called for: ${phone.brand} ${phone.model}');
    try {
      await HiveService.addPhone(phone);
      debugPrint('✅ HiveService.addPhone completed');
      // Reload from Hive to get the generated ID
      _phones = await HiveService.getAllPhones();
      debugPrint('📱 After add, loaded ${_phones.length} phones');
      _applyFilter();
      notifyListeners();
      debugPrint('✅ notifyListeners called after add');
    } catch (e) {
      debugPrint('❌ Error in addPhone: $e');
      rethrow;
    }
  }

  Future<void> updatePhone(Phone phone) async {
    try {
      await HiveService.updatePhone(phone);
      _phones = await HiveService.getAllPhones();
      _applyFilter();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error in updatePhone: $e');
      rethrow;
    }
  }

  Future<void> deletePhone(int id) async {
    try {
      await HiveService.deletePhone(id);
      _phones = await HiveService.getAllPhones();
      _applyFilter();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error in deletePhone: $e');
      rethrow;
    }
  }

  Future<bool> sellPhone(int phoneId, int quantity) async {
    final phone = _phones.firstWhere((p) => p.id == phoneId);

    if (phone.stock < quantity) {
      debugPrint('❌ Not enough stock. Available: ${phone.stock}, Requested: $quantity');
      return false;
    }

    final updatedPhone = phone.copyWith(stock: phone.stock - quantity);
    try {
      await HiveService.updatePhone(updatedPhone);
      _phones = await HiveService.getAllPhones();
      _applyFilter();
      notifyListeners();
      debugPrint('✅ Sold $quantity units of ${phone.brand} ${phone.model}. Remaining stock: ${updatedPhone.stock}');
      return true;
    } catch (e) {
      debugPrint('❌ Error in sellPhone: $e');
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPhones = List.from(_phones);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredPhones = _phones.where((phone) {
        final matchesBrand = phone.brand.toLowerCase().contains(query);
        final matchesModel = phone.model.toLowerCase().contains(query);
        final matchesPrice = phone.price.toString().contains(query);
        final matchesImei1 = phone.imei1?.toLowerCase().contains(query) ?? false;
        final matchesImei2 = phone.imei2?.toLowerCase().contains(query) ?? false;
        return matchesBrand || matchesModel || matchesPrice || matchesImei1 || matchesImei2;
      }).toList();
    }
  }
}
