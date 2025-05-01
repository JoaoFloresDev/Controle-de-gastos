import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/cadastro_login/logout.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/main.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/authentication.dart';

class singInScreen extends StatefulWidget {
  final VoidCallback updateUser;
  final VoidCallback loadcards;
  final bool isPro;
  final void Function(BuildContext context) showProModal;
  singInScreen(
      {required this.updateUser,
      required this.isPro,
      required this.showProModal,
      required this.loadcards});
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
    if (!widget.isPro) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
        if (mounted) {
          widget.showProModal(context);
        }
      });
    }
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
            // Área com blur (envolta em Stack)
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final user =
                                      await _authService.signInWithGoogle();
                                  if (user != null) {
                                    print(
                                        'Usuário logado: ${user.displayName}');
                                  } else {
                                    print('Login cancelado ou falhou.');
                                  }
                                  setState(() {
                                    print("A");
                                    if (user != null) {
                                      print("B");
                                      widget.updateUser();
                                      widget.loadcards();
                                    }
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.g_mobiledata),
                                    const Text("Login com Google"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isPro) // Blur apenas nesta seção
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
