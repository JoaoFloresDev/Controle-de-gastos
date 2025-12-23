import 'package:flutter/material.dart';
import 'package:meus_gastos/services/firebase/syncService.dart';

class SyncViewModel extends ChangeNotifier {
  bool _isSyncing = false;
  bool _hasSynced = false;

  bool get isSyncing => _isSyncing;
  bool get hasSynced => _hasSynced;

  Future<void> sync(String userId) async {
    _isSyncing = true;
    notifyListeners();

    await SyncService().syncData(userId);

    _isSyncing = false;
    _hasSynced = true;
    notifyListeners();
  }
}