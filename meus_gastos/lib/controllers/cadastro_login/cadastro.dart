import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/cadastro_login/login.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/authentication.dart';
import 'package:meus_gastos/snackbarPaste/snackbarAuth.dart';

class singUpScreen extends StatefulWidget {
  @override
  _singUpScreen createState() => _singUpScreen();
}

class _singUpScreen extends State<singUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassowrdController = TextEditingController();
  bool _isObscured = true;
  String? errorMenssage;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            CustomHeader(
              title: AppLocalizations.of(context)!.signup,
              onCancelPressed: () {
                Navigator.of(context).pop();
              },
              onDeletePressed: () {},
              showDeleteButton: false,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                  ),
                  CupertinoTextField(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.label,
                        ),
                      ),
                    ),
                    placeholder: AppLocalizations.of(context)!.name,
                    placeholderStyle:
                        TextStyle(color: AppColors.labelPlaceholder),
                    style: const TextStyle(color: AppColors.label),
                    controller: nameController,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  CupertinoTextField(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.label,
                        ),
                      ),
                    ),
                    placeholder: "Email",
                    placeholderStyle:
                        TextStyle(color: AppColors.labelPlaceholder),
                    style: const TextStyle(color: AppColors.label),
                    controller: emailController,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  CupertinoTextField(
                    obscureText: _isObscured,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.label,
                        ),
                      ),
                    ),
                    placeholder: AppLocalizations.of(context)!.password,
                    placeholderStyle:
                        TextStyle(color: AppColors.labelPlaceholder),
                    suffix: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      child: Icon(
                        _isObscured
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: AppColors.labelPlaceholder,
                      ),
                    ),
                    style: TextStyle(color: AppColors.label),
                    controller: passwordController,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  if (errorMenssage != null) ...[
                    Text(
                      errorMenssage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Text(
                      "Cadastrado com sucesso!",
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: AppColors.button,
                        onPressed: () {
                          signupAuthentication();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.signup,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.label),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(context).pop();
                        _singInScreen();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.alreadyHaveAccount,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: AppColors.label,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _singInScreen() {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.05,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: singInScreen(), // Aqui chamamos a função que retorna o widget
        );
      },
    );
  }

  void signupAuthentication() {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    if ((name.length > 0) && (email.length > 0) && (password.length > 0)) {
      Authentication()
          .signupUser(
              name: nameController.text,
              email: emailController.text,
              password: passwordController.text)
          .then((String? error) {
        if (error != null) {
          print("voltou com erro");
          setState(() {
            errorMenssage = error;
          });
        } else {
          print("Deu certo");
          // showCupertinoSnackBar(context, "Cadastrado com sucesso", false);
        }
      });
    }
  }

  void showCupertinoSnackBar(
      BuildContext context, String message, bool isError) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoSnackBar(
            message: message,
            duration: const Duration(seconds: 2),
            isError: isError);
      },
    );
  }
}
