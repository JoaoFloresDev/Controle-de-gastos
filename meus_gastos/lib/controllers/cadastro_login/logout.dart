import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/cadastro_login/login.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/authentication.dart';
import 'package:meus_gastos/services/syncService.dart';

class Logout extends StatefulWidget {
  final VoidCallback updateUser;
  final VoidCallback loadcards;
  final bool isPro;
  final void Function(BuildContext context) showProModal;
  const Logout({required this.updateUser, required this.loadcards, required this.isPro, required this.showProModal});
  @override
  _Logout createState() => _Logout();
}

class _Logout extends State<Logout> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassowrdController = TextEditingController();
  bool _isObscured = true;
  String? errorMenssage;
  Authentication? _authService;
  User? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _authService = Authentication();
  }

  @override
  Widget build(BuildContext context) {
    String userName = "";
    if (user != null) {
      userName = user!.displayName!;
      print('Nome do usuário: $userName');
    } else {
      print('Usuário não está autenticado.');
    }
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
              title: AppLocalizations.of(context)!.signout,
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
                  Container(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            border: Border.all(width: 0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(Icons.person,
                              size: 50, color: AppColors.label),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName,
                                style: TextStyle(
                                    color: AppColors.label, fontSize: 20)),
                            Text(user!.email!,
                                style: TextStyle(
                                    color: AppColors.label, fontSize: 14))
                          ],
                        ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      SyncService().syncData(user!.uid);
                      widget.loadcards;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text("Sincronização concluída!"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Sincronizar"),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService?.signOut();
                      setState(() {
                        // user?.reload();
                      });
                      print('Usuário deslogado.');
                      widget.updateUser();
                    },
                    child: Text("Logout",
                        style: TextStyle(
                          color: AppColors.deletionButton,
                        )),
                  ),
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
          child: singInScreen(
            updateUser: () {
              setState(() {
                user = FirebaseAuth.instance.currentUser;
              });
            },
            loadcards: widget.loadcards,
            isPro: widget.isPro, 
              showProModal: (context) {
                widget.showProModal(context);
              },
          ), // Aqui chamamos a função que retorna o widget
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
}
