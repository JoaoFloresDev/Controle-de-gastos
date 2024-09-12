import 'package:shared_preferences/shared_preferences.dart';

class InAppSave {
  static Future<SharedPreferences> data = SharedPreferences.getInstance();

  static Future<void> saveInsertTransationsStatus() async {
    final value = await data;

    value.setBool("InsertTransactions", true);
  }

  static Future<bool> getInsertTransactionsStatus() async {
    final value = await data;
    if (value.containsKey("InsertTransactions")) {
      bool? getData = value.getBool("InsertTransactions");
      return getData!;
    } else {
      return false;
    }
  }
}
