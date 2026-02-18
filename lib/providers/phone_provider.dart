import 'package:flutter/foundation.dart';
import '../models/phone.dart';
import '../services/hive_service.dart';

class PhoneProvider with ChangeNotifier {
  List<Phone> _phones = [];
  List<Phone> _filteredPhones = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Phone> get phones => _searchQuery.isEmpty ? _availablePhones : _filteredPhones;
  List<Phone> get allPhones => _phones;
  List<Phone> get availablePhones => _availablePhones;
  List<Phone> get soldPhones => _phones.where((p) => p.status == 'sold').toList();
  bool get isLoading => _isLoading;

  List<Phone> get _availablePhones =>
      _phones.where((p) => p.status == 'available').toList();

  Future<void> loadPhones({bool showLoading = false}) async {
    debugPrint('🔄 loadPhones called. Current phones: ${_phones.length}');
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _phones = await HiveService.getAllPhones();
      debugPrint('📱 Loaded ${_phones.length} phones (${_availablePhones.length} available)');
      _applyFilter();
    } catch (e) {
      debugPrint('❌ Error loading phones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPhone(Phone phone) async {
    debugPrint('➕ addPhone called for: ${phone.brand} ${phone.model}');
    try {
      await HiveService.addPhone(phone);
      _phones = await HiveService.getAllPhones();
      _applyFilter();
      notifyListeners();
      debugPrint('✅ Phone added. Total: ${_phones.length}');
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

  /// Mark a phone as sold
  Future<void> markAsSold(int phoneId) async {
    final phone = _phones.firstWhere((p) => p.id == phoneId);
    final updatedPhone = phone.copyWith(
      status: 'sold',
      dateSold: DateTime.now(),
    );
    await HiveService.updatePhone(updatedPhone);
    _phones = await HiveService.getAllPhones();
    _applyFilter();
    notifyListeners();
    debugPrint('✅ Phone ${phone.brand} ${phone.model} marked as sold');
  }

  /// Mark a sold phone as returned (back to available)
  Future<void> markAsReturned(int phoneId) async {
    final phone = _phones.firstWhere((p) => p.id == phoneId);
    final updatedPhone = phone.copyWith(
      status: 'available',
    );
    await HiveService.updatePhone(updatedPhone);
    _phones = await HiveService.getAllPhones();
    _applyFilter();
    notifyListeners();
    debugPrint('✅ Phone ${phone.brand} ${phone.model} returned to inventory');
  }

  /// Check for duplicate IMEI
  Future<bool> isDuplicateImei(String imei, {int? excludeId}) async {
    return HiveService.isDuplicateImei(imei, excludeId: excludeId);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPhones = List.from(_availablePhones);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredPhones = _availablePhones.where((phone) {
        return phone.brand.toLowerCase().contains(query) ||
            phone.model.toLowerCase().contains(query) ||
            phone.sellingPrice.toString().contains(query) ||
            phone.imei1.toLowerCase().contains(query) ||
            (phone.imei2?.toLowerCase().contains(query) ?? false) ||
            (phone.color?.toLowerCase().contains(query) ?? false) ||
            (phone.storage?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }
}
