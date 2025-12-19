import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/FixedExpensesViewModel.dart';
import 'package:meus_gastos/services/firebase/FireBaseServiceSingleton.dart';

class FixedExpensesRepositoryRemote {
  final String userId;

  FixedExpensesRepositoryRemote({required this.userId});

  Future<List<FixedExpense>> fetch() async {
    try {
      QuerySnapshot snapshot = await FirebaseService()
          .firestore
          .collection(userId)
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

  Future<void> add(FixedExpense card) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('fixedCards')
          .collection("cardList")
          .doc(card.id)
          .set(card.toJson());
      print("Gasto salvo com sucesso!");
    } catch (e) {
      print("Erro ${e}");
    }
  }

  Future<void> update(FixedExpense card) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('fixedCards')
          .collection("cardList")
          .doc(card.id)
          .update(card.toJson());
      print("Gasto atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar: $e");
    }
  }

  Future<void> delete(String cardId) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('fixedCards')
          .collection("cardList")
          .doc(cardId)
          .delete();

      print("Document with ID ${cardId} deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }
}

// Future<void> addDatesOfOfflineStateFixedCards() async {
//     List<FixedExpense> cards =
//         await FixedExpensesService.getSortedFixedExpenses();
//     for (var card in cards) {
//       await FirebaseService().firestore.collection(FirebaseService().userId!).doc(card.id).set(card.toJson());
//       // await firestore.collection(userId).doc(card.id)
//     }
//   }
