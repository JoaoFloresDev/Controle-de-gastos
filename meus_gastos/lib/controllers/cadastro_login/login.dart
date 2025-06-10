import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/cadastro_login/logout.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/main.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

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
    // Auto-redirect para modal Pro se não for usuário Pro

    if (!widget.isPro) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
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
            // Header
            CustomHeader(
              title: AppLocalizations.of(context)!.signin,
              onCancelPressed: () {
                Navigator.of(context).pop();
              },
              onDeletePressed: () {},
              showDeleteButton: false,
            ),

            // Conteúdo principal
            Expanded(
              child: Stack(
                children: [
                  // Conteúdo da tela
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        // Espaçamento superior
                        const Spacer(flex: 2),

                        // Ícone de login
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.label.withOpacity(0.1),
                                AppColors.label.withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.person_add,
                            size: 40,
                            color: AppColors.label,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Título e descrição
                        Text(
                          AppLocalizations.of(context)!.signin,
                          style: const TextStyle(
                            color: AppColors.label,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          AppLocalizations.of(context)!
                              .loginWithGoogleToSyncData,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.label.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Botão de login com Google
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: widget.isPro
                                ? () async {
                                    final user =
                                        await _authService.signInWithGoogle();
                                    if (user != null) {
                                      print(
                                          'Usuário logado: ${user.displayName}');
                                      setState(() {
                                        widget.updateUser();
                                        widget.loadcards();
                                      });
                                    } else {
                                      print('Login cancelado ou falhou.');
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 2,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Ícone do Google melhorado
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4285F4),
                                        Color(0xFF34A853),
                                        Color(0xFFFBBC05),
                                        Color(0xFFEA4335),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.g_mobiledata,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.loginWithGoogle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),

                  // Overlay de blur para usuários não-Pro
                  if (!widget.isPro)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ícone de bloqueio
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.lock,
                                  color: Colors.amber,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Texto de upgrade
                              Text(
                                AppLocalizations.of(context)!.proFeature,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                AppLocalizations.of(context)!
                                    .upgradeToProToSync,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Indicador de carregamento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.amber,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .redirectingToUpgrade,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
