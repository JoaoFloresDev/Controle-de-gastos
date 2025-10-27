import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/controllers/Login/Authentication.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Login/cadastro_login/LoginScrean.dart';
import 'package:meus_gastos/controllers/Login/cadastro_login/LogoutScrean.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/ProManeger.dart';

class LoginRoute {

  void loginScrean(
    BuildContext context,
    LoginViewModel viewModel,
    ProManeger proViewModel,
    VoidCallback onLoginChange,
  ) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height / 1.8,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: LoginScreen(
              viewModel: viewModel,
              loadcards: () {
                onLoginChange();
              },
              isPro: proViewModel.isPro,
              showProModal: (context) {
                _showProModal(context);
              },
            ));
      },
    );
  }

  void _showProModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return ProModal(
            isLoading: false,
            onSubscriptionPurchased: () {},
          );
        } else {
          return ProModalAndroid(
            isLoading: false,
            onSubscriptionPurchased: () {},
          );
        }
      },
    );
  }

  void logoutScreen(
    BuildContext context,
    LoginViewModel viewModel,
    ProManeger proViewModel,
    VoidCallback onLoginChange,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height / 2.0,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: LogoutScrean(
              
              loadcards: () {
                onLoginChange();
              },
              loginModelView: viewModel,
              isPro: proViewModel.isPro,
              showProModal: (context) {
                _showProModal(context);
              },
            ));
      },
    );
  }

  Future<bool> isFirstLogin(String userId) async {
    //   final prefs = await SharedPreferences.getInstance();
    //   return prefs.getBool('synced_$userId') != true;
    return true;
  }

  Future<void> sincroniza_primeiro_acesso() async {
    //   if (userId == null) {
    //     // Trate o caso em que o user não está disponível
    //     return;
    //   }
    //   bool prim = await isFirstLogin(userId!);
    //   if (prim) {
    //     showDialog(
    //       context: context,
    //       barrierDismissible: false, // Impede fechamento acidental
    //       builder: (_) => AlertDialog(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(16),
    //         ),
    //         backgroundColor: AppColors.background1,
    //         elevation: 8,
    //         contentPadding: EdgeInsets.zero,
    //         content: Container(
    //           constraints: const BoxConstraints(maxWidth: 320),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               // Header com ícone
    //               Container(
    //                 width: double.infinity,
    //                 padding: const EdgeInsets.all(24),
    //                 decoration: BoxDecoration(
    //                   color: AppColors.label.withOpacity(0.05),
    //                   borderRadius: const BorderRadius.only(
    //                     topLeft: Radius.circular(16),
    //                     topRight: Radius.circular(16),
    //                   ),
    //                 ),
    //                 child: Column(
    //                   children: [
    //                     Container(
    //                       width: 60,
    //                       height: 60,
    //                       decoration: BoxDecoration(
    //                         gradient: LinearGradient(
    //                           colors: [
    //                             Colors.blue.withOpacity(0.1),
    //                             Colors.blue.withOpacity(0.2),
    //                           ],
    //                           begin: Alignment.topLeft,
    //                           end: Alignment.bottomRight,
    //                         ),
    //                         borderRadius: BorderRadius.circular(30),
    //                       ),
    //                       child: const Icon(
    //                         Icons.sync,
    //                         size: 30,
    //                         color: Colors.blue,
    //                       ),
    //                     ),
    //                     const SizedBox(height: 16),
    //                     Text(
    //                       AppLocalizations.of(context)!.syncData,
    //                       style: const TextStyle(
    //                         color: AppColors.label,
    //                         fontSize: 20,
    //                         fontWeight: FontWeight.w600,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),

    //               // Conteúdo
    //               Padding(
    //                 padding: const EdgeInsets.all(24),
    //                 child: Column(
    //                   children: [
    //                     Text(
    //                       AppLocalizations.of(context)!.syncQuestion,
    //                       textAlign: TextAlign.center,
    //                       style: TextStyle(
    //                         color: AppColors.label.withOpacity(0.8),
    //                         fontSize: 16,
    //                         height: 1.4,
    //                       ),
    //                     ),

    //                     const SizedBox(height: 24),

    //                     // Benefícios da sincronização
    //                     Container(
    //                       padding: const EdgeInsets.all(16),
    //                       decoration: BoxDecoration(
    //                         color: Colors.blue.withOpacity(0.05),
    //                         borderRadius: BorderRadius.circular(12),
    //                         border: Border.all(
    //                           color: Colors.blue.withOpacity(0.1),
    //                           width: 1,
    //                         ),
    //                       ),
    //                       child: Column(
    //                         children: [
    //                           Row(
    //                             children: [
    //                               Icon(
    //                                 Icons.cloud_upload,
    //                                 size: 20,
    //                                 color: Colors.blue.withOpacity(0.7),
    //                               ),
    //                               const SizedBox(width: 12),
    //                               Expanded(
    //                                 child: Text(
    //                                   AppLocalizations.of(context)!
    //                                       .secureCloudBackup,
    //                                   style: TextStyle(
    //                                     color: AppColors.label.withOpacity(0.7),
    //                                     fontSize: 14,
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                           const SizedBox(height: 8),
    //                           Row(
    //                             children: [
    //                               Icon(
    //                                 Icons.devices,
    //                                 size: 20,
    //                                 color: Colors.blue.withOpacity(0.7),
    //                               ),
    //                               const SizedBox(width: 12),
    //                               Expanded(
    //                                 child: Text(
    //                                   AppLocalizations.of(context)!
    //                                       .accessAcrossDevices,
    //                                   style: TextStyle(
    //                                     color: AppColors.label.withOpacity(0.7),
    //                                     fontSize: 14,
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                     ),

    //                     const SizedBox(height: 24),

    //                     // Botões de ação
    //                     Row(
    //                       children: [
    //                         // Botão "Agora não"
    //                         Expanded(
    //                           child: TextButton(
    //                             onPressed: () async {
    //                               final prefs =
    //                                   await SharedPreferences.getInstance();
    //                               await prefs.setBool('synced_${userId}', true);
    //                               Navigator.pop(context);
    //                             },
    //                             style: TextButton.styleFrom(
    //                               padding:
    //                                   const EdgeInsets.symmetric(vertical: 12),
    //                               shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(8),
    //                               ),
    //                             ),
    //                             child: Text(
    //                               AppLocalizations.of(context)!.notNow,
    //                               style: TextStyle(
    //                                 color: AppColors.label.withOpacity(0.6),
    //                                 fontSize: 16,
    //                                 fontWeight: FontWeight.w500,
    //                               ),
    //                             ),
    //                           ),
    //                         ),

    //                         const SizedBox(width: 12),

    //                         // Botão "Sincronizar"
    //                         Expanded(
    //                           child: StatefulBuilder(
    //                             builder: (context, setState) {
    //                               bool isLoading = false;

    //                               return ElevatedButton(
    //                                 onPressed: isLoading
    //                                     ? null
    //                                     : () async {
    //                                         setState(() {
    //                                           isLoading = true;
    //                                         });

    //                                         try {
    //                                           // await SyncService()
    //                                           //     .syncData(userId!);
    //                                           final prefs =
    //                                               await SharedPreferences
    //                                                   .getInstance();
    //                                           await prefs.setBool(
    //                                               'synced_${userId}', true);
    //                                           Navigator.pop(context);

    //                                           // Mostrar feedback de sucesso
    //                                           ScaffoldMessenger.of(context)
    //                                               .showSnackBar(
    //                                             SnackBar(
    //                                               content: Row(
    //                                                 children: [
    //                                                   const Icon(
    //                                                     Icons.check_circle,
    //                                                     color: Colors.white,
    //                                                     size: 20,
    //                                                   ),
    //                                                   const SizedBox(width: 8),
    //                                                   const Text(
    //                                                       'Dados sincronizados com sucesso!'),
    //                                                 ],
    //                                               ),
    //                                               backgroundColor: Colors.green,
    //                                               behavior:
    //                                                   SnackBarBehavior.floating,
    //                                               shape: RoundedRectangleBorder(
    //                                                 borderRadius:
    //                                                     BorderRadius.circular(8),
    //                                               ),
    //                                             ),
    //                                           );
    //                                         } catch (e) {
    //                                           setState(() {
    //                                             isLoading = false;
    //                                           });

    //                                           // Mostrar erro
    //                                           ScaffoldMessenger.of(context)
    //                                               .showSnackBar(
    //                                             SnackBar(
    //                                               content: Row(
    //                                                 children: [
    //                                                   const Icon(
    //                                                     Icons.error,
    //                                                     color: Colors.white,
    //                                                     size: 20,
    //                                                   ),
    //                                                   const SizedBox(width: 8),
    //                                                   const Text(
    //                                                       'Erro ao sincronizar. Tente novamente.'),
    //                                                 ],
    //                                               ),
    //                                               backgroundColor: Colors.red,
    //                                               behavior:
    //                                                   SnackBarBehavior.floating,
    //                                               shape: RoundedRectangleBorder(
    //                                                 borderRadius:
    //                                                     BorderRadius.circular(8),
    //                                               ),
    //                                             ),
    //                                           );
    //                                         }
    //                                       },
    //                                 style: ElevatedButton.styleFrom(
    //                                   backgroundColor: Colors.blue,
    //                                   foregroundColor: Colors.white,
    //                                   padding: const EdgeInsets.symmetric(
    //                                       vertical: 12),
    //                                   elevation: 0,
    //                                   shape: RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(8),
    //                                   ),
    //                                 ),
    //                                 child: isLoading
    //                                     ? const SizedBox(
    //                                         width: 20,
    //                                         height: 20,
    //                                         child: CircularProgressIndicator(
    //                                           strokeWidth: 2,
    //                                           valueColor:
    //                                               AlwaysStoppedAnimation<Color>(
    //                                             Colors.white,
    //                                           ),
    //                                         ),
    //                                       )
    //                                     : Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.center,
    //                                         children: [
    //                                           const Icon(
    //                                             Icons.sync,
    //                                             size: 18,
    //                                           ),
    //                                           const SizedBox(width: 8),
    //                                           Text(
    //                                             AppLocalizations.of(context)!
    //                                                 .sync,
    //                                             style: const TextStyle(
    //                                               fontSize: 16,
    //                                               fontWeight: FontWeight.w500,
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                               );
    //                             },
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    // }
  }
}
