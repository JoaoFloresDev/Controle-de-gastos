import 'dart:io';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Login/cadastro_login/LoginScrean.dart';
import 'package:meus_gastos/controllers/Login/cadastro_login/LogoutScrean.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRoute {
  void loginScrean(
    BuildContext context,
    LoginViewModel viewModel,
    ProManeger proViewModel,
    VoidCallback onLoginChange,
  ) {
    // Sincronizar exige assinatura: quem nao tem vai direto pro paywall, em vez
    // de abrir a tela de login bloqueada.
    if (!proViewModel.isPro) {
      FocusScope.of(context).unfocus();
      _showProModal(context, proViewModel);
      return;
    }

    final syncVM = context.read<SyncViewModel>();
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
                  _showProModal(context, proViewModel);
                },
                showSyncModel: () async {
                  // Auto-sync silencioso no primeiro login. Antes mostrava um
                  // dialog com "Agora não" — quem clicasse via lista vazia,
                  // porque o repoSelector passa a ler do remote (vazio) após
                  // o login e os dados locais ficavam invisíveis.
                  await firstLoginAutoSync(
                      context, viewModel.user!.uid, syncVM);
                }));
      },
    );
  }

  void _showProModal(BuildContext context, ProManeger proViewModel) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return ProModal(
            isLoading: false,
            onSubscriptionPurchased: () {
              proViewModel.checkUserProStatus();
            },
          );
        } else {
          return ProModalAndroid(
            isLoading: false,
            onSubscriptionPurchased: () {
              proViewModel.checkUserProStatus();
            },
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
                _showProModal(context, proViewModel);
              },
            ));
      },
    );
  }

  Future<bool> isFirstLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('synced_$userId') != true;
  }

  /// Sincroniza automaticamente no primeiro login do usuário, sem dialog.
  /// Após o login, o repoSelector troca de local pra remote — se não
  /// sincronizar, os dados locais ficam invisíveis até o usuário ir nas
  /// Settings e clicar em "Backup & Sync".
  Future<void> firstLoginAutoSync(
      BuildContext context, String userId, SyncViewModel syncVM) async {
    final bool prim = await isFirstLogin(userId);
    if (!prim) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('synced_$userId', true);
    try {
      await syncVM.sync(userId);
      if (context.mounted) _showSyncToast(context, true);
    } catch (_) {
      if (context.mounted) _showSyncToast(context, false);
    }
  }

  Future<void> syncInFirstAcess(
      BuildContext context, String userId, SyncViewModel syncVM, bool prim) async {
    final navigator = Navigator.of(context);

    if (prim) {
      showDialog(
        context: context,
        barrierDismissible: false, // Impede fechamento acidental
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.background1,
          elevation: 8,
          contentPadding: EdgeInsets.zero,
          content: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com ícone
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.label.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.1),
                              Colors.blue.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.sync,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.syncData,
                        style: const TextStyle(
                          color: AppColors.label,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Conteúdo
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.syncQuestion,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.label.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Benefícios da sincronização
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 20,
                                  color: Colors.blue.withOpacity(0.7),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .secureCloudBackup,
                                    style: TextStyle(
                                      color: AppColors.label.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.devices,
                                  size: 20,
                                  color: Colors.blue.withOpacity(0.7),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .accessAcrossDevices,
                                    style: TextStyle(
                                      color: AppColors.label.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botões de ação
                      Row(
                        children: [
                          // Botão "Agora não"
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('synced_${userId}', true);
                                // if (!mounted) return;
                                navigator.pop();
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.notNow,
                                style: TextStyle(
                                  color: AppColors.label.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Botão "Sincronizar"
                          Expanded(
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                bool isLoading = false;

                                return ElevatedButton(
                                  onPressed: isLoading
                                      // ignore: dead_code
                                      ? () {}
                                      : () async {
                                          setState(() {
                                            isLoading = true;
                                          });

                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.setBool(
                                              'synced_${userId}', true);

                                          try {
                                            await syncVM
                                                .sync(userId);
                                            navigator.pop();
                                            _showSyncToast(context, true);
                                          } catch (e) {
                                            navigator.pop();
                                            _showSyncToast(context, false);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: syncVM.isSyncing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.sync,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .sync,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _showSyncToast(BuildContext context, bool success) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _SyncToastWidget(
        success: success,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _SyncToastWidget extends StatefulWidget {
  final bool success;
  final VoidCallback onDismiss;

  const _SyncToastWidget({required this.success, required this.onDismiss});

  @override
  State<_SyncToastWidget> createState() => _SyncToastWidgetState();
}

class _SyncToastWidgetState extends State<_SyncToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _slide = Tween(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) _controller.reverse().then((_) => widget.onDismiss());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.success ? Colors.green : Colors.red;
    final icon = widget.success ? Icons.check_circle : Icons.error;
    final text = widget.success
        ? AppLocalizations.of(context)!.sync
        : AppLocalizations.of(context)!.errorTitle;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a23),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
