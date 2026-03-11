import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Login/LoginRoute.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/FixedExpensesViewModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/RecurrentExpenseScreen.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';

class SettingsScreenCompact extends StatelessWidget {
  const SettingsScreenCompact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Consumer2<LoginViewModel, ProManeger>(
        builder: (context, loginVM, proVM, child) {
          return Column(
            children: [
              // Header com gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: proVM.isPro
                        ? [
                            AppColors.background1,
                            AppColors.background1,
                          ]
                        : [
                            const Color(0xFFFFD700),
                            const Color(0xFFFFA500),
                          ],
                  ),
                ),
                child: _buildHeaderContent(context, loginVM, proVM),
              ),
              const Divider(
                color: AppColors.modalBackground,
                thickness: 0.5,
                height: 10,
              ),
              // Conteúdo rolável
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Opções
                      _buildOptionsCard(context),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(
      BuildContext context, LoginViewModel loginVM, ProManeger proVM) {
    if (proVM.isPro) {
      // Usuário PRO - mostra info do usuário ou login
      return _buildUserInfo(context, loginVM, proVM);
    } else {
      // Usuário não-PRO - mostra oferta PRO
      return _buildProOffer(context);
    }
  }

  Widget _buildProOffer(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.unlockPro,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.proDescription,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showProModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium, size: 20),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.subscribeNow,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildUserInfo(
      BuildContext context, LoginViewModel loginVM, ProManeger proVM) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loginVM.isLogin) ...[
              // Avatar e Info
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        loginVM.user!.displayName![0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loginVM.user!.displayName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loginVM.user!.email!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botão Logout
                  IconButton(
                    onPressed: () => _showLogoutDialog(context, loginVM),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.proAccount,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.loginToSync,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Botão Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => LoginRoute().loginScrean(
                    context,
                    loginVM,
                    proVM,
                    () {},
                  ),
                  icon: const Icon(Icons.login, size: 20),
                  label: Text(AppLocalizations.of(context)!.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.button,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    final vm = context.watch<CategoryViewModel>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildOption(
            icon: Icons.repeat,
            title: AppLocalizations.of(context)!.fixedExpenses,
            subtitle: AppLocalizations.of(context)!.fixedExpensesDesc,
            onTap: () => _navigateToFixedExpenses(context),
          ),
          _buildDivider(),
          _buildOption(
            icon: Icons.category,
            title: AppLocalizations.of(context)!.categories,
            subtitle: AppLocalizations.of(context)!.categoriesDesc,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext modalContext) {
                  return ChangeNotifierProvider.value(
                    value: vm,
                    child: Container(
                      height: MediaQuery.of(context).size.height - 70,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: CategoryCreater(
                        onCategoryAdded: () {},
                      ),
                    ),
                  );
                },
              );
            },
          ),
          _buildDivider(),
          _buildOption(
            icon: Icons.notifications,
            title: AppLocalizations.of(context)!.notifications,
            subtitle: AppLocalizations.of(context)!.notificationsDesc,
            onTap: () {},
          ),
          _buildDivider(),
          if (context.read<LoginViewModel>().isLogin)
            _buildOption(
              icon: Icons.backup,
              title: AppLocalizations.of(context)!.backupSync,
              subtitle: AppLocalizations.of(context)!.backupSyncDesc,
              onTap: () {
                LoginRoute().syncInFirstAcess(
                    context,
                    context.read<LoginViewModel>().user!.uid,
                    context.read<SyncViewModel>(),
                    true);
              },
            ),
          _buildDivider(),
          _buildOption(
            icon: Icons.help_outline,
            title: AppLocalizations.of(context)!.helpSupport,
            subtitle: AppLocalizations.of(context)!.helpSupportDesc,
            onTap: () {},
          ),
          _buildDivider(),
          _buildOption(
            icon: Icons.info_outline,
            title: AppLocalizations.of(context)!.about,
            subtitle: AppLocalizations.of(context)!.version,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.button.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.button,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.label,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.label.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.label.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 80,
      color: AppColors.label.withOpacity(0.1),
    );
  }

  void _showLogoutDialog(BuildContext context, LoginViewModel loginVM) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sair'),
            onPressed: () {
              loginVM.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showProModal(BuildContext context) {
    ProManeger proViewModel = context.read<ProManeger>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return ProModal(
            isLoading: false,
            onSubscriptionPurchased: () {
              proViewModel.checkUserProStatus();
            },
          );
        } else {
          return SizedBox(
              child: ProModalAndroid(
            isLoading: false,
            onSubscriptionPurchased: () {
              proViewModel.checkUserProStatus();
            },
          ));
        }
      },
    );
  }

  void _navigateToFixedExpenses(BuildContext context) {
    FocusScope.of(context).unfocus();
    FixedExpensesViewModel fixedExpensesViewModel =
        context.read<FixedExpensesViewModel>();
    CategoryViewModel categoryViewModel = context.read<CategoryViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height - 70,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: RecurrentExpenseScreen(
              onAddPressedBack: () {
                print(categoryViewModel.avaliebleCetegories.length);
              },
              fixedExpensesViewModel: fixedExpensesViewModel,
              categories: categoryViewModel.avaliebleCetegories,
            ),
          ),
        );
      },
    );
  }
}
