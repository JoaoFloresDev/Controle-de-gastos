// RatingGate — pipeline de avaliação do GambitStudio (adaptado de
// _GambitStudio/templates/flutter/rating_gate.dart para um app Cupertino).
//
// O pré-gate pergunta antes do prompt nativo: quem está gostando vai para a
// App Store, quem não está fica no app num formulário de feedback — a intenção
// de 1-2 estrelas nunca chega à loja sem passar por aqui.
//
// Ligação (main.dart):
//   1. `navigatorKey: RatingGate.navigatorKey` no CupertinoApp
//   2. No aha-moment: `RatingGate.instance.recordPositiveEvent(trigger: '...')`
//      (já sai de dentro de AnalyticsService.coreAction)

import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/AnalyticsService.dart';

class RatingGate {
  RatingGate._();
  static final RatingGate instance = RatingGate._();

  /// Ligado ao CupertinoApp para o gate conseguir aparecer mesmo quando quem
  /// dispara está fechando a própria rota.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // -- Config ---------------------------------------------------------------
  /// Lançamentos antes de o gate poder aparecer pela primeira vez.
  static const int _minPositiveEvents = 3;
  static const int _cooldownDays = 60;
  static const int _negativeCooldownDays = 120;
  static const int _maxNativePromptsPerYear = 3;

  static const _kPositiveCount = 'gate.positiveCount';
  static const _kLastShown = 'gate.lastShownMs';
  static const _kLastNegative = 'gate.lastNegativeMs';
  static const _kNativePrompts = 'gate.nativePromptsMs';
  static const _kAnsweredYes = 'gate.answeredYes';

  // -- API ------------------------------------------------------------------

  /// Chamar em todo momento de valor. Mostra o gate quando for a hora.
  Future<void> recordPositiveEvent({String trigger = 'aha_moment'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_kPositiveCount) ?? 0) + 1;
      await prefs.setInt(_kPositiveCount, count);
      if (count < _minPositiveEvents) return;
      await _presentIfEligible(prefs, trigger);
    } catch (_) {
      // Analytics e rating nunca podem derrubar um fluxo do usuário.
    }
  }

  Future<void> _presentIfEligible(SharedPreferences prefs, String trigger) async {
    if (!_isEligible(prefs)) return;
    await prefs.setInt(_kLastShown, DateTime.now().millisecondsSinceEpoch);
    AnalyticsService().ratingGateShown(trigger);
    // Quem dispara costuma estar fechando a própria tela — deixa a navegação
    // assentar antes de abrir o diálogo, senão ele briga com a transição.
    await Future.delayed(const Duration(milliseconds: 600));
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final answered = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => _GateDialog(trigger: trigger),
    );
    if (answered == null) AnalyticsService().ratingGateDismissed(trigger);
  }

  // -- Elegibilidade --------------------------------------------------------

  bool _isEligible(SharedPreferences prefs) {
    if (prefs.getBool(_kAnsweredYes) ?? false) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    const dayMs = 86400000;
    final last = prefs.getInt(_kLastShown);
    if (last != null && now - last < _cooldownDays * dayMs) return false;
    final negative = prefs.getInt(_kLastNegative);
    if (negative != null && now - negative < _negativeCooldownDays * dayMs) return false;
    final prompts = prefs.getStringList(_kNativePrompts) ?? [];
    final yearAgo = now - 365 * dayMs;
    return prompts.where((m) => (int.tryParse(m) ?? 0) > yearAgo).length <
        _maxNativePromptsPerYear;
  }

  // -- Desfechos ------------------------------------------------------------

  Future<void> _answeredYes(String trigger) async {
    AnalyticsService().ratingGateYes(trigger);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAnsweredYes, true);
    final prompts = prefs.getStringList(_kNativePrompts) ?? [];
    prompts.add(DateTime.now().millisecondsSinceEpoch.toString());
    await prefs.setStringList(_kNativePrompts,
        prompts.length > 10 ? prompts.sublist(prompts.length - 10) : prompts);
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  }

  Future<void> _answeredNo(String trigger) async {
    AnalyticsService().ratingGateNo(trigger);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastNegative, DateTime.now().millisecondsSinceEpoch);
  }

  void _submitFeedback(String text, String trigger) {
    AnalyticsService().ratingGateFeedback(trigger, text);
  }
}

// -- Diálogo -----------------------------------------------------------------

class _GateDialog extends StatefulWidget {
  const _GateDialog({required this.trigger});
  final String trigger;

  @override
  State<_GateDialog> createState() => _GateDialogState();
}

class _GateDialogState extends State<_GateDialog> {
  bool _showFeedback = false;
  bool _sent = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_sent) {
      return CupertinoAlertDialog(
        title: Text(l10n.ratingGateFeedbackThanks),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      );
    }
    if (_showFeedback) {
      return CupertinoAlertDialog(
        title: Text(l10n.ratingGateFeedbackTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: l10n.ratingGateFeedbackPlaceholder,
            maxLines: 4,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                RatingGate.instance._submitFeedback(text, widget.trigger);
              }
              setState(() => _sent = true);
            },
            child: Text(l10n.ratingGateFeedbackSend),
          ),
        ],
      );
    }
    return CupertinoAlertDialog(
      title: Text(l10n.ratingGateTitle),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(l10n.ratingGateSubtitle),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            RatingGate.instance._answeredYes(widget.trigger);
            Navigator.of(context).pop(true);
          },
          child: Text(l10n.ratingGateYes),
        ),
        CupertinoDialogAction(
          onPressed: () {
            RatingGate.instance._answeredNo(widget.trigger);
            setState(() => _showFeedback = true);
          },
          child: Text(l10n.ratingGateNo),
        ),
      ],
    );
  }
}
