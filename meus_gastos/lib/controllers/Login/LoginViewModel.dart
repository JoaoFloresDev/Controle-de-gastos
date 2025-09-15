import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:meus_gastos/services/firebase/FirebaseService.dart';

class LoginViewModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLogin = false;
  bool get isLogin => _isLogin;

  bool _isPro = false;
  bool get isPro => _isPro;

  Future<void> isProCheck() async {
    _isPro = await ProManeger().checkUserProStatus();
    notifyListeners();
  }

  void isLoadingCheck() {
    _isLogin = (FirebaseService().userId != null);
  }

  void init() {
    isProCheck();
    isLoadingChange();
  }

  void isLoadingChange() {
    _isLogin = !_isLogin;
    notifyListeners();
  }
}
