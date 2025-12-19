import 'package:firebase_auth/firebase_auth.dart';

import 'package:meus_gastos/controllers/Login/AuthenticationSingleton.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';


class LoginViewModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLogin = false;
  bool get isLogin => _isLogin;

  Authentication auth = Authentication();

  void init() {
    isLoadingCheck();
  }

  Future<void> isLoadingCheck() async {
  _user = auth.getCurrentUser();
  _isLogin = user != null;
  notifyListeners();
}

  Future<void> login() async {
    _user = await auth.signInWithGoogle();
    _isLogin = auth.isLoggedIn;

    

    notifyListeners();
  }

  Future<void> logout() async {
    _isLogin = false;
    _user = null;
    await auth.signOut();
    notifyListeners();
  }


}
