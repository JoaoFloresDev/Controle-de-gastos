import 'package:shared_preferences/shared_preferences.dart';

class ProManeger {

  Future<bool> checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    return isYearlyPro || isMonthlyPro;
  }

}
