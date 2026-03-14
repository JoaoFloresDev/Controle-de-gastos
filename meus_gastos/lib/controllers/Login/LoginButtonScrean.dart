
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';
import 'LoginRoute.dart';

class LoginButtonScrean extends StatelessWidget {
  final VoidCallback onLoginChange;
  final Color? loginTextColor;
  LoginButtonScrean({required this.onLoginChange, this.loginTextColor});

  Widget build(BuildContext context) {
    return Consumer2<LoginViewModel, ProManeger>(
        builder: (context, loginViewModel, proManeger, child) {
      return GestureDetector(
        onTap: () async {
          if (loginViewModel.isLogin) {
            LoginRoute().logoutScreen(
              context,
              loginViewModel,
              proManeger,
              onLoginChange,
            );
          } else if (!proManeger.isPro) {
            _showPremiumAlert(context, proManeger);
          } else {
            LoginRoute()
                .loginScrean(context, loginViewModel, proManeger, onLoginChange);
          }
        },
        child: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: loginViewModel.isLogin
              ? Icon(
                  Icons.cloud,
                  color: AppColors.labelPlaceholder,
                  size: 22,
                )
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.cloud_outlined,
                      color: loginTextColor ?? AppColors.button,
                      size: 22,
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background1,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.priority_high,
                          color: Colors.white,
                          size: 7,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  void _showPremiumAlert(BuildContext context, ProManeger proManeger) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.premiumVersion),
        content: Text(AppLocalizations.of(context)!.loginToSync),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showProModal(context, proManeger);
            },
          ),
        ],
      ),
    );
  }

  void _showProModal(BuildContext context, ProManeger proManeger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return ProModal(
            isLoading: false,
            onSubscriptionPurchased: () {
              proManeger.checkUserProStatus();
            },
          );
        } else {
          return SizedBox(
            child: ProModalAndroid(
              isLoading: false,
              onSubscriptionPurchased: () {
                proManeger.checkUserProStatus();
              },
            ),
          );
        }
      },
    );
  }
}
