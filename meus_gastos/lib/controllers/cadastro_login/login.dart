import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/cadastro_login/cadastro.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class singInScreen extends StatefulWidget {
  @override
  _singInScreen createState() => _singInScreen();
}

class _singInScreen extends State<singInScreen> {
  final nameController = TextEditingController();
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
                    placeholder: AppLocalizations.of(context)!.password,
                    placeholderStyle:
                        TextStyle(color: AppColors.labelPlaceholder),
                    style: const TextStyle(color: AppColors.label),
                    controller: nameController,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: AppColors.button,
                        onPressed: () async {},
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
                        _singUpScreen();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.dontHaveAccount,
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

  void _singUpScreen() {
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
            child: singUpScreen());
      },
    );
  }
}
