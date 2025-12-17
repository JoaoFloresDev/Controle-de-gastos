
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';
import 'LoginRoute.dart';

class LoginButtonScrean extends StatelessWidget {
  final VoidCallback onLoginChange;
  LoginButtonScrean({required this.onLoginChange});

  Widget build(BuildContext context) {
    return Consumer2<LoginViewModel, ProManeger>(
        builder: (context, loginViewModel, proManeger, child) {
      return GestureDetector(
        onTap: () async {
          if (loginViewModel.isLogin)
            LoginRoute().logoutScreen(
              context,
              loginViewModel,
              proManeger,
              onLoginChange,
              
            );
          else
            LoginRoute()
                .loginScrean(context, loginViewModel, proManeger, onLoginChange);

          // onLoginChange();
        },
        child: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: loginViewModel.isLogin

              ? Icon(
                  Icons.cloud,
                  color: AppColors.labelPlaceholder,
                  size: 20,
                )
              : Text(
                  "Login",
                  style: TextStyle(
                    color: AppColors.button,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }
}
