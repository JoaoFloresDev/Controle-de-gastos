import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meus_gastos/controllers/orcamentos/budgetModel.dart';
import 'package:meus_gastos/controllers/orcamentos/goalsService.dart';
import 'package:meus_gastos/services/saveOnClound.dart';

class Saveorcamentosnanuvem extends Saveonclound {
  // get all budgets
  Future<List<Budgetmodel>> getAllBudgets() async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection(userId!)
          .doc('budgets')
          .collection('budgetsList')
          .get();

      return snapshot.docs
          .map(
              (doc) => Budgetmodel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("erro: $e");
      return [];
    }
  }

  // save
  Future<void> addBudgetInClound(Budgetmodel budget) async {
    await firestore
        .collection(userId!)
        .doc('budgets')
        .collection('budgetsList')
        .doc(budget.categoryId)
        .set(budget.toJson());
  }

  // delete
  Future<void> deleteBudgetInClound(String budgetId) async {
    try {
      await firestore
          .collection(userId!)
          .doc('budgets')
          .collection('budgetsList')
          .doc(budgetId)
          .delete();
      print("Document with ID ${budgetId} deleted successfully.");
    } catch (e) {
      print("erro: $e");
    }
  }

  // add offLineOrcamentos
}
