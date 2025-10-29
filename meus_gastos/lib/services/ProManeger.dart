import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProManeger extends ChangeNotifier {
  bool _isPro = false;

  bool get isPro => _isPro;

  Future<bool> checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    _isPro = isYearlyPro || isMonthlyPro;
    notifyListeners();
    return isYearlyPro || isMonthlyPro;
  }

  Future<void> changeProStatus(String keyTypePro, bool newProState) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(keyTypePro, newProState);
    _isPro = newProState;
    notifyListeners();
  }
}
