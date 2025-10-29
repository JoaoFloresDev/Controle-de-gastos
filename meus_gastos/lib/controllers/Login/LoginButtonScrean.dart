import 'package:meus_gastos/controllers/Login/Authentication.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';
import 'LoginRoute.dart';

class LoginButtonScrean extends StatelessWidget {
  final VoidCallback onLoginChange;
  final Authentication auth;
  LoginButtonScrean({required this.onLoginChange, required this.auth});

  Widget build(BuildContext context) {
    return Consumer2<LoginViewModel, ProManeger>(
        builder: (context, viewModel, proManeger, child) {
      print("Consumer2 rebuildou: isLogin = ${viewModel.isLogin}");
      return GestureDetector(
        onTap: () async {
          if (viewModel.isLogin)
            LoginRoute().logoutScreen(
              context,
              viewModel,
              proManeger,
              onLoginChange, auth
            );
          else
            LoginRoute()
                .loginScrean(context, viewModel, proManeger, onLoginChange, auth);
          onLoginChange();
        },
        child: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: viewModel.isLogin
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
