import 'package:flutter/material.dart';
import 'package:meus_gastos/services/firebase/syncService.dart';
import 'package:meus_gastos/services/AnalyticsService.dart';

class SyncViewModel extends ChangeNotifier {
  bool _isSyncing = false;
  bool _hasSynced = false;

  bool get isSyncing => _isSyncing;
  bool get hasSynced => _hasSynced;

  Future<void> sync(String userId) async {
    _isSyncing = true;
    notifyListeners();

    await SyncService().syncData(userId);
    AnalyticsService().featureUsed('cloud_sync', source: 'settings');

    _isSyncing = false;
    _hasSynced = true;
    notifyListeners();
  }
}