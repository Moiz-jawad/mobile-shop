import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/phone.dart';
import '../services/hive_service.dart';

class PhoneProvider with ChangeNotifier {
  List<Phone> _phones = [];
  List<Phone> _filteredPhones = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Phone> get phones => _searchQuery.isEmpty ? _phones : _filteredPhones;
  bool get isLoading => _isLoading;

  Future<void> loadPhones({bool showLoading = false}) async {
    debugPrint('🔄 loadPhones called. Current phones: ${_phones.length}');
    if (showLoading || _phones.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    _phones = await HiveService.getAllPhones();
    debugPrint('📱 Loaded ${_phones.length} phones from Hive');
    _applyFilter();

    if (_isLoading) {
      _isLoading = false;
    }
    notifyListeners();
    debugPrint('✅ notifyListeners called. phones.length: ${phones.length}');
  }

  Future<void> addPhone(Phone phone) async {
    await HiveService.addPhone(phone);
    await loadPhones();
  }

  Future<void> updatePhone(Phone phone) async {
    await HiveService.updatePhone(phone);
    await loadPhones();
  }

  Future<void> deletePhone(int id) async {
    await HiveService.deletePhone(id);
    await loadPhones();
  }

  Future<bool> sellPhone(int phoneId, int quantity) async {
    final phone = _phones.firstWhere((p) => p.id == phoneId);
    
    if (phone.stock < quantity) {
      debugPrint('❌ Not enough stock. Available: ${phone.stock}, Requested: $quantity');
      return false;
    }

    final updatedPhone = phone.copyWith(stock: phone.stock - quantity);
    await HiveService.updatePhone(updatedPhone);
    await loadPhones();
    
    debugPrint('✅ Sold $quantity units of ${phone.brand} ${phone.model}. Remaining stock: ${updatedPhone.stock}');
    return true;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPhones = [];
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredPhones = _phones.where((phone) {
        final matchesBrand = phone.brand.toLowerCase().contains(query);
        final matchesModel = phone.model.toLowerCase().contains(query);
        final matchesPrice = phone.price.toString().contains(query);
        return matchesBrand || matchesModel || matchesPrice;
      }).toList();
    }
  }
}
