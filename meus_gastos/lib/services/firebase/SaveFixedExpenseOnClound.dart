import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesService.dart';
import 'package:meus_gastos/services/firebase/FirebaseService.dart';

class SaveFixedExpenseOnClound {
  Future<void> addDatesOfOfflineStateFixedCards() async {
    List<FixedExpense> cards =
        await FixedExpensesService.getSortedFixedExpenses();
    for (var card in cards) {
      await FirebaseService().firestore.collection(FirebaseService().userId!).doc(card.id).set(card.toJson());
      // await firestore.collection(userId).doc(card.id)
    }
  }

  Future<void> addNewDateFixedCards(FixedExpense card) async {
    if (FirebaseService().userId == null) {
      print("Erro: userId é null!");
      return;
    }
    try {
      await FirebaseService().firestore
          .collection(FirebaseService().userId!)
          .doc('fixedCards')
          .collection("cardList")
          .doc(card.id)
          .set(card.toJson());
      print("Gasto salvo com sucesso!");
    } catch (e) {
      print("Erro ${e}");
    }
  }

  Future<void> deleteDateFixedCards(FixedExpense card) async {
    try {
      await FirebaseService().firestore
          .collection(FirebaseService().userId!)
          .doc('fixedCards')
          .collection("cardList")
          .doc(card.id)
          .delete();

      print("Document with ID ${card.id} deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  Future<List<FixedExpense>> fetchCardsFixedCards() async {
    try {
      QuerySnapshot snapshot = await FirebaseService().firestore
          .collection(FirebaseService().userId!)
          .doc('fixedCards')
          .collection('cardList')
          .get();

      return snapshot.docs
          .map((doc) =>
              FixedExpense.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar cartões: $e');
      return [];
    }
  }
}