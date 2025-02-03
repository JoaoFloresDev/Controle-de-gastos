import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/cadastro_login/logout.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/main.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/authentication.dart';

class singInScreen extends StatefulWidget {
  final VoidCallback updateUser;
  singInScreen({required this.updateUser});
  @override
  _singInScreen createState() => _singInScreen();
}

class _singInScreen extends State<singInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final Authentication _authService = Authentication();

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
              title: AppLocalizations.of(context)!.signin,
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
                    height: 8,
                  ),
                  // CupertinoTextField(
                  //   decoration: const BoxDecoration(
                  //     border: Border(
                  //       bottom: BorderSide(
                  //         color: AppColors.label,
                  //       ),
                  //     ),
                  //   ),
                  //   placeholder: "Email",
                  //   placeholderStyle:
                  //       TextStyle(color: AppColors.labelPlaceholder),
                  //   style: const TextStyle(color: AppColors.label),
                  //   controller: emailController,
                  // ),
                  // SizedBox(
                  //   height: 8,
                  // ),
                  // CupertinoTextField(
                  //   obscureText: _isObscured,
                  //   decoration: const BoxDecoration(
                  //     border: Border(
                  //       bottom: BorderSide(
                  //         color: AppColors.label,
                  //       ),
                  //     ),
                  //   ),
                  //   placeholder: AppLocalizations.of(context)!.password,
                  //   placeholderStyle:
                  //       TextStyle(color: AppColors.labelPlaceholder),
                  //   suffix: GestureDetector(
                  //     onTap: () {
                  //       setState(() {
                  //         _isObscured = !_isObscured;
                  //       });
                  //     },
                  //     child: Icon(
                  //       _isObscured
                  //           ? CupertinoIcons.eye
                  //           : CupertinoIcons.eye_slash,
                  //       color: AppColors.labelPlaceholder,
                  //     ),
                  //   ),
                  //   style: TextStyle(color: AppColors.label),
                  //   controller: passwordController,
                  // ),
                  // SizedBox(
                  //   height: 32,
                  // ),
                  // if (errorMenssage != null) ...[
                  //   Text(
                  //     errorMenssage!,
                  //     style: const TextStyle(color: Colors.red, fontSize: 14),
                  //     textAlign: TextAlign.center,
                  //   ),
                  //   const SizedBox(height: 16),
                  // ],
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final user = await _authService.signInWithGoogle();
                            if (user != null) {
                              print('Usuário logado: ${user.displayName}');
                              widget.updateUser;
                              Navigator.of(context).pop();
                            } else {
                              print('Login cancelado ou falhou.');
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata),
                              Text("Login com Google"),
                            ],
                          ),
                        ),
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     await _authService.signOut();

                        //     print('Usuário deslogado.');
                        //   },
                        //   child: Text("Logout", style: TextStyle(color: AppColors.deletionButton,)),
                        // ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     child: CupertinoButton(
                  //       color: AppColors.button,
                  //       onPressed: () {
                  //         signipAuthentication();
                  //       },
                  //       child: Text(
                  //         AppLocalizations.of(context)!.signin,
                  //         style: const TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             color: AppColors.label),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 32,
                  // ),
                  // GestureDetector(
                  //     onTap: () {
                  //       FocusManager.instance.primaryFocus?.unfocus();
                  //       Navigator.of(context).pop();
                  //       _singUpScreen();
                  //     },
                  //     child: Text(
                  //       AppLocalizations.of(context)!.dontHaveAccount,
                  //       style: TextStyle(
                  //         decoration: TextDecoration.underline,
                  //         color: AppColors.label,
                  //       ),
                  //     )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _singUpScreen() {
  //   FocusScope.of(context).unfocus();
  //   showCupertinoModalPopup(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //           height: MediaQuery.of(context).size.height / 1.05,
  //           decoration: const BoxDecoration(
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(20),
  //               topRight: Radius.circular(20),
  //             ),
  //           ),
  //           child: singUpScreen());
  //     },
  //   );
  // }

  void signipAuthentication() {
    String email = emailController.text;
    String password = passwordController.text;
    if ((email.length > 0) && (password.length > 0)) {
      Authentication()
          .signinUser(emailController.text, passwordController.text)
          .then((String? error) {
        if (error != null) {
          print("voltou com erro");
          setState(() {
            errorMenssage = error;
          });
        } else {
          print("Deu certo");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
      });
    }
  }
}
