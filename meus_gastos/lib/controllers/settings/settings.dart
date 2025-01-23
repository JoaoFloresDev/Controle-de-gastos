import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/cadastro_login/login.dart';
import 'package:meus_gastos/controllers/settings/testeDb.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/main.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/services/authentication.dart';

class Settings extends StatefulWidget {
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  User? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = FirebaseAuth.instance.currentUser;
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
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          AppLocalizations.of(context)!.other,
          style: const TextStyle(color: AppColors.label, fontSize: 16),
        ),
        backgroundColor: AppColors.background1,
      ),
      body: Container(
        alignment: Alignment.topLeft,
        width: double.infinity,
        child: Column(
          children: [
            if (user != null)
              Container(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(width: 0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child:
                          Icon(Icons.person, size: 50, color: AppColors.label),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName,
                            style: TextStyle(
                                color: AppColors.label, fontSize: 20)),
                        Text(user!.email!,
                            style:
                                TextStyle(color: AppColors.label, fontSize: 14))
                      ],
                    ))
                  ],
                ),
              ),
            GestureDetector(
              onTap: () {
                _testDb(context);
              },
              child: Row(
                children: [
                  Icon(Icons.repeat, color: AppColors.label),
                  SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Text(
                    "Teste",
                    style:
                        const TextStyle(color: AppColors.label, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(Icons.star_sharp, color: AppColors.label),
                  SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Text(
                    "${AppLocalizations.of(context)!.removeAds}",
                    style:
                        const TextStyle(color: AppColors.label, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(Icons.reviews_outlined, color: AppColors.label),
                  SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Text(
                    "${AppLocalizations.of(context)!.reviewAppTitle}",
                    style:
                        const TextStyle(color: AppColors.label, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(Icons.add, color: AppColors.label),
                  SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Text(
                    "${AppLocalizations.of(context)!.addCategory}",
                    style:
                        const TextStyle(color: AppColors.label, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: AppColors.label),
                  SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Text(
                    "${AppLocalizations.of(context)!.contactus}",
                    style:
                        const TextStyle(color: AppColors.label, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () async {
                if (user != null) {
                  await Authentication().signout().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => singInScreen()),
                  );
                }
              },
              child: Row(
                children: [
                  Icon(user != null ? Icons.logout : Icons.login,
                      color: AppColors.label),
                  SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Text(
                    "${user != null ? AppLocalizations.of(context)!.signout : AppLocalizations.of(context)!.signin}",
                    style:
                        const TextStyle(color: AppColors.label, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.9),
    );
  }
}

_testDb(BuildContext context) {
  FocusScope.of(context).unfocus();
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height / 1.3,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Testedb(),
      );
    },
  );
}
