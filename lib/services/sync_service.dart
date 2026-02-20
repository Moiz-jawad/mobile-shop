import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';
import 'sales_service.dart';

/// Sync status for UI indicators
enum SyncState { idle, syncing, synced, offline, error }

/// Background service that syncs Hive data ↔ Firestore
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;
  bool _initialized = false;

  // Stream controller for sync state
  final _syncStateController = StreamController<SyncState>.broadcast();
  Stream<SyncState> get syncStateStream => _syncStateController.stream;
  SyncState _currentState = SyncState.idle;
  SyncState get currentState => _currentState;
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Firestore collection names
  static const String _phonesCollection = 'phones';
  static const String _salesCollection = 'sales';

  /// Initialize the sync service — starts listening to connectivity
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('🔄 SyncService initialized');

    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (isOnline) {
      _setState(SyncState.idle);
      // Trigger initial sync
      await syncAll();
    } else {
      _setState(SyncState.offline);
    }

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isConnected = !results.contains(ConnectivityResult.none);
        if (isConnected) {
          debugPrint('🌐 Online — triggering sync...');
          await syncAll();
        } else {
          debugPrint('📴 Offline');
          _setState(SyncState.offline);
        }
      },
    );
  }

  /// Full bidirectional sync
  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _setState(SyncState.syncing);

    try {
      // Step 1: Push pending local data → Firestore
      await _pushPendingPhones();
      await _pushPendingSales();

      // Step 2: Pull cloud data → Hive (only records we don't have locally)
      await _pullCloudPhones();
      await _pullCloudSales();

      _lastSyncTime = DateTime.now();
      _setState(SyncState.synced);
      debugPrint('✅ Sync completed at $_lastSyncTime');
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      _setState(SyncState.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Push unsynced phones from Hive → Firestore
  Future<void> _pushPendingPhones() async {
    final pending = await HiveService.getPendingPhones();
    if (pending.isEmpty) return;

    debugPrint('📤 Pushing ${pending.length} pending phones to Firestore...');
    for (final phoneData in pending) {
      try {
        final hiveKey = phoneData['_hiveKey'];
        final imei1 = phoneData['imei1']?.toString() ?? '';
        if (imei1.isEmpty) continue;

        // Remove internal fields before uploading
        final uploadData = Map<String, dynamic>.from(phoneData);
        uploadData.remove('_hiveKey');
        uploadData.remove('syncStatus');

        // Use IMEI as document ID for idempotent writes
        await _firestore.collection(_phonesCollection).doc(imei1).set(
              uploadData,
              SetOptions(merge: true),
            );

        // Mark as synced locally
        if (hiveKey is int) {
          await HiveService.markAsSynced(hiveKey);
        }
        debugPrint('  ✅ Synced phone: $imei1');
      } catch (e) {
        debugPrint('  ❌ Failed to sync phone: $e');
      }
    }
  }

  /// Push unsynced sales from Hive → Firestore
  Future<void> _pushPendingSales() async {
    final pending = await SalesService.getPendingSales();
    if (pending.isEmpty) return;

    debugPrint('📤 Pushing ${pending.length} pending sales to Firestore...');
    for (final saleData in pending) {
      try {
        final hiveKey = saleData['_hiveKey'];
        final phoneImei = saleData['phoneImei']?.toString() ?? '';
        final timestamp = saleData['timestamp']?.toString() ?? '';

        // Create a unique doc ID from IMEI + timestamp
        final docId = '${phoneImei}_$timestamp'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

        final uploadData = Map<String, dynamic>.from(saleData);
        uploadData.remove('_hiveKey');
        uploadData.remove('syncStatus');

        await _firestore.collection(_salesCollection).doc(docId).set(
              uploadData,
              SetOptions(merge: true),
            );

        if (hiveKey is int) {
          await SalesService.markAsSynced(hiveKey);
        }
        debugPrint('  ✅ Synced sale: $docId');
      } catch (e) {
        debugPrint('  ❌ Failed to sync sale: $e');
      }
    }
  }

  /// Pull phones from Firestore → Hive (for records we don't have locally)
  Future<void> _pullCloudPhones() async {
    try {
      final snapshot = await _firestore.collection(_phonesCollection).get();
      if (snapshot.docs.isEmpty) return;

      debugPrint('📥 Pulling ${snapshot.docs.length} phones from Firestore...');
      for (final doc in snapshot.docs) {
        final cloudData = doc.data();
        // Check by lastModified to resolve conflicts (latest wins)
        await HiveService.upsertFromCloud(cloudData);
      }
    } catch (e) {
      debugPrint('❌ Error pulling phones: $e');
    }
  }

  /// Pull sales from Firestore → Hive
  Future<void> _pullCloudSales() async {
    try {
      final snapshot = await _firestore.collection(_salesCollection).get();
      if (snapshot.docs.isEmpty) return;

      debugPrint('📥 Pulling ${snapshot.docs.length} sales from Firestore...');
      for (final doc in snapshot.docs) {
        final cloudData = doc.data();
        await SalesService.upsertFromCloud(cloudData);
      }
    } catch (e) {
      debugPrint('❌ Error pulling sales: $e');
    }
  }

  void _setState(SyncState state) {
    _currentState = state;
    _syncStateController.add(state);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStateController.close();
  }
}
