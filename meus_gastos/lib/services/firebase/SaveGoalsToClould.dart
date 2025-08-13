import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meus_gastos/controllers/Goals/BudgetModel.dart';
import 'package:meus_gastos/controllers/Goals/GoalsService.dart';
import 'package:meus_gastos/services/firebase/saveOnClound.dart';

class SaveGoalsToClould extends Saveonclound {
  Future<List<BudgetModel>> getAllBudgets() async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection(userId!)
          .doc('budgets')
          .collection('budgetsList')
          .get();

      return snapshot.docs
          .map(
              (doc) => BudgetModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // save
  Future<void> addBudgetInClound(BudgetModel budget) async {
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
    } catch (e) {
      print("erro: $e");
    }
  }
}
