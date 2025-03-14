import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/saveExpensOnCloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // 🔹 1. Carrega os dados locais
    List<FixedExpense> localFixedExpenses = await
        Fixedexpensesservice.getSortedFixedExpenses();
    List<CardModel> localNormalExpenses = await CardService.retrieveCards();

    // 🔹 2. Baixa os dados do Firebase
    List<FixedExpense> remoteFixedExpenses = await SaveExpensOnCloud().fetchCardsFixedCards();
    List<CardModel> remoteNormalExpenses = await SaveExpensOnCloud().fetchCards();

    // RESOLVER ESSA PARTE
    // 🔹 3. Processa sincronização

    // List<FixedExpense> updatedFixedExpenses =
    //     _mergeData(localFixedExpenses, remoteFixedExpenses);
    // List<CardModel> updatedNormalExpenses =
    //     _mergeData(localNormalExpenses, remoteNormalExpenses);


    // // 🔹 4. Salva as mudanças localmente
    // await _saveExpensesToLocal(prefs, updatedFixedExpenses, 'fixed_expenses');
    // await _saveExpensesToLocal(prefs, updatedNormalExpenses, 'normal_expenses');

    // // 🔹 5. Envia para o Firebase os dados locais que ainda não estão lá
    // await _syncToFirebase(userId, updatedFixedExpenses, 'fixedCards');
    // await _syncToFirebase(userId, updatedNormalExpenses, 'NormalCards');
  }


  // 🔹 Compara e mergeia os dados
  List<T> _mergeData<T>(List<T> local, List<T> remote) {
    Map<String, T> merged = {
      for (var e in remote) (e as dynamic).id: e
    }; // Firebase tem prioridade
    for (var e in local) {
      if (!merged.containsKey((e as dynamic).id)) {
        merged[(e as dynamic).id] = e;
      }
    }
    return merged.values.toList();
  }

  // 🔹 Salva os dados localmente
  Future<void> _saveExpensesToLocal(
      SharedPreferences prefs, List<dynamic> expenses, String key) async {
    String jsonString = json.encode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(key, jsonString);
  }

  // 🔹 Envia os dados locais para o Firebase
  Future<void> _syncToFirebase(
      String userId, List<dynamic> expenses, String collection) async {
    for (var expense in expenses) {
      await _firestore
          .collection(userId)
          .doc(collection)
          .collection("cardList")
          .doc((expense as dynamic).id)
          .set(expense.toJson());
    }
  }
}

