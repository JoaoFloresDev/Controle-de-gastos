import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLogin = false;
  bool get isLogin => _isLogin;

  void init() {
    isLoadingCheck();
  }

  Future<void> isLoadingCheck() async {
    final prefs = await SharedPreferences.getInstance();
    _isLogin = prefs.getBool('isLogin') ?? false;
    notifyListeners();
  }

  Future<void> login(User user) async {
    _isLogin = true;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLogin = false;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);
    notifyListeners();
  }
}
