import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

import 'package:meus_gastos/controllers/Login/authentication.dart';

class LogoutScrean extends StatefulWidget {
  final VoidCallback updateUser;
  final VoidCallback loadcards;
  final bool isPro;
  final void Function(BuildContext context) showProModal;
  const LogoutScrean(
      {required this.updateUser,
      required this.loadcards,
      required this.isPro,
      required this.showProModal});
  @override
  _LogoutScreanState createState() => _LogoutScreanState();
}

class _LogoutScreanState extends State<LogoutScrean> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassowrdController = TextEditingController();
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
            // Header mais compacto
            CustomHeader(
              title: AppLocalizations.of(context)!.signout,
              onCancelPressed: () {
                Navigator.of(context).pop();
              },
              onDeletePressed: () {},
              showDeleteButton: false,
            ),

            // Conteúdo principal com melhor distribuição de espaço
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Card do usuário mais elegante
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar melhorado
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.label.withOpacity(0.1),
                                  AppColors.label.withOpacity(0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.label,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Informações do usuário
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: AppColors.label,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user!.email!,
                                  style: TextStyle(
                                    color: AppColors.label.withOpacity(0.7),
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botão de logout melhorado
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _authService?.signOut();
                          setState(() {
                            // user?.reload();
                          });
                          print('Usuário deslogado.');
                          widget.updateUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.deletionButton.withOpacity(0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.deletionButton.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: AppColors.deletionButton,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.signout,
                              style: const TextStyle(
                                color: AppColors.deletionButton,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _singInScreen() {
  //   FocusScope.of(context).unfocus();
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height / 3.0,
  //         decoration: const BoxDecoration(
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(20),
  //             topRight: Radius.circular(20),
  //           ),
  //         ),
  //         child: LoginScreen(
  //           updateUser: () {
  //             setState(() {
  //               user = FirebaseAuth.instance.currentUser;
  //             });
  //           },
  //           loadcards: widget.loadcards,
  //           isPro: widget.isPro,
  //           showProModal: (context) {
  //             widget.showProModal(context);
  //           },
  //         ), // Aqui chamamos a função que retorna o widget
  //       );
  //     },
  //   );
  // }

  
}
