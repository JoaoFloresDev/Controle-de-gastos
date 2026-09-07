import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

// MARK: - Pending Expense
/// Um gasto enfileirado pelo widget nativo (App Group) aguardando ser
/// persistido pelo app no próximo open/resume.
class PendingWidgetExpense {
  final String categoryId;
  final double amount;
  final DateTime date;

  PendingWidgetExpense({
    required this.categoryId,
    required this.amount,
    required this.date,
  });

  factory PendingWidgetExpense.fromJson(Map<String, dynamic> json) {
    return PendingWidgetExpense(
      categoryId: json['categoryId']?.toString() ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['date'] as num).toInt())
          : DateTime.now(),
    );
  }
}

/// Ponte entre o app Flutter e o widget nativo de adição rápida (iOS 17+).
///
/// O widget é puramente nativo: botões de valor somam um total pendente
/// (`pendingAmount`) e tocar numa categoria enfileira `{categoryId, amount,
/// date}` em `widget_pending_expenses` (App Group UserDefaults). Esta classe
/// (1) espelha as categorias e o símbolo da moeda para o App Group para o
/// widget renderizar, e (2) drena a fila pendente para o app persistir os
/// gastos pelo repositório real (com sync Firebase).
class WidgetBridge {
  // MARK: - Constants
  static const String appGroupId = 'group.com.gambit.meusgastos';
  static const String iOSWidgetName = 'MeusGastosQuickAdd';

  static const String _keyCategories = 'widget_categories';
  static const String _keyCurrency = 'widget_currency';
  static const String _keyPending = 'widget_pending_expenses';
  static const String _keyPendingAmount = 'widget_pending_amount';
  static const String _keyUndoDeadline = 'widget_undo_deadline';
  static const String _keyUndoAmount = 'widget_undo_amount';

  static bool _initialized = false;

  /// home_widget only ships an iOS/Android implementation. On macOS every call
  /// throws MissingPluginException — and since [init] is awaited before
  /// runApp, that exception used to abort main() and leave the Mac build on a
  /// black window forever.
  static bool get isSupported => Platform.isIOS || Platform.isAndroid;

  // MARK: - Setup
  static Future<void> init() async {
    if (_initialized || !isSupported) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      _initialized = true;
    } catch (_) {
      // No widget host on this platform: the app works, it just has no widget.
    }
  }

  // MARK: - Sync categories + currency to the widget
  static Future<void> syncCategories({
    required List<CategoryModel> categories,
    required Map<String, String> localizedNames,
    required String currencySymbol,
  }) async {
    if (!isSupported) return;
    await init();

    final List<Map<String, dynamic>> payload = categories
        .where((c) => c.id != 'AddCategory' && c.available)
        .take(12)
        .map((c) => {
              'id': c.id,
              'name': localizedNames[c.id] ?? c.name,
              'color': c.color.value,
              'icon': c.icon.codePoint,
            })
        .toList();

    await HomeWidget.saveWidgetData<String>(
        _keyCategories, jsonEncode(payload));
    await HomeWidget.saveWidgetData<String>(_keyCurrency, currencySymbol);
    await _reload();
  }

  // MARK: - Drain pending expenses queued by the widget
  static Future<List<PendingWidgetExpense>> drainPendingExpenses() async {
    if (!isSupported) return [];
    await init();

    final String? raw =
        await HomeWidget.getWidgetData<String>(_keyPending, defaultValue: null);
    if (raw == null || raw.isEmpty) return [];

    List<PendingWidgetExpense> result = [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      result = list
          .whereType<Map<String, dynamic>>()
          .map(PendingWidgetExpense.fromJson)
          .where((e) => e.amount > 0)
          .toList();
    } catch (_) {
      // JSON corrompido: limpa e segue.
    }

    // Limpa a fila, o total pendente e o estado de undo do widget — os gastos
    // já foram persistidos pelo app, então não há mais o que desfazer.
    await HomeWidget.saveWidgetData<String>(_keyPending, null);
    await HomeWidget.saveWidgetData<double>(_keyPendingAmount, 0.0);
    await HomeWidget.saveWidgetData<String>(_keyUndoDeadline, null);
    await HomeWidget.saveWidgetData<String>(_keyUndoAmount, null);
    await _reload();

    return result;
  }

  // MARK: - Private
  static Future<void> _reload() async {
    try {
      await HomeWidget.updateWidget(iOSName: iOSWidgetName);
    } catch (_) {
      // Widget pode não estar instalado — ignora.
    }
  }
}
