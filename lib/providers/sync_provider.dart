import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  StreamSubscription? _subscription;

  SyncState _state = SyncState.idle;
  SyncState get state => _state;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;

  String get statusText {
    switch (_state) {
      case SyncState.idle:
        return 'Ready';
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.synced:
        return 'Synced';
      case SyncState.offline:
        return 'Offline';
      case SyncState.error:
        return 'Sync Error';
    }
  }

  IconData get statusIcon {
    switch (_state) {
      case SyncState.idle:
        return Icons.cloud_outlined;
      case SyncState.syncing:
        return Icons.sync;
      case SyncState.synced:
        return Icons.cloud_done;
      case SyncState.offline:
        return Icons.cloud_off;
      case SyncState.error:
        return Icons.error_outline;
    }
  }

  Color get statusColor {
    switch (_state) {
      case SyncState.idle:
        return Colors.grey;
      case SyncState.syncing:
        return Colors.blue;
      case SyncState.synced:
        return Colors.green;
      case SyncState.offline:
        return Colors.orange;
      case SyncState.error:
        return Colors.red;
    }
  }
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _subscription = _syncService.syncStateStream.listen((state) {
      _state = state;
      notifyListeners();
    });

    await _syncService.init();
    _state = _syncService.currentState;
    notifyListeners();
  }

  /// Manually trigger a full sync
  Future<void> manualSync() async {
    await _syncService.syncAll();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _syncService.dispose();
    super.dispose();
  }
}
