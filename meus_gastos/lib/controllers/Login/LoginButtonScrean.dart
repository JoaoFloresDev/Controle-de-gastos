import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';
import 'LoginRoute.dart';

class LoginButtonScrean extends StatelessWidget {
  Widget build(BuildContext context) {
    // LoginViewModel modelView = context.read<LoginViewModel>();
    // modelView.isProCheck();

    return Consumer<LoginViewModel>(
        builder: (context, viewModel, child) => GestureDetector(
              onTap: () {
                if (viewModel.isLogin)
                  LoginRoute().logoutScreen(context);
                else
                  LoginRoute().loginScrean(context, viewModel);
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
            ));
  }
}
