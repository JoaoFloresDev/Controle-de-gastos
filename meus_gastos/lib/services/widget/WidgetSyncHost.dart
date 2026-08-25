import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardServiceRefatore.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/services/widget/WidgetBridge.dart';

/// Wrapper que mantém o widget nativo de adição rápida em sincronia com o app.
///
/// - Espelha as categorias disponíveis + símbolo da moeda para o App Group
///   sempre que mudam, para o widget renderizar os botões.
/// - Ao iniciar e a cada retomada do app, drena os gastos enfileirados pelo
///   widget e os persiste pelo [TransactionsViewModel] (repositório real +
///   sync). Deduplicação não é necessária: a fila é limpa atomicamente no
///   drain.
class WidgetSyncHost extends StatefulWidget {
  const WidgetSyncHost({required this.child, super.key});

  final Widget child;

  @override
  State<WidgetSyncHost> createState() => _WidgetSyncHostState();
}

class _WidgetSyncHostState extends State<WidgetSyncHost>
    with WidgetsBindingObserver {
  // MARK: - Properties
  String _lastCategorySignature = '';
  bool _draining = false;

  // MARK: - Lifecycle
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drainPending();
      _syncCategories();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _drainPending();
      _syncCategories();
    }
  }

  // MARK: - Sync categories to widget
  Future<void> _syncCategories() async {
    if (!mounted) return;
    final categoryVM = context.read<CategoryViewModel>();
    final List<CategoryModel> categories = categoryVM.avaliebleCetegories
        .where((c) => c.id != 'AddCategory')
        .toList();
    if (categories.isEmpty) return;

    final signature = categories
        .map((c) => '${c.id}:${c.color.value}:${c.icon.codePoint}')
        .join('|');
    if (signature == _lastCategorySignature) return;
    _lastCategorySignature = signature;

    final Map<String, String> localizedNames = {
      for (final c in categories)
        c.id: TranslateService.getTranslatedCategoryUsingModel(context, c)
    };
    final currency = TranslateService.getCurrencySymbol(context);

    await WidgetBridge.syncCategories(
      categories: categories,
      localizedNames: localizedNames,
      currencySymbol: currency,
    );
  }

  // MARK: - Drain pending expenses
  Future<void> _drainPending() async {
    if (_draining || !mounted) return;
    _draining = true;
    try {
      final pending = await WidgetBridge.drainPendingExpenses();
      if (pending.isEmpty || !mounted) return;

      final categoryVM = context.read<CategoryViewModel>();
      final transactionsVM = context.read<TransactionsViewModel>();

      for (final p in pending) {
        final category = categoryVM.categories.firstWhere(
          (c) => c.id == p.categoryId,
          orElse: () => CategoryModel(
            id: 'Unknown',
            name: 'Unknown',
            color: Colors.grey,
            icon: Icons.question_mark_rounded,
          ),
        );

        await transactionsVM.addCard(
          CardModel(
            id: CardService().generateUniqueId(),
            amount: p.amount,
            description: '',
            date: p.date,
            category: category,
          ),
        );
      }
    } finally {
      _draining = false;
    }
  }

  // MARK: - Build
  @override
  Widget build(BuildContext context) {
    // Re-sincroniza quando a lista de categorias muda (login/sync/edição).
    context.watch<CategoryViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCategories());
    return widget.child;
  }
}
